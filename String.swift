import Foundation

extension String {
    func isTrimmedEmpty() -> Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
