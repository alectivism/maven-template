---
name: office-editing
description: Use when reading or editing Microsoft Word (.docx) or Excel (.xlsx) files that live in MMA SharePoint/OneDrive — the synced folder ~/Library/CloudStorage/OneDrive-MMAGlobal, or files only in SharePoint/Teams. Covers the OneDrive/SharePoint transport waterfall, the Word run-splitting gotcha, and reading Word comments. NOT needed for plain local files (e.g. ~/Downloads, a repo working copy) — those are edited directly with python-docx/openpyxl.
---

# Editing Word & Excel files

Edit by running a Python script via Bash. **Don't read the whole document into the conversation** — the script makes the targeted change and returns only a confirmation. Both libraries are already installed (python-docx 1.2.0, openpyxl 3.1.5); don't reinstall.

**Scope:** this skill is for MMA SharePoint/OneDrive documents. For a **plain local file** (`~/Downloads`, a repo working copy, anything not in SharePoint/OneDrive), skip the transport section and just edit it in place with python-docx/openpyxl — editing local files is the default and this skill never blocks it. The run-splitting and comments sections below apply to any `.docx` regardless of where it lives.

- `.docx` → python-docx (`import docx`)
- `.xlsx` → openpyxl (`import openpyxl`)

## Waterfall (verified — quality is a tie, local wins on tokens)

The editor is python-docx/openpyxl either way — **ms365/Graph has no content-edit tool, it only moves bytes** — so editing fidelity is identical across methods. The choice is purely transport cost.

1. **File has a path on this Mac** (anywhere on disk, including OneDrive-synced `~/Library/CloudStorage/OneDrive-MMAGlobal/…`) → **edit in place by path. This is the default.** One Bash call, file bytes never enter the conversation (verified: full create→edit→save roundtrip in 0.03s). OneDrive files auto-download on open and re-sync on save (see below).
2. **File is only in SharePoint/Teams and NOT synced to this Mac** (no local path) → use ms365 as transport, via `curl` so bytes bypass context:
   - download: `get-drive-item` → take `@microsoft.graph.downloadUrl` → `curl -o /tmp/f.docx "<url>"`
   - edit `/tmp/f.docx` with python-docx
   - upload: `create-upload-session` → `curl -X PUT --data-binary @/tmp/f.docx "<uploadUrl>"`
   - **Avoid `download-bytes` / `upload-file-content`** except for tiny files — they pass the file as base64 through the conversation (token-expensive, 4MB cap).

## OneDrive online-only files

Files under `~/Library/CloudStorage/OneDrive-MMAGlobal` are usually online-only placeholders (0 blocks on disk). **Opening the path auto-downloads it** — python-docx, openpyxl, and `cat` all trigger hydration transparently, then proceed. Saving keeps the same path and OneDrive re-uploads automatically, so the file's link and "recent files" position are preserved.

- Check state: `stat -f '%b' "<file>"` → `0` = not downloaded yet (first open blocks while it pulls).
- Requires the OneDrive client running and online. For a large file, open it once to pre-warm.

## Word: the run-splitting gotcha

Word splits a paragraph's text across multiple "runs." Reading `paragraph.text` works, but **assigning to it does nothing** — you must write to runs. To replace text, capture the full text first, blank the extra runs, write the result into the first (this collapses to run 0's formatting, fine for plain text):

```python
for p in doc.paragraphs:
    if "OLD" in p.text:
        new = p.text.replace("OLD", "NEW")
        for r in p.runs[1:]:
            r.text = ""
        if p.runs:
            p.runs[0].text = new
```
Tables: iterate `doc.tables[i].rows[j].cells[k].paragraphs`.

## Reading Word comments (python-docx can't)

Comments live in `word/comments.xml` inside the .docx zip:

```python
import zipfile, defusedxml.ElementTree as ET  # defusedxml: safe vs XXE/billion-laughs
ns = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
with zipfile.ZipFile(path) as z:
    if "word/comments.xml" in z.namelist():
        root = ET.fromstring(z.read("word/comments.xml"))
        for c in root.findall("w:comment", ns):
            author = c.get(f"{{{ns['w']}}}author")
            text = "".join(t.text or "" for t in c.iter(f"{{{ns['w']}}}t"))
            print(author, ":", text)
```
