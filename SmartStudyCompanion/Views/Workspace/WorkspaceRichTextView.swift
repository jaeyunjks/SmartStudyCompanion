import SwiftUI
import UIKit
import Combine

final class WorkspaceRichTextController: NSObject, ObservableObject {
    enum ListStyle {
        case paragraph
        case bullet
        case numbered
    }

    weak var textView: UITextView?

    @Published var isBold = false
    @Published var isItalic = false
    @Published var isUnderline = false
    @Published var currentFontSize: CGFloat = 18
    @Published var currentAlignment: NSTextAlignment = .left
    @Published var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @Published var isEditing = false
    var onAttributedTextMutated: ((NSAttributedString) -> Void)?

    func refreshSelectionState() {
        guard let textView else { return }
        let range = textView.selectedRange
        selectedRange = range
        let attrs: [NSAttributedString.Key: Any]
        if range.length > 0,
           let selected = textView.attributedText?.attributes(at: range.location, effectiveRange: nil) {
            attrs = selected
        } else {
            attrs = textView.typingAttributes
        }

        if let font = attrs[.font] as? UIFont {
            isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
            isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
            currentFontSize = font.pointSize
        }

        if let underline = attrs[.underlineStyle] as? Int {
            isUnderline = underline != 0
        } else {
            isUnderline = false
        }

        currentAlignment = textView.textAlignment
    }

    func toggleBold() {
        toggleSymbolicTrait(.traitBold)
    }

    func toggleItalic() {
        toggleSymbolicTrait(.traitItalic)
    }

    func toggleUnderline() {
        toggleIntegerAttribute(.underlineStyle, enabled: !isUnderline)
    }

    func setFontSize(_ size: CGFloat) {
        guard let textView else { return }
        let range = textView.selectedRange
        if range.length > 0, let attributed = textView.attributedText?.mutableCopy() as? NSMutableAttributedString {
            attributed.enumerateAttribute(.font, in: range) { value, subrange, _ in
                let old = (value as? UIFont) ?? UIFont.systemFont(ofSize: currentFontSize)
                let newFont = UIFont(descriptor: old.fontDescriptor, size: size)
                attributed.addAttribute(.font, value: newFont, range: subrange)
            }
            textView.attributedText = attributed
            textView.selectedRange = range
        } else {
            var attrs = textView.typingAttributes
            let old = (attrs[.font] as? UIFont) ?? UIFont.systemFont(ofSize: currentFontSize)
            attrs[.font] = UIFont(descriptor: old.fontDescriptor, size: size)
            textView.typingAttributes = attrs
        }
        currentFontSize = size
        notifyMutation()
    }

    func setAlignment(_ alignment: NSTextAlignment) {
        guard let textView else { return }
        textView.textAlignment = alignment
        currentAlignment = alignment
        notifyMutation()
    }

    func applyListStyle(_ style: ListStyle) {
        guard let textView else { return }
        let selection = textView.selectedRange
        let nsText = textView.text as NSString
        let paragraphRange = nsText.paragraphRange(for: selection)
        let original = nsText.substring(with: paragraphRange)
        let lines = original.components(separatedBy: "\n")

        let replaced: [String]
        switch style {
        case .paragraph:
            replaced = lines.map { line in
                line
                    .replacingOccurrences(of: "• ", with: "")
                    .replacingOccurrences(of: "^[0-9]+\\. ", with: "", options: .regularExpression)
            }
        case .bullet:
            replaced = lines.map { line in
                let cleaned = line
                    .replacingOccurrences(of: "^[0-9]+\\. ", with: "", options: .regularExpression)
                    .replacingOccurrences(of: "• ", with: "")
                return cleaned.isEmpty ? "• " : "• \(cleaned)"
            }
        case .numbered:
            replaced = lines.enumerated().map { idx, line in
                let cleaned = line
                    .replacingOccurrences(of: "• ", with: "")
                    .replacingOccurrences(of: "^[0-9]+\\. ", with: "", options: .regularExpression)
                return "\(idx + 1). \(cleaned)"
            }
        }

        let output = replaced.joined(separator: "\n")
        let mutable = NSMutableString(string: textView.text)
        mutable.replaceCharacters(in: paragraphRange, with: output)
        textView.text = String(mutable)
        textView.selectedRange = NSRange(location: paragraphRange.location, length: output.count)
        notifyMutation()
    }

    private func toggleIntegerAttribute(_ key: NSAttributedString.Key, enabled: Bool) {
        guard let textView else { return }
        let range = textView.selectedRange
        let value = enabled ? NSUnderlineStyle.single.rawValue : 0

        if range.length > 0, let attributed = textView.attributedText?.mutableCopy() as? NSMutableAttributedString {
            attributed.addAttribute(key, value: value, range: range)
            textView.attributedText = attributed
            textView.selectedRange = range
        } else {
            var attrs = textView.typingAttributes
            attrs[key] = value
            textView.typingAttributes = attrs
        }

        refreshSelectionState()
        notifyMutation()
    }

    private func toggleSymbolicTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        guard let textView else { return }
        let range = textView.selectedRange

        if range.length > 0, let attributed = textView.attributedText?.mutableCopy() as? NSMutableAttributedString {
            attributed.enumerateAttribute(.font, in: range) { value, subrange, _ in
                let oldFont = (value as? UIFont) ?? UIFont.systemFont(ofSize: currentFontSize)
                var traits = oldFont.fontDescriptor.symbolicTraits
                if traits.contains(trait) {
                    traits.remove(trait)
                } else {
                    traits.insert(trait)
                }
                let descriptor = oldFont.fontDescriptor.withSymbolicTraits(traits) ?? oldFont.fontDescriptor
                let newFont = UIFont(descriptor: descriptor, size: oldFont.pointSize)
                attributed.addAttribute(.font, value: newFont, range: subrange)
            }
            textView.attributedText = attributed
            textView.selectedRange = range
        } else {
            var attrs = textView.typingAttributes
            let oldFont = (attrs[.font] as? UIFont) ?? UIFont.systemFont(ofSize: currentFontSize)
            var traits = oldFont.fontDescriptor.symbolicTraits
            if traits.contains(trait) {
                traits.remove(trait)
            } else {
                traits.insert(trait)
            }
            let descriptor = oldFont.fontDescriptor.withSymbolicTraits(traits) ?? oldFont.fontDescriptor
            attrs[.font] = UIFont(descriptor: descriptor, size: oldFont.pointSize)
            textView.typingAttributes = attrs
        }

        refreshSelectionState()
        notifyMutation()
    }

    private func notifyMutation() {
        guard let textView else { return }
        onAttributedTextMutated?(textView.attributedText ?? NSAttributedString(string: textView.text ?? ""))
    }
}

struct WorkspaceRichTextView: UIViewRepresentable {
    @Binding var textDataBase64: String
    @Binding var measuredHeight: CGFloat
    @Binding var focusedBlockID: UUID?
    let blockID: UUID
    let textSize: CGFloat
    let alignment: WorkspaceNoteTextAlignment
    let isActive: Bool
    let controller: WorkspaceRichTextController
    let onTextChange: () -> Void
    let onFocus: () -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: textSize, weight: .regular)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.lineBreakMode = .byCharWrapping
        textView.textContainer.maximumNumberOfLines = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.alwaysBounceHorizontal = false
        textView.showsHorizontalScrollIndicator = false
        textView.keyboardDismissMode = .interactive
        textView.smartDashesType = .yes
        textView.smartQuotesType = .yes
        textView.smartInsertDeleteType = .yes
        textView.autocorrectionType = .yes
        textView.autocapitalizationType = .sentences
        textView.typingAttributes = defaultTypingAttributes(fontSize: textSize)

        let alignmentValue = nsAlignment(alignment)
        textView.textAlignment = alignmentValue

        if let attributed = decodeAttributedText(from: textDataBase64) {
            textView.attributedText = normalizedAttributedTextForDisplay(attributed, fontSize: textSize)
        } else {
            textView.attributedText = NSAttributedString(string: "", attributes: defaultTypingAttributes(fontSize: textSize))
        }

        if isActive {
            controller.textView = textView
            controller.onAttributedTextMutated = { attributed in
                self.textDataBase64 = self.encodeAttributedText(attributed)
                self.onTextChange()
            }
            controller.refreshSelectionState()
        }
        context.coordinator.updateHeight(for: textView)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let alignmentValue = nsAlignment(alignment)
        if uiView.textAlignment != alignmentValue {
            uiView.textAlignment = alignmentValue
        }
        uiView.textContainer.size = CGSize(
            width: max(1, uiView.bounds.width),
            height: .greatestFiniteMagnitude
        )

        if let incoming = decodeAttributedText(from: textDataBase64),
           uiView.attributedText != incoming {
            let selected = uiView.selectedRange
            uiView.attributedText = normalizedAttributedTextForDisplay(incoming, fontSize: textSize)
            uiView.selectedRange = selected
        }

        let currentFontSize = ((uiView.typingAttributes[.font] as? UIFont)?.pointSize) ?? 0
        if abs(currentFontSize - textSize) > 0.1 {
            uiView.typingAttributes = defaultTypingAttributes(fontSize: textSize)
        }

        if isActive, controller.textView !== uiView {
            controller.textView = uiView
            controller.onAttributedTextMutated = { attributed in
                self.textDataBase64 = self.encodeAttributedText(attributed)
                self.onTextChange()
            }
            controller.refreshSelectionState()
        }

        if focusedBlockID == blockID, !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        }

        context.coordinator.updateHeight(for: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        private let parent: WorkspaceRichTextView

        init(_ parent: WorkspaceRichTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.textDataBase64 = parent.encodeAttributedText(textView.attributedText)
            parent.controller.refreshSelectionState()
            updateHeight(for: textView)
            parent.onTextChange()
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.onFocus()
            parent.controller.textView = textView
            parent.controller.refreshSelectionState()
            if parent.focusedBlockID != parent.blockID {
                parent.focusedBlockID = parent.blockID
            }
            updateHeight(for: textView)
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onFocus()
            parent.controller.textView = textView
            parent.controller.isEditing = true
            parent.controller.refreshSelectionState()
            if parent.focusedBlockID != parent.blockID {
                parent.focusedBlockID = parent.blockID
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.controller.isEditing = false
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // Smart continuation for bullets and numbered lists.
            guard text == "\n",
                  let currentText = textView.text,
                  !currentText.isEmpty
            else { return true }

            let current = currentText as NSString
            let paragraphRange = current.paragraphRange(for: range)
            let line = current.substring(with: paragraphRange)
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmed.hasPrefix("• ") {
                if trimmed == "•" || trimmed == "• " {
                    replaceText(in: textView, range: paragraphRange, with: "\n")
                    textView.selectedRange = NSRange(location: paragraphRange.location + 1, length: 0)
                    textViewDidChange(textView)
                    return false
                }

                let insertion = "\n• "
                replaceText(in: textView, range: range, with: insertion)
                textView.selectedRange = NSRange(location: range.location + insertion.count, length: 0)
                textViewDidChange(textView)
                return false
            }

            let pattern = #"^(\d+)\.\s"#
            if let match = trimmed.range(of: pattern, options: .regularExpression) {
                let numberString = String(trimmed[match]).replacingOccurrences(of: ".", with: "").trimmingCharacters(in: .whitespaces)
                if trimmed == "\(numberString)." || trimmed == "\(numberString). " {
                    replaceText(in: textView, range: paragraphRange, with: "\n")
                    textView.selectedRange = NSRange(location: paragraphRange.location + 1, length: 0)
                    textViewDidChange(textView)
                    return false
                }

                let nextNumber = (Int(numberString) ?? 0) + 1
                let insertion = "\n\(nextNumber). "
                replaceText(in: textView, range: range, with: insertion)
                textView.selectedRange = NSRange(location: range.location + insertion.count, length: 0)
                textViewDidChange(textView)
                return false
            }

            return true
        }

        private func replaceText(in textView: UITextView, range: NSRange, with replacement: String) {
            let current = textView.attributedText ?? NSAttributedString(string: "")
            let mutable = NSMutableAttributedString(attributedString: current)
            let attrs = textView.typingAttributes
            mutable.replaceCharacters(in: range, with: NSAttributedString(string: replacement, attributes: attrs))
            textView.attributedText = mutable
        }

        func updateHeight(for textView: UITextView) {
            let fallbackWidth = (textView.window?.windowScene?.screen.bounds.width ?? 390) - 40
            let fittingSize = CGSize(width: textView.bounds.width > 0 ? textView.bounds.width : fallbackWidth, height: .greatestFiniteMagnitude)
            let size = textView.sizeThatFits(fittingSize)
            let height = max(56, ceil(size.height))
            if parent.measuredHeight != height {
                DispatchQueue.main.async {
                    self.parent.measuredHeight = height
                }
            }
        }
    }

    private func decodeAttributedText(from base64: String) -> NSAttributedString? {
        guard let data = Data(base64Encoded: base64) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data)
    }

    private func encodeAttributedText(_ text: NSAttributedString) -> String {
        let data = (try? NSKeyedArchiver.archivedData(withRootObject: text, requiringSecureCoding: true)) ?? Data()
        return data.base64EncodedString()
    }

    private func nsAlignment(_ alignment: WorkspaceNoteTextAlignment) -> NSTextAlignment {
        switch alignment {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }

    private func defaultTypingAttributes(fontSize: CGFloat) -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.paragraphSpacing = 10
        return [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .regular),
            .foregroundColor: UIColor.label,
            .paragraphStyle: style
        ]
    }

    private func normalizedAttributedTextForDisplay(_ text: NSAttributedString, fontSize: CGFloat) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: text)
        let fullRange = NSRange(location: 0, length: mutable.length)
        mutable.enumerateAttributes(in: fullRange) { attrs, range, _ in
            let oldFont = (attrs[.font] as? UIFont) ?? UIFont.systemFont(ofSize: fontSize)
            if attrs[.font] == nil {
                mutable.addAttribute(.font, value: oldFont, range: range)
            }
            mutable.removeAttribute(.foregroundColor, range: range)
            mutable.addAttribute(.foregroundColor, value: UIColor.label, range: range)
        }
        return mutable
    }
}
