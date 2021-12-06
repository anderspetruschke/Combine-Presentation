import SwiftUI
import Combine

// Model
// used to decode the data fetched from the backend
struct EmojiData: Codable {
    let emojis: [String]
}

// contains an emoji string and an unique id, used for identification in the gridview
struct Emoji: Identifiable {
    let id: Int
    let emojiString: String
}

// ViewModel
// publishes the list of emojis
class EmojiViewModel: ObservableObject {
    @Published var emojis : [Emoji] = []
    
    var emojiCancellable : AnyCancellable?
    var timerCancellable : AnyCancellable?
    
    init() {
        fetchEmojis()
        setupTimePublisher()
    }
    
    // sets up a Time Publisher that fetches emojis every 3 seconds
    private func setupTimePublisher() {
        timerCancellable = Timer.publish(every: 3, on: .main, in: .default)
            .autoconnect()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { value in self.fetchEmojis() })
    }
    
    // use the "dataTaskPublisher" of URLSesion to fetch a list of emojis from the server
    public func fetchEmojis() {
        let url = URL(string: "https://ios-emoji-picker.herokuapp.com/")!
        emojiCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: EmojiData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {_ in }, receiveValue: {emojiData in self.assignEmojis(emojiList: emojiData.emojis)})
    }
    
    //Give each Emoji an id and save it in the published emoji list
    private func assignEmojis(emojiList: [String]) {
        var i = 0
        var newEmojiList : [Emoji] = []
        emojiList.forEach() {
            emojiString in
            newEmojiList.append(Emoji(id: i, emojiString: emojiString))
            i += 1
        }
        self.emojis = newEmojiList;
    }
}

//View
struct EmojiGridView: View {
    // view updates if this object changes
    @StateObject var viewModel = EmojiViewModel()
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        // order emojis in grid
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVGrid(columns: layout, spacing: 10) {
                    ForEach(viewModel.emojis) {
                        item in
                        EmojiView(emoji: item.emojiString)
                    }
                }
                .padding(.horizontal)
            }
            // scroll to bottom if thee are new emojis
            .onChange(of: viewModel.emojis.count) { _ in
                withAnimation {
                    scrollView.scrollTo(viewModel.emojis.count - 1)
                }
            }
        }
    }
}

// used for animating Emojis
struct EmojiView: View {
    @State public var emoji: String
    @State private var scale = 0.01
    
    var body: some View {
        Text(emoji).font(.system(size: 80)).scaleEffect(scale)
            .onAppear {
                withAnimation(.spring()) {
                    scale = 1
                }
            }
    }
}

struct EmojiGridView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


