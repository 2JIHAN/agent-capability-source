---
name: doc-cluster
description: Use when you need to group a folder of scattered markdown documents into themes (chapters) by reading their content. One atomic step of the doc-librarian cataloging flow; can also run standalone to answer "what themes are in this folder?". Input is a folder of *.md; output is a taxonomy mapping theme → member files. Does NOT write files — it only decides grouping. For writing chapter summaries use doc-summarize, for the catalog file use doc-index.
version: 0.1.0
---

# doc-cluster

Group scattered markdown into themes by reading content. Single job: decide which documents belong together. Write nothing.

## Input

A target folder holding `*.md` originals (possibly across subfolders), excluding `INDEX.md` and anything under `_chapters/`.

## Steps

1. List the originals: `find "$root" -name '*.md' -not -path "$root/_chapters/*" ! -name INDEX.md`.
2. If `<root>/INDEX.md` exists, read its existing theme taxonomy first. **Preserve it** — established chapter names and boundaries are stable identity. You are extending, not re-clustering from scratch.
3. Read enough of each unclustered original to judge its subject. Group by genuine theme, not by folder location and not by file count.
4. Aim for chapters a human would name without hesitation (e.g. `sensors`, `networking`, `build-and-deploy`). Avoid a catch-all `misc` unless a document truly belongs nowhere.

## Output

A taxonomy mapping, one chapter per line, with its members. No files written:

```
sensors        → mlx90640.md, sht3x.md, sw801s.md
networking     → wifi.md, ntp.md, websocket.md
build-and-deploy → platformio.md, flashing.md
```

## Rules

- Theme is read from content. Never split by folder or by raw count.
- Each original belongs to exactly one chapter.
- Reuse existing chapter names verbatim when a document fits one; only coin a new name when nothing fits.
