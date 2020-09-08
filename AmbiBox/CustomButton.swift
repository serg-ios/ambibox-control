//
//  CustomButton.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 17/11/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import Foundation
import UIKit

protocol CustomButtonDelegate: class {
    func customButtontouchUpInside(_ sender: UIButton)
}

class CustomButton: UIButton {
    
    private var title: String?
    var delegate: CustomButtonDelegate?
    
    // MARK: - Stack view
    
    private lazy var stackViewConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let parentView = self, let stackView = self?.stackView, let detail = self?.rightDetailImageView else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: parentView, attribute: .top, relatedBy: .equal, toItem: stackView, attribute: .top, multiplier: 1.0, constant: -8.0)
        let bottomConstraint = NSLayoutConstraint(item: parentView, attribute: .bottom, relatedBy: .equal, toItem: stackView, attribute: .bottom, multiplier: 1.0, constant: 12.0)
        let leadConstraint = NSLayoutConstraint(item: parentView, attribute: .leading, relatedBy: .equal, toItem: stackView, attribute: .leading, multiplier: 1.0, constant: -8.0)
        let trailConstraint = NSLayoutConstraint(item: detail, attribute: .leading, relatedBy: .equal, toItem: stackView, attribute: .trailing, multiplier: 1.0, constant: 8)
        return [topConstraint, bottomConstraint, leadConstraint, trailConstraint]
        }()
    
    private lazy var stackView: UIStackView  = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    // MARK: - Right detail

    private lazy var rightDetailConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let parentView = self, let detail = self?.rightDetailImageView else {
            return []
        }
        let trailConstraint = NSLayoutConstraint(item: detail, attribute: .trailing, relatedBy: .equal, toItem: parentView, attribute: .trailing, multiplier: 1.0, constant: -8)
        
        let centerX = NSLayoutConstraint(item: detail, attribute: .centerY, relatedBy: .equal, toItem: parentView, attribute: .centerY, multiplier: 1, constant: 0)
        return [ trailConstraint, centerX]
    }()

    private lazy var rightDetailImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "detail_right"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    // MARK: - Title label

    private lazy var myTitleLabelConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let titleLabel = self?.myTitleLabel else {
            return []
        }
        let heightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 26)
        return [heightConstraint]
    }()

    private lazy var myTitleLabel: UILabel = { [weak self] in
        let label = UILabel()
        if let font = UIFont(name: "SanFranciscoDisplay-Bold", size: 22), let text = self?.title {
            let attrs: [NSAttributedString.Key:Any]?
            attrs = [.font:font, .foregroundColor:UIColor.white]
            label.attributedText = NSAttributedString(string: text, attributes: attrs)
        }
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Subtitle label
    
    private lazy var subtitleLabelConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let subtitleLabel = self?.subtitleLabel else {
            return []
        }
        let heightConstraint = NSLayoutConstraint(item: subtitleLabel, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 18)
        return [heightConstraint]
    }()
    
    private lazy var subtitleLabel: UILabel = { [weak self] in
        let label = UILabel()
        if let font = UIFont(name: "SanFranciscoText-Regular", size: 15) {
            let attrs: [NSAttributedString.Key:Any]?
            attrs = [.font:font, .foregroundColor:UIColor.white]
            label.attributedText = NSAttributedString(string: "", attributes: attrs)
        }
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Public methods
    
    func setSubtitle(string: String, color: UIColor) {
        if let font = UIFont(name: "SanFranciscoText-Regular", size: 15) {
            let attrs: [NSAttributedString.Key:Any]?
            attrs = [.font:font, .foregroundColor: color]
            // TODO: - Translate
            self.subtitleLabel.attributedText = NSAttributedString(string: string, attributes: attrs)
        }
    }
    
    // MARK: - Selectors
    
    @objc private func buttonTouchUpInside(sender: UIButton) {
        delegate?.customButtontouchUpInside(sender)
    }
    
    // MARK: - Initialize
    
    init(title: String) {
        super.init(frame: .zero)
        self.title = title
        backgroundColor = UIColor(red: 54.0/255.0, green: 54.0/255.0, blue: 54.0/255.0, alpha: 1.0)
        layer.cornerRadius = 1
        
        addSubview(stackView)
        addSubview(rightDetailImageView)
        stackView.addArrangedSubview(myTitleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        NSLayoutConstraint.activate(stackViewConstraints + rightDetailConstraints + myTitleLabelConstraints + subtitleLabelConstraints)
        
        addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
