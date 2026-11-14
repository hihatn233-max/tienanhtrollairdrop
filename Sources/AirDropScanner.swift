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
        // Bắt buộc phải khởi tạo thì mới xin được quyền
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            statusText = "Đang quét AirDrop quanh đây..."
            // Quét TẤT CẢ thiết bị (nil), cho phép nhận trùng lặp (AllowDuplicates: true)
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
        var isAirDrop = false
        
        // 1. Kiểm tra mã nhà sản xuất (Manufacturer Data)
        if let mData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, mData.count >= 4 {
            // 0x4C 0x00 là Apple
            if mData[0] == 0x4C && mData[1] == 0x00 {
                // 0x05 0x12 là AirDrop (có thể thay đổi tùy version iOS)
                if mData[2] == 0x05 && mData[3] == 0x12 {
                    isAirDrop = true
                }
                // Mở rộng: Bắt mọi gói tin quảng bá của Apple để không bỏ sót
                if mData[2] == 0x10 || mData[2] == 0x0F || mData[2] == 0x07 {
                    // Các cục này là Nearby/Action Modal, cũng có thể gây nhiễu
                    // isAirDrop = true 
                }
            }
        }
        
        // 2. Kiểm tra UUID (Dự phòng)
        if let services = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            if services.contains(CBUUID(string: "FE9F")) {
                isAirDrop = true
            }
        }
        
        // Nếu là thiết bị AirDrop, thêm vào danh sách
        if isAirDrop {
            if foundName == nil || foundName!.isEmpty {
                foundName = "Thiết bị Apple ẩn danh"
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
