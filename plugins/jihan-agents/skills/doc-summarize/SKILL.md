---
name: doc-summarize
description: Use when you need to write or refresh a single chapter summary — a dense synopsis of the documents in one theme — so a reader can skim it instead of opening every original. One atomic step of the doc-librarian flow; can run standalone to summarize a set of related docs. Input is a theme name plus its member files; output is one <root>/_chapters/<topic>.md file. For grouping into themes use doc-cluster, for the top catalog use doc-index.
version: 0.1.0
---

# doc-summarize

Write one chapter summary. Single job: synthesize one theme's documents into a synopsis that usually removes the need to open the originals.

## Input

- A chapter topic (the theme name).
- Its member document paths.

## Steps

1. Read the member documents in full.
2. Write `<root>/_chapters/<topic>.md`:
   - Lead with what the theme is and why it exists.
   - Capture the load-bearing facts, decisions, and constraints — the things a reader would otherwise open the originals to learn.
   - Link each member by relative path so the reader can drill down.
   - Do not paste originals verbatim. Synthesize.

## Output

One file: `<root>/_chapters/<topic>.md`. Refresh in place if it already exists.

## Rules

- Summarize, never copy. If the summary is as long as the originals, it failed.
- Every member document is linked.
- Capture *why*, not just *what* — the why is what the one-line INDEX entry can't hold.
