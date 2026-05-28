---
name: doc-file
description: Use when one or a few new/unfiled markdown documents need to be slotted into an existing theme taxonomy without re-clustering the whole folder. One atomic step of the doc-librarian flow; the incremental counterpart to doc-cluster. Input is the unfiled doc(s) plus the existing taxonomy from INDEX.md; output is a chapter assignment per doc. Keeps chapter names stable. For first-time grouping of a whole folder use doc-cluster instead.
version: 0.1.0
---

# doc-file

Place unfiled documents into the existing taxonomy. Single job: assign each loose doc to a chapter, preferring existing chapters to keep the taxonomy stable.

## Input

- The unfiled document(s) — originals not yet listed under any chapter in `<root>/INDEX.md`.
- The existing taxonomy read from `<root>/INDEX.md`.

## Steps

1. Read each unfiled document enough to judge its subject.
2. Match it to the existing chapter whose theme it fits.
3. Only when it fits no existing chapter, propose a new chapter for it.

## Output

A chapter assignment per document:

```
new-doc.md → sensors            (existing)
odd-one.md → power-management   (new chapter)
```

Hand the assignments to doc-summarize (refresh the affected chapters) and doc-index (update the catalog).

## Rules

- Prefer existing chapters. A new chapter is a last resort — established names and boundaries are stable identity readers depend on.
- Do not rename or re-scope existing chapters here; that is a re-cluster, not a file.
- One document, one chapter.
