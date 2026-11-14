import SwiftUI

struct ContentView: View {
    @StateObject private var scanner = AirDropScanner()
    @StateObject private var spammer = TrollSpammer()
    @State private var selectedDevice: UUID?
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Load ảnh từ URL của Bundle
                if let url = Bundle.main.url(forResource: "bg", withExtension: "jpg"),
                   let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                } else {
                    Color.red.ignoresSafeArea()
                    VStack {
                        Text("LỖI: Không tìm thấy ảnh")
                            .foregroundColor(.white)
                            .font(.headline)
                        Text("Kiểm tra lại file bg.jpg trên GitHub")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                
                // Lớp phủ đen mờ để dễ đọc chữ
                Color.black.opacity(0.6).ignoresSafeArea()
                
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
                            ProgressView().tint(.white)
                            Text(scanner.statusText)
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
