import requests
from datetime import datetime, timedelta
import os

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
REPO = os.getenv("GITHUB_REPO")  # e.g. "org/repo"
SINCE = (datetime.utcnow() - timedelta(days=1)).isoformat() + "Z"

HEADERS = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}

CATEGORY_KEYWORDS = {
    "New": ["add", "create", "initial", "feature"],
    "Enhancement": ["improve", "optimize", "enhance"],
    "Fix": ["fix", "bug", "correct", "patch"],
    "Behavior change": ["deprecate", "remove", "change", "default"]
}

def fetch_prs():
    url = f"https://api.github.com/repos/{REPO}/pulls?state=closed&sort=updated&direction=desc"
    response = requests.get(url, headers=HEADERS)
    prs = response.json()
    return [pr for pr in prs if pr["merged_at"] and pr["merged_at"] > SINCE]

def categorize(pr):
    title = pr["title"].lower()
    for category, keywords in CATEGORY_KEYWORDS.items():
        if any(kw in title for kw in keywords):
            return category
    return "Behavior change"

def build_notes(prs):
    categories = {"New": [], "Enhancement": [], "Fix": [], "Behavior change": []}
    for pr in prs:
        category = categorize(pr)
        entry = f"- {pr['title']} ([#{pr['number']}]({pr['html_url']})) by @{pr['user']['login']}"
        categories[category].append(entry)
    return categories

def format_notes(categories):
    today = datetime.utcnow().strftime("%B %d, %Y")
    lines = [f"### {today} release notes...\n"]
    for cat, items in categories.items():
        if items:
            lines.append(f"**{cat}:**")
            lines.extend(items)
            lines.append("")
    return "\n".join(lines)

def write_to_file(text):
    with open("RELEASE_NOTES.md", "a") as f:
        f.write(text + "\n\n")

if __name__ == "__main__":
    prs = fetch_prs()
    categorized = build_notes(prs)
    final_text = format_notes(categorized)
    print(final_text)
    write_to_file(final_text)
