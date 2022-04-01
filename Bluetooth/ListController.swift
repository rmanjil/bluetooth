//
//  ViewController.swift
//  Bluetooth
//
//  Created by manjil on 09/08/2021.
//

import UIKit
import BaseDesignFramework
import CoreBluetooth
import Combine

enum Judgment: String {
    case notPass = "-"
    case tighteningDirectionNG = "D"
    case ok = "O"
    case lowNG = "L"
    case highNG = "H"
}

class ListView: BaseView {
    private(set) lazy var blueToothStatus: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.registerCell(UITableViewCell.self)
        tableView.tableFooterView = UIView()
        
        return tableView
    }()
    
    private(set) lazy var deviceDetailHolder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.isHidden = true
        return view
    }()
    
    private(set) lazy var deviceName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
        
    }()
    
    private(set) lazy var updateValue: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        return textView
        
    }()
    
    private(set) lazy var  valueName: UITextView = {
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isEditable = false
        return label
        
    }()
    
    private(set) lazy var reset: UIButton = {
        let label = UIButton()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setTitle("RESET", for: .normal)
        return label
        
    }()
    
    private(set) lazy var clear: UIButton = {
        let label = UIButton()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setTitle("Clear", for: .normal)
        return label
        
    }()
    
    private(set) lazy var send: UIButton = {
        let label = UIButton()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setTitle("send", for: .normal)
        return label
        
    }()
    
    private(set) lazy var stackTextsView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        return stackView
    }()
    
    private(set) lazy var stackTextView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        return stackView
    }()
    private(set) lazy var stackButtonView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private(set) lazy var text: UITextField = {
        let stackView = UITextField()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .lightGray
        stackView.textColor = .black
        return stackView
    }()
    
    
    override func createDesign() {
        super.createDesign()
        addSubview(blueToothStatus)
        addSubview(stackView)
        
        stackView.addArrangedSubview(tableView)
        stackView.addArrangedSubview(deviceDetailHolder)
        
        deviceDetailHolder.addSubview(deviceName)
        deviceDetailHolder.addSubview(stackTextsView)
        stackTextsView.addArrangedSubview(stackTextView)
        stackTextsView.addArrangedSubview(text)
        
        
        stackTextView.addArrangedSubview(updateValue)
        stackTextView.addArrangedSubview(valueName)
        deviceDetailHolder.addSubview(stackButtonView)
        stackButtonView.addArrangedSubview(reset)
        stackButtonView.addArrangedSubview(clear)
        stackButtonView.addArrangedSubview(send)
        
        
        NSLayoutConstraint.activate([
            blueToothStatus.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            blueToothStatus.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 4),
            blueToothStatus.centerXAnchor.constraint(equalTo: centerXAnchor),
            //   blueToothStatus.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: blueToothStatus.bottomAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            deviceName.leadingAnchor.constraint(equalTo: deviceDetailHolder.leadingAnchor, constant: 4),
            deviceName.topAnchor.constraint(equalTo: deviceDetailHolder.topAnchor, constant: 4),
            deviceName.centerXAnchor.constraint(equalTo: deviceDetailHolder.centerXAnchor),
            
            stackTextsView.leadingAnchor.constraint(equalTo: deviceDetailHolder.leadingAnchor, constant: 4),
            stackTextsView.topAnchor.constraint(equalTo: deviceName.bottomAnchor, constant: 4),
            stackTextsView.centerXAnchor.constraint(equalTo: deviceDetailHolder.centerXAnchor),
            
            stackButtonView.leadingAnchor.constraint(equalTo: deviceDetailHolder.leadingAnchor, constant: 4),
            stackButtonView.topAnchor.constraint(equalTo: stackTextsView.bottomAnchor, constant: 4),
            stackButtonView.bottomAnchor.constraint(equalTo: deviceDetailHolder.bottomAnchor, constant: -4),
            stackButtonView.centerXAnchor.constraint(equalTo: deviceDetailHolder.centerXAnchor),
            stackButtonView.heightAnchor.constraint(equalToConstant: 40),
            text.heightAnchor.constraint(equalToConstant: 40)
            
        ])
    }
}

class ListController: BaseController  {
    private var screen: ListView  {
        baseView as! ListView
    }
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var remotePeripheral = [CBPeripheral]()
    private var transferCharacteristic: CBCharacteristic?
    lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Next", style:  .plain, target: self, action:  #selector(goNext))
        
        return button
    }()
    let serviceTochiUUID = CBUUID(string: "55DF0001-A9B0-11E3-A5E2-000190F08F1E")
    
    var commadn = ""
    
    var response = ""
    var torque = ""
    var unit = ""
    var angele = ""
    var angleUnit = ""
    var judgment = ""
    var date = ""
    var time = ""
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [nextButton]
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        
    }
    
    
    // MARK: - override
    override func setupUI() {
        setUpTableView()
    }
    
    override func observeEvents() {
        observeScreen()
    }
}
// MARK: - Methods
extension ListController {
    private func observeScreen() {
        screen.reset.publisher(for: .touchUpInside).receive(on: RunLoop.main).sink { [weak self] _ in
            guard let self = self else { return }
            self.centralManager.scanForPeripherals(withServices: [self.serviceTochiUUID], options: nil)
            self.screen.tableView.isHidden = false
            self.screen.updateValue.text = ""
            self.screen.valueName.text = ""
            self.response = ""
            self.screen.deviceDetailHolder.isHidden = !self.screen.tableView.isHidden
        }.store(in: &baseViewModel.bag)
        
        
        screen.clear.publisher(for: .touchUpInside).receive(on: RunLoop.main).sink { [weak self] _ in
            guard let self = self else { return }
            self.screen.updateValue.text = ""
            self.screen.valueName.text = ""
            self.response = ""
        }.store(in: &baseViewModel.bag)
        
        screen.send.publisher(for: .touchUpInside).receive(on: RunLoop.main).sink { [weak self] _ in
            guard let self = self else { return }
            self.sendMessage()
        }.store(in: &baseViewModel.bag)
    }
    
    
    @objc private func goNext() {
        print("test")
        let controller = ChooseController(baseView: ChooseScreen(), baseViewModel: BaseViewModel())
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
// MARK: - TableView Delegate and DataSource Handler
extension ListController: UITableViewDataSource, UITableViewDelegate {
    
    private func setUpTableView() {
        screen.tableView.delegate = self
        screen.tableView.dataSource  = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        remotePeripheral.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueCell(UITableViewCell.self, for: indexPath)
        cell.textLabel?.text =  remotePeripheral[indexPath.row].name ?? "Unknown"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        peripheral = remotePeripheral[indexPath.row]
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
        screen.tableView.isHidden = true
        screen.deviceDetailHolder.isHidden = !screen.tableView.isHidden
        centralManager.stopScan()
        
        screen.deviceName.text = peripheral.name ?? "Unknown"
    }
    
    private  func sendMessage() {
        guard //!(screen.text.text ?? "").isEmpty,
              let discoveredPeripheral = peripheral,
              let transferCharacteristic = transferCharacteristic else {
                  return
              }
        
        
        /// no issuen
        //        if let data = "AT037,20.00,10.00\r\n".data(using: .utf8) {
        //            discoveredPeripheral.writeValue(data, for: transferCharacteristic, type: .withResponse) }
        //        /// no issuen
        //        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
        //            if let data = "AT023,123456A\r\n".data(using: .utf8) {
        //                discoveredPeripheral.writeValue(data, for: transferCharacteristic, type: .withResponse) }
        //        }
        
        
//        if let data = "AT008,02\r\n".data(using: .utf8) {
//            discoveredPeripheral.writeValue(data, for: transferCharacteristic, type: .withResponse) }
//
        //
        //        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
        
        let triggerTorque =  "AT045,11.00\r\n"
        let angle = "AT046,015,030,999\r\n"
        let test =   "AT037,30.00,20.00\r\n"
        
                  // commadn =  test //"AT023,654321A\r\n" // ////"AT008,02\r\n" //
                    if let data = test.data(using: .utf8) {
                        discoveredPeripheral.writeValue(data, for: transferCharacteristic, type: .withoutResponse)
                    }
        //        }
        //
              

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            if let data = triggerTorque.data(using: .utf8) {
                discoveredPeripheral.writeValue(data, for: transferCharacteristic, type: .withoutResponse)

            }
        }
        //

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            if let data = angle.data(using: .utf8) {
                discoveredPeripheral.writeValue(data, for: transferCharacteristic, type: .withoutResponse)

            }
        }
        
        
        
        
        
    }
    
}

// MARK: - CBCentralManagerDelegate Handler
extension ListController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var consoleLog = ""
        switch central.state {
        case .poweredOff:
            consoleLog = "BLE is powered off"
            remotePeripheral = []
            if peripheral != nil {
                peripheral.delegate = nil
                peripheral = nil
            }
            screen.tableView.reloadData()
        case .poweredOn:
            consoleLog = "BLE is poweredOn"
          
            centralManager.scanForPeripherals(withServices: [serviceTochiUUID], options: nil)
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
        screen.blueToothStatus.text = consoleLog
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if !remotePeripheral.contains(where: { $0.identifier.uuidString == peripheral.identifier.uuidString}) {
            remotePeripheral.append(peripheral)
            screen.tableView.reloadData()
        }
        if  TransferService.devices.contains(peripheral.identifier.uuidString) && self.peripheral == nil {
            self.peripheral = peripheral
            peripheral.delegate  = self
            central.connect(peripheral, options: nil)
            screen.tableView.isHidden = true
            screen.deviceDetailHolder.isHidden = !screen.tableView.isHidden
            central.stopScan()
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
         peripheral.discoverServices(nil)
       // peripheral.discoverServices([TransferService.serviceTochiUUID])
       
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("=================peripheral fail: \(peripheral)  ============")
        if let error = error {
            screen.updateValue.text = "\(peripheral.name ?? "NO_NAME") -> \(error.localizedDescription) \(Date())"
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("=================peripheral didDisconnectPeripheral: \(peripheral) \n error \(error)  ============")
    }
    
}
// MARK: - CBPeripheralDelegate
extension ListController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("service error: \(error.localizedDescription)")
        }
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("characteristics error: \(error.localizedDescription)")
        }
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic.description)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")
                transferCharacteristic = characteristic
            }
            
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            
            
            let string = String(data: data, encoding: .utf8)
            let str = String(decoding: data, as: UTF8.self)
           // let oldValue  = screen.valueName.text ?? ""
            
            response += string ?? ""
            
           // screen.valueName.text = oldValue +  (string ?? "")
            let oldText = screen.updateValue.text + "\n===============\n"
            screen.updateValue.text = oldText + "\(characteristic.uuid)(\(characteristic.uuid.uuidString)) -> data: (\(string ?? "Empty")), -data (\(str)) at \(Date()) "
            
            //            if value.count == 58 {
            //                print("all value \(value)")
            //
            //   }
            
            if response.contains("\r\n") {
                print("all value \(response)")
                let neededValue =  screen.valueName.text ?? ""
                screen.valueName.text = neededValue + "\n" + response
                let array = response.split(separator: ",")
                print(array)
                if array.count < 3 {
                    print("success")
                    screen.updateValue.text = "Command: \(commadn) \n response: \(response)"
                    response = ""
                    return
                }
//                torque = String(array[2])
//
//                unit =  String(array[3])
//                angele =  String(array[4])
//                angleUnit =  String(array[5])
//                judgment =  String(array[6])
//                date =  String(array[8])
//                time =  String(array[9])
                
                let final = judgmentValue(string: judgment)
                response = ""
            }
            
            
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        if let error = error {
            print("characteristics  update error error: \(error.localizedDescription)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error \(error.localizedDescription)")
            return
        }
        print("notify")
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == TransferService.characteristicUUID else { return }
        
        if characteristic.isNotifying {
            // Notification has started
            print("notify")
        } else {
            // Notification has stopped, so disconnect from the peripheral
            
        }
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        // sendMessage()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error {
            print("error \(error.localizedDescription)")
            return
        }
        print("didWriteValueFor \(descriptor)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error {
            print("error \(error.localizedDescription)")
            return
        }
        print("didUpdateValueFor \(descriptor)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error \(error.localizedDescription)")
            return
        }
        print(characteristic)
        print("didWriteValueFor characteristic:")
        if let data = characteristic.value {
            let value = String(data: data, encoding: .utf8) ?? ""
            print(value)
        }
        
    
    }
    
    
    func judgmentValue(string: String) -> (trque: Judgment, angele: Judgment) {
        var trque = Judgment.notPass
        var angle = Judgment.notPass
        
        if  string == "--" {
            return (trque, angle)
        }
        
        if string.uppercased() == "DN" {
            return (.tighteningDirectionNG, .tighteningDirectionNG)
        }
        
        for (index , value) in string.enumerated() {
            let char = String(value)
            if index == 0 {
                trque = checkCharcter(string: char)
            }
            if index == 1 {
                angle = checkCharcter(string: char)
            }
        }
        return (trque, angle)
    }
    
    func checkCharcter(string: String) -> Judgment {
        Judgment(rawValue: string.uppercased()) ?? .tighteningDirectionNG
    }
    
}


