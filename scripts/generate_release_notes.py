import os
import requests
from datetime import datetime, timedelta
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
    since = (datetime.utcnow() - timedelta(days=1)).isoformat() + "Z"
    url = f"https://api.github.com/repos/{REPO}/pulls?state=closed&sort=updated&direction=desc&per_page=100"
    prs = requests.get(url, headers=HEADERS).json()
    
    print(f"Fetched {len(prs)} PRs")
    for pr in prs:
        print(f"PR #{pr['number']} merged_at: {pr['merged_at']}")
        
    return [pr for pr in prs if pr["merged_at"] and pr["merged_at"] > since]

def fetch_files(pr_number):
    url = f"https://api.github.com/repos/{REPO}/pulls/{pr_number}/files"
    return requests.get(url, headers=HEADERS).json()

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

    print(f"OpenAI Response: {res}")
    
    return eval(res.choices[0].message["content"])  # use `json.loads` in production

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
    results = []
    for pr in prs:
        files = fetch_files(pr["number"])
        result = analyze_pr_with_gpt(pr, files)
        print(f"PR #{pr['number']} categorized as {result['category']} ({result['audience']})")
        results.append(result)

    notes = format_output(results)
    with open("RELEASE_NOTES.md", "w") as f:
        f.write(notes)

if __name__ == "__main__":
    main()
