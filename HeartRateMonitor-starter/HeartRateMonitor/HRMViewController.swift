

import UIKit
import CoreBluetooth
class HRMViewController: UIViewController {
  var alreadyconnected:[CBPeripheral]! = []
  var centralManager:CBCentralManager!
  var someperipheral:CBPeripheral!
  var uuid = CBUUID(string: "81E07049-CDF5-01B1-D37A-FEB1C7DFB4D7")
  var uuid2 = CBUUID(string: "768C8184-A833-FA11-CD8B-464F66635033")
  var bp = CBUUID(string: "D43E9736-5FF1-3DE7-A426-9F86A6B2B2B6")
  let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "FFE1")
  //  var uid = CBUUID(string: "282604d10")
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Make the digits monospaces to avoid shifting when the numbers change
    
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }
  
}

extension HRMViewController:CBCentralManagerDelegate{
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state{
    case .unknown:
      print("unknown")
    case .resetting:
      print("resetting")
    case .unsupported:
      print("unsupported")
    case .unauthorized:
      print("unauthorised")
    case .poweredOff:
      print("powered off")
    case .poweredOn:
      print("powered on")
      //      centralManager.scanForPeripherals(withServices: [uuid,uuid2])
      //      centralManager.scanForPeripherals(withServices: nil)
      //      centralManager.scanForPeripherals(withServices: [bp])
      centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
    }
  }
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print(peripheral)
    //    print(advertisementData)
    
    self.someperipheral=peripheral
    if(alreadyconnected.count>0){
      if(alreadyconnected.contains(self.someperipheral)){
        someperipheral.delegate=self
        centralManager.connect(peripheral, options:nil)
        
        centralManager.stopScan()
        print("stopped scanning")
      }
    }
    else{
      alreadyconnected.append(peripheral)
    }
    if(peripheral.identifier == UUID(uuidString:"D43E9736-5FF1-3DE7-A426-9F86A6B2B2B6")){
      someperipheral.delegate=self
      centralManager.connect(peripheral, options:nil)
      
      centralManager.stopScan()
      print("stopped scanning")
    }
  }
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("connected to \(peripheral)")
    peripheral.discoverServices(nil)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            print("Async after 10 seconds")
//          self.centralManager.cancelPeripheralConnection(peripheral)
//        }
  }
  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    print("error \(error)")
  }
  
}

extension HRMViewController:CBPeripheralDelegate{
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let error = error{
      print(error)
    }
    guard let services = peripheral.services else { return }
    
    for service in services {
      print(service)
      //      print(service.characteristics ?? "characteristics are nil")
      peripheral.discoverCharacteristics(nil, for: service)
      
    }
    
  }
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else { return }
    
    for characteristic in characteristics {
      print(characteristic)
      if characteristic.properties.contains(.read) {
        print("\(characteristic.uuid): properties contains .read")
        peripheral.readValue(for: characteristic)
      }
      if characteristic.properties.contains(.notify) {
        print("\(characteristic.uuid): properties contains .notify")
        peripheral.setNotifyValue(true, for: characteristic)
      }
      if characteristic.properties.contains(.broadcast) {
        print("\(characteristic.uuid): properties contains .broadcast")
      }
      if characteristic.properties.contains(.write) {
        print("\(characteristic.uuid): properties contains .write")
      }
      
    }
  }
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    print(characteristic.uuid)
    print(characteristic.value ?? "no value")
  }
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    print("isNotifying: \(characteristic.isNotifying)")
  }
}
