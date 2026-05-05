import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var model: AppModel
    @State private var inputAppeared = false
    @State private var trimAppeared = false
    @State private var historyAppeared = false
    @State private var displayedTrimSession: ActiveTrimSession?
    @State private var transitionGeneration = 0

    var body: some View {
        ZStack {
            Color.clear

            VStack(spacing: 12) {
                DownloadInputView(
                    text: $model.inputText,
                    isDownloading: model.isDownloading,
                    folderName: URL(fileURLWithPath: model.downloadFolderPath).lastPathComponent,
                    onSubmit: model.submitInput,
                    onPaste: model.handlePasteCandidate,
                    onChooseFolder: model.chooseDownloadFolder
                )
                .opacity(inputAppeared ? 1 : 0)
                .scaleEffect(inputAppeared ? 1 : 0.965)
                .blur(radius: inputAppeared ? 0 : 7)

                if let session = displayedTrimSession {
                    VideoTrimPanelView(
                        session: session,
                        onClose: model.closeTrim,
                        onCopy: model.copyActiveTrim,
                        onSave: model.saveActiveTrim
                    )
                    .id(session.id)
                    .opacity(trimAppeared ? 1 : 0)
                    .scaleEffect(trimAppeared ? 1 : 0.985, anchor: .top)
                    .blur(radius: trimAppeared ? 0 : 7)
                    .offset(y: trimAppeared ? 0 : -8)
                }

                if !model.history.isEmpty {
                    HistoryListView(
                        items: model.history,
                        onCopy: model.copyFile,
                        onReveal: model.revealInFinder,
                        onOpenSource: model.openSourceURL,
                        onEdit: model.editTrim
                    )
                    .opacity(historyAppeared ? 1 : 0)
                    .scaleEffect(historyAppeared ? 1 : 0.985, anchor: .top)
                    .blur(radius: historyAppeared ? 0 : 5)
                    .offset(y: historyAppeared ? 0 : -8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 56)
            .padding(.bottom, 56)
        }
        .onAppear {
            runActivationAnimation()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            runActivationAnimation()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            inputAppeared = false
            trimAppeared = false
            historyAppeared = false
        }
        .onReceive(model.$activeTrimSession) { session in
            runTrimModeTransition(to: session)
        }
        .animation(.easeOut(duration: 0.16), value: model.history)
    }

    private func runActivationAnimation() {
        let generation = nextTransitionGeneration()
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            inputAppeared = false
            trimAppeared = false
            historyAppeared = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            guard transitionGeneration == generation else { return }
            withAnimation(.easeOut(duration: 0.18)) {
                inputAppeared = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            guard transitionGeneration == generation else { return }
            if displayedTrimSession != nil {
                withAnimation(.easeOut(duration: 0.22)) {
                    trimAppeared = true
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (displayedTrimSession == nil ? 0.12 : 0.22)) {
            guard transitionGeneration == generation else { return }
            withAnimation(.easeOut(duration: 0.22)) {
                historyAppeared = true
            }
        }
    }

    private func runTrimModeTransition(to session: ActiveTrimSession?) {
        let generation = nextTransitionGeneration()

        withAnimation(.easeOut(duration: 0.12)) {
            historyAppeared = false
        }

        if session == nil {
            withAnimation(.easeOut(duration: 0.14)) {
                trimAppeared = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                guard transitionGeneration == generation else { return }
                displayedTrimSession = nil

                withAnimation(.easeOut(duration: 0.22)) {
                    historyAppeared = true
                }
            }

            return
        }

        withAnimation(.easeOut(duration: 0.12)) {
            trimAppeared = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            guard transitionGeneration == generation else { return }

            displayedTrimSession = session
            withAnimation(.easeOut(duration: 0.2)) {
                trimAppeared = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            guard transitionGeneration == generation else { return }

            withAnimation(.easeOut(duration: 0.22)) {
                historyAppeared = true
            }
        }
    }

    private func nextTransitionGeneration() -> Int {
        transitionGeneration += 1
        return transitionGeneration
    }
}
