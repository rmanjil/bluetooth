//
//  ChooseController.swift
//  Bluetooth
//
//  Created by manjil on 10/08/2021.
//

import UIKit
import BaseDesignFramework
import Combine

class ChooseScreen: BaseView {
    
    private(set) lazy var central: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("central", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blue.cgColor
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    private(set) lazy var peripheral: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blue.cgColor
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("peripheral", for: .normal)
        return button
    }()
    private(set) lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 4
        stack.axis = .vertical
        return stack
    }()
    
    override func createDesign() {
        super.createDesign()
        addSubview(stack)
        stack.addArrangedSubview(central)
        stack.addArrangedSubview(peripheral)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
           
            central.heightAnchor.constraint(equalToConstant: 100),
            central.widthAnchor.constraint(equalToConstant: 100),
            peripheral.heightAnchor.constraint(equalToConstant: 100),
            peripheral.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
}
class ChooseController: BaseController {
    private var screen: ChooseScreen  {
        baseView as! ChooseScreen
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    // MARK: - Override
    override func observeEvents() {
        observeScreen()
    }
}

// MARK: - Method
extension ChooseController {
    private  func observeScreen() {
        screen.central.publisher(for: .touchUpInside).receive(on: RunLoop.main).sink(receiveValue: { [weak self] _ in
            self?.gotoCentral()
        }).store(in: &baseViewModel.bag)
        
        
        screen.peripheral.publisher(for: .touchUpInside).receive(on: RunLoop.main).sink(receiveValue: { [weak self] _ in
            self?.gotoPeripheral()
        }).store(in: &baseViewModel.bag)
    }
    
    private func gotoCentral() {
        let controller = CentralController(baseView: CentralScreen(), baseViewModel: BaseViewModel())
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func  gotoPeripheral() {
        let controller = PeripheralController(baseView: CentralScreen(), baseViewModel: BaseViewModel())
        navigationController?.pushViewController(controller, animated: true)
    }
}





class PeripheralController: BaseController {
    
}
