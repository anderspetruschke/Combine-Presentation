import SwiftUI
import Combine

// ViewModel
class JustViewModel: ObservableObject {
    // values published by Just will be stored in here
    @Published var published: Int = 0
    
    // String typed in to the Textfield
    var inputString: String = ""
    
    // a set of all cancellables
    // used so they will persist outside of the setup function
    var cancellables = Set<AnyCancellable>()
    
    public func publishWithJust() {
        // The Just publisher publishes one value and then completes successfully
        Just(inputString)
            .filter({value in Int(value) != nil})
            .map({value in Int(value)! * 2})
            .assign(to: \.published, on: self)
            .store(in: &cancellables)
    }
}

// View
struct JustView: View {
    // view updates when this object changes
    @StateObject var viewModel = JustViewModel()
    
    var body: some View {
        // bind inutString to the Textfield text
        TextField("Enter a number to double it", text: $viewModel.inputString)
            .textFieldStyle(RoundedBorderTextFieldStyle()).padding(10)
        // call method to publish
        Button("publish with just",action: viewModel.publishWithJust).padding(20)
        Text("received value: \(viewModel.published)")
        Spacer()
    }
}


struct JustView_Previews: PreviewProvider {
    static var previews: some View {
        JustView()
    }
}
