# firefox-extensions-releases

Self-hosted Firefox update manifests and GitHub Release assets for personal
unlisted extension builds.

## Extensions

| Extension | Source repository | Update manifest |
| --- | --- | --- |
| Obsidian Clipper | `obsidianmd/obsidian-clipper` | `updates/obsidian-clipper.json` |
| Tabalanche | `eight04/tabalanche-extension` | `updates/tabalanche.json` |

Run the `release` workflow manually and choose the extension to publish. The
workflow signs the Firefox build through AMO as an unlisted extension, uploads
the signed XPI to a GitHub Release, and appends the new version to that
extension's update manifest.
