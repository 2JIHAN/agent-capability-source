---
name: doc-index
description: Use when you need to build or refresh the top-level catalog file (INDEX.md) for a managed doc folder from a known theme taxonomy. One atomic step of the doc-librarian flow; mostly mechanical. Input is a taxonomy (theme → members) plus existing chapter summaries; output is <root>/INDEX.md, the Tier-0 browse-first table of contents. For deciding the taxonomy use doc-cluster, for chapter bodies use doc-summarize.
version: 0.1.0
---

# doc-index

Build or refresh `<root>/INDEX.md`, the Tier-0 catalog. Single job: turn a taxonomy into a browse-first table of contents. Mechanical — no theme judgment here.

## Input

- The taxonomy (chapters → member files), e.g. from doc-cluster.
- Existing `<root>/_chapters/<topic>.md` files (linked, not generated here).

## Output

`<root>/INDEX.md`:

```markdown
# <root> — catalog

Start here. Skim a chapter summary before opening originals. Open an original only when the summary is not enough.

## <chapter topic> — <one-line hook>
Summary: [_chapters/<topic>.md](_chapters/<topic>.md)
- [original-a.md](original-a.md) — one-line summary
- [sub/original-b.md](sub/original-b.md) — one-line summary

## <next chapter> — ...
```

## Rules

- The header's "Start here" line always present — it tells readers (and agents) to read the catalog before the originals.
- One line per chapter hook, one line per member. Keep it skimmable; detail lives in the chapter summary, not here.
- Preserve chapter order and names from the existing INDEX unless the taxonomy changed.
- Link paths are relative to `<root>`.
