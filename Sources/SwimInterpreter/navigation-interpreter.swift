/// A navigation step for read-only views: lists, menus and documents.
public enum NavigationStep:
    Sendable,
    Codable,
    Hashable
{
    case up
    case down
    case left
    case right
    case first
    case last
    /// A one-based position, from `23G` or `23gg`.
    case position(Int)
    case pageUp
    case pageDown
    case halfPageUp
    case halfPageDown
}

public enum NavigationInterpretation:
    Sendable,
    Codable,
    Hashable
{
    case pending
    case navigate(
        NavigationStep,
        count: Int
    )
    case cancelled
    case unhandled
}

/// The motion subset of the normal-mode grammar, for views that are not editors.
///
/// Counts, `gg`, `G`, `h j k l`, `ctrl-d ctrl-u ctrl-f ctrl-b`. Every other key is
/// `.unhandled` and clears a pending sequence, so a view's own keys (`y`, `q`,
/// Enter) are never multiplied or swallowed. Pending counts do not time out.
public struct NavigationInterpreter:
    Sendable,
    Codable,
    Hashable
{
    private var commands: CommandInterpreter

    public init() {
        commands = CommandInterpreter(
            timing:
                .init(
                    sequenceTimeoutNanoseconds: .max
                )
        )
    }

    public var isPending: Bool {
        commands.state.isPending
    }

    /// The typed prefix while a sequence is pending, such as `23` or `g`.
    public var pendingText: String? {
        let state = commands.state

        guard state.isPending else {
            return nil
        }

        return (state.count.map(String.init) ?? "")
            + (state.pendingPrefix == .g ? "g" : "")
    }

    public mutating func reset() {
        commands.reset()
    }

    public mutating func handle(
        _ key: Input
    ) -> NavigationInterpretation {
        let count = commands.state.count

        switch key {
        case .escape:
            guard isPending else {
                return .unhandled
            }

            reset()
            return .cancelled

        case .control("D"):
            return finish(
                .halfPageDown,
                count: count
            )

        case .control("U"):
            return finish(
                .halfPageUp,
                count: count
            )

        case .control("F"):
            return finish(
                .pageDown,
                count: count
            )

        case .control("B"):
            return finish(
                .pageUp,
                count: count
            )

        case .char(let character):
            guard accepts(
                character,
                count: count
            ) else {
                reset()
                return .unhandled
            }

        default:
            reset()
            return .unhandled
        }

        switch commands.handle(
            key,
            atNanoseconds: 0
        ) {
        case .pending:
            return .pending

        case .cancelled:
            return .cancelled

        case .unhandled,
             .command(.operate),
             .command(.paste),
             .command(.edit),
             .command(.replaceCharacters),
             .command(.joinLines),
             .command(.toggleCase):
            reset()
            return .unhandled

        case .command(.motion(let motion, let resolvedCount)):
            guard let step = step(
                for: motion,
                explicitCount: count
            ) else {
                return .unhandled
            }

            if case .position = step {
                return .navigate(
                    step,
                    count: 1
                )
            }

            return .navigate(
                step,
                count: max(
                    1,
                    resolvedCount
                )
            )
        }
    }

    private func accepts(
        _ character: String,
        count: Int?
    ) -> Bool {
        switch character {
        case "1", "2", "3", "4", "5", "6", "7", "8", "9":
            return true

        // A leading 0 belongs to the view; after digits it extends the count.
        case "0":
            return count != nil

        case "h", "j", "k", "l", "g", "G":
            return true

        default:
            return false
        }
    }

    private func step(
        for motion: Motion,
        explicitCount: Int?
    ) -> NavigationStep? {
        switch motion {
        case .up:
            return .up

        case .down:
            return .down

        case .left:
            return .left

        case .right:
            return .right

        case .documentStart:
            return explicitCount.map(
                NavigationStep.position
            ) ?? .first

        case .documentEnd:
            return explicitCount.map(
                NavigationStep.position
            ) ?? .last

        case .wordBackward,
             .wordForward,
             .wordEnd,
             .lineStart,
             .lineEnd,
             .pageUp,
             .pageDown:
            return nil
        }
    }

    private mutating func finish(
        _ step: NavigationStep,
        count: Int?
    ) -> NavigationInterpretation {
        reset()

        return .navigate(
            step,
            count: max(
                1,
                count ?? 1
            )
        )
    }
}
