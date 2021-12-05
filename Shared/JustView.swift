//
//  JustView.swift
//  Combine Presentation
//
//  Created by Anders Petruschke on 05.12.21.
//

import SwiftUI
import Combine

class JustViewModel: ObservableObject {
    @Published var inputString: String = ""
    @Published var published: Int = 0
    
    var cancellables = Set<AnyCancellable>()
    
    public func publishWithJust() {
        Just(inputString)
            .filter({value in Int(value) != nil})
            .map({value in Int(value)! * 2})
            .assign(to: \.published, on: self)
            .store(in: &cancellables)
    }
}

struct JustView: View {
    @StateObject var viewModel = JustViewModel()
    
    var body: some View {
        TextField("Enter a number to double it", text: $viewModel.inputString)
            .textFieldStyle(RoundedBorderTextFieldStyle()).padding(10)
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
