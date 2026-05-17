# Learning Complex Software with Obsidian (Method + Examples)

[中文](README.md) | [English](README.en.md)

This repository shares a **repeatable way to learn and memorize complex software** using Obsidian, plus **ready-to-use example vaults** (starting with SolidWorks, with more to come).

You may keep two different vaults locally (recommended):

- **Your private “everything” vault**: your long-term personal knowledge base (not meant to be public).
- **This public examples repo**: the method + multiple example vaults that others can download selectively.

## What this repo is for

For software with heavy UI and many commands (CAD/CAE, IDEs, editing tools, etc.), common problems are:

- random graph layouts break memorization
- deep folder trees become hard to navigate
- tips/lessons don’t reliably “go back” to the right context

This method is built for **top-down learning** (UI map first, details later) and **stable ordering** (left→right, top→bottom).

## Core constraints (do not break these)

- Canvas is for **visual indexing + stable ordering** (screenshots + links; avoid walls of text).
- Markdown is for **hierarchy + details** (index pages stay lightweight; leaf pages hold details).
- Keep a stable reading path: **left→right, top→bottom**.
- If there are many commands: **cluster first, then drill down**.
- Screenshots are **manual** (automation helps scaffolding/links/organization, not capturing UI).

See: `docs/方法论.md` (Chinese, for now).

## Example vaults (download only what you need)

Each example is a standalone vault under `examples/<name>_vault/`.

- SolidWorks: `examples/solidworks_vault/`

### SolidWorks Preview

- Canvas: `examples/solidworks_vault/02-知识图谱/SolidWorks/白板思维导图.canvas`
- Demo video: `assets/solidworks-example.mp4`

Canvas graph preview (click to play the demo video):

[![Click to watch the demo video](assets/solidworks-canvas-preview.png)](assets/solidworks-example.mp4)

## How to open an example (important)

In Obsidian, open the **example vault folder** as a vault (e.g. `examples/solidworks_vault/`).  
Do **not** open the repository root as a vault, otherwise canvas images/links may show as missing.

## Scripts (optional)

- SolidWorks surface scaffolding + canvas links: `scripts/solidworks_surface_scaffold.ps1`
- Organize canvas images into `99-Images`-style folder + rename: `scripts/obsidian_canvas_organize_images.ps1`
- Export a minimal SolidWorks subset from a private vault into a public example vault: `scripts/export_solidworks_for_github.ps1`
