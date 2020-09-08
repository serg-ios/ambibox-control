//
//  InitialViewController.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 23/10/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    private let delegate = UIApplication.shared.delegate as? AppDelegate

    private var ip: String?
    private var port: UInt32?
    private var topConstraint: NSLayoutConstraint?

    private var upView: Bool = false {
        didSet {
            topConstraint?.constant = upView ? 62 : -27.5
            UIView.animate(withDuration: upView ? 0.2 : 0.0) { [weak self] in
                self?.titleLabel.alpha = self?.upView == true ? 0.3 : 1.0
                self?.view.layoutIfNeeded()
            }
        }
    }

    private var ipOk: Bool = false {
        didSet {
            if portOk && ipOk {
                portTextField.enableOkButton()
            } else {
                portTextField.disableOkButton()
            }
        }
    }

    private var portOk: Bool = false {
        didSet {
            if portOk && ipOk {
                portTextField.enableOkButton()
            } else {
                portTextField.disableOkButton()
            }
        }
    }

    // MARK: Title Label view and constraints
    
    private lazy var titleLabelConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let safeArea = self?.view.safeAreaLayoutGuide, let titleLabel = self?.titleLabel else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: safeArea, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .top, multiplier: 1.0, constant: -27.5)
        let leadConstraint = NSLayoutConstraint(item: safeArea, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .leading, multiplier: 1.0, constant: -24.0)
        let centerXConstraint = NSLayoutConstraint(item: safeArea, attribute: .centerX, relatedBy: .equal, toItem: titleLabel, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        self?.topConstraint = topConstraint
        
        return [topConstraint, leadConstraint, centerXConstraint]
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        // TODO: - Localize
        let text = "iOS\nAmbiBox."
        var attr: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoDisplay-Semibold", size: 60.0) {
            attr = [.font: font, .foregroundColor: UIColor.white]
        }
        let attrText = NSAttributedString.init(string: text, attributes: attr)
        label.attributedText = attrText
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - IP text field view and constraints
    
    private lazy var ipTextFieldConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let safeArea = self?.view.safeAreaLayoutGuide, let titleLabel = self?.titleLabel, let ipTextField = self?.ipTextField else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: ipTextField, attribute: .top, multiplier: 1.0, constant: -57.0)
        let leadConstraint = NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: ipTextField, attribute: .leading, multiplier: 1.0, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: ipTextField, attribute: .centerX, multiplier: 1.0, constant: 0)
        return [topConstraint, leadConstraint, centerXConstraint]
    }()
    
    private lazy var ipTextField: CustomUITextField = {
        let validators:[((String?) -> String?)] = [ipTextFieldValidator]
        // TODO: - Localize
        let textField = CustomUITextField(target: nil, placeHolder: "IP", withButton: false, validators: validators)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tag = TextFieldIdentifier.ip.rawValue
        textField.clipsToBounds = true
        return textField
    }()

    private func ipTextFieldValidator(text: String?) -> String? {
        if let ipStr = text {
            do {
                let pattern = "^ *([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+) *$"
                let regex = try NSRegularExpression(pattern: pattern)
                let result = regex.matches(in: ipStr, range: NSMakeRange(0, ipStr.count))
                if let nsStr = ipStr as NSString?, let range1 = result.first?.range(at: 1), let range2 = result.first?.range(at: 2), let range3 = result.first?.range(at: 3), let range4 = result.first?.range(at: 4)  {
                    let ranges = [range1, range2, range3, range4]
                    let rangesOk = ranges.filter { (range) -> Bool in
                        if let ipFragment = Int(nsStr.substring(with: range)), case 0...255 = ipFragment {
                            return true
                        }
                        return false
                    }.count
                    if rangesOk == 4 {
                        ipOk = true
                        ip = ipStr.replacingOccurrences(of: " ", with: "")
                        return nil
                    }
                }
            } catch { }
        }
        ipOk = false
        return "0-255.0-255.0-255.0-255"
    }
    
    // MARK: - Port text field view and constraints
    
    private lazy var portTextFieldConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let safeArea = self?.view.safeAreaLayoutGuide, let ipTextField = self?.ipTextField, let portTextField = self?.portTextField else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: ipTextField, attribute: .bottom, relatedBy: .equal, toItem: portTextField, attribute: .top, multiplier: 1.0, constant: 0.0)
        let leadConstraint = NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: portTextField, attribute: .leading, multiplier: 1.0, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: portTextField, attribute: .centerX, multiplier: 1.0, constant: 0)
        return [topConstraint, leadConstraint, centerXConstraint]
    }()
    
    private lazy var portTextField: CustomUITextField = {
        let validators:[((String?) -> String?)] = [portTextFieldValidator]
        // TODO: - Localize
        let textField = CustomUITextField(target: nil, placeHolder: "Port", withButton: true, validators: validators)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tag = TextFieldIdentifier.port.rawValue
        textField.clipsToBounds = true
        textField.delegate = self
        return textField
    }()
    
    private func portTextFieldValidator(text: String?) -> String? {
        if let portStr = text {
            do {
                let pattern = "^ *([0-9]+) *$"
                let regex = try NSRegularExpression(pattern: pattern)
                let result = regex.matches(in: portStr, range: NSMakeRange(0, portStr.count))
                if let range = result.first?.range(at: 1), let nsStr = portStr as NSString?, let port = UInt32(nsStr.substring(with: range)), case 0...65535 = port {
                    portOk = true
                    self.port = port
                    return nil
                }
            } catch {
                
            }
        }
        portOk = false
        return "[0-65535]"
    }
    
    // MARK: - Custom activity indicator
    
    private lazy var activityIndicatorConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let safeArea = self?.view.safeAreaLayoutGuide, let portTextField = self?.portTextField, let activityIndicator = self?.activityIndicator else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: portTextField, attribute: .bottom, relatedBy: .equal, toItem: activityIndicator, attribute: .top, multiplier: 1.0, constant: -60.0)
        let centerXConstraint = NSLayoutConstraint(item: safeArea, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1.0, constant: 0)
        return [topConstraint, centerXConstraint]
    }()
    
    private lazy var activityIndicator: CustomActivityIndicator = {
        let activityIndicator = CustomActivityIndicator()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.clipsToBounds = true
        return activityIndicator
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate(titleLabelConstraints)
        view.addSubview(ipTextField)
        NSLayoutConstraint.activate(ipTextFieldConstraints)
        view.addSubview(portTextField)
        NSLayoutConstraint.activate(portTextFieldConstraints)
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate(activityIndicatorConstraints)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let ip = UserDefaults.standard.object(forKey: "ip") as? String, let port = UserDefaults.standard.object(forKey: "port") as? UInt32  {
            self.ip = ip
            self.port = port
            ipTextField.textField.text = ip
            portTextField.textField.text = String(port)
            portTextField.enableOkButton()
            portOk = true
            ipOk = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        delegate?.client.delegate = self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        view.endEditing(true)
    }
    
    // MARK: - Open / Close keyboard
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height {
            let landscape: Bool = view.frame.width > view.frame.height
            let ipad: Bool = UIDevice.current.userInterfaceIdiom == .pad
            let keyboardY = UIScreen.main.bounds.height - keyboardHeight
            if portTextField.frame.origin.y + portTextField.frame.height > keyboardY || (landscape && ipad) {
                upView = true
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if upView {
            upView = false
        }
    }


    // MARK: - Connection completions

    private lazy var readyConn: ((String) -> ()) = { [weak self] (readStr) in
        self?.delegate?.client.getStatusApi()
    }
    
    private lazy var endConn: ((String) -> ()) = { [weak self] (_) in
        // TODO: - Translate
        self?.activityIndicator.stop(text: "Impossible to connect")
    }
    
    // MARK: - Navigation
    
    private func presentHome() {
        UserDefaults.standard.set(ip, forKey: "ip")
        UserDefaults.standard.set(port, forKey: "port")
        let homeViewController = HomeViewController()
        homeViewController.view.backgroundColor = .black
        let navigationController = UINavigationController(rootViewController: homeViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension InitialViewController: CustomUITextFieldProtocol {
    func okButtonTouchUpInside() {
        view.endEditing(true)
        if let ip = ip, let port = port {
            activityIndicator.start()
            delegate?.connect(ip: ip, port: port, okCompletion: nil, readyCompletion: readyConn, busyCompletion: nil, endCompletion: endConn)
        }
    }
}

extension InitialViewController: SocketAPIProtocol {
    func getStatusApiOk() {
        activityIndicator.stop(text: nil)
        view.endEditing(true)
        presentHome()
    }
    
    func getStatusApiError(_ error: GetStatusApiError) {
        switch error {
        case .endConn:
            // TODO: - Translate
            activityIndicator.stop(text: "Impossible to connect")
        case .badConn:
            // TODO: - Translate
            activityIndicator.stop(text: "Connection problems")
        case .busy:
            // TODO: - Translate
            activityIndicator.stop(text: "The device is busy")
        default:
            break
        }
    }
}
