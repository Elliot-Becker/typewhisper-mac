# Local Prompt Review

An independent GPLv3 action plugin for the pinned TypeWhisper 1.8.2 development host (`7a9bcec83d92bfc548edaf8f93eacf7d8368b6d7`). The host source is unmodified.

The action receives `input` (rewritten prompt) and `ActionContext.originalText` (ASR transcript). It opens a resizable native window with the original transcript, editable prompt, reminders about changed numbers/negative phrases/scope words/identifiers, and explicit Copy Prompt / Copy Original buttons. No automatic insertion or submission is implemented. Closing the window discards the plugin's in-memory text; the host's storage settings are separate.

Warnings are deliberately incomplete attention cues. For example, the numeric check cannot distinguish 300 milliseconds from 300 seconds. An absence of warnings must never be presented as approval or semantic equivalence.

## Build and checks

First build the pinned TypeWhisper Debug scheme. Its product directory must include `TypeWhisperPluginSDK.swiftmodule` and `PackageFrameworks/TypeWhisperPluginSDK.framework`.

Run `python3 build.py` with the adjacent evaluation checkout present, or pass the original host's Debug product directory as its first argument. `swift test` runs the isolated warning-policy regression checks without downloading model dependencies.

Bundle ID: `local.elliot.prompt-review`. Action ID selected by workflow output: `local-prompt-review`. Host SDK compatibility: `v1`. Install the built bundle only into the isolated host's `TypeWhisper-Dev/Plugins` directory.

The original host's action route passes the raw ASR transcript to the action. It can fall through to text insertion if a configured action cannot be resolved; leave dictation hotkeys paused until the plugin and workflow output have been checked live. A strict fail-closed guarantee for a missing action would need a narrow host change.

## Verification boundary

The plugin compiles and its installed bundle loads against the actual host SDK, registers the expected ActionPlugin and exposes its settings view. Seven policy regression tests pass. User-supplied screenshots confirm the real sample window, warning, copy confirmations and microphone → prompt → review route. The user confirmed editing and copying into TextEdit, cancellation, and separate direct Literal insertion. Desktop capture itself failed during the automated session, so these live checks combine supplied screenshot evidence with the user's reports. Host API workflow benchmarks do not execute output actions. Broader editor, permission, cancellation-race and long-recording validation remains future work.

The settings page includes **Try a sample**, demonstrating the observed omission of “without applying it.” It opens the same review action used by dictation and does not record audio or contact a model.

## License

GPLv3; see LICENSE. The linked TypeWhisper SDK has its upstream GPL terms. Apple Speech and Apple Intelligence are on-device system frameworks, not open-source model weights. Optional Qwen weights and llama.cpp retain their separate upstream licenses. No publication, remote repository, CLA acceptance or paid service is involved.
