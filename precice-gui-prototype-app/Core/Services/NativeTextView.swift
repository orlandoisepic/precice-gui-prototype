
import SwiftUI
import AppKit

struct NativeTextView: NSViewRepresentable {
    @Binding var text: String
    var fontSize: CGFloat
    var lineSpacing: CGFloat
    var minWidth: CGFloat
    var minHeight: CGFloat
    var onTextChange: (() -> Void)?
    @Binding var isEditable: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
            // We wrap the NSTextView in an NSScrollView.
            // Even though you have an outer SwiftUI ScrollView, NSTextView behaves
            // MUCH better regarding infinite width when it lives inside its own scroll container class,
            // even if we disable the actual scrollbars to let the outer view handle it.
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
            // Use our custom subclass to fix the top-alignment issue
        let textView = MacEditorTextView()
        textView.autoresizingMask = [.width, .height]
        textView.delegate = context.coordinator
        
            // --- 1. Fix Alignment (Top-Left) ---
            // (Handled in the MacEditorTextView subclass below)
        
            // --- 2. Disable Line Wrapping (Horizontal Scroll) ---
        let contentSize = scrollView.contentSize
        
            // Stop the container from tracking the view width (this turns off wrapping)
        textView.textContainer?.widthTracksTextView = false
        
            // Give the container infinite width so it never wraps
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
            // Allow the text view to grow horizontally
        textView.isHorizontallyResizable = true
            // A small space before the text is also selectable
        textView.textContainerInset = NSSize(width: 10, height: 0)
        textView.textContainer?.lineFragmentPadding = 0
        
            // Set the max size to infinite so it doesn't get clamped
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
            // Ensure it starts at least as wide as the available space (for clicking empty areas)
        textView.minSize = NSSize(width: contentSize.width, height: contentSize.height)
        
            // --- 3. Visual Styling ---
        textView.isRichText = false
            // Set editable to "isEditable" reference
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.usesFontPanel = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        
        scrollView.documentView = textView
        
        context.coordinator.textView = textView // store reference
        
        updateAppearance(textView)
        
        return scrollView
    }
    
    func updateNSView(_ nsScrollView: NSScrollView, context: Context) {
        guard let textView = nsScrollView.documentView as? NSTextView else { return }
        
            // Update Text
        if textView.string != text {
                // Keep selection state if possible, otherwise it jumps
            let selectedRanges = textView.selectedRanges
            textView.string = text
                // Only restore if the text length permits (prevent crash on delete)
            if let firstRange = selectedRanges.first as? NSRange,
                firstRange.upperBound <= text.count {
                textView.selectedRanges = selectedRanges
            }
        }
        textView.isEditable = isEditable
            // Update styling
        updateAppearance(textView)
        
            // Ensure the frame is at least as wide as the SwiftUI view passed in
            // This ensures you can click far to the right even if the text is short
        if textView.frame.width < minWidth {
            textView.frame.size.width = minWidth
        }
    }
    
    private func updateAppearance(_ textView: NSTextView) {
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        textView.font = font
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
            // Apply attributes
        textView.defaultParagraphStyle = paragraphStyle
        textView.typingAttributes = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: NSColor.textColor
        ]
        
        if let storage = textView.textStorage {
                // We need to re-apply attributes to existing text
            storage.addAttributes([
                .font: font,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: NSColor.textColor
            ], range: NSRange(location: 0, length: storage.length))
        }
    }
    
        // MARK: - Coordinator
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NativeTextView
        weak var textView: NSTextView?
        
        init(_ parent: NativeTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.parent.text = textView.string
            self.parent.onTextChange?()
        }
    }
}

    // MARK: - Custom Subclass for Alignment
    // This is the "Magic" that fixes the bottom-alignment issue.
class MacEditorTextView: NSTextView {
    
        // This tells macOS: "Start drawing from the top-left, not bottom-left"
    override var isFlipped: Bool {
        return true
    }
}
