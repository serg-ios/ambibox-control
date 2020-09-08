//
//  NewBackgroundViewController.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 18/11/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit
import CoreData

class NewBackgroundViewController: UIViewController {

    private let delegate = UIApplication.shared.delegate as? AppDelegate

    private var background: Background?
    private var dynamic: Bool = false
    private var lastIndexPathSelected: IndexPath?
    private var lastColorsStr: String?
    private var numLeds: Int = 0
    private var dynBackground: DynBackground?

    private var selecting: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.selectButton.layer.borderColor = UIColor.white.cgColor
                self?.selectButton.layer.borderWidth = self?.selecting == true ? 1 : 0
            }
            ledsCollectionView.isScrollEnabled = !selecting
            changeBottomLabelStatus()
        }
    }
    
    private var selected: [Int] = [] {
        didSet {
            pickerBarButton.isEnabled = !selected.isEmpty
            if selecting, selected.isEmpty {
                selecting = false
            }
            changeBottomLabelStatus()
        }
    }
    
    private var colors: [UIColor] = [] {
        didSet {
            if let colorsStr = colorsParser() {
                lastColorsStr = colorsStr
                delegate?.setColor(string: colorsStr)
            }
        }
    }
    
    // MARK: - Pan gesture recognizer
    
    private lazy var selectLedsPanGesture: UIPanGestureRecognizer = { [weak self] in
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        return pan
    }()
    
    // MARK: - Bottom label status
    
    enum BottomLabelStatus {
        case tapToStart
        case tapToStartHoldToUnsel
        case tapToStopHoldToSel
        case tapToStop
    }
    
    var bottomLabelStatus: BottomLabelStatus? {
        didSet {
            // TODO: - Translate
            var string = ""
            switch bottomLabelStatus {
            case .tapToStart?:
                string = "Tap \"Select\" to start selection."
            case .tapToStop?:
                string = "Tap \"Select\" to stop selection."
            case .tapToStartHoldToUnsel?:
                string = "Tap \"Select\" to start selection, hold to unselect all."
            case .tapToStopHoldToSel?:
                string = "Tap \"Select\" to stop selection, hold to select all."
            default:
                break
            }
            var attrs: [NSAttributedString.Key:Any]?
            if let font = UIFont(name: "SanFranciscoText-Regular", size: 12) {
                attrs = [.foregroundColor: UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0), .font: font]
            }
            bottomLabel.attributedText = NSAttributedString(string: string, attributes: attrs)
        }
    }
    
    private func changeBottomLabelStatus() {
        if selecting && selected.count < numLeds {
            bottomLabelStatus = .tapToStopHoldToSel
        } else if selecting && selected.count == numLeds {
            bottomLabelStatus = .tapToStop
        } else if !selecting && selected.count > 0 {
            bottomLabelStatus = .tapToStartHoldToUnsel
        } else if !selecting && selected.count == 0 {
            bottomLabelStatus = .tapToStart
        } else {
            bottomLabelStatus = nil
        }
    }

    // MARK: - Save background warning label

    private lazy var saveBackgroundWarningLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 18, width: 500, height: 20))
        // TODO: - Translate
        let text = "This name has already been used"
        var attrs: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoText-Regular", size: 10) {
            attrs = [.font:font, .foregroundColor:UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)]
        }
        let attrStr = NSAttributedString(string: text, attributes: attrs)
        label.attributedText = attrStr
        label.alpha = 0
        return label
    }()

    // MARK: - Save background alert

    private lazy var saveBackgroundAlert: UIAlertController = {
        // TODO: - Translate
        var textField: UITextField?
        let title = dynamic ? "Save dynamic background" : "Save static background"
        let alert = UIAlertController(title: title, message: "It needs a name", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: { [weak self] (tF) in
            tF.placeholder = "Name"
            tF.addTarget(self, action: #selector(self?.backgroundNameChanged), for: .editingChanged)
            if let warnLabel = self?.saveBackgroundWarningLabel {
                tF.addSubview(warnLabel)
            }
            tF.text = self?.background?.name
            textField = tF
        })
        // TODO: - Translate
        let saveAction: UIAlertAction = UIAlertAction(title: "Save", style: .default) { [weak self] (_) in
            guard let text = textField?.text else { return }
            self?.saveBackground(name: text)
        }
        saveAction.isEnabled = background != nil
        // TODO: - Translate
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        return alert
    }()

    // MARK: - Buttons stack view
    
    private lazy var buttonsStackConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let bottomBar = self?.bottomBarView, let buttonsStack = self?.buttonsStackView else {
            return []
        }
        let trailing = NSLayoutConstraint(item: buttonsStackView, attribute: .leading, relatedBy: .equal, toItem: bottomBar, attribute: .leading, multiplier: 1, constant: 37)
        let centerY = NSLayoutConstraint(item: buttonsStackView, attribute: .centerY, relatedBy: .equal, toItem: bottomBar, attribute: .centerY, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: buttonsStackView, attribute: .centerX, relatedBy: .equal, toItem: bottomBar, attribute: .centerX, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: buttonsStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
        return [trailing, centerX, centerY, height]
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 37
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Save button

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(white: 1, alpha: 0.2)
        button.layer.cornerRadius = 1
        if let font = UIFont(name: "SanFranciscoText-Semibold", size: 18) {
            let attrs: [NSAttributedString.Key:Any]? = [.font:font, .foregroundColor: UIColor.white]
            // TODO: - Translate
            let title = "Save"
            let attrStr = NSAttributedString(string: title, attributes: attrs)
            button.setAttributedTitle(attrStr, for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTouchUpInside), for: .touchUpInside)
        button.alpha = dynamic ? 0.3 : 1
        button.isEnabled = !dynamic
        return button
    }()
    
    // MARK: - Select button

    private lazy var selectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(white: 1, alpha: 0.2)
        button.layer.cornerRadius = 1
        if let font = UIFont(name: "SanFranciscoText-Semibold", size: 18) {
            let attrs: [NSAttributedString.Key:Any]? = [.font:font, .foregroundColor: UIColor.white]
            // TODO: - Translate
            let title = "Select"
            let attrStr = NSAttributedString(string: title, attributes: attrs)
            button.setAttributedTitle(attrStr, for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(selectButtonTouchUpInside), for: .touchUpInside)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(selectButtonLongPress))
        button.addGestureRecognizer(longPress)
        return button
    }()
    
    // MARK: - Bottom bar
    
    private lazy var bottomBarConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let view = self?.view, let bottomBar = self?.bottomBarView, let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else {
            return []
        }
        let leading = NSLayoutConstraint(item: bottomBar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: bottomBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: bottomBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 72)
        let bottom = NSLayoutConstraint(item: bottomBar, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -(8 + bottomSafeArea))
        return [leading, trailing, height, bottom]
    }()
    
    private lazy var bottomBarView: UIView = { [weak self] in
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Label bottom
    
    private lazy var bottomLabelConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let bottomLabel = self?.bottomLabel, let bottomBar = self?.bottomBarView, let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom, let selectButton = self?.selectButton else {
            return []
        }
        let leading = NSLayoutConstraint(item: bottomBar, attribute: .leading, relatedBy: .equal, toItem: bottomLabel, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: bottomBar, attribute: .trailing, relatedBy: .equal, toItem: bottomLabel, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: bottomLabel, attribute: .top, relatedBy: .equal, toItem: selectButton, attribute: .bottom, multiplier: 1, constant: 4)
        return [leading, trailing, top]
    }()
    
    private lazy var bottomLabel: UILabel = {
        let label = UILabel ()
        label.translatesAutoresizingMaskIntoConstraints = false
        // TODO: - Translate
        let string = ""
        var attrs: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoText-Regular", size: 12) {
            attrs = [.foregroundColor: UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0), .font: font]
        }
        label.attributedText = NSAttributedString(string: string, attributes: attrs)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    // MARK: - Collection view

    private lazy var ledsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.itemSize = CGSize(width: 44, height: 44)
        layout.sectionInset = UIEdgeInsets(top: 4, left: 18, bottom: 32, right: 18)
        var frame: CGRect = view.frame
        let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
        frame.size.height -= (64 + 72 + (bottomSafeArea ?? 0) + 8)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var ledsCollectionViewConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let ledsCollectionView = self?.ledsCollectionView, let parentView = self else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: ledsCollectionView, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: ledsCollectionView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: ledsCollectionView, attribute: .leading, relatedBy: .equal, toItem: parentView, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: ledsCollectionView, attribute: .trailing, relatedBy: .equal, toItem: parentView, attribute: .trailing, multiplier: 1, constant: 0)
        return [topConstraint, leadingConstraint, bottomConstraint, trailingConstraint]
    }()
    
    // MARK: - Title view and constraints
    
    private lazy var titleView: UILabel = {
        let label = UILabel()
        // TODO: - Translate
        let string = dynamic ? delegate?.timerDyn.timeStr : "Background"
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
        guard let titleView = self?.titleView, let underlineTitleView = self?.underlineTitleView else {
            return []
        }
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
    
    // MARK: - Bar buttons
    
    private lazy var popBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "prev"), style: .plain, target: self, action: #selector(popSelf))
        return barButtonItem
    }()
    
    private lazy var pickerBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "picker"), style: .plain, target: self, action: #selector(pickerTouch))
        barButtonItem.isEnabled = false
        return barButtonItem
    }()
    
    private lazy var recBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: delegate?.timerDyn.navBarImage, style: .plain, target: self, action: #selector(recTouch))
        return barButtonItem
    }()

    // MARK: - Private methods
    
    private func reinitCollectionView(size: CGSize) {
        let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
        var frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        frame.size.height -= (64 + (bottomSafeArea ?? 0) + 8)
        ledsCollectionView.frame = frame
        ledsCollectionView.reloadData()
    }
    
    private func refreshTimerNavBar() {
        let string = delegate?.timerDyn.timeStr
        var attrs: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoDisplay-Thin", size: 35) {
            attrs = [.foregroundColor: UIColor.white, .font: font]
        }
        titleView.attributedText = NSAttributedString(string: string ?? "", attributes: attrs)
        recBarButton.image = delegate?.timerDyn.navBarImage
    }
    
    private func setUpNavBar() {
        navigationItem.titleView = titleView
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = popBarButton
        if (dynamic) {
            navigationItem.setRightBarButtonItems([pickerBarButton, recBarButton], animated: true)
        } else {
            navigationItem.rightBarButtonItem = pickerBarButton
        }
        titleView.addSubview(underlineTitleView)
        NSLayoutConstraint.activate(underlineTitleViewConstraints)
    }
    
    private func saveBackground(name: String) {
        if dynamic {
            saveBackgroundAlert.textFields?[0].text = ""
            delegate?.client.dynBackground = delegate?.saveRec(name: name)
            if let background = delegate?.client.dynBackground, let backgrounds = background.backgrounds {
                delegate?.dynamicManager.create(backgrounds: backgrounds)
                if let color = delegate?.dynamicManager.background() {
                    delegate?.setColor(dynBackground: background, string: color, dynamic: dynamic)
                }
            }
            popSelf()
            return
        }
        guard let value = lastColorsStr, let context = delegate?.backgroundsContext else { return }
        saveBackgroundWarningLabel.alpha = 0
        if self.background != nil {
            self.background?.setValuesForKeys(["leds":Int32(numLeds), "name": name, "value": value])
        } else {
            let background = Background(context: context)
            background.name = name
            background.leds = Int32(numLeds)
            background.value = value
            self.background = background
        }
        do {
            try context.save()
            saveBackgroundAlert.textFields?[0].text = ""
            delegate?.client.background = background
            popSelf()
        } catch {
            // Do nothing
        }
    }
    
    private func enableSaveButton() {
        if !saveButton.isEnabled && (delegate?.dynamicManager.backgrounds.count ?? 0) > 0 {
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.saveButton.alpha = 1
            }) { [weak self] (_) in
                self?.saveButton.isEnabled = true
            }
        }
    }

    // MARK: - Selectors
    
    @objc private func selectButtonLongPress() {
        switch bottomLabelStatus {
        case .tapToStart?:
            break
        case .tapToStop?:
            break
        case .tapToStartHoldToUnsel?:
            selected = []
            ledsCollectionView.reloadData()
        case .tapToStopHoldToSel?:
            var selected: [Int] = []
            for i in 0..<numLeds {
                selected.append(i)
            }
            self.selected = selected
            ledsCollectionView.reloadData()
        default:
            break
        }
    }
    
    @objc private func popSelf() {
        delegate?.client.lastBackground = nil
        if delegate?.client.background == nil && delegate?.client.dynBackground == nil {
            delegate?.client.setColorStatus = .stop
        }
        if dynamic {
            if delegate?.client.dynBackground == nil {
                delegate?.client.dynBackground = dynBackground
            }
            if let background = delegate?.client.dynBackground, let backgrounds = background.backgrounds {
                delegate?.dynamicManager.create(backgrounds: backgrounds)
                if let color = delegate?.dynamicManager.background() {
                    delegate?.setColor(dynBackground: background, string: color, dynamic: dynamic)
                }
            }
        }
        navigationController?.popViewController(animated: true)
        delegate?.timerDyn.statusDyn = .stop
    }
    
    @objc private func recTouch() {
        delegate?.timerDyn.toggle()
    }
    
    @objc private func pickerTouch() {
        let vc = ColorPickerViewController.create(color: UIColor(red: 12/255.0, green: 122/255.0, blue: 77/255.0, alpha: 1), dynamic: dynamic)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func selectButtonTouchUpInside() {
        selecting = !selecting
    }
    
    @objc private func saveButtonTouchUpInside() {
        delegate?.timerDyn.statusDyn = .pause
        present(saveBackgroundAlert, animated: true)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        if selecting {
            let touchPoint = ledsCollectionView.convert(gesture.location(in: view), from: view)
            if let indexPath = ledsCollectionView.indexPathForItem(at: touchPoint) {
                guard let cell = ledsCollectionView.cellForItem(at: indexPath) as? LedCollectionViewCell else {
                    return
                }
                if indexPath != lastIndexPathSelected {
                    cell.marked = !cell.marked
                    lastIndexPathSelected = indexPath
                    
                    if cell.marked, !selected.contains(indexPath.row) {
                        selected.append(indexPath.row)
                    }
                    if !cell.marked, selected.contains(indexPath.row) {
                        selected = selected.filter { $0 != indexPath.row }
                    }
                }
            }
        }
    }

    @objc private func backgroundNameChanged(_ textField: UITextField) {
        guard let count = textField.text?.count else { return }
        var nameFree = true
        do {
            guard let context = delegate?.backgroundsContext else {
                return
            }
            if dynamic {
                guard let backgrounds = try context.fetch(DynBackground.fetchRequest()) as? [DynBackground] else { return }
                if (backgrounds.filter { (background) in
                    background.name == textField.text
                    }.count > 0) && textField.text != background?.name {
                    nameFree = false
                    saveBackgroundWarningLabel.alpha = 1
                } else {
                    saveBackgroundWarningLabel.alpha = 0
                }
            } else {
                guard let backgrounds = try context.fetch(Background.fetchRequest()) as? [Background] else { return }
                if (backgrounds.filter { (background) in
                    background.name == textField.text
                    }.count > 0) && textField.text != background?.name {
                    nameFree = false
                    saveBackgroundWarningLabel.alpha = 1
                } else {
                    saveBackgroundWarningLabel.alpha = 0
                }
            }
            
        } catch {
            // Do nothing
        }
        saveBackgroundAlert.actions[1].isEnabled = count > 0 && nameFree
    }

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black

        setUpNavBar()
        view.addSubview(ledsCollectionView)
        view.addSubview(bottomBarView)
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(selectButton)
        buttonsStackView.addArrangedSubview(saveButton)
        ledsCollectionView.register(LedCollectionViewCell.self, forCellWithReuseIdentifier: "LedCollectionViewCell")
        view.addSubview(bottomLabel)
        NSLayoutConstraint.activate(bottomBarConstraints + buttonsStackConstraints + bottomLabelConstraints)
        view.addGestureRecognizer(selectLedsPanGesture)
        if dynamic {
            delegate?.dynamicManager.startRec()
        }
        bottomLabelStatus = .tapToStart
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.timerDyn.delegate = self
        delegate?.dynamicManager.delegate = self
        if delegate?.timerDyn.statusDyn == nil {
            delegate?.timerDyn.statusDyn = .stop
        }
        if dynamic {
            refreshTimerNavBar()
        }
        enableSaveButton()
        ledsCollectionView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        reinitCollectionView(size: size)
        (TimerUIApplication.shared as? TimerUIApplication)?.resetTimer()
    }
    
    // MARK: - Initialization
    
    static func create(numLeds: Int, colors: [UIColor]? = nil, background: Background? = nil, dynBackground: DynBackground? = nil, dynamic: Bool = false) -> NewBackgroundViewController {
        let vc = NewBackgroundViewController()
        vc.numLeds = numLeds
        vc.background = background
        vc.dynamic = dynamic
        vc.dynBackground = dynBackground
        if let colors = colors {
            vc.colors = colors
        } else {
            vc.colors = Array.init(repeating: .black, count: numLeds)
        }
        return vc
    }
}

extension NewBackgroundViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numLeds
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LedCollectionViewCell", for: indexPath) as! LedCollectionViewCell
        cell.setText(String(indexPath.row + 1))
        // Don't animate this change
        cell.animate = false
        cell.marked = selected.contains(indexPath.row)
        cell.animate = true
        cell.setColor(colors[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LedCollectionViewCell
        cell.marked = !cell.marked
        if cell.marked, !selected.contains(indexPath.row) {
            selected.append(indexPath.row)
        }
        if !cell.marked, selected.contains(indexPath.row) {
            selected = selected.filter { $0 != indexPath.row }
        }
    }
}

extension NewBackgroundViewController: ColorPickerDelegate {
    func endColorPick() {
        selecting = false
    }
    
    func colorPicked(color: UIColor) {
        let mutableColors = NSMutableArray(array: colors)
        for index in selected {
            mutableColors[index] = color
        }
        if let array = mutableColors as? [UIColor] {
            colors = array
        }
    }
}

extension NewBackgroundViewController {
    func colorsParser() -> String? {
        guard colors.count > 0 else { return nil }
        let baseStr: String = "setcolor:%@\n"
        var colorsStr: String = ""
        for (i, color) in colors.enumerated() {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: nil)
            colorsStr.append(String(format: "%@-%@,%@,%@;", String(i + 1), String(Int(red * 255)), String(Int(green * 255)), String(Int(blue * 255))))
        }
        return String(format: baseStr, colorsStr)
    }
}

extension NewBackgroundViewController: TimerDynDelegate {
    func stop() {
        delegate?.dynamicManager.stopRec()
        recBarButton.image = delegate?.timerDyn.navBarImage
    }

    func play() {
        delegate?.dynamicManager.playRec()
        recBarButton.image = delegate?.timerDyn.navBarImage
    }

    func pause() {
        delegate?.dynamicManager.pauseRec()
        recBarButton.image = delegate?.timerDyn.navBarImage
    }
    
    func finish() {
        delegate?.dynamicManager.stopRec()
        navigationItem.setRightBarButtonItems([pickerBarButton], animated: true)
    }

    func incrementSecond(timeStr: String) {
        if let font = UIFont(name: "SanFranciscoDisplay-Thin", size: 35) {
            let attrs:[NSAttributedString.Key:Any]? = [.foregroundColor: UIColor.white, .font: font]
            titleView.attributedText = NSAttributedString(string: timeStr, attributes: attrs)
        }
    }
}

extension NewBackgroundViewController: DynamicManagerDelegate {
    func newBackground() {
        if let backgroundStr = delegate?.client.lastBackground {
            delegate?.dynamicManager.backgrounds.append(backgroundStr)
            enableSaveButton()
        }
    }
}
