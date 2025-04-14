import os
import requests
import json
from datetime import datetime, timedelta, timezone
from dateutil.parser import parse as parse_date
import openai

REPO = os.environ["GITHUB_REPO"]
TOKEN = os.environ["GITHUB_TOKEN"]
OPENAI_KEY = os.environ["OPENAI_API_KEY"]

# Optional env var to override lookback
LOOKBACK_HOURS = int(os.getenv("LOOKBACK_HOURS", "0"))

HEADERS = {
    "Authorization": f"Bearer {TOKEN}",
    "Accept": "application/vnd.github+json"
}

openai.api_key = OPENAI_KEY

def fetch_recent_prs():
    def get_prs():
        url = f"https://api.github.com/repos/{REPO}/pulls?state=closed&sort=updated&direction=desc&per_page=100"
        prs = requests.get(url, headers=HEADERS).json()
        if isinstance(prs, dict) and prs.get("message"):
            raise RuntimeError(f"GitHub API error: {prs['message']}")
        return [pr for pr in prs if pr.get("merged_at")]

    def filter_recent(prs, since_dt):
        return [pr for pr in prs if parse_date(pr["merged_at"]) > since_dt]

    if LOOKBACK_HOURS > 0:
        ranges = [LOOKBACK_HOURS / 24]
    else:
        ranges = [1, 3]

    for days in ranges:
        since_dt = datetime.now(timezone.utc) - timedelta(days=days)
        print(f"\n🔍 Fetching merged PRs since {since_dt.isoformat()} (last {days:.1f} days)")
        
        all_merged = get_prs()
        print(f"ℹ️  Found {len(all_merged)} merged PRs total (including older ones):")
        for pr in all_merged:
            print(f" - PR #{pr['number']} merged_at: {pr['merged_at']}")

        recent_merged = filter_recent(all_merged, since_dt)
        if recent_merged:
            print(f"\n✅ {len(recent_merged)} recent PR(s) found.")
            return recent_merged

        print(f"⚠️  No PRs found in the last {days:.1f} day(s). Trying a wider window...")

    print("\n❌ No recent merged PRs found.")
    return []

def fetch_files(pr_number):
    url = f"https://api.github.com/repos/{REPO}/pulls/{pr_number}/files"
    response = requests.get(url, headers=HEADERS)
    response.raise_for_status()
    return response.json()

def analyze_pr_with_gpt(pr, files):
    file_list = [f['filename'] for f in files][:10]
    prompt = f"""
You are an assistant generating release notes.

Analyze this pull request:

Title: {pr['title']}
Description: {pr['body']}
Files changed: {', '.join(file_list)}

Instructions:
- Summarize in one bullet point.
- Classify into one of: New, Enhancement, Fix, Behavior change.
- Decide if it is INTERNAL (for developers only) or EXTERNAL (safe for customers).
- Keep it short, clear, and informative.

Respond in JSON:
{{
  "summary": "...",
  "category": "...",
  "audience": "internal|external"
}}
"""

    res = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3
    )

    raw_content = res.choices[0].message["content"]
    print(f"GPT Response: {raw_content}")

    try:
        return json.loads(raw_content)
    except json.JSONDecodeError:
        print("⚠️ Failed to parse GPT response. Skipping this PR.")
        return {
            "summary": f"Could not analyze PR #{pr['number']}",
            "category": "Enhancement",
            "audience": "internal"
        }

def format_output(results):
    today = datetime.utcnow().strftime("%B %d, %Y")
    out = [f"## 🗓️ {today} Release Notes\n"]

    external = {}
    internal = {}

    for r in results:
        target = external if r["audience"] == "external" else internal
        target.setdefault(r["category"], []).append(r["summary"])

    def format_section(title, cat_map):
        lines = [f"### {title}\n"]
        for cat in ["New", "Enhancement", "Fix", "Behavior change"]:
            if cat in cat_map:
                lines.append(f"#### {cat}")
                for line in cat_map[cat]:
                    lines.append(f"- {line}")
                lines.append("")
        return lines

    out += format_section("External Notes", external)
    out += format_section("Internal Notes", internal)

    return "\n".join(out)

def main():
    prs = fetch_recent_prs()
    if not prs:
        print("No recent merged PRs found.")
        return

    results = []
    for pr in prs:
        print(f"Analyzing PR #{pr['number']}: {pr['title']}")
        files = fetch_files(pr["number"])
        result = analyze_pr_with_gpt(pr, files)
        results.append(result)

    notes = format_output(results)
    with open("RELEASE_NOTES.md", "w") as f:
        f.write(notes)
    print("✅ Release notes written to RELEASE_NOTES.md")

if __name__ == "__main__":
    main()
