//
//  PeripheralController.swift
//  Bluetooth
//
//  Created by manjil on 11/08/2021.
//

import UIKit
import BaseDesignFramework
import Combine
import CoreBluetooth

class PeripheralController: BaseController {
    private var screen: CentralScreen  {
        baseView as! CentralScreen
    }
    
    var peripheralManager: CBPeripheralManager!

    var transferCharacteristic: CBMutableCharacteristic?
    var connectedCentral: CBCentral?
    var message: [Message] = [Message(message: "test", itsMine: false), Message(message: "your msg", itsMine: true)]
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
        super.viewDidLoad()
        title = "Peripheral"
        screen.tableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        peripheralManager.stopAdvertising()
        super.viewDidDisappear(animated)
    }
    // MARK: - override
    override func setupUI() {
        setUpTable()
    }
    
    override func observeEvents() {
        observeUI()
    }
}

// MARK: - Methods
extension PeripheralController {
    private func observeUI() {
        screen.send.publisher(for: .touchUpInside).receive(on: RunLoop.main).sink { [weak self] _ in
            self?.sendMessage()
        }.store(in: &baseViewModel.bag)
    }
    
    private  func sendMessage() {
        guard !screen.textView.text.isEmpty,
              let transferCharacteristic = transferCharacteristic,
              let data = screen.textView.text.data(using: .utf8) else {
             return
        }
        peripheralManager.updateValue(data, for: transferCharacteristic, onSubscribedCentrals: nil)
        message.append(Message(message: screen.textView.text, itsMine: true))
        screen.textView.text = ""
        screen.tableView.reloadData()
    }
}


extension PeripheralController: UITableViewDelegate, UITableViewDataSource {
    
    private func setUpTable() {
        screen.tableView.delegate = self
        screen.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = message[indexPath.row]
       
        if data.itsMine {
          let   cell = tableView.dequeueCell(MyMessageCell.self, for: indexPath)
            cell.label.text = data.message
            return cell
        }
        let cell  = tableView.dequeueCell(OtherMessageCell.self, for: indexPath)
        cell.label.text = data.message
        
        return cell
    }
}

extension PeripheralController: CBPeripheralManagerDelegate {
    private func setupPeripheral() {
        let transferCharacteristic = CBMutableCharacteristic(type: TransferService.characteristicUUID, properties: [.notify, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
        let transferService = CBMutableService(type: TransferService.characteristicUUID, primary: true)
        transferService.characteristics = [transferCharacteristic]
        peripheralManager.add(transferService)
        
        self.transferCharacteristic = transferCharacteristic
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [TransferService.serviceUUID]])
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var consoleLog = ""
        switch peripheral.state {
        case .poweredOff:
            consoleLog = "BLE is powered off"
        case .poweredOn:
            consoleLog = "BLE is poweredOn"
            setupPeripheral()
        case .resetting:
            consoleLog = "BLE is resetting"
        case .unauthorized:
            consoleLog = "BLE is unauthorized"
        case .unknown:
            consoleLog = "BLE is unknown"
        case .unsupported:
            consoleLog = "BLE is unsupported"
        default:
            consoleLog = "default"
        }
        print(consoleLog)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        connectedCentral = central
        sendMessage()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        connectedCentral = nil
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        sendMessage()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        requests.forEach { request in
            if let value = request.value,
               let string = String(data: value, encoding: .utf8) {
                let msg = Message(message: string, itsMine: false)
                message.append(msg)
                screen.tableView.reloadData()
            }
        }
    }
}
