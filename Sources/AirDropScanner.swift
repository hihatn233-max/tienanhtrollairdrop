import SwiftUI

struct ContentView: View {
    @StateObject private var spammer = TrollSpammer()
    
    var body: some View {
        ZStack {
            // 1. Nền đen tuyền
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("TIENANH BLAST")
                    .font(.system(size: 32, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(spammer.isSpamming ? "ĐANG BẮN SPAM..." : "SẴN SÀNG")
                    .font(.headline)
                    .foregroundColor(spammer.isSpamming ? .green : .gray)
                
                // Nút bấm khổng lồ
                Button(action: {
                    if spammer.isSpamming {
                        spammer.stopSpam()
                    } else {
                        spammer.startSpam()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(spammer.isSpamming ? Color.red : Color.blue)
                            .frame(width: 200, height: 200)
                            .shadow(color: spammer.isSpamming ? .red : .blue, radius: 20)
                        
                        Text(spammer.isSpamming ? "STOP" : "BLAST\nALL")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
