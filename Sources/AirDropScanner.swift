import Foundation
import CoreBluetooth

struct AirDropDevice: Identifiable {
    let id: UUID
    let name: String
    let rssi: Int
}

class AirDropScanner: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var devices: [AirDropDevice] = []
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Quét mọi thiết bị, lọc bằng tay ở dưới
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Check Apple AirDrop Manufacturer Data
        if let mData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, mData.count >= 4 {
            // 0x4C, 0x00 = Apple. 0x05, 0x12 = AirDrop
            if mData[0] == 0x4C && mData[1] == 0x00 && mData[2] == 0x05 && mData[3] == 0x12 {
                let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "AirDrop User"
                
                DispatchQueue.main.async {
                    if let index = self.devices.firstIndex(where: { $0.id == peripheral.identifier }) {
                        self.devices[index] = AirDropDevice(id: peripheral.identifier, name: name, rssi: RSSI.intValue)
                    } else {
                        self.devices.append(AirDropDevice(id: peripheral.identifier, name: name, rssi: RSSI.intValue))
                    }
                }
            }
        }
    }
}
