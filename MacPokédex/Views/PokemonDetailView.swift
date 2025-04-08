import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            // Title bar
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                .padding()
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Pokemon Image
                    RemoteImage(url: pokemon.imageUrl)
                        .frame(width: 300, height: 300)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                        .padding()
                        .clipped()
                    
                    // Pokemon Info
                    VStack(alignment: .leading, spacing: 16) {
                        // Name and Number
                        HStack {
                            Text(pokemon.name)
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                            Text("#\(String(format: "%04d", pokemon.id))")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        
                        // Types
                        HStack {
                            ForEach(pokemon.types, id: \.self) { type in
                                Text(type.capitalized)
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        // Description
                        Text("Description")
                            .font(.headline)
                            .padding(.top)
                        Text(pokemon.description)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    PokemonDetailView(pokemon: Pokemon.sample)
} 