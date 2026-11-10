import Foundation

/// Attention cues only. Every result requires review; an empty array is not approval.
public enum ReviewChecks {
    public static func warnings(original: String, proposed: String) -> [String] {
        var warnings: [String] = []
        if proposed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            warnings.append("The rewritten prompt is empty. You can copy the original transcript.")
        }
        let numbers = #"\b\d+(?:\.\d+)?\b"#
        if matches(numbers, original) != matches(numbers, proposed) {
            warnings.append("Numbers changed. Check amounts, counts, dates, and units.")
        }
        let negatives = #"\b(?:do not|must not|don't|without|never|not)\b"#
        if matches(negatives, original).count > matches(negatives, proposed).count {
            warnings.append("There are fewer negative phrases. Check that every prohibition remains.")
        }
        for qualifier in ["only", "exactly"] {
            if !matches("\\b" + qualifier + "\\b", original).isEmpty && matches("\\b" + qualifier + "\\b", proposed).isEmpty {
                warnings.append("The word ‘\(qualifier)’ was removed. Check the scope of the request.")
            }
        }
        let literalTokens = #"(?:\b[A-Za-z][A-Za-z0-9]*_[A-Za-z0-9_]+\b|(?:/|~/)[A-Za-z0-9_.\-/]+)"#
        let missing = Set(matches(literalTokens, original, caseSensitive: true)).subtracting(matches(literalTokens, proposed, caseSensitive: true))
        if !missing.isEmpty {
            warnings.append("Check changed identifiers or paths: " + missing.sorted().joined(separator: ", "))
        }
        return warnings
    }

    private static func matches(_ pattern: String, _ text: String, caseSensitive: Bool = false) -> [String] {
        let expression = try! NSRegularExpression(pattern: pattern, options: caseSensitive ? [] : [.caseInsensitive])
        return expression.matches(in: text, range: NSRange(text.startIndex..., in: text)).map {
            let value = String(text[Range($0.range, in: text)!])
            return caseSensitive ? value : value.lowercased()
        }
    }
}
