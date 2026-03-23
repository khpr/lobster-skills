#!/usr/bin/env bash
# sp500-verify.sh — 紅藍隊驗證（wrapper，實際邏輯用 python3）
set -euo pipefail

BATCH_SIZE="${1:-5}"
DOMAIN_ARG=""
if [[ "${1:-}" == "--domain" && -n "${2:-}" ]]; then
    DOMAIN_ARG="$2"
    BATCH_SIZE=1
fi

python3 - "$BATCH_SIZE" "$DOMAIN_ARG" << 'PYEOF'
import sys, os, re, json, subprocess, time
from urllib.parse import urlparse

batch_size = int(sys.argv[1]) if len(sys.argv) > 1 else 5
domain_arg = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] else None

CANDIDATES = os.path.expanduser("~/.openclaw/workspace/sp500-candidates.md")
SOURCES = os.path.expanduser("~/.openclaw/workspace/sp500-sources.md")
OUTPUT_DIR = "/tmp/sp500-verify"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def log(msg):
    print(f"[{time.strftime('%H:%M:%S')}] {msg}", file=sys.stderr)

def curl_get(url, timeout=10):
    try:
        r = subprocess.run(["curl", "-sL", "--max-time", str(timeout), url],
                          capture_output=True, text=True, timeout=timeout+5)
        return r.stdout[:50000]
    except:
        return ""

def curl_head(url, timeout=5):
    try:
        r = subprocess.run(["curl", "-sI", "-o", "/dev/null", "-w", "%{http_code}",
                           "-L", "--max-time", str(timeout), url],
                          capture_output=True, text=True, timeout=timeout+3)
        return r.stdout.strip()
    except:
        return "000"

# Get domains
domains = []
if domain_arg:
    domains = [domain_arg]
else:
    if os.path.exists(CANDIDATES):
        with open(CANDIDATES) as f:
            for line in f:
                if line.startswith("- ") and "待審核" in line:
                    parts = line.split("|")
                    if len(parts) >= 2:
                        d = parts[1].strip()
                        if d:
                            domains.append(d)
                if len(domains) >= batch_size:
                    break

if not domains:
    log("沒有待驗證的候選來源")
    sys.exit(0)

log(f"驗證 {len(domains)} 個 domain...")

for domain in domains:
    log(f"--- 驗證: {domain} ---")
    
    # Ensure domain has no protocol
    domain_clean = domain.replace("https://","").replace("http://","").strip("/")
    url_base = f"https://{domain_clean}"
    
    # Fetch homepage
    homepage = curl_get(url_base)
    if not homepage:
        result = {"domain": domain_clean, "status": "unreachable", "articles": []}
        with open(f"{OUTPUT_DIR}/{domain_clean.replace('/','_')}.json", "w") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        log(f"❌ {domain_clean} 無法連線")
        continue
    
    # Extract title
    title_match = re.search(r'<title[^>]*>([^<]+)</title>', homepage, re.I)
    title = title_match.group(1).strip() if title_match else ""
    
    # Find article links
    all_links = re.findall(r'href="(https?://[^"]+)"', homepage)
    # Filter to same domain, exclude static files
    skip_patterns = re.compile(r'\.(css|js|png|jpg|gif|svg|ico|woff)', re.I)
    skip_paths = re.compile(r'(login|signup|about|contact|privacy|terms|tag/|category/)', re.I)
    
    article_urls = []
    for link in all_links:
        if domain_clean not in link: continue
        if skip_patterns.search(link): continue
        if skip_paths.search(link): continue
        if link not in article_urls:
            article_urls.append(link)
        if len(article_urls) >= 6: break
    
    # If no full URLs, try relative
    if not article_urls:
        rel_links = re.findall(r'href="(/[^"]{10,})"', homepage)
        for link in rel_links[:6]:
            full = f"{url_base}{link}"
            if skip_patterns.search(full): continue
            article_urls.append(full)
    
    # Fetch up to 3 articles
    articles = []
    for aurl in article_urls[:3]:
        body = curl_get(aurl, timeout=8)
        if not body: continue
        
        a_title_match = re.search(r'<title[^>]*>([^<]+)</title>', body, re.I)
        a_title = a_title_match.group(1).strip() if a_title_match else ""
        
        text = re.sub(r'<[^>]+>', ' ', body)
        word_count = len(text.split())
        
        has_author = bool(re.search(r'author|作者|記者|by\s', body, re.I))
        has_date = bool(re.search(r'datetime|published|發布|日期|202\d', body, re.I))
        
        articles.append({
            "url": aurl,
            "title": a_title[:100],
            "word_count": word_count,
            "has_author": has_author,
            "has_date": has_date
        })
    
    # Detect RSS
    rss = None
    for path in ["/feed", "/rss", "/atom.xml", "/feed/", "/rss.xml", "/index.xml"]:
        code = curl_head(f"{url_base}{path}")
        if code.startswith("2"):
            rss = f"{url_base}{path}"
            break
    
    result = {
        "domain": domain_clean,
        "title": title[:100],
        "status": "verified",
        "rss": rss,
        "article_count": len(articles),
        "articles": articles,
        "verdict": "pending_ai_review"
    }
    
    outfile = f"{OUTPUT_DIR}/{domain_clean.replace('/','_')}.json"
    with open(outfile, "w") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    
    log(f"✅ {domain_clean} — {len(articles)} 篇文章, RSS: {rss or 'none'}")
    time.sleep(2)

files = [f for f in os.listdir(OUTPUT_DIR) if f.endswith(".json")]
log(f"完成！共 {len(files)} 個驗證報告在 {OUTPUT_DIR}/")
PYEOF
