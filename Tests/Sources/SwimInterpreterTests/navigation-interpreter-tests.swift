import SwimInterpreter
import Testing

private func feed(
    _ keys: [Input],
    into interpreter: inout NavigationInterpreter
) -> [NavigationInterpretation] {
    keys.map { key in
        interpreter.handle(
            key
        )
    }
}

private func chars(
    _ text: String
) -> [Input] {
    text.map { character in
        .char(
            String(character)
        )
    }
}

enum NavigationInterpreterTests {
    static let suite = TestSuite("navigation interpreter") {
        Test("single steps") { _ in
            var interpreter = NavigationInterpreter()
            try Expect.equal(
                feed(chars("jkhl"), into: &interpreter),
                [
                    .navigate(.down, count: 1),
                    .navigate(.up, count: 1),
                    .navigate(.left, count: 1),
                    .navigate(.right, count: 1),
                ],
                "hjkl"
            )
        }

        Test("counts multiply steps and show while pending") { _ in
            var interpreter = NavigationInterpreter()
            try Expect.equal(interpreter.handle(.char("2")), .pending, "first digit")
            try Expect.equal(interpreter.pendingText, "2", "pending one digit")
            try Expect.equal(interpreter.handle(.char("3")), .pending, "second digit")
            try Expect.equal(interpreter.pendingText, "23", "pending two digits")
            try Expect.equal(interpreter.handle(.char("j")), .navigate(.down, count: 23), "23j")
            try Expect.equal(interpreter.pendingText, nil, "consumed")
            try Expect.equal(
                feed(chars("10k"), into: &interpreter).last,
                .navigate(.up, count: 10),
                "zero inside a count"
            )
        }

        Test("gg, G and counted positions") { _ in
            var interpreter = NavigationInterpreter()
            try Expect.equal(interpreter.handle(.char("g")), .pending, "g prefix")
            try Expect.equal(interpreter.pendingText, "g", "g shown")
            try Expect.equal(interpreter.handle(.char("g")), .navigate(.first, count: 1), "gg")
            try Expect.equal(interpreter.handle(.char("G")), .navigate(.last, count: 1), "G")
            try Expect.equal(
                feed(chars("23G"), into: &interpreter).last,
                .navigate(.position(23), count: 1),
                "23G"
            )
            try Expect.equal(
                feed(chars("4gg"), into: &interpreter).last,
                .navigate(.position(4), count: 1),
                "4gg"
            )
        }

        Test("paging keys take counts") { _ in
            var interpreter = NavigationInterpreter()
            try Expect.equal(interpreter.handle(.control("D")), .navigate(.halfPageDown, count: 1), "ctrl-d")
            try Expect.equal(interpreter.handle(.control("U")), .navigate(.halfPageUp, count: 1), "ctrl-u")
            try Expect.equal(interpreter.handle(.control("F")), .navigate(.pageDown, count: 1), "ctrl-f")
            _ = interpreter.handle(.char("3"))
            try Expect.equal(interpreter.handle(.control("B")), .navigate(.pageUp, count: 3), "3 ctrl-b")
        }

        Test("view keys pass through and clear a pending count") { _ in
            var interpreter = NavigationInterpreter()
            for key in chars("yYdcpqmsrxt[]/") + [.enter, .space, .tab, .up, .down, .home, .end, .pageUp, .pageDown] {
                try Expect.equal(interpreter.handle(key), .unhandled, "passes \(key)")
            }

            _ = interpreter.handle(.char("5"))
            try Expect.equal(interpreter.handle(.char("y")), .unhandled, "5y is the view's y")
            try Expect.false(interpreter.isPending, "count dropped before a view key")
            try Expect.equal(interpreter.handle(.char("j")), .navigate(.down, count: 1), "count did not leak")

            _ = interpreter.handle(.char("g"))
            try Expect.equal(interpreter.handle(.enter), .unhandled, "g then enter")
            try Expect.false(interpreter.isPending, "g prefix dropped")
        }

        Test("a leading zero belongs to the view") { _ in
            var interpreter = NavigationInterpreter()
            try Expect.equal(interpreter.handle(.char("0")), .unhandled, "bare 0")
            try Expect.false(interpreter.isPending, "nothing pending")
        }

        Test("escape cancels only a pending sequence") { _ in
            var interpreter = NavigationInterpreter()
            try Expect.equal(interpreter.handle(.escape), .unhandled, "escape with nothing pending")
            _ = interpreter.handle(.char("4"))
            try Expect.equal(interpreter.handle(.escape), .cancelled, "escape cancels count")
            try Expect.equal(interpreter.pendingText, nil, "nothing shown")
        }

        Test("huge counts saturate") { _ in
            var interpreter = NavigationInterpreter()
            let result = feed(
                chars("99999999999999999999999j"),
                into: &interpreter
            ).last
            try Expect.equal(result, .navigate(.down, count: Int.max), "saturated")
        }
    }
}
