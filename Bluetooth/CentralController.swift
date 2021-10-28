//
//  CentralController.swift
//  Bluetooth
//
//  Created by manjil on 10/08/2021.
//

import UIKit
import BaseDesignFramework
import CoreBluetooth

struct TransferService {
    static let serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    static let characteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    
    static let serviceTochiUUID = CBUUID(string: "55DF0001-A9B0-11E3-A5E2-000190F08F1E")
    static let characteristicWriteUUID = CBUUID(string: "55DF0002-A9B0-11E3-A5E2-000190F08F1E")
}

struct Message {
    var message: String
    var itsMine: Bool
}

class MyMessageCell: UITableViewCell {
    
    private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .lightGray
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareLayout() {
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 100),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
}

class OtherMessageCell: UITableViewCell {
    
    private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemBlue
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareLayout() {
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
}

class CentralScreen: BaseView {
    
    private(set) lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.blue.cgColor
        return textView
    }()
    
    private(set) lazy var send: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.registerCell(MyMessageCell.self)
        tableView.registerCell(OtherMessageCell.self)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func createDesign() {
        super.createDesign()
        addSubview(tableView)
        addSubview(textView)
        addSubview(send)
        
        NSLayoutConstraint.activate([
            
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            tableView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
            
            
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            textView.centerXAnchor.constraint(equalTo: centerXAnchor),
            textView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            textView.heightAnchor.constraint(equalToConstant: 100),
            
            send.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 0),
            send.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            send.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            send.centerXAnchor.constraint(equalTo: centerXAnchor),
            send.heightAnchor.constraint(equalToConstant: 40),
            
        ])
    }
}

class CentralController: BaseController {
    private var screen: CentralScreen  {
        baseView as! CentralScreen
    }
    

    // MARK: - Properties
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
    var message: [Message] = [Message(message: "test", itsMine: true), Message(message: "your msg", itsMine: false)]
    
    // MARK: - life cycle
    override func viewDidLoad() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        super.viewDidLoad()
        title = "Central"
        screen.tableView.reloadData()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        centralManager.stopScan()
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
extension CentralController {
    private func observeUI() {
        screen.send.publisher(for: .touchUpInside).receive(on: RunLoop.main).sink { [weak self] _ in
            self?.sendMessage()
        }.store(in: &baseViewModel.bag)
    }
    
    private  func sendMessage() {
        guard !screen.textView.text.isEmpty,
              let discoveredPeripheral = discoveredPeripheral,
              let transferCharacteristic = transferCharacteristic,
              let data = screen.textView.text.data(using: .utf8) else {
             return
        }
       // guard let data = "l,20,u,30".data(using: .utf8) else { return }
        discoveredPeripheral.writeValue(data, for: transferCharacteristic, type: .withoutResponse)
        message.append(Message(message: screen.textView.text, itsMine: true))
        screen.textView.text = ""
        screen.tableView.reloadData()
    }
}

extension CentralController: UITableViewDelegate, UITableViewDataSource {
    
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

extension CentralController: CBCentralManagerDelegate {
    
    private func retrievePeripheral() {
        ///Returns a list of the peripherals connected to the system whose services match a given set of criteria.
        let connectedPeripherals: [CBPeripheral] = (centralManager.retrieveConnectedPeripherals(withServices: [TransferService.serviceUUID]))
       
        
        if let connectedPeripheral = connectedPeripherals.last {
            self.discoveredPeripheral = connectedPeripheral
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            centralManager.scanForPeripherals(withServices: [TransferService.serviceUUID],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    private func clean() {
        guard let discoveredPeripheral = discoveredPeripheral,
              case .connected = discoveredPeripheral.state else { return }
         discoveredPeripheral.services?.forEach({ service in
            service.characteristics?.filter( {  $0.uuid == TransferService.characteristicUUID && $0.isNotifying } ).forEach({
                discoveredPeripheral.setNotifyValue(false, for: $0)
            })
        })
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var consoleLog = ""
        switch central.state {
        case .poweredOff:
            consoleLog = "BLE is powered off"
        case .poweredOn:
            consoleLog = "BLE is poweredOn"
            retrievePeripheral()
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if discoveredPeripheral !=  peripheral {
            discoveredPeripheral = peripheral
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("fail to connect \(peripheral)")
        if let error = error {
            print("error fail \(error.localizedDescription)")
        }
        clean()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([TransferService.serviceUUID])
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        discoveredPeripheral = nil
        retrievePeripheral()
    }
}

// MARK: - CBPeripheralManagerDelegate handler
extension CentralController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("error \(error.localizedDescription)")
            clean()
        }
        
        if let service = peripheral.services {
            service.forEach({
                peripheral.discoverCharacteristics([TransferService.characteristicUUID], for: $0)
                
            })
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            clean()
            print(error.localizedDescription)
            guard let characteristics =  service.characteristics else { return }
            for characteristic in characteristics where characteristic.uuid == TransferService.characteristicUUID {
                transferCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            clean()
        }
        guard let value = characteristic.value,
              let string = String(data: value, encoding: .utf8)  else { return }
       
        let msg = Message(message: string, itsMine: false)
        message.append(msg)
        screen.tableView.reloadData()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error \(error.localizedDescription)")
            return
        }
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == TransferService.characteristicUUID else { return }
        
        if characteristic.isNotifying {
            // Notification has started
        } else {
            // Notification has stopped, so disconnect from the peripheral
            clean()
        }
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        sendMessage()
    }
    
}
