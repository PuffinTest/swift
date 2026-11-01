import Foundation

/// A named synchronous test case with optional tags and a skip reason.
public struct TestCase {
    public let name: String
    public let tags: Set<String>
    public let skipReason: String?
    let body: () throws -> Void

    public init(
        _ name: String,
        tags: Set<String> = [],
        skipReason: String? = nil,
        body: @escaping () throws -> Void
    ) {
        precondition(!name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "test name must not be blank")
        precondition(tags.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }, "tags must be nonempty")
        precondition(skipReason == nil || !skipReason!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "skipReason must not be blank")
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.tags = Set(tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
        self.skipReason = skipReason
        self.body = body
    }
}

/// Create a named test case.
public func test(
    _ name: String,
    tags: Set<String> = [],
    skipReason: String? = nil,
    body: @escaping () throws -> Void
) -> TestCase {
    TestCase(name, tags: tags, skipReason: skipReason, body: body)
}

private struct ExpectationFailure: Error, CustomStringConvertible {
    let message: String
    let expected: String?
    let actual: String?
    let file: String
    let line: UInt
    var description: String { message }
}

private func failure(
    _ message: String,
    expected: String? = nil,
    actual: String? = nil,
    file: StaticString,
    line: UInt
) -> ExpectationFailure {
    ExpectationFailure(message: message, expected: expected, actual: actual, file: "\(file)", line: line)
}

/// Fail unless `actual` has a length in the inclusive range.
public func expectLengthBetween<C: Collection>(
    _ actual: C,
    _ minimum: Int,
    _ maximum: Int,
    _ message: String? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
) throws {
    guard minimum >= 0, maximum >= 0, minimum <= maximum else {
        throw failure("length bounds must be nonnegative and ordered", file: file, line: line)
    }
    let actualLength = actual.count
    guard actualLength >= minimum, actualLength <= maximum else {
        throw failure(message ?? "Value length is outside the expected range", expected: "length between \(minimum) and \(maximum), inclusive", actual: String(actualLength), file: file, line: line)
    }
}

/// Fail unless `actual` equals `expected`.
public func expectEqual<T: Equatable>(
    _ actual: T,
    _ expected: T,
    _ message: String? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
) throws {
    guard actual == expected else {
        throw failure(message ?? "Values are not equal", expected: String(describing: expected), actual: String(describing: actual), file: file, line: line)
    }
}

/// Fail unless `actual` differs from `unexpected`.
public func expectNotEqual<T: Equatable>(
    _ actual: T,
    _ unexpected: T,
    _ message: String? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
) throws {
    guard actual != unexpected else {
        throw failure(message ?? "Values are unexpectedly equal", expected: "different from \(unexpected)", actual: String(describing: actual), file: file, line: line)
    }
}

/// Fail unless `actual` starts with `prefix`.
public func expectStartsWith(
    _ actual: String,
    _ prefix: String,
    _ message: String? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
) throws {
    guard actual.hasPrefix(prefix) else {
        throw failure(message ?? "Text does not start with the expected prefix", expected: "text starting with \(prefix)", actual: actual, file: file, line: line)
    }
}

/// Fail unless `actual` ends with `suffix`.
public func expectEndsWith(
    _ actual: String,
    _ suffix: String,
    _ message: String? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
) throws {
    guard actual.hasSuffix(suffix) else {
        throw failure(message ?? "Text does not end with the expected suffix", expected: "text ending with \(suffix)", actual: actual, file: file, line: line)
    }
}

/// Fail if `actual` ends with `suffix`.
public func expectNotEndsWith(
    _ actual: String,
    _ suffix: String,
    _ message: String? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
) throws {
    guard !actual.hasSuffix(suffix) else {
        throw failure(message ?? "Text unexpectedly ends with the suffix", expected: "text not ending with \(suffix)", actual: actual, file: file, line: line)
    }
}

/// Fail if `actual` starts with `prefix`.
public func expectNotStartsWith(
    _ actual: String,
    _ prefix: String,
    _ message: String? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
) throws {
    guard !actual.hasPrefix(prefix) else {
        throw failure(message ?? "Text unexpectedly starts with the prefix", expected: "text not starting with \(prefix)", actual: actual, file: file, line: line)
    }
}

/// Fail unless two numbers are close under relative and absolute tolerances.
public func expectClose(
    _ actual: Double,
    _ expected: Double,
    relTolerance: Double = 1e-9,
    absTolerance: Double = 0,
    file: StaticString = #fileID,
    line: UInt = #line
) throws {
    guard relTolerance.isFinite, absTolerance.isFinite, relTolerance >= 0, absTolerance >= 0 else {
        throw failure("tolerances must be finite and nonnegative", file: file, line: line)
    }
    let difference = abs(actual - expected)
    let scale = max(abs(actual), abs(expected))
    let close = actual == expected || (actual.isFinite && expected.isFinite &&
        (difference <= absTolerance || (scale != 0 && difference / scale <= relTolerance)))
    guard close else {
        throw failure("Values are not close", expected: String(expected), actual: String(actual), file: file, line: line)
    }
}

/// Fail unless `actual` is between `minimum` and `maximum`, inclusive.
public func expectBetween(
    _ actual: Double,
    _ minimum: Double,
    _ maximum: Double,
    file: StaticString = #fileID,
    line: UInt = #line
) throws {
    guard !minimum.isNaN, !maximum.isNaN, minimum <= maximum else {
        throw failure("minimum must be less than or equal to maximum", file: file, line: line)
    }
    guard actual >= minimum && actual <= maximum else {
        throw failure("Value is outside the expected range", expected: "between \(minimum) and \(maximum), inclusive", actual: String(actual), file: file, line: line)
    }
}

/// Fail unless `actual` is true.
public func expectTrue(_ actual: Bool, _ message: String? = nil, file: StaticString = #fileID, line: UInt = #line) throws {
    guard actual else {
        throw failure(message ?? "Expected true", expected: "true", actual: "false", file: file, line: line)
    }
}

/// Fail unless `actual` is false.
public func expectFalse(_ actual: Bool, _ message: String? = nil, file: StaticString = #fileID, line: UInt = #line) throws {
    guard !actual else {
        throw failure(message ?? "Expected false", expected: "false", actual: "true", file: file, line: line)
    }
}

/// Fail unless `actual` is `nil`.
public func expectNil<T>(_ actual: T?, _ message: String? = nil, file: StaticString = #fileID, line: UInt = #line) throws {
    guard case .none = actual else {
        throw failure(message ?? "Expected nil", expected: "nil", actual: String(describing: actual), file: file, line: line)
    }
}

/// Fail unless `actual` contains a value, returning that value.
public func expectNotNil<T>(_ actual: T?, _ message: String? = nil, file: StaticString = #fileID, line: UInt = #line) throws -> T {
    guard let value = actual else {
        throw failure(message ?? "Expected a non-nil value", expected: "non-nil", actual: "nil", file: file, line: line)
    }
    return value
}

/// Fail unless `actual` has no elements.
public func expectEmpty<C: Collection>(_ actual: C, _ message: String? = nil, file: StaticString = #fileID, line: UInt = #line) throws {
    guard actual.isEmpty else {
        throw failure(message ?? "Expected an empty value", expected: "0 items", actual: String(actual.count), file: file, line: line)
    }
}

/// Fail unless `actual` has at least one element.
public func expectNotEmpty<C: Collection>(_ actual: C, _ message: String? = nil, file: StaticString = #fileID, line: UInt = #line) throws {
    guard !actual.isEmpty else {
        throw failure(message ?? "Expected a non-empty value", expected: "at least 1 item", actual: "0", file: file, line: line)
    }
}

/// Fail unless `item` occurs in `collection`.
public func expectContains<C: Collection>(
    _ collection: C,
    _ item: C.Element,
    _ message: String? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
) throws where C.Element: Equatable {
    guard collection.contains(item) else {
        throw failure(message ?? "Item is not present in the collection", expected: "a collection containing \(item)", actual: String(describing: collection), file: file, line: line)
    }
}

/// Fail if `item` occurs in `collection`.
public func expectNotContains<C: Collection>(
    _ collection: C,
    _ item: C.Element,
    _ message: String? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
) throws where C.Element: Equatable {
    guard !collection.contains(item) else {
        throw failure(message ?? "Item is unexpectedly present in the collection", expected: "a collection without \(item)", actual: String(describing: collection), file: file, line: line)
    }
}

/// Fail unless `key` is present in `dictionary`.
public func expectContainsKey<K: Hashable, V>(
    _ dictionary: [K: V],
    _ key: K,
    _ message: String? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
) throws {
    guard dictionary.keys.contains(key) else {
        throw failure(message ?? "Key is not present in the dictionary", expected: "a dictionary containing key \(key)", actual: String(describing: dictionary), file: file, line: line)
    }
}

/// Fail if `key` is present in `dictionary`.
public func expectNotContainsKey<K: Hashable, V>(
    _ dictionary: [K: V],
    _ key: K,
    _ message: String? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
) throws {
    guard !dictionary.keys.contains(key) else {
        throw failure(message ?? "Key is unexpectedly present in the dictionary", expected: "a dictionary without key \(key)", actual: String(describing: dictionary), file: file, line: line)
    }
}

/// Require `body` to throw an error of type `E` and return it.
public func expectThrows<E: Error>(
    _ type: E.Type,
    file: StaticString = #fileID,
    line: UInt = #line,
    _ body: () throws -> Void
) throws -> E {
    do {
        try body()
    } catch let error as E {
        return error
    } catch {
        throw failure("Expected \(type), got \(Swift.type(of: error))", expected: String(describing: type), actual: String(describing: Swift.type(of: error)), file: file, line: line)
    }
    throw failure("Expected \(E.self) to be thrown", expected: String(describing: E.self), actual: "no error", file: file, line: line)
}

/// Explicitly fail the current test case.
public func fail(_ message: String = "Explicit failure", file: StaticString = #fileID, line: UInt = #line) throws {
    throw failure(message, file: file, line: line)
}

/// Run matching cases sequentially and return 0 on success or 1 on failure.
public func runTests(
    _ cases: [TestCase],
    filter: String? = nil,
    tag: String? = nil,
    failFast: Bool = false,
    beforeEach: (() throws -> Void)? = nil,
    afterEach: (() throws -> Void)? = nil
) -> Int {
    let selected = cases.filter { item in
        (filter == nil || item.name.localizedCaseInsensitiveContains(filter!)) &&
            (tag == nil || item.tags.contains { $0.caseInsensitiveCompare(tag!) == .orderedSame })
    }
    var passed = 0
    var failed = 0
    var skipped = 0
    var processed = 0
    for item in selected {
        processed += 1
        if let reason = item.skipReason {
            print("SKIP  \(item.name) (\(reason))")
            skipped += 1
            continue
        }
        var setupSucceeded = false
        var phase = "beforeEach"
        var caseFailed = false
        do {
            try beforeEach?()
            setupSucceeded = true
            phase = "test"
            try item.body()
            phase = "afterEach"
            try afterEach?()
            print("PASS  \(item.name)")
            passed += 1
        } catch {
            failed += 1
            caseFailed = true
            printFailure(item, error: error, phase: phase)
        }
        if setupSucceeded && phase != "afterEach" && afterEach != nil && caseFailed {
            do {
                try afterEach?()
            } catch {
                failed += 1
                printFailure(item, error: error, phase: "afterEach")
            }
        }
        if caseFailed && failFast { break }
    }
    print("\n\(processed) processed: \(passed) passed, \(failed) failed, \(skipped) skipped")
    guard !selected.isEmpty else {
        if let filter, let tag { print("No test cases matched name '\(filter)' and tag '\(tag)'") }
        else if let filter { print("No test cases matched name '\(filter)'") }
        else if let tag { print("No test cases matched tag '\(tag)'") }
        else { print("No test cases were found") }
        return 1
    }
    return failed == 0 ? 0 : 1
}

private func printFailure(_ item: TestCase, error: Error, phase: String) {
    print("FAIL  \(item.name)\(phase == "test" ? "" : " (\(phase))")")
    if let error = error as? ExpectationFailure {
        print("      \(error.message)")
        if let expected = error.expected { print("      Expected: \(expected)") }
        if let actual = error.actual { print("      Actual:   \(actual)") }
        print("      \(error.file):\(error.line)")
    } else {
        print("      \(type(of: error)): \(error)")
    }
}
