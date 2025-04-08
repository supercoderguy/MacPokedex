import requests
import json
import os
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
from tqdm import tqdm

def get_games_for_pokemon(pokemon_id, generation):
    # This is a simplified mapping of which Pokémon appear in which games
    # In reality, this would need to be more comprehensive and accurate
    all_games = {
        # Gen 1 games - all Gen 1 Pokémon
        "Red": range(1, 152),
        "Blue": range(1, 152),
        "Yellow": range(1, 152),
        
        # Gen 2 games - all Gen 1-2 Pokémon
        "Gold": range(1, 252),
        "Silver": range(1, 252),
        "Crystal": range(1, 252),
        
        # Gen 3 games - all Gen 1-3 Pokémon
        "Ruby": range(1, 387),
        "Sapphire": range(1, 387),
        "Emerald": range(1, 387),
        "FireRed": range(1, 387),
        "LeafGreen": range(1, 387),
        
        # Gen 4 games - all Gen 1-4 Pokémon
        "Diamond": range(1, 494),
        "Pearl": range(1, 494),
        "Platinum": range(1, 494),
        "HeartGold": range(1, 494),
        "SoulSilver": range(1, 494),
        
        # Gen 5 games - all Gen 1-5 Pokémon
        "Black": range(1, 650),
        "White": range(1, 650),
        "Black 2": range(1, 650),
        "White 2": range(1, 650),
        
        # Gen 6 games - all Gen 1-6 Pokémon
        "X": range(1, 722),
        "Y": range(1, 722),
        "Omega Ruby": range(1, 722),
        "Alpha Sapphire": range(1, 722),
        
        # Gen 7 games - all Gen 1-7 Pokémon
        "Sun": range(1, 810),
        "Moon": range(1, 810),
        "Ultra Sun": range(1, 810),
        "Ultra Moon": range(1, 810),
        "Let's Go Pikachu": range(1, 152),  # Only Gen 1
        "Let's Go Eevee": range(1, 152),    # Only Gen 1
        
        # Gen 8 games - all Gen 1-8 Pokémon
        "Sword": range(1, 899),
        "Shield": range(1, 899),
        "Brilliant Diamond": range(1, 494),  # Gen 1-4 only (remakes)
        "Shining Pearl": range(1, 494),      # Gen 1-4 only (remakes)
        "Legends: Arceus": range(1, 899),
        
        # Gen 9 games - all Gen 1-9 Pokémon
        "Scarlet": range(1, 1026),
        "Violet": range(1, 1026)
    }
    
    games = []
    for game, pokemon_range in all_games.items():
        if pokemon_id in pokemon_range:
            games.append(game)
    
    return games

def download_image(url, pokemon_id):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            image_path = f"MacPokédex/Assets/PokemonImages/{pokemon_id:03d}.png"
            with open(image_path, "wb") as f:
                f.write(response.content)
            return True
        return False
    except Exception as e:
        print(f"Error downloading image for Pokemon {pokemon_id}: {e}")
        return False

def fetch_pokemon(id):
    # Fetch basic Pokemon data
    pokemon_url = f"https://pokeapi.co/api/v2/pokemon/{id}"
    species_url = f"https://pokeapi.co/api/v2/pokemon-species/{id}"
    
    try:
        pokemon_response = requests.get(pokemon_url)
        species_response = requests.get(species_url)
        
        if pokemon_response.status_code == 200 and species_response.status_code == 200:
            pokemon_data = pokemon_response.json()
            species_data = species_response.json()
            
            # Get English flavor text
            description = next((entry['flavor_text'].replace('\n', ' ').replace('\f', ' ')
                             for entry in species_data['flavor_text_entries']
                             if entry['language']['name'] == 'en'), "No description available.")
            
            # Get generation number
            generation = int(species_data['generation']['url'].split('/')[-2])
            
            # Get games this Pokémon appears in
            games = get_games_for_pokemon(pokemon_data['id'], generation)
            
            # Use Pokemon Company's CDN
            padded_id = str(pokemon_data['id']).zfill(3)
            image_url = f"https://assets.pokemon.com/assets/cms2/img/pokedex/full/{padded_id}.png"
            
            # Store image path in a bundle-friendly format
            image_filename = f"{pokemon_data['id']:03d}.png"
            local_image_path = f"PokemonImages/{image_filename}"  # Simplified path for bundle access
            
            if download_image(image_url, pokemon_data['id']):
                print(f"Downloaded image for Pokemon {pokemon_data['id']}")
            else:
                print(f"Failed to download image for Pokemon {pokemon_data['id']}")
            
            return {
                'id': pokemon_data['id'],
                'name': pokemon_data['name'].capitalize(),
                'types': [t['type']['name'] for t in pokemon_data['types']],
                'imageUrl': local_image_path,
                'description': description,
                'generation': generation,
                'games': games
            }
    except Exception as e:
        print(f"Error fetching Pokemon {id}: {e}")
    return None

def main():
    # Fetch all 1025 Pokemon (including Pecharunt)
    pokemon_count = 1025
    
    print("Fetching Pokemon data...")
    with ThreadPoolExecutor(max_workers=10) as executor:
        pokemon_futures = [executor.submit(fetch_pokemon, i) for i in range(1, pokemon_count + 1)]
        pokemon_list = []
        
        for future in tqdm(pokemon_futures, total=pokemon_count):
            result = future.result()
            if result:
                pokemon_list.append(result)
    
    # Sort by ID
    pokemon_list.sort(key=lambda x: x['id'])
    
    # Save to JSON
    output = {'pokemon': pokemon_list}
    with open('MacPokédex/pokemon.json', 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    
    print(f"Successfully saved {len(pokemon_list)} Pokemon to pokemon.json")

if __name__ == '__main__':
    main() 