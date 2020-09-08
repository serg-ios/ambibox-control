//
//  CustomUITextField.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 23/10/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit

public enum TextFieldIdentifier: Int {
    case ip
    case port
}

protocol CustomUITextFieldProtocol: class {
    func okButtonTouchUpInside()
}

class CustomUITextField: UIView {
    
    override var tag: Int {
        didSet {
            textField.tag = tag
        }
    }
    
    weak var delegate: CustomUITextFieldProtocol?

    private var placeholderText: String?
    private var validators: [((String?) -> String?)]?
    
    // MARK: - Stack view 1
    
    private lazy var stackView1Constraints: [NSLayoutConstraint] = { [weak self] in
        guard let parentView = self, let stackView1 = self?.stackView1 else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: parentView, attribute: .top, relatedBy: .equal, toItem: stackView1, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: parentView, attribute: .bottom, relatedBy: .equal, toItem: stackView1, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let leadConstraint = NSLayoutConstraint(item: parentView, attribute: .leading, relatedBy: .equal, toItem: stackView1, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let trailConstraint = NSLayoutConstraint(item: parentView, attribute: .trailing, relatedBy: .equal, toItem: stackView1, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        return [topConstraint, bottomConstraint, leadConstraint, trailConstraint]
    }()
    
    private lazy var stackView1: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()
    
    // MARK: - Stack view 2
    
    private lazy var stackView2: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Text field view and constraints
    
    private lazy var textFieldConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let textField = self?.textField else {
            return []
        }
        let heightConstraint = NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0)
        return [heightConstraint]
    }()
    
    public lazy var textField: UITextField = { [weak self] in
        let textField = UITextField()
        var placeholderAttr: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoText-Bold", size: 20.0) {
            placeholderAttr = [.font: font, .foregroundColor: UIColor.white]
        }
        let attrPlaceholder = NSAttributedString(string: self?.placeholderText ?? "", attributes: placeholderAttr)
        var textFieldAttributes: [NSAttributedString.Key:Any] = [:]
        if let font = UIFont(name: "SanFranciscoText-Regular", size: 18.0) {
            textFieldAttributes = [.font: font, .foregroundColor: UIColor.white]
        }
        textField.defaultTextAttributes = textFieldAttributes
        textField.attributedPlaceholder = attrPlaceholder
        textField.tintColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: - Underline view and constraints
    
    private lazy var underlineViewConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let underlineView = self?.underlineView, let textField = self?.textField, let parentView = self else {
            return []
        }
        let heightConstraint = NSLayoutConstraint(item: underlineView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0)
        return [heightConstraint]
    }()
    
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Info label view and constraints

    private lazy var infoLabelConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let underlineView = self?.infoLabel else {
            return []
        }
        let heightConstraint = NSLayoutConstraint(item: underlineView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 16.0)
        return [heightConstraint]
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Info label methods
    
    func showInfo(_ text: String) {
        var attr: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoText-Regular", size: 12.0) {
            attr = [.font: font, .foregroundColor: UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0)]
        }
        let attrText = NSAttributedString.init(string: text, attributes: attr)
        infoLabel.attributedText = attrText
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.infoLabel.alpha = 1
        }
    }
    
    func hideInfo() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.infoLabel.alpha = 0
        }
    }
    
    // MARK: - Ok button view, constraints and selectors
    
    lazy var okButtonConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let okButton = self?.okButton, let parentView = self, let textField = self?.textField else {
            return []
        }
        let widthConstraint = NSLayoutConstraint(item: okButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 78.0)
        let heightConstraint = NSLayoutConstraint(item: okButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44.0)
        return [widthConstraint, heightConstraint]
    }()
    
    lazy var okButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.init(white: 1.0, alpha: 0.2)
        var attr: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoText-Semibold", size: 18.0) {
            attr = [.font: font, .foregroundColor: UIColor.white]
        }
        // TODO: - Localize
        let attrText = NSAttributedString.init(string: "OK", attributes: attr)
        button.setAttributedTitle(attrText, for: .normal)
        button.addTarget(self, action: #selector(okButtonTouchUpInside), for: .touchUpInside)
        button.layer.cornerRadius = 1.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc private func okButtonTouchUpInside() {
        delegate?.okButtonTouchUpInside()
    }
    
    func enableOkButton() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.okButton.alpha = 1.0
        }) { [weak self] (_) in
            self?.okButton.isUserInteractionEnabled = true
        }
    }
    
    func disableOkButton() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.okButton.alpha = 0.3
        }) { [weak self] (_) in
            self?.okButton.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Selectors
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let validators = validators, validators.count > 0 else {
            hideInfo()
            return
        }
        for validator in validators {
            if let info = validator(textField.text) {
                showInfo(info)
                return
            }
        }
        hideInfo()
    }
    
    // MARK: - Initializers
    
    init(target: UITextFieldDelegate?, placeHolder: String?, withButton: Bool, validators: [((String?) -> String?)]?) {
        super.init(frame: .zero)
        
        placeholderText = placeHolder
        
        addSubview(stackView1)
        NSLayoutConstraint.activate(stackView1Constraints)
        
        stackView2.addArrangedSubview(textField)
        NSLayoutConstraint.activate(textFieldConstraints)
        stackView2.addArrangedSubview(underlineView)
        NSLayoutConstraint.activate(underlineViewConstraints)
        stackView2.addArrangedSubview(infoLabel)
        NSLayoutConstraint.activate(infoLabelConstraints)
        stackView1.addArrangedSubview(stackView2)
        stackView1.addArrangedSubview(okButton)
        NSLayoutConstraint.activate(okButtonConstraints)
        
        okButton.isHidden = !withButton
        disableOkButton()
        
        textField.isUserInteractionEnabled = true
        self.validators = validators
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = target
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
