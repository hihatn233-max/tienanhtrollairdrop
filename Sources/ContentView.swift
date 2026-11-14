import SwiftUI

struct ContentView: View {
    @State private var ble = BLESpammer()
    @State private var nearby = NearbyBlast()
    @State private var running = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Blast").font(.largeTitle).bold()
            Button(running ? "STOP" : "START") {
                running.toggle()
                if running { ble.start(); nearby.start() }
                else { ble.stop() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
