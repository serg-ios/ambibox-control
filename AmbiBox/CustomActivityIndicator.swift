//
//  CustomActivityIndicator.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 27/10/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit

class CustomActivityIndicator: UIView {

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
    
    private lazy var stackView1: UIStackView  = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Activity indicator
    
    private lazy var activityIndicatorConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let activityIndicator = self?.activityIndicator else {
            return []
        }
        let heightConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0)
        return [heightConstraint]
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView  = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    // MARK: - Info label
    
    private lazy var infoLabelConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let infoLabel = self?.infoLabel else {
            return []
        }
        let heightConstraint = NSLayoutConstraint(item: infoLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0)
        return [heightConstraint]
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Show / hide methods
    
    func start() {
        stop(text: nil)
        activityIndicator.startAnimating()
    }
    
    func stop(text: String? = nil) {
        activityIndicator.stopAnimating()
        if let text = text {
            var attr: [NSAttributedString.Key:Any]?
            if let font = UIFont(name: "SanFranciscoText-Regular", size: 18.0) {
                attr = [.font: font, .foregroundColor: UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)]
            }
            let attrText = NSAttributedString.init(string: text, attributes: attr)
            infoLabel.attributedText = attrText
            infoLabel.isHidden = false
        } else {
            infoLabel.isHidden = true
        }
    }
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        
        addSubview(stackView1)
        NSLayoutConstraint.activate(stackView1Constraints)
        stackView1.addArrangedSubview(infoLabel)
        NSLayoutConstraint.activate(infoLabelConstraints)
        stackView1.addArrangedSubview(activityIndicator)
        NSLayoutConstraint.activate(activityIndicatorConstraints)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
