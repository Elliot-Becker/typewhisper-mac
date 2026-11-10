# Local voice-to-prompt iteration

This fork is Elliot's isolated evaluation branch. Upstream baseline: `7a9bcec83d92bfc548edaf8f93eacf7d8368b6d7`. The compiled host source files remain unchanged; `LocalExtensions/LocalPromptReview` contains the independent review action plugin and its regression tests.

## Release pace

1. Make one bounded change on a feature branch in our fork.
2. Build it and run the relevant automated checks. Clearly record anything blocked or untested.
3. Try the real workflow on the M5, including cancellation and the actual target app; preserve rollback to the last checked build.
4. Review the resulting behavior with Elliot before starting a larger change.
5. Prepare an upstream-sized diff and ask Elliot to confirm it before opening an upstream issue or PR. No upstream PR, request for review, CLA acceptance or merge is authorized by this local evaluation alone.

Keep the fork's default branch aligned with upstream. Do not force-push or move default branches for iteration. The `upstream` remote is fetch-only by configuration; work belongs on `iteration/local-voice-prompt` or a later focused feature branch.

## Current boundary

- Builds and audio-file API replay succeeded with Apple Speech plus Apple Intelligence and with optional Qwen3 4B Q4 via the existing upstream llama.cpp plugin.
- The review action's seven policy tests pass. They expose, rather than solve, the limits of checking semantic faithfulness.
- User-supplied screenshots confirm real microphone → prompt → review behavior and copy confirmations. Editing success is user-reported. Literal direct insertion remains under clarification; do not mark the whole workflow passed from an aggregate answer.
- The default Escape behavior asks for a second Escape press to confirm cancellation.
- The full upstream test target did not build because the Metal compiler component was unavailable. Its download stalled. Do not claim upstream CI passed.
- The plugin keeps a user review step because both tested language models made substantive rewrite errors on some synthetic cases.
- Before unattended use, consider a narrowly scoped host change that blocks delivery when a configured action is missing. The current host can fall back to insertion in that case; keep this separate from the review UI feature.

## Reproduction

Build the pinned host Debug scheme with its documented direct-distribution instructions. Pass its Debug product directory to `python3 LocalExtensions/LocalPromptReview/build.py <products>`; the directory must contain the matching `TypeWhisperPluginSDK.swiftmodule` and `PackageFrameworks/TypeWhisperPluginSDK.framework`. Run `swift test --package-path LocalExtensions/LocalPromptReview` for the isolated policy tests.

Personal workflow exports, recordings, screenshots, model weights, local tokens, signing keys, logs and generated app bundles stay outside this repository. Preserve GPL notices. The host and plugin require no Apple Development private key for the ad-hoc prototype.
