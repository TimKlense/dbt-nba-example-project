import os
import requests
import json
from datetime import datetime, timezone, timedelta
import openai

REPO = os.environ["GITHUB_REPO"]
TOKEN = os.environ["GITHUB_TOKEN"]
OPENAI_KEY = os.environ["OPENAI_API_KEY"]

HEADERS = {
    "Authorization": f"Bearer {TOKEN}",
    "Accept": "application/vnd.github+json"
}

openai.api_key = OPENAI_KEY

def fetch_recent_prs():
    since = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
    print(f"Fetching merged PRs since {since}")
    
    query = f"repo:{REPO} is:pr is:merged merged:>={since}"
    url = f"https://api.github.com/search/issues?q={query}&sort=updated&order=desc&per_page=100"

    response = requests.get(url, headers=HEADERS)
    response.raise_for_status()
    data = response.json()
    items = data.get("items", [])

    print(f"Found {len(items)} merged PRs")

    prs = []
    for item in items:
        pr_number = item["number"]
        pr_url = f"https://api.github.com/repos/{REPO}/pulls/{pr_number}"
        pr_response = requests.get(pr_url, headers=HEADERS)
        pr_response.raise_for_status()
        pr_data = pr_response.json()
        prs.append(pr_data)

    return prs

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
        print("Failed to parse GPT response. Skipping this PR.")
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
    print("Release notes written to RELEASE_NOTES.md")

if __name__ == "__main__":
    main()
