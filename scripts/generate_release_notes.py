import os
import requests
import json
from datetime import datetime, timedelta, timezone
from dateutil.parser import parse as parse_date
from openai import OpenAI

REPO = os.environ["GITHUB_REPO"]
TOKEN = os.environ["GITHUB_TOKEN"]
OPENAI_KEY = os.environ["OPENAI_API_KEY"]

HEADERS = {
    "Authorization": f"Bearer {TOKEN}",
    "Accept": "application/vnd.github+json"
}

client = OpenAI(api_key=OPENAI_KEY)

def fetch_recent_prs(hours=24):
    cutoff_time = datetime.now(timezone.utc) - timedelta(hours=hours)
    url = f"https://api.github.com/repos/{REPO}/pulls?state=closed&sort=updated&direction=desc&per_page=100"
    response = requests.get(url, headers=HEADERS)
    prs = response.json()

    if isinstance(prs, dict) and prs.get("message"):
        raise RuntimeError(f"GitHub API error: {prs['message']}")

    merged_prs = []
    for pr in prs:
        merged_at = pr.get("merged_at")
        if merged_at:
            merged_time = parse_date(merged_at)
            if merged_time > cutoff_time:
                merged_prs.append(pr)

    print(f"⏱️ Looking back {hours} hours. Found {len(merged_prs)} recently merged PRs.")
    return merged_prs

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

    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3,
    )

    content = response.choices[0].message.content
    print(f"🔍 GPT Output: {content}")

    try:
        return json.loads(content)
    except json.JSONDecodeError:
        print("⚠️ Failed to parse GPT response. Skipping.")
        return {
            "summary": f"Could not analyze PR #{pr['number']}",
            "category": "Enhancement",
            "audience": "internal"
        }

def format_output(results):
    today = datetime.now(timezone.utc).strftime("%B %d, %Y")
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
    hours = int(os.getenv("LOOKBACK_HOURS", "24"))  # Default 24 hours
    prs = fetch_recent_prs(hours)
    if not prs:
        print("🚫 No PRs found in the given lookback window.")
        return

    results = []
    for pr in prs:
        print(f"🔍 Analyzing PR #{pr['number']}: {pr['title']}")
        files = fetch_files(pr["number"])
        result = analyze_pr_with_gpt(pr, files)
        results.append(result)

    notes = format_output(results)
    with open("RELEASE_NOTES.md", "w") as f:
        f.write(notes)
    print("✅ Release notes written to RELEASE_NOTES.md")

if __name__ == "__main__":
    main()
