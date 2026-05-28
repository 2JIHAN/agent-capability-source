---
name: doc-tier
description: Use when a doc catalog has itself grown too large — INDEX.md plus the _chapters/ summaries exceed the budget — and the chapters need grouping into a higher tier (parts). One atomic step of the doc-librarian flow; the recursion step. Input is the current chapters; output is a parts grouping with INDEX.md restructured to parts → chapters. Apply the same engage gate before adding a level; do not pre-build tiers a small catalog does not need.
version: 0.1.0
---

# doc-tier

Add a higher tier when the catalog outgrows one level. Single job: group chapters into parts so the Tier-0 catalog stays skimmable.

## When to engage

Only when `<root>/INDEX.md` plus the `<root>/_chapters/` summaries together exceed `chapter_threshold_bytes` (default 8192). Below that, do nothing — a flat chapter list is correct.

## Steps

1. Group related chapters into **parts** by theme (the same semantic judgment as doc-cluster, one level up).
2. Restructure `INDEX.md` to list parts → chapters.
3. Optionally give each part its own overview at `<root>/_chapters/_parts/<part>.md`.

## Output

- `INDEX.md` reorganized into parts → chapters.
- Optional `_chapters/_parts/<part>.md` overviews.

## Rules

- Apply the engage gate first. Never pre-build tiers a small catalog does not need.
- Parts are grouped by theme, never by chapter count.
- Recurse the same way if parts themselves later exceed budget.
