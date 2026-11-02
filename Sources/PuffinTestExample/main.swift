import Foundation
import PuffinTest

#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

let status = runTests([
    test("formats a title") {
        try expectEqual("Hello, Puffin", "hello, puffin".capitalized)
    },
    test("finds an item", tags: ["unit"]) {
        try expectContains(["puffin", "tern"], "puffin")
        try expectMatches("order-4821 accepted", "order-\\d+ accepted")
        try expectNotMatches("request failed", "\\b2xx\\b")
    },
])
exit(Int32(status))
