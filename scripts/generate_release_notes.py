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
    heading = f"## 🗓️ {today} Release Notes\n"

    category_order = ["Behavior change", "New", "Enhancement", "Fix"]
    category_emojis = {
        "New": "✨",
        "Enhancement": "⚡",
        "Fix": "🐛",
        "Behavior change": "🚨"
    }

    # Create Table of Contents
    toc = ["### 🧭 Jump to"]
    for cat in category_order:
        if categories[cat]:
            emoji = category_emojis.get(cat, "")
            anchor = cat.lower().replace(" ", "-")
            toc.append(f"- [{emoji} {cat}](#{anchor})")
    toc.append("")

    # Build section content
    sections = []
    for cat in category_order:
        pr_list = categories[cat]
        if not pr_list:
            continue
        emoji = category_emojis.get(cat, "")
        sections.append(f"### {emoji} {cat}")
        # Sort by PR number
        sorted_prs = sorted(pr_list, key=lambda pr: pr["number"])
        for pr in sorted_prs:
            title = pr["title"]
            number = pr["number"]
            user = pr["user"]["login"]
            html_url = pr["html_url"]
            diff_url = f"{html_url}.diff"
            sections.append(f"- {title} ([#{number}]({html_url}) • [diff]({diff_url})) — @{user}")
        sections.append("")

    return "\n".join([heading] + toc + sections)

def write_to_file(text):
    with open("RELEASE_NOTES.md", "a") as f:
        f.write(text + "\n\n")

if __name__ == "__main__":
    prs = fetch_prs()
    categorized = build_notes(prs)
    final_text = format_notes(categorized)
    print(final_text)
    write_to_file(final_text)
