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
        try expectGreaterThan(5, 3)
        try expectLessThan(2, 3)
        try expectAtLeast(3, 3)
        try expectAtMost(3, 3)
        try expectNotBetween(4, 1, 3)
        try expectNotClose(0.1, 0.9)
        try expectFinite(3.14)
        try expectNaN(Double.nan)
        try expectNotNaN(3.14)
        try expectInfinite(Double.infinity)
        try expectNotInfinite(3.14)
    },
])
exit(Int32(status))
