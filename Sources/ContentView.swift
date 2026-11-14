import SwiftUI

struct ContentView: View {
    @StateObject private var ble = BLESpammer()
    @StateObject private var nearby = NearbyBlast()
    @State private var running = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Blast")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)
            
            Button(running ? "STOP" : "START") {
                running.toggle()
                if running { 
                    ble.start()
                    nearby.start() 
                } else { 
                    ble.stop()
                    nearby.stop()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
