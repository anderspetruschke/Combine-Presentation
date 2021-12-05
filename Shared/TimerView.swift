//
//  TimerView.swift
//  Combine Presentation
//
//  Created by Anders Petruschke on 05.12.21.
//

import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    @Published var currrentTime: String = ""
    
    var timerCancellable: AnyCancellable?
    
    init() {
        currrentTime = self.formatDate(date: Date.now)
        setupTimePublisher()
    }
    
    private func setupTimePublisher() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink(receiveCompletion: { _ in },
                receiveValue: { date in
                self.currrentTime = self.formatDate(date: date) })
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct TimerView: View {
    @StateObject var viewModel = TimerViewModel()
    
    var body: some View {
        Text(viewModel.currrentTime).font(.system(size: 80))
        Spacer()
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
