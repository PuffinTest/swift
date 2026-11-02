# PuffinTest for Swift

PuffinTest is an early Swift package for named test cases and readable expectation failures. The initial implementation provides equality, inequality, inclusive numeric range and approximate numeric checks, truth, falsehood, positive and negative string prefix and suffix checks, positive and negative collection membership, dictionary key checks, case-sensitive string-substring and error-message checks, typed error expectations, explicit failure, tags, skips, name and tag filters, per-case hooks, fail-fast mode, sequential execution, and a status code.

It uses Swift Package Manager and has not been published. The manifest uses Swift tools 5.9 or newer.

## Run the example

From this directory:

```sh
swift run puffintest-example
```

Declare cases with `test("name") { ... }`. Expectations throw errors, so mark the body `try`:

```swift
import Foundation

let cases = [
    test("greets the user") {
        try expectEqual("HELLO", "hello".uppercased())
        try expectStartsWith("puffin test", "puffin")
        try expectLengthBetween(["north", "south"], 1, 3)
        try expectLength(["north", "south"], 2)
        try expectNil(Optional<String>.none)
        _ = try expectNotNil(Optional("puffin"))
        try expectEmpty([String]())
        try expectNotEmpty(["puffin"])
        try expectContainsKey(["puffin": 1], "puffin")
        try expectNotContainsKey(["puffin": 1], "tern")
        try expectContainsText("puffin test", "test")
        try expectNotContainsText("puffin test", "penguin")
        let error = NSError(domain: "puffin", code: 1, userInfo: [NSLocalizedDescriptionKey: "missing puffin"])
        try expectErrorMessage(error, "puffin")
        try expectBetween(4.5, 0, 5)
    }
]
let status = runTests(cases)
```

Each case runs independently. Expectation reports include the case, failed check, expected and actual values when available, and the call-site file and line. Other thrown errors include their type and message. `runTests` returns `1` when a case fails or no cases match; the executable example passes that result to the process exit function.

This package is an early implementation and has not yet been verified. It uses Swift's `Equatable` protocol for equality, compares string prefixes and suffixes with Swift's case-sensitive string APIs, counts collections using their native `count`, runs synchronous cases, and has no test target yet.
