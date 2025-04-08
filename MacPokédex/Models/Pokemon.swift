import Foundation

struct Pokemon: Identifiable, Codable {
    let id: Int
    let name: String
    let types: [String]
    let imageUrl: String
    let description: String
    let generation: Int
    let games: [String]
    
    static let sample = Pokemon(
        id: 1,
        name: "Bulbasaur",
        types: ["Grass", "Poison"],
        imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
        description: "A strange seed was planted on its back at birth. The plant sprouts and grows with this Pokémon.",
        generation: 1,
        games: ["Red", "Blue", "Yellow"]
    )
} 