import SwiftUI

struct ContentView: View {
    @StateObject private var scanner = AirDropScanner()
    @StateObject private var spammer = TrollSpammer()
    @State private var selectedDevice: UUID?
    
    init() {
        // Ép List nền trong suốt trên iOS 15
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Ảnh nền
                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // Lớp phủ đen mờ
                Color.black.opacity(0.65).ignoresSafeArea()
                
                // Danh sách thiết bị
                List(scanner.devices) { device in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(device.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Tín hiệu: \(device.rssi) dBm")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        Button(action: {
                            if spammer.isSpamming && selectedDevice == device.id {
                                spammer.stopSpam()
                                selectedDevice = nil
                            } else {
                                selectedDevice = device.id
                                spammer.startSpam()
                            }
                        }) {
                            Text(spammer.isSpamming && selectedDevice == device.id ? "STOP" : "TROLL")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(spammer.isSpamming && selectedDevice == device.id ? Color.red : Color.blue)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.borderless)
                    }
                    // Làm trong suốt row
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
            .navigationTitle("TienAnh")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(spammer.isSpamming && selectedDevice == nil ? "Stop" : "Blast All") {
                        if spammer.isSpamming && selectedDevice == nil {
                            spammer.stopSpam()
                        } else {
                            selectedDevice = nil
                            spammer.startSpam()
                        }
                    }
                    .foregroundColor(spammer.isSpamming && selectedDevice == nil ? .red : .cyan)
                    .font(.headline)
                }
            }
            .overlay(
                Group {
                    if scanner.devices.isEmpty {
                        VStack(spacing: 10) {
                            ProgressView()
                                .tint(.white)
                            Text("Đang quét AirDrop quanh đây...")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                    }
                }
            )
        }
    }
}
