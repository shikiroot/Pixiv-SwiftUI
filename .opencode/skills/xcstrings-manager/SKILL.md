---
name: xcstrings-manager
description: Manage Xcode String Catalog (.xcstrings) localization files through a command-line interface. Used when adding, updating, or querying localization strings.
---

When managing localization strings in `Localizable.xcstrings` for this repository:

- Do not assume any helper script exists. The old `scripts/localization_manager.py` workflow is not available here.
- Modify `Localizable.xcstrings` directly only when the user explicitly requests localization work.
- Prefer read-only inspection first with tools such as `rg`, `sed`, or `plutil -p`.
- Keep edits minimal and targeted to the requested keys/languages.
- Do not run any local build or simulator validation as part of localization work.

After editing, verify with a non-build check such as `plutil -lint Localizable.xcstrings` or a targeted file read.
