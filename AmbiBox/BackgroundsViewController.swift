//
//  BackgroundsViewController.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 18/11/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit

class BackgroundsViewController: UIViewController {

    private var numLeds: Int = 0
    private var dynamic: Bool = false
    private var lastColorsStr: String?
    private var selectedDynBackground: DynBackground?

    private var backgrounds: [Background] = [] {
        didSet {
            tableView.reloadData()
            if !dynamic {
                emptyLabel.isHidden = !filteredBackgrounds.isEmpty
            }
        }
    }

    private var filteredBackgrounds: [Background] {
        return backgrounds.filter { (background: Background) -> Bool in
            Int(background.leds) == numLeds
        }
    }
    
    private var dynBackgrounds: [DynBackground] = [] {
        didSet {
            tableView.reloadData()
            if dynamic {
                emptyLabel.isHidden = !filteredDynBackgrounds.isEmpty
            }
        }
    }
    
    private var filteredDynBackgrounds: [DynBackground] {
        return dynBackgrounds.filter { (background: DynBackground) -> Bool in
            Int(background.leds) == numLeds
        }
    }

    private let delegate = UIApplication.shared.delegate as? AppDelegate

    // MARK: - No backgrounds label

    private lazy var emptyLabelConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let view = self?.view, let emptyLabel = self?.emptyLabel else { return [] }
        let leadingConstraint = NSLayoutConstraint(item: emptyLabel, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: emptyLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: emptyLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: emptyLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        return [leadingConstraint, centerXConstraint, centerYConstraint, heightConstraint]
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        // TODO: - Translate
        let text = "Add a background"
        var attrs: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoText-Regular", size: 18) {
            attrs = [.font: font, .foregroundColor:UIColor.white]
        }
        let attrStr = NSAttributedString(string: text, attributes: attrs)
        label.attributedText = attrStr
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    // MARK: - Backgrounds table view

    private lazy var tableViewConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let tableView = self?.tableView, let view = self?.view, let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else { return [] }
        let topConstraint = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -bottomSafeArea)
        let leadConstraint = NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        return [topConstraint, bottomConstraint, leadConstraint, trailingConstraint]
    }()

    private lazy var tableView: UITableView = { [weak self] in
        let table = UITableView()
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.separatorColor = UIColor.init(white: 1, alpha: 0.4)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Custom activity indicator
    
    private lazy var activityIndicatorConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let safeArea = self?.view.safeAreaLayoutGuide, let activityIndicator = self?.activityIndicator else {
            return []
        }
        let centerYConstraint = NSLayoutConstraint(item: safeArea, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: safeArea, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        return [centerYConstraint, centerXConstraint]
    }()
    
    private lazy var activityIndicator: CustomActivityIndicator = {
        let activityIndicator = CustomActivityIndicator()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.clipsToBounds = true
        return activityIndicator
    }()
    
    // MARK: - Title view and constraints
    
    private lazy var titleView: UILabel = { [weak self] in
        let label = UILabel()
        // TODO: - Translate
        let string = self?.dynamic == true ? "Dynamic backgrounds" : "My backgrounds"
        var attrs: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoDisplay-Thin", size: 35) {
            attrs = [.foregroundColor: UIColor.white, .font: font]
        }
        label.attributedText = NSAttributedString(string: string, attributes: attrs)
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
    
    private lazy var addBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Add"), style: .plain, target: self, action: #selector(newBackground))
        return barButtonItem
    }()
    
    // MARK: - Private methods
    
    private func setUpNavBar() {
        navigationItem.titleView = titleView
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = popBarButton
        navigationItem.rightBarButtonItem = addBarButton
        titleView.addSubview(underlineTitleView)
        NSLayoutConstraint.activate(underlineTitleViewConstraints)
    }
    
    // MARK: - Selectors
    
    @objc private func popSelf() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func newBackground() {
        let newBackgroundViewController = NewBackgroundViewController.create(numLeds: numLeds, dynBackground: selectedDynBackground, dynamic: dynamic)
        navigationController?.pushViewController(newBackgroundViewController, animated: true)
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(activityIndicator)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate(activityIndicatorConstraints + tableViewConstraints + emptyLabelConstraints)
        view.backgroundColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavBar()
        do {
            guard let context = delegate?.backgroundsContext, let backgrounds = try context.fetch(Background.fetchRequest()) as? [Background], let dynBackgrounds = try context.fetch(DynBackground.fetchRequest()) as? [DynBackground] else {
                return
            }
            self.backgrounds = backgrounds
            self.dynBackgrounds = dynBackgrounds
        } catch {
            // Do nothing
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        (TimerUIApplication.shared as? TimerUIApplication)?.resetTimer()
        tableView.reloadData()
    }

    // MARK: - Initializers

    static func create(leds: Int, dynamic: Bool = false) -> BackgroundsViewController {
        let vc = BackgroundsViewController()
        vc.numLeds = leds
        vc.dynamic = dynamic
        return vc
    }
}

extension BackgroundsViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamic ? filteredDynBackgrounds.count : filteredBackgrounds.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        let text = dynamic ? filteredDynBackgrounds[indexPath.row].name : filteredBackgrounds[indexPath.row].name
        if let font = UIFont(name: "SanFranciscoText-Regular", size: 16), let text = text {
            let attrs: [NSAttributedString.Key:Any] = [.font:font, .foregroundColor:UIColor.white]
            cell.textLabel?.attributedText = NSAttributedString(string: text, attributes: attrs)
        }
        cell.textLabel?.textColor = .white
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if dynamic {
            let background: DynBackground = filteredDynBackgrounds[indexPath.row]
            if let backgrounds = background.backgrounds {
                delegate?.dynamicManager.create(backgrounds: backgrounds)
                if let color = delegate?.dynamicManager.background() {
                    delegate?.setColor(dynBackground: background, string: color, dynamic: dynamic)
                }
            }
            selectedDynBackground = background
        } else {
            let background = filteredBackgrounds[indexPath.row]
            lastColorsStr = background.value
            delegate?.setColor(background: background)
        }
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, handler) in
            if let background = self?.backgrounds[indexPath.row], let backgroundValue = background.value, let numLeds = self?.numLeds {
                let newBackgroundViewController = NewBackgroundViewController.create(numLeds: numLeds, colors: self?.colorsFromString(backgroundValue), background: background)
                self?.navigationController?.pushViewController(newBackgroundViewController, animated: true)
            }
        }
        editAction.backgroundColor = UIColor(red: 28.0/255, green: 28.0/255, blue: 28.0/255, alpha: 1)
        editAction.image = UIImage(named: "edit")

        let deleteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, handler) in
            if let backgrounds = self?.filteredBackgrounds, let dynBackgrounds = self?.filteredDynBackgrounds {
                let background: Background? = self?.dynamic == true ? nil : backgrounds[indexPath.row]
                let dynBackground: DynBackground? = self?.dynamic == true ? dynBackgrounds[indexPath.row] : nil
                if background != nil && background == self?.delegate?.client.background {
                    self?.delegate?.client.setColorStatus = .stop
                } else if dynBackground != nil && dynBackground == self?.delegate?.client.dynBackground {
                    self?.delegate?.client.setColorStatus = .stop
                }
                if self?.dynamic == true {
                    self?.delegate?.backgroundsContext.delete(dynBackground!)
                } else {
                    self?.delegate?.backgroundsContext.delete(background!)
                }
                do {
                    try self?.delegate?.backgroundsContext.save()
                    guard let context = self?.delegate?.backgroundsContext, let backgrounds = try context.fetch(Background.fetchRequest()) as? [Background], let dynBackgrounds = try context.fetch(DynBackground.fetchRequest()) as? [DynBackground] else {
                        return
                    }
                    self?.backgrounds = backgrounds
                    self?.dynBackgrounds = dynBackgrounds
                } catch {
                    // Do nothing
                }
                tableView.reloadData()
            }
        }
        deleteAction.backgroundColor = UIColor(red: 42.0/255, green: 42.0/255, blue: 42.0/255, alpha: 1)
        deleteAction.image = UIImage(named: "delete")

        let configuration = UISwipeActionsConfiguration(actions: dynamic ? [deleteAction] : [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

extension BackgroundsViewController {
    func colorsFromString(_ string: String) -> [UIColor]? {
        var colors: [UIColor] = []
        var aux: String = string
        var splits: [Substring] = aux.split(separator: ":")
        if splits.count == 2 {
            aux = String(splits[1])
        } else {
            return []
        }
        splits = aux.split(separator: ";")
        for split in splits {
            let pattern: String = "([0-9]{1,3}),([0-9]{1,3}),([0-9]{1,3})"
            let string = String(split)
            let regex = try? NSRegularExpression(pattern: pattern)
            let result = regex?.matches(in:string, range:NSMakeRange(0, string.count))
            if let result  = result?.first, let r = Range(result.range(at: 1), in: string), let g = Range(result.range(at: 2), in: string) ,let b = Range(result.range(at: 3), in: string) {
                let cgFloatR: CGFloat = CGFloat(Int(String(string[r])) ?? 0) / 255.0
                let cgFloatG: CGFloat = CGFloat(Int(String(string[g])) ?? 0) / 255.0
                let cgFloatB: CGFloat = CGFloat(Int(String(string[b])) ?? 0) / 255.0
                colors.append(UIColor(red: cgFloatR, green: cgFloatG, blue: cgFloatB, alpha: 1))
            }
        }
        return colors.count == numLeds ? colors : nil
    }
}
