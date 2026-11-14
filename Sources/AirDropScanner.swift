import Foundation
import CoreBluetooth

struct AirDropDevice: Identifiable {
    let id: UUID
    let name: String
    let rssi: Int
}

class AirDropScanner: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var devices: [AirDropDevice] = []
    @Published var statusText: String = "Đang khởi tạo..."
    
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            statusText = "Đang quét diện rộng..."
            // Quét tất cả, không lọc service UUID
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case .unauthorized:
            statusText = "LỖI: Chưa cấp quyền Bluetooth!"
        case .poweredOff:
            statusText = "LỖI: Bluetooth đang TẮT!"
        default:
            statusText = "Lỗi BLE: \(central.state.rawValue)"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var foundName: String? = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        var isAppleDevice = false
        
        // Kiểm tra Manufacturer Data: Bất kỳ gói nào bắt đầu bằng 0x4C 0x00 (Apple) là bắt hết
        if let mData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, mData.count >= 2 {
            if mData[0] == 0x4C && mData[1] == 0x00 {
                isAppleDevice = true
            }
        }
        
        if isAppleDevice {
            if foundName == nil || foundName!.isEmpty {
                // Cố gắng lấy tên, nếu ẩn danh thì ghi là Apple Device
                foundName = "Apple Device (\(peripheral.identifier.uuidString.prefix(4)))"
            }
            
            DispatchQueue.main.async {
                // Cập nhật hoặc thêm mới
                if let index = self.devices.firstIndex(where: { $0.id == peripheral.identifier }) {
                    // Chỉ cập nhật nếu tên thay đổi hoặc RSSI mạnh hơn
                    self.devices[index] = AirDropDevice(id: peripheral.identifier, name: foundName!, rssi: RSSI.intValue)
                } else {
                    self.devices.append(AirDropDevice(id: peripheral.identifier, name: foundName!, rssi: RSSI.intValue))
                }
            }
        }
    }
}
