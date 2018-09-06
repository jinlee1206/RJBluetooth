//
//  ViewController.swift
//  RJBluetooth
//
//  Created by Euijae Hong on 2018. 9. 3..
//  Copyright © 2018년 JAEJIN. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralDeviceVC: UIViewController {
    
    let button : UIButton = {
        
        let b = UIButton()
        b.setTitle("송신", for: .normal)
        b.setTitleColor(.black, for: .normal)
        
        return b
        
    }()
    
    let serviceUUID = CBUUID(string:"68b696d7-320b-4402-a412-d9cee10fc6a3")
    
    var peripheralManager : CBPeripheralManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupButton()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    private func setupButton() {
        
        view.addSubview(button)
        button.frame.size = CGSize(width: 100, height: 100)
        button.center = view.center
        button.addTarget(self, action: #selector(sendText(_:)), for: .touchUpInside)
        
    }
    
    @objc func sendText(_ sender:UIButton) {
        
        
        
        
        
    }
}


extension PeripheralDeviceVC : CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        switch peripheral.state {
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            
            let service = CBMutableService(type: self.serviceUUID, primary: true)
            let properties : CBCharacteristicProperties = [.notify,.read,.write]
            let permissions : CBAttributePermissions = [.readable,.writeable]
            let characteristic = CBMutableCharacteristic(type: self.serviceUUID, properties: properties, value: nil, permissions: permissions)
            // 서비스에 캐릭터리스틱 추가
            service.characteristics = [characteristic]
            
            // 서비스 추가
            self.peripheralManager?.add(service)
            
            print("poweredOn")
        case .resetting:
            print("resetting")
        case .unauthorized:
            print("unauthorized")
        case .unknown:
            print("unknown")
        case .unsupported:
            print("unsupported")
            
        }
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        if let err = error {
            
            print("didAdd :",err.localizedDescription)
            
        } else {
            
            print("service :",service)
            // Advertising 시작
            self.peripheralManager?.startAdvertising([CBAdvertisementDataLocalNameKey :"Sample",CBAdvertisementDataServiceUUIDsKey:[service.uuid]])
        }
        
    }
    
    
    // Advertising 시작
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        print("광고 성공")
        print(peripheral.isAdvertising)
        
    }
    
}


