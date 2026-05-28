---
name: doc-scaffold
description: Use when a doc folder's purpose is clear and you want to give it a conventional reference folder structure so future documents have an obvious home. One atomic step of the doc-librarian flow. Input is the folder plus its discovered themes; output is a skeleton of subfolders (e.g. project-natured → history/ todo/ WIP/ handoffs/) with placeholder READMEs, recorded in INDEX.md. Files NEW docs into the skeleton; only PROPOSES moves for existing well-placed docs.
version: 0.1.0
---

# doc-scaffold

Lay a reference folder skeleton once the corpus purpose is clear. Single job: give future docs an obvious home, without disturbing what already has one.

## Input

- The target folder.
- Its discovered themes (e.g. from doc-cluster) — these reveal the corpus nature.

## Steps

1. Judge the corpus nature from the themes. A **project-natured** corpus (notes about building/running one thing) takes a skeleton like `history/`, `todo/`, `WIP/`, `handoffs/`. Other natures take their own fitting skeleton — do not force this one.
2. Create each skeleton folder with a one-line `README.md` placeholder so it persists in git.
3. Fold loose conventional folders into this root — handoff notes live in `<root>/handoffs/`, not a separate top-level `.claude/handoffs/`.
4. Record the skeleton in `<root>/INDEX.md` so it reads as the reference for where new docs go.
5. File **new / still-loose** documents into the fitting skeleton folder.

## Output

- Skeleton folders with placeholder READMEs.
- A skeleton note in `INDEX.md`.

## Rules

- Establishing the skeleton and filing new docs is safe. **Existing well-placed documents: propose moves to the user, never relocate silently.**
- Pick the skeleton from the corpus's actual nature, not a fixed template.
