import SwiftUI

struct PokemonCard: View {
    let pokemon: Pokemon
    @State private var isShowingDetail = false
    
    var body: some View {
        Button {
            isShowingDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                RemoteImage(url: pokemon.imageUrl)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .clipped()
                
                Text(pokemon.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    ForEach(pokemon.types, id: \.self) { type in
                        Text(type.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
                
                Text(pokemon.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isShowingDetail) {
            PokemonDetailView(pokemon: pokemon)
                .frame(minWidth: 600, minHeight: 700)
        }
    }
} 