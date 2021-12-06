import SwiftUI
import Combine

// ViewModel
class TimerViewModel: ObservableObject {
    // the time string thats displayed in the app
    @Published var currrentTime: String = ""
    
    // reference to cancellable of the timer
    // so it will persist after the setup function is done
    var timerCancellable: AnyCancellable?
    
    init() {
        currrentTime = self.formatDate(date: Date.now)
        setupTimePublisher()
    }
    
    // sets up the timer publisher
    private func setupTimePublisher() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink(receiveCompletion: { completion in print(completion) },
                receiveValue: { date in
                self.currrentTime = self.formatDate(date: date) })
    }
    
    // formats a date to only show hours, minutes and seconds
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

// View
struct TimerView: View {
    // view gets updated if this changes
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
