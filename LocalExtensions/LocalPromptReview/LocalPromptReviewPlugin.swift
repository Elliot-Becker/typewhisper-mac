import AppKit
import SwiftUI
import TypeWhisperPluginSDK

@objc(LocalPromptReviewPlugin)
final class LocalPromptReviewPlugin: NSObject, ActionPlugin, @unchecked Sendable {
    static let pluginId = "local.elliot.prompt-review"
    static let pluginName = "Local Prompt Review"
    var actionName: String { "Review Local Prompt" }
    var actionId: String { "local-prompt-review" }
    var actionIcon: String { "doc.text.magnifyingglass" }
    @MainActor private var controllers: [UUID: ReviewController] = [:]
    required override init() { super.init() }
    func activate(host: HostServices) {}
    func deactivate() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            for controller in Array(self.controllers.values) { controller.close() }
            self.controllers.removeAll()
        }
    }
    func execute(input: String, context: ActionContext) async throws -> ActionResult {
        await present(original: context.originalText, proposed: input, target: context.appName)
        return ActionResult(success: true, message: "Prompt ready for review", icon: actionIcon)
    }
    @MainActor private func present(original: String, proposed: String, target: String?) {
        let id = UUID()
        let controller = ReviewController(original: original, proposed: proposed, target: target)
        controller.onClose = { [weak self] in self?.controllers.removeValue(forKey: id) }
        controllers[id] = controller
        controller.showWindow(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        controller.window?.makeKeyAndOrderFront(nil)
    }
    @MainActor var settingsView: AnyView? {
        AnyView(VStack(alignment: .leading, spacing: 14) {
            Text("Review before you paste").font(.headline)
            Text("This action shows the original transcript beside an editable prompt. You choose what to copy. Each result stays in memory until its window is closed.")
            Text("Select Review Local Prompt as the output action for your prompt workflow.").foregroundStyle(.secondary)
            Button("Try a sample") {
                Task {
                    _ = try? await self.execute(input: "Set the timeout to 300 milliseconds, not 3 seconds. Describe the change.", context: ActionContext(originalText: "Set the timeout to 300 milliseconds, not 3 seconds. Describe the change without applying it."))
                }
            }
        }.padding(20).frame(maxWidth: .infinity, alignment: .leading))
    }
}

@MainActor
private final class ReviewController: NSWindowController, NSWindowDelegate {
    var onClose: (() -> Void)?
    init(original: String, proposed: String, target: String?) {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 620), styleMask: [.titled, .closable, .resizable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Review Local Prompt"
        window.minSize = NSSize(width: 580, height: 480)
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
        window.contentView = NSHostingView(rootView: PromptReviewView(original: original, proposed: proposed, target: target, close: { [weak self] in self?.close() }))
        window.center()
    }
    required init?(coder: NSCoder) { fatalError("Not supported") }
    func windowWillClose(_ notification: Notification) { onClose?() }
}

private struct PromptReviewView: View {
    let original: String
    let target: String?
    let close: () -> Void
    @State private var draft: String
    @State private var status = ""
    init(original: String, proposed: String, target: String?, close: @escaping () -> Void) {
        self.original = original; self.target = target; self.close = close
        _draft = State(initialValue: proposed)
    }
    private var warnings: [String] { ReviewChecks.warnings(original: original, proposed: draft) }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Check the meaning before copying").font(.headline)
                Spacer()
                Button("Close", action: close).keyboardShortcut(.cancelAction)
            }
            Text("Compare the transcript and prompt. Warnings are reminders; they cannot verify meaning.").foregroundStyle(.secondary)
            if let target, !target.isEmpty { Text("Recorded from: \(target)").font(.caption).foregroundStyle(.secondary) }
            HStack(spacing: 10) {
                Button("Copy Prompt") { copy(draft, label: "Prompt") }.disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Button("Copy Original") { copy(original, label: "Original transcript") }.disabled(original.isEmpty)
                Text(status).font(.caption).foregroundStyle(.secondary).accessibilityLabel(status)
            }
            if !warnings.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Label("Check these changes", systemImage: "exclamationmark.triangle").font(.subheadline.bold())
                    ForEach(warnings, id: \.self) { Text("• " + $0).font(.callout) }
                }.padding(10).frame(maxWidth: .infinity, alignment: .leading).background(Color.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
            }
            GroupBox("Original transcript") {
                ScrollView { Text(original).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading).padding(6) }.frame(minHeight: 75, maxHeight: 130)
            }
            GroupBox("Prompt — edit if needed") {
                TextEditor(text: $draft).font(.body).frame(minHeight: 135).accessibilityLabel("Editable prompt")
            }
            Text("Nothing is inserted or submitted automatically. Closing this window discards its in-memory text.").font(.caption).foregroundStyle(.secondary)
        }.padding(20).frame(minWidth: 540, minHeight: 430)
    }
    private func copy(_ text: String, label: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        status = label + " copied. Paste it where you want to use it."
    }
}
