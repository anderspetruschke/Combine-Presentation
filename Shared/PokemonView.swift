//
//  PokemonView.swift
//  Combine Presentation
//
//  Created by Anders Petruschke on 03.12.21.
//

import SwiftUI
import Combine

struct PokemonData: Codable {
    let name: String
    let id: Int
    let sprites: SpriteData
}

struct SpriteData: Codable {
    let front_default: String
}

class PokemonViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var currentPokemon: PokemonData?
    
    var searchTextCancellable : AnyCancellable?
    var pokemonCancellable : AnyCancellable?
    
    init() {
        setupSearchTextPublisher()
    }
    
    func setupSearchTextPublisher() {
        searchTextCancellable = $searchText.debounce(for: .seconds(0.5), scheduler: RunLoop.main).sink(receiveCompletion: { _ in }, receiveValue: { value in
            self.fetchPokemon(name: value)
        })
    }
    
    public func fetchPokemon(name: String) {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(name.lowercased())")!
        pokemonCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: PokemonData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {_ in }, receiveValue: {pokemonData in
                self.currentPokemon = pokemonData})
    }
}

struct PokemonView: View {
    @ObservedObject var viewModel = PokemonViewModel()
    
    var body: some View {
        TextField("Enter Pokemon name or ID", text: $viewModel.searchText).textFieldStyle(RoundedBorderTextFieldStyle()).padding(10)
        VStack {
            if let pokemon = viewModel.currentPokemon {
                AsyncImage(url: URL(string: pokemon.sprites.front_default)) { phase in
                    switch phase {
                            case .success(let image):
                                image
                            .interpolation(.none)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                     
                            case .failure(let error):
                                Text(error.localizedDescription)
                     
                            case .empty:
                                Text("loading sprite...")
                     
                            @unknown default:
                                EmptyView()
                        }
                }
                HStack {
                    Text(pokemon.name.capitalizingFirstLetter())
                    Text(String(pokemon.id))
                }
            }
        }
        Spacer()
    }
}

struct PokemonView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonView()
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
