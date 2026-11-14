import SwiftUI

struct ContentView: View {
    @StateObject private var spammer = TrollSpammer()
    
    var body: some View {
        ZStack {
            // Ảnh nền nhúng Base64 (Đéo cần file ngoài)
            if let uiImage = UIImage(data: Data(base64Encoded: getBgBase64(), options: .ignoreUnknownCharacters)!) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // Lớp phủ đen
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("TIENANH BLAST")
                    .font(.system(size: 32, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(spammer.isSpamming ? "ĐANG BẮN SPAM..." : "SẴN SÀNG")
                    .font(.headline)
                    .foregroundColor(spammer.isSpamming ? .green : .gray)
                
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
    
    func getBgBase64() -> String {
        return "/9j/4AAQSkZJRgABAQAAAQABAAD/4gHYSUNDX1BST0ZJTEUAAQEAAAHIAAAAAAQwAABtbnRyUkdCIFhZWiAH4AABAAEAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAACRyWFlaAAABFAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAAABRyVFJDAAABZAAAAChnVFJDAAABZAAAAChiVFJDAAABZAAAAChjcHJ0AAABjAAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAAgAAAAcAHMAUgBHAEJYWVogAAAAAAAAb6IAADj1AAADkFhZWiAAAAAAAABimQAAt4UAABjaWFlaIAAAAAAAACSgAAAPhAAAts9YWVogAAAAAAAA9tYAAQAAAADTLXBhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABtbHVjAAAAAAAAAAEAAAAMZW5VUwAAACAAAAAcAEcAbwBvAGcAbABlACAASQBuAGMALgAgADIAMAAxADb/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAf/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCwABmX/9k="
    }
}
