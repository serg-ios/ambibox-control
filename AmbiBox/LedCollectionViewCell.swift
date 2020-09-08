//
//  LedCollectionViewCell.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 18/11/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit

class LedCollectionViewCell: UICollectionViewCell {
    
    var animate: Bool = false
    
    var marked: Bool = false {
        didSet {
            if marked {
                UIView.animate(withDuration: animate ? 0.25 : 0) { [weak self] in
                    self?.colorView.alpha = 0
                    self?.selectImageView.backgroundColor = UIColor(white: 1, alpha: 0.5)
                    self?.selectImageView.layer.borderWidth = 1
                    self?.numLedLabel.alpha = 0
                }
            } else {
                UIView.animate(withDuration: animate ? 0.25 : 0) { [weak self] in
                    self?.colorView.alpha = 1
                    self?.selectImageView.backgroundColor = UIColor(white: 1, alpha: 1)
                    self?.selectImageView.layer.borderWidth = 0
                    self?.numLedLabel.alpha = 1
                }
            }
        }
    }
    
    func setColor(_ color: UIColor) {
        colorView.backgroundColor = color
    }
    
    func setText(_ text: String) {
        if let font = UIFont(name: "SanFranciscoText-Regular", size: 10) {
            let attrs: [NSAttributedString.Key:Any]?
            attrs = [.font:font, .foregroundColor: UIColor.black]
            let attributtedString = NSAttributedString(string: text, attributes: attrs)
            numLedLabel.attributedText = attributtedString
        }
    }
    
    // MARK: - Num led label
    
    private lazy var numLedConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let parentView = self, let numLedLabel = self?.numLedLabel else {
            return []
        }
        let bottomConstraint = NSLayoutConstraint(item: numLedLabel, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: numLedLabel, attribute: .trailing, relatedBy: .equal, toItem: parentView, attribute: .trailing, multiplier: 1, constant: -2)
        let leadingConstraint = NSLayoutConstraint(item: numLedLabel, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: parentView, attribute: .leading, multiplier: 1, constant: 2)
        return [bottomConstraint, trailingConstraint, leadingConstraint]
    }()
    
    private lazy var numLedLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Image view select
    
    private lazy var selectImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "check"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.layer.borderColor = UIColor(red: 0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1).cgColor
        imageView.layer.borderWidth = 0
        imageView.backgroundColor = UIColor(white: 1, alpha: 1)
        return imageView
    }()
    
    private lazy var selectImageViewConstraint: [NSLayoutConstraint] = { [weak self] in
        guard let selectImageView = self?.selectImageView, let parentView = self else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: selectImageView, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: selectImageView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: selectImageView, attribute: .leading, relatedBy: .equal, toItem: parentView, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: selectImageView, attribute: .trailing, relatedBy: .equal, toItem: parentView, attribute: .trailing, multiplier: 1, constant: 0)
        return [topConstraint, leadingConstraint, bottomConstraint, trailingConstraint]
    }()
    
    // MARK: - Color view
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        // Default color is white
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var colorViewConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let parentView = self, let colorView = self?.colorView else {
            return []
        }
        let heightConstraint = NSLayoutConstraint(item: colorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        let widthConstraint = NSLayoutConstraint(item: colorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        let centerXConstraint = NSLayoutConstraint(item: colorView, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: colorView, attribute: .centerY, relatedBy: .equal, toItem: parentView, attribute: .centerY, multiplier: 1, constant: 0)
        return [heightConstraint, widthConstraint, centerXConstraint, centerYConstraint]
    }()
    
    // MARK: - Cell
    
    private lazy var cellConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let cell = self else {
            return []
        }
        let heightConstraint = NSLayoutConstraint(item: cell, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
        let widthConstraint = NSLayoutConstraint(item: cell, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
        return [heightConstraint, widthConstraint]
    }()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(selectImageView)
        addSubview(colorView)
        addSubview(numLedLabel)
        NSLayoutConstraint.activate(cellConstraints + colorViewConstraints + selectImageViewConstraint + numLedConstraints)
        bringSubviewToFront(colorView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
