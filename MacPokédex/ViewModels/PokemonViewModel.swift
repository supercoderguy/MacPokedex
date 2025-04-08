import Foundation

struct PokemonResponse: Codable {
    let pokemon: [Pokemon]
}

@MainActor
class PokemonViewModel: ObservableObject {
    @Published var pokemon: [Pokemon] = []
    @Published var searchText: String = ""
    @Published var selectedTypes: Set<String> = []
    @Published var selectedGames: Set<String> = []
    
    var filteredPokemon: [Pokemon] {
        var filtered = pokemon
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        if !selectedTypes.isEmpty {
            filtered = filtered.filter { pokemon in
                !selectedTypes.isDisjoint(with: Set(pokemon.types))
            }
        }
        
        if !selectedGames.isEmpty {
            filtered = filtered.filter { pokemon in
                !selectedGames.isDisjoint(with: Set(pokemon.games))
            }
        }
        
        return filtered
    }
    
    init() {
        loadPokemon()
    }
    
    private func loadPokemon() {
        guard let url = Bundle.main.url(forResource: "pokemon", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let response = try? JSONDecoder().decode(PokemonResponse.self, from: data) else {
            pokemon = [Pokemon.sample]
            return
        }
        
        pokemon = response.pokemon
    }
    
    var allTypes: [String] {
        Array(Set(pokemon.flatMap { $0.types })).sorted()
    }
    
    var allGames: [String] {
        Array(Set(pokemon.flatMap { $0.games })).sorted()
    }
    
    func toggleType(_ type: String) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
    }
    
    func toggleGame(_ game: String) {
        if selectedGames.contains(game) {
            selectedGames.remove(game)
        } else {
            selectedGames.insert(game)
        }
    }
    
    func isTypeSelected(_ type: String) -> Bool {
        selectedTypes.contains(type)
    }
    
    func isGameSelected(_ game: String) -> Bool {
        selectedGames.contains(game)
    }
    
    var hasFilters: Bool {
        !selectedTypes.isEmpty || !selectedGames.isEmpty
    }
    
    func clearFilters() {
        selectedTypes.removeAll()
        selectedGames.removeAll()
    }
}