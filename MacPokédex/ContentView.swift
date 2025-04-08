import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List {
                Section("Types") {
                    ForEach(viewModel.allTypes, id: \.self) { type in
                        FilterButton(
                            title: type,
                            isSelected: viewModel.isTypeSelected(type),
                            action: { viewModel.toggleType(type) }
                        )
                    }
                }
                
                Section("Games") {
                    ForEach(viewModel.allGames, id: \.self) { game in
                        FilterButton(
                            title: game,
                            isSelected: viewModel.isGameSelected(game),
                            action: { viewModel.toggleGame(game) }
                        )
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 200)
        } detail: {
            // Content area
            VStack(spacing: 16) {
                SearchBar(text: $viewModel.searchText)
                    .padding()
                
                if viewModel.hasFilters {
                    VStack(spacing: 8) {
                        if !viewModel.selectedTypes.isEmpty {
                            FilterSection(
                                title: "Types:",
                                items: Array(viewModel.selectedTypes).sorted(),
                                onRemove: { viewModel.toggleType($0) }
                            )
                        }
                        
                        if !viewModel.selectedGames.isEmpty {
                            FilterSection(
                                title: "Games:",
                                items: Array(viewModel.selectedGames).sorted(),
                                onRemove: { viewModel.toggleGame($0) }
                            )
                        }
                        
                        Button("Clear All Filters") {
                            viewModel.clearFilters()
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.horizontal)
                }
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 200))
                    ], spacing: 16) {
                        ForEach(viewModel.filteredPokemon) { pokemon in
                            PokemonCard(pokemon: pokemon)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Pokédex")
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .accentColor : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

struct FilterSection: View {
    let title: String
    let items: [String]
    let onRemove: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .foregroundColor(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(items, id: \.self) { item in
                            FilterChip(title: item) {
                                onRemove(item)
                            }
                        }
                    }
                    .padding(.trailing, 8)
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search Pokémon", text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview {
    ContentView()
} 