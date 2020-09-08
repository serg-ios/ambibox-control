//
//  ProfilesViewController.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 27/12/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit

class ProfilesViewController: UIViewController {
    
    // MARK: - Vars & cons
    
    private var profiles: [String] = []
    private let delegate = UIApplication.shared.delegate as? AppDelegate

    // MARK: - Table view
    
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
        let string = "My profiles"
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
    
    // MARK: - Private methods
    
    private func setUpNavBar() {
        navigationItem.titleView = titleView
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = popBarButton
        titleView.addSubview(underlineTitleView)
        NSLayoutConstraint.activate(underlineTitleViewConstraints)
    }

    // MARK: - Selectors
    
    @objc private func popSelf() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(activityIndicator)
        view.addSubview(tableView)
        NSLayoutConstraint.activate(activityIndicatorConstraints + tableViewConstraints)
        view.backgroundColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavBar()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        (TimerUIApplication.shared as? TimerUIApplication)?.resetTimer()
        tableView.reloadData()
    }
    
    // MARK: - Initializers
    
    static func create(profiles: [String]) -> ProfilesViewController {
        let vc = ProfilesViewController()
        vc.profiles = profiles
        return vc
    }
}

extension ProfilesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        let text = profiles[indexPath.row]
        if let font = UIFont(name: "SanFranciscoText-Regular", size: 16) {
            let attrs: [NSAttributedString.Key:Any] = [.font:font, .foregroundColor:UIColor.white]
            cell.textLabel?.attributedText = NSAttributedString(string: text, attributes: attrs)
        }
        cell.textLabel?.textColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let profile = tableView.cellForRow(at: indexPath)?.textLabel?.text {
            popBarButton.isEnabled = false
            activityIndicator.start()
            delegate?.client.setProfile(profile: profile, error: { [weak self] in
                self?.activityIndicator.stop()
                self?.popBarButton.isEnabled = true
            }, ok: { [weak self] in
                self?.delegate?.client.setColorStatus = .stop
                self?.popBarButton.isEnabled = true
                self?.delegate?.client.lastProfile = profile
                self?.activityIndicator.stop()
            })
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
