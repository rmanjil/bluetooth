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
    
    
    private(set) lazy var reset: UIButton = {
        let label = UIButton()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setTitle("RESET", for: .normal)
        return label
        
    }()
    
    
    override func createDesign() {
        super.createDesign()
        addSubview(blueToothStatus)
        addSubview(stackView)
        
        stackView.addArrangedSubview(tableView)
        stackView.addArrangedSubview(deviceDetailHolder)
        
        deviceDetailHolder.addSubview(deviceName)
        deviceDetailHolder.addSubview(updateValue)
        deviceDetailHolder.addSubview(reset)
        
        
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
            
            updateValue.leadingAnchor.constraint(equalTo: deviceDetailHolder.leadingAnchor, constant: 4),
            updateValue.topAnchor.constraint(equalTo: deviceName.bottomAnchor, constant: 4),
            updateValue.centerXAnchor.constraint(equalTo: deviceDetailHolder.centerXAnchor),
            
            
            reset.leadingAnchor.constraint(equalTo: deviceDetailHolder.leadingAnchor, constant: 4),
            reset.topAnchor.constraint(equalTo: updateValue.bottomAnchor, constant: 4),
            reset.bottomAnchor.constraint(equalTo: deviceDetailHolder.bottomAnchor, constant: -4),
            reset.centerXAnchor.constraint(equalTo: deviceDetailHolder.centerXAnchor),
            reset.heightAnchor.constraint(equalToConstant: 40),
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
    
    lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Next", style:  .plain, target: self, action:  #selector(goNext))
        
        return button
    }()
    
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
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
            self.screen.tableView.isHidden = false
            self.screen.deviceDetailHolder.isHidden = !self.screen.tableView.isHidden
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
        cell.textLabel?.text =  remotePeripheral[indexPath.row].name ?? "No Name"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                peripheral = remotePeripheral[indexPath.row]
                peripheral.delegate = self
                centralManager.connect(peripheral, options: nil)
        screen.tableView.isHidden = true
        screen.deviceDetailHolder.isHidden = !screen.tableView.isHidden
        centralManager.stopScan()
        
        screen.deviceName.text = peripheral.name ?? "No Name"
    }
    
    
}

// MARK: - CBCentralManagerDelegate Handler
extension ListController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var consoleLog = ""
        switch central.state {
        case .poweredOff:
            consoleLog = "BLE is powered off"
        case .poweredOn:
            consoleLog = "BLE is poweredOn"
            centralManager.scanForPeripherals(withServices: nil, options: nil)
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
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("=================peripheral fail: \(peripheral)  ============")
        if let error = error {
            screen.updateValue.text = "\(peripheral.name ?? "NO_NAME") -> \(error.localizedDescription) \(Date())"
        }
        
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
            
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            
            let string = String(data: data, encoding: .utf8)
            let str = String(decoding: data, as: UTF8.self)
            let oldText = screen.updateValue.text + "\n\n"
            screen.updateValue.text = oldText + "\(characteristic.uuid)(\(characteristic.uuid.uuidString)) -> \(string ?? "Empty"), \(str) at \(Date()) "
            
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        if let error = error {
            print("characteristics  update error error: \(error.localizedDescription)")
        }
   }
    
}


