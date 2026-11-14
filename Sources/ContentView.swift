import SwiftUI

struct ContentView: View {
    @StateObject private var scanner = AirDropScanner()
    @StateObject private var spammer = TrollSpammer()
    @State private var selectedDevice: UUID?
    
    init() {
        // Xoá nền trắng mặc định của List trên iOS 15
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 1. Ảnh nhúng trực tiếp dưới dạng Base64 (Không cần file)
                if let uiImage = UIImage(data: Data(base64Encoded: getBgBase64(), options: .ignoreUnknownCharacters)!) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                } else {
                    Color.black.ignoresSafeArea() // Fallback nếu ảnh lỗi
                }
                
                // 2. Lớp phủ đen mờ
                Color.black.opacity(0.6).ignoresSafeArea()
                
                // 3. Danh sách
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
    
    // Hàm chứa ảnh Base64
    func getBgBase64() -> String {
        return "/9j/4AAQSkZJRgABAQAAAQABAAD/4gHYSUNDX1BST0ZJTEUAAQEAAAHIAAAAAAQwAABtbnRyUkdCIFhZWiAH4AABAAEAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAACRyWFlaAAABFAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAAABRyVFJDAAABZAAAAChnVFJDAAABZAAAAChiVFJDAAABZAAAAChjcHJ0AAABjAAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAAgAAAAcAHMAUgBHAEJYWVogAAAAAAAAb6IAADj1AAADkFhZWiAAAAAAAABimQAAt4UAABjaWFlaIAAAAAAAACSgAAAPhAAAts9YWVogAAAAAAAA9tYAAQAAAADTLXBhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABtbHVjAAAAAAAAAAEAAAAMZW5VUwAAACAAAAAcAEcAbwBvAGcAbABlACAASQBuAGMALgAgADIAMAAxADb/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAf/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCwABmX/9k="
    }
}
