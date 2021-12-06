import SwiftUI
import Combine

// Model
// Used to decode the data fetched from PokeAPI
struct PokemonData: Codable {
    let name: String
    let id: Int
    let sprites: SpriteData
}

struct SpriteData: Codable {
    let front_default: String
}

// ViewModel
class PokemonViewModel: ObservableObject {
    // text typed into the search bar
    @Published var searchText: String = ""
    // data fetched from PokeAPI and decoded as PokemonData
    @Published var currentPokemon: PokemonData?
    
    // reference to cancellables
    // so it will persist outside of their setup functions
    // could be replaced with a set of cancellables
    var searchTextCancellable : AnyCancellable?
    var pokemonCancellable : AnyCancellable?
    
    init() {
        setupSearchTextPublisher()
    }
    
    // subscribes to the publisher of searchText
    func setupSearchTextPublisher() {
        // use $ to access publisher of searchText
        searchTextCancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { value in
            self.fetchPokemon(name: value)
        })
    }
    
    // fetches the data from the PokemonAPI
    // if Pokemon does not exist, the currentPokemon will not be updated
    public func fetchPokemon(name: String) {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(name.lowercased().filter{!$0.isWhitespace})")!
        
        pokemonCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
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

// View
struct PokemonView: View {
    // view will update when this updates
    @StateObject var viewModel = PokemonViewModel()
    
    var body: some View {
        TextField("Enter Pokemon name or ID", text: $viewModel.searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(10)
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

//extension used to capitalize the first letter of a pokemons name
extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
