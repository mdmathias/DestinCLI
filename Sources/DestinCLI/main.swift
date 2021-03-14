import ArgumentParser

struct Destincli: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A command-line tool to retrieve PvP data in Destiny",
        subcommands: [
            SearchPlayer.self,
            ActivityHistory.self,
            CharacterIds.self
        ])
    
    init() {}
}

Destincli.main()
