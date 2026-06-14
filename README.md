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

The same workflow also runs on a daily schedule. Scheduled
runs compare each source repository's current upstream commit with
`upstreams.json`; only extensions with upstream changes are released. The
upstream state is updated only after the release metadata is written.

Obsidian Clipper uses the upstream `package.json` version for Firefox's update
version. If upstream commits change without a version bump, the workflow appends
a fourth numeric build part, such as `1.6.3.1`, while keeping `version_name` at
the upstream version, such as `1.6.3`.
