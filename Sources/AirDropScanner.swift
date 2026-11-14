import Foundation
import CoreBluetooth

struct AirDropDevice: Identifiable {
    let id: UUID
    let name: String
    let rssi: Int
}

class AirDropScanner: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var devices: [AirDropDevice] = []
    @Published var statusText: String = "Đang khởi tạo Bluetooth..."
    
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            statusText = "Đang quét AirDrop quanh đây..."
            // Quét trực tiếp vào UUID của AirDrop
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "FE9F")], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            
            // Nếu 3 giây không thấy gì, quét diện rộng (fallback)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if self.devices.isEmpty {
                    self.statusText = "Quét diện rộng (Fallback)..."
                    self.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
                }
            }
        } else if central.state == .unauthorized {
            statusText = "LỖI: Chưa cấp quyền Bluetooth!"
        } else if central.state == .poweredOff {
            statusText = "LỖI: Bluetooth đang TẮT trên máy mày!"
        } else {
            statusText = "Lỗi trạng thái BLE: \(central.state.rawValue)"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var foundName: String? = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        var isAirDrop = false
        
        if let services = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            if services.contains(CBUUID(string: "FE9F")) {
                isAirDrop = true
            }
        }
        
        if let mData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, mData.count >= 4 {
            if mData[0] == 0x4C && mData[1] == 0x00 && mData[2] == 0x05 && mData[3] == 0x12 {
                isAirDrop = true
            }
        }
        
        // Nếu không phải AirDrop chuẩn nhưng đang trong chế độ fallback, vẫn hiện (tuỳ chọn)
        if isAirDrop {
            if foundName == nil || foundName!.isEmpty {
                foundName = "AirDrop Device"
            }
            
            DispatchQueue.main.async {
                if let index = self.devices.firstIndex(where: { $0.id == peripheral.identifier }) {
                    self.devices[index] = AirDropDevice(id: peripheral.identifier, name: foundName!, rssi: RSSI.intValue)
                } else {
                    self.devices.append(AirDropDevice(id: peripheral.identifier, name: foundName!, rssi: RSSI.intValue))
                }
            }
        }
    }
}
