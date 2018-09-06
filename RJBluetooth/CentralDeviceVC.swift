//
//  ViewController.swift
//  RJBluetooth
//
//  Created by Euijae Hong on 2018. 9. 3..
//  Copyright © 2018년 JAEJIN. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralDeviceVC : UIViewController {
    
    let connectButton : UIButton = {
        
        let b = UIButton()
        b.setTitle("연결", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.addTarget(self, action: #selector(connect), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        
        return b
        
    }()
    
    let passDateButton : UIButton = {
        
        let b = UIButton()
        b.setTitle("데이터보내기", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.addTarget(self, action: #selector(sendData), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        
        return b
        
    }()
    
    let serviceUUID = CBUUID(string: "68b696d7-320b-4402-a412-d9cee10fc6a3")
    
    var characteristic : CBMutableCharacteristic?
    var centralManager : CBCentralManager?
    var discoveredPeripheral : CBPeripheral?
    
    var peripheralManagers : CBPeripheralManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupButtons()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.peripheralManagers = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    
    
    private func setupButtons() {
        
        view.addSubview(connectButton)
        view.addSubview(passDateButton)
        
        connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        connectButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        connectButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        passDateButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        passDateButton.leadingAnchor.constraint(equalTo: connectButton.trailingAnchor).isActive = true
        passDateButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        passDateButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
    }
    
    @objc func connect(_ sender:UIButton) {
        
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        self.centralManager?.scanForPeripherals(withServices:[serviceUUID], options: options)
        
    }
    
    @objc func sendData(_ sender:UIButton) {
        
        //        let data = "안녕하세요".data(using: String.Encoding.utf8)
        //        let base64 = data?.base64EncodedData(options: .lineLength64Characters)
        
        
    }
    
    
    
    
}

//MARK:- CBCentralManagerDelegate
extension CentralDeviceVC : CBCentralManagerDelegate {
    
    
    // 센트럴 기기 스테이터스 바뀔때마다 불려지는 콜백함수
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state == .poweredOn {
            
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
            self.centralManager?.scanForPeripherals(withServices:[serviceUUID], options: options)
            
        }
        
    }
    
    
    // 1.주변 기기검색
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        self.discoveredPeripheral = peripheral
        self.discoveredPeripheral?.delegate = self
        
        self.centralManager?.stopScan()
        self.centralManager?.connect(peripheral, options: nil)
        
        print("============didDiscover============")
        print(peripheral)
        print(advertisementData)
        
    }
    
    
    // 2.centralManger.connect 를 통해서 Peripheral 기기랑 커넥션이 이루어졌을때
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        // 프리퍼럴기기의 서비스 검색
        self.discoveredPeripheral?.discoverServices([self.serviceUUID])
        
        print("============didConnect============")
        print(peripheral)
        
        
    }
    
    // 3. Peripheral 기기랑 끊어졌을때
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if let err = error {
            print("============didDisconnectPeripheral============")
            print(peripheral)
            print(err.localizedDescription)
        }
    }
    
    
    // 4. Peripheral 기기랑 커넥이 실패했을때
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect")
    }
    
    
}


//MARK:- CBPeripheralManagerDelegate & CBPeripheralDelegate
extension CentralDeviceVC : CBPeripheralManagerDelegate,CBPeripheralDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        
    }
    
    
    // 커넥션된 프리퍼럴 서비스 검색
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        self.discoveredPeripheral = peripheral
        guard let services = discoveredPeripheral?.services else { return }
        
        for service in services {
            
            print("service :",service)
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
    }
    
    // 서비스안에있는 캐릭터리스틱 검색
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("characteristic :",characteristic)
            print("characteristic.uuid : ",characteristic.uuid)
            print("characteristic.properties :",characteristic.properties)
            print("readValue :",peripheral.readValue(for: characteristic))
            
        }
        
    }
    
    
}


