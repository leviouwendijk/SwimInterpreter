import SwimInterpreter

@main
enum SwimInterpreterTest {
    static func main() throws {
        try SwimCommandInterpreterSmoke.run()
        try SwimModalInteractionSmoke.run()
        try SwimExCommandLineSmoke.run()
    }
}
