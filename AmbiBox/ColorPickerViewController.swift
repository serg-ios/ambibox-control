//
//  ColorPickerViewController.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 20/11/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate: class {
    func colorPicked(color: UIColor)
    func endColorPick()
}

class ColorPickerViewController: UIViewController {
    
    weak var delegate: ColorPickerDelegate?
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    private var color: UIColor? {
        didSet {
            if let color = color {
                colorPickedView.backgroundColor = color
                setColorText()
                delegate?.colorPicked(color: color)
            }
        }
    }
    
    private var dynamic: Bool = false
    
    // MARK: - Title view and constraints
    
    private lazy var titleView: UILabel = {
        let label = UILabel()
        // TODO: - Translate
        let string = dynamic ? appDelegate?.timerDyn.timeStr : "Color picker"
        var attrs: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoDisplay-Thin", size: 35) {
            attrs = [.foregroundColor: UIColor.white, .font: font]
        }
        label.attributedText = NSAttributedString(string: string ?? "", attributes: attrs)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var underlineTitleViewConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let titleView = self?.titleView, let underlineTitleView = self?.underlineTitleView else { return [] }
        let topConstraint = NSLayoutConstraint(item: titleView, attribute: .bottom, relatedBy: .equal, toItem: underlineTitleView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: underlineTitleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.5)
        let centerXConstraint = NSLayoutConstraint(item: titleView, attribute: .centerX, relatedBy: .equal, toItem: underlineTitleView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let widthConstraint = NSLayoutConstraint(item: underlineTitleView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: UIScreen.main.bounds.width * 2)
        return [widthConstraint, centerXConstraint, topConstraint, heightConstraint]
        }()
    
    private lazy var underlineTitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Stack view
    
    private lazy var stackViewConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let view = self?.view, let stack = self?.stackView, let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else { return [] }
        let topConstraint = NSLayoutConstraint(item: stack, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: stack, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: -5)
        let trailingConstraint = NSLayoutConstraint(item: stack, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 5)
        let bottomConstraint = NSLayoutConstraint(item: stack, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -(8 + bottomSafeArea))
        return [topConstraint, leadingConstraint, trailingConstraint, bottomConstraint]
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Color picked label
    
    private lazy var colorPickedLabelConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let label = self?.colorPickedLabel else { return [] }
        let heightConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 21)
        return [heightConstraint]
    }()
    
    private lazy var colorPickedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Color picked view
    
    private lazy var colorPickedConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let colorPickedView = self?.colorPickedView else { return [] }
        let widthConstraint = NSLayoutConstraint(item: colorPickedView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 61)
        let maxHeightConstraint = NSLayoutConstraint(item: colorPickedView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 61)
        let minHeightConstraint = NSLayoutConstraint(item: colorPickedView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 32)
        return [widthConstraint, maxHeightConstraint, minHeightConstraint]
    }()
    
    private lazy var colorPickedView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Color picker image view
    
    private lazy var colorPickerImageViewConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let colorPickerImageView = self?.colorPickerImageView else { return [] }
        let widthConstraint = NSLayoutConstraint(item: colorPickerImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width)
        return [widthConstraint]
    }()

    private lazy var colorPickerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "colors"))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(selectColorOnTouch)
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    // MARK: - Bar buttons
    
    private lazy var popBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "prev"), style: .plain, target: self, action: #selector(popSelf))
        return barButtonItem
    }()
    
    private lazy var recBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: appDelegate?.timerDyn.navBarImage, style: .plain, target: self, action: #selector(recTouch))
        return barButtonItem
    }()
    
    // MARK: - Gestures
    
    private lazy var selectColorOnTouch: UILongPressGestureRecognizer = { [weak self] in
        let press = UILongPressGestureRecognizer(target: self, action: #selector(handlePressGesture(_:)))
        press.minimumPressDuration = 0
        return press
    }()
    
    // MARK: - Private methods
    
    private func refreshTimerNavBar() {
        let string = appDelegate?.timerDyn.timeStr
        var attrs: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoDisplay-Thin", size: 35) {
            attrs = [.foregroundColor: UIColor.white, .font: font]
        }
        titleView.attributedText = NSAttributedString(string: string ?? "", attributes: attrs)
        recBarButton.image = appDelegate?.timerDyn.navBarImage
    }
    
    private func setUpNavBar() {
        navigationItem.titleView = titleView
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = popBarButton
        if (dynamic) {
            navigationItem.rightBarButtonItem = recBarButton
        }
        titleView.addSubview(underlineTitleView)
        NSLayoutConstraint.activate(underlineTitleViewConstraints)
    }
    
    private func setColorText() {
        // First part of attributed string
        // TODO: - Translate
        let text1: String = "RGB"
        var attrs1: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoText-Light", size: 18) {
            attrs1 = [.font:font, .foregroundColor:UIColor(white: 1, alpha: 0.6)]
        }
        let attrStr1 = NSMutableAttributedString(string: text1, attributes: attrs1)
        // Second part of attributed string
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color?.getRed(&red, green: &green, blue: &blue, alpha: nil)
        // TODO: - Translate
        let text2 = String(format: " %@ %@ %@", String(Int(red * 255)), String(Int(green * 255)), String(Int(blue * 255)))
        var attrs2: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoText-Light", size: 18) {
            attrs2 = [.font:font, .foregroundColor:UIColor(white: 1, alpha: 1)]
        }
        let attrStr2 = NSAttributedString(string: text2, attributes: attrs2)
        // Concatenate both parts
        attrStr1.append(attrStr2)
        // Set the result
        colorPickedLabel.attributedText = attrStr1
    }
    
    // MARK: - Selectors
    
    @objc private func recTouch() {
        appDelegate?.timerDyn.toggle()
    }
    
    @objc private func popSelf() {
        delegate?.endColorPick()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handlePressGesture(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: view)
        if colorPickerImageView.point(inside: point, with: nil) {
            if let newColor = colorPickerImageView.getColourFromPoint(point: point) {
                color = newColor
            }
        }
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setUpNavBar()
        view.addSubview(stackView)
        stackView.addArrangedSubview(colorPickerImageView)
        stackView.addArrangedSubview(colorPickedView)
        stackView.addArrangedSubview(colorPickedLabel)
        NSLayoutConstraint.activate(stackViewConstraints + colorPickedLabelConstraints + colorPickedConstraints + colorPickerImageViewConstraints)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate?.timerDyn.delegate = self
        appDelegate?.dynamicManager.delegate = self
        if dynamic {
            refreshTimerNavBar()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        (TimerUIApplication.shared as? TimerUIApplication)?.resetTimer()
    }
    
    // MARK: - Initialization
    
    static func create(color: UIColor? = nil, dynamic: Bool = false) -> ColorPickerViewController {
        let vc = ColorPickerViewController()
        vc.dynamic = dynamic
        vc.color = color ?? .white
        return vc
    }
}

extension ColorPickerViewController: TimerDynDelegate {
    func stop() {
        appDelegate?.dynamicManager.stopRec()
    }
    
    func play() {
        appDelegate?.dynamicManager.playRec()
        recBarButton.image = appDelegate?.timerDyn.navBarImage
    }
    
    func pause() {
        appDelegate?.dynamicManager.pauseRec()
        recBarButton.image = appDelegate?.timerDyn.navBarImage
    }
    
    func finish() {
        appDelegate?.dynamicManager.stopRec()
        navigationItem.rightBarButtonItem = nil
    }
    
    func incrementSecond(timeStr: String) {
        if let font = UIFont(name: "SanFranciscoDisplay-Thin", size: 35) {
            let attrs:[NSAttributedString.Key:Any]? = [.foregroundColor: UIColor.white, .font: font]
            titleView.attributedText = NSAttributedString(string: timeStr, attributes: attrs)
        }
    }
}

extension ColorPickerViewController: DynamicManagerDelegate {
    func newBackground() {
        if let backgroundStr = appDelegate?.client.lastBackground {
            appDelegate?.dynamicManager.backgrounds.append(backgroundStr)
        }
    }
}
