//
//  HomeViewController.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 28/10/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import UIKit
import Foundation

class HomeViewController: UIViewController {
    
    private let delegate = UIApplication.shared.delegate as? AppDelegate
    private var errorTimer: Timer?
    private var refreshTimer: Timer?
    
    // MARK: - Profiles button
    
    private lazy var profileButtonConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let safeArea = self?.view.safeAreaLayoutGuide, let profileButton = self?.profileButton, let dynBackgroundButton = self?.dynBackgroundButton else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: profileButton, attribute: .top, relatedBy: .equal, toItem: dynBackgroundButton, attribute: .bottom, multiplier: 1.0, constant: 13)
        let leadingConstraint = NSLayoutConstraint(item: profileButton, attribute: .leading, relatedBy: .equal, toItem: dynBackgroundButton, attribute: .leading, multiplier: 1.0, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: profileButton, attribute: .centerX, relatedBy: .equal, toItem: safeArea, attribute: .centerX, multiplier: 1.0, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: profileButton, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 72.0)
        return [topConstraint, leadingConstraint, centerXConstraint, heightConstraint]
    }()
    
    private lazy var profileButton: CustomButton = { [weak self] in
        // TODO: - Translate
        let button = CustomButton(title: "My profiles")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self
        // TODO: - Translate
        button.setSubtitle(string: "Set a profile", color: .white)
        return button
    }()
    
    // MARK: - Dynamic backgrounds button
    
    private lazy var dynBackgroundButtonConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let safeArea = self?.view.safeAreaLayoutGuide, let dynBackgroundButton = self?.dynBackgroundButton, let backgroundButton = self?.backgroundButton else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: dynBackgroundButton, attribute: .top, relatedBy: .equal, toItem: backgroundButton, attribute: .bottom, multiplier: 1.0, constant: 13)
        let leadingConstraint = NSLayoutConstraint(item: dynBackgroundButton, attribute: .leading, relatedBy: .equal, toItem: backgroundButton, attribute: .leading, multiplier: 1.0, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: dynBackgroundButton, attribute: .centerX, relatedBy: .equal, toItem: backgroundButton, attribute: .centerX, multiplier: 1.0, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: dynBackgroundButton, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 72.0)
        return [topConstraint, leadingConstraint, centerXConstraint, heightConstraint]
    }()
    
    private lazy var dynBackgroundButton: CustomButton = { [weak self] in
        // TODO: - Translate
        let button = CustomButton(title: "Dynamic backgrounds")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self
        // TODO: - Translate
        button.setSubtitle(string: "Set dynamic background", color: .white)
        return button
    }()
    
    // MARK: - Backgrounds button
    
    private lazy var backgroundButtonConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let safeArea = self?.view.safeAreaLayoutGuide, let backgroundButton = self?.backgroundButton, let segmentedControl = self?.segmentedControl else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: backgroundButton, attribute: .top, relatedBy: .equal, toItem: segmentedControl, attribute: .bottom, multiplier: 1.0, constant: 29)
        let leadingConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .leading, relatedBy: .equal, toItem: backgroundButton, attribute: .leading, multiplier: 1.0, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: backgroundButton, attribute: .centerX, relatedBy: .equal, toItem: safeArea, attribute: .centerX, multiplier: 1.0, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: backgroundButton, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 72.0)
        return [topConstraint, leadingConstraint, centerXConstraint, heightConstraint]
    }()
    
    private lazy var backgroundButton: CustomButton = { [weak self] in
        // TODO: - Translate
        let button = CustomButton(title: "My backgrounds")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self
        // TODO: - Translate
        button.setSubtitle(string: "Set static background", color: .white)
        return button
    }()
    
    // MARK: - Segmented control view and constraints
    
    private lazy var segmentedControlConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let safeArea = self?.view.safeAreaLayoutGuide, let segmentedControl = self?.segmentedControl else {
            return []
        }
        let topConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .top, relatedBy: .equal, toItem: safeArea, attribute: .top, multiplier: 1.0, constant: 25)
        let leadingConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .leading, relatedBy: .equal, toItem: safeArea, attribute: .leading, multiplier: 1.0, constant: 23)
        let centerXConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .centerX, relatedBy: .equal, toItem: safeArea, attribute: .centerX, multiplier: 1.0, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0)
        return [topConstraint, leadingConstraint, centerXConstraint, heightConstraint]
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        var items: [UIImage]?
        if let on = UIImage(named: "on.png"), let off = UIImage(named: "off.png") {
            items = [on, off]
        }
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.tintColor = .white
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.alpha = 0.3
        segmentedControl.isUserInteractionEnabled = false
        segmentedControl.addTarget(self, action: #selector(setStatus), for: .valueChanged)
        return segmentedControl
    }()
    
    // MARK: - Set status info label
    
    private lazy var setStatusInfoLabelConstraints: [NSLayoutConstraint] = { [weak self] in
        guard let segmentedControl = self?.segmentedControl, let setStatusInfoLabel = self?.infoLabel else {
            return []
        }
        let bottomConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .top, relatedBy: .equal, toItem: setStatusInfoLabel, attribute: .bottom, multiplier: 1, constant: 5)
        let leadingConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .leading, relatedBy: .equal, toItem: setStatusInfoLabel, attribute: .leading, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .centerX, relatedBy: .equal, toItem: setStatusInfoLabel, attribute: .centerX, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: setStatusInfoLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 16)
        return [bottomConstraint, leadingConstraint, centerXConstraint, heightConstraint]
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Refresh bar button
    
    private var refreshBarButton: UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "refresh.png"), style: .plain, target: self, action: #selector(refresh))
        return barButtonItem
    }
    
    // MARK: - Dismiss bar button
    
    private lazy var dismissBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "dismiss.png"), style: .plain, target: self, action: #selector(dismissSelf))
        return barButtonItem
    }()
    
    // MARK: - Title view and constraints
    
    private lazy var titleView: UILabel = {
        let label = UILabel()
        // TODO: - Translate
        let string = "Home"
        var attrs: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoDisplay-Thin", size: 35) {
            attrs = [.foregroundColor: UIColor.white, .font: font]
        }
        label.attributedText = NSAttributedString(string: string, attributes: attrs)
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
    
    private var setStatusError: Bool = false {
        didSet {
            if setStatusError {
                segmentedControl.selectedSegmentIndex = (segmentedControl.selectedSegmentIndex + 1) % 2
                setStatusError = false
            }
        }
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(segmentedControl)
        view.addSubview(infoLabel)
        view.addSubview(activityIndicator)
        view.addSubview(backgroundButton)
        view.addSubview(dynBackgroundButton)
        view.addSubview(profileButton)
        NSLayoutConstraint.activate(backgroundButtonConstraints + dynBackgroundButtonConstraints + activityIndicatorConstraints + setStatusInfoLabelConstraints + segmentedControlConstraints + profileButtonConstraints)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavBar()
        delegate?.client.delegate = self
        if delegate?.client.setColorStatus == .stop {
            writeGetStatus()
        } else if delegate?.client.setColorStatus == .play {
            disableSegmentedControl()
        }
        setBackgroundName()
        setPauseButton()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        (TimerUIApplication.shared as? TimerUIApplication)?.resetTimer()
    }
    
    // MARK: - Selectors
    
    @objc private func dismissSelf() {
        delegate?.client.setColorStatus = .stop
        delegate?.client.disconnect()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func writeGetStatus() {
        navigationItem.rightBarButtonItem = nil
        activityIndicator.start()
        delegate?.client.unlock(success: { [weak self] in
            self?.delegate?.client.write("getstatus\n", okCompletion: nil, readyCompletion: self?.readyGetStatus, busyCompletion: nil, endCompletion: self?.endConn)
        })
    }
    
    @objc private func setStatus() {
        if !setStatusError {
            activityIndicator.start()
            launchRefreshTimer()
            delegate?.client.setStatus(on: segmentedControl.selectedSegmentIndex == 0)
        }
    }
    
    @objc private func refresh() {
        activityIndicator.start()
        delegate?.client.reconnect()
    }
    
    @objc private func stopColors() {
        navigationItem.setRightBarButton(nil, animated: true)
        delegate?.client.setColorStatus = .stop
        setBackgroundName()
        writeGetStatus()
    }
    
    // MARK: - Private methods
    
    private func setBackgroundName() {
        // TODO: - Translate
        if let backgroundName = delegate?.client.background?.name, delegate?.client.dynamic == false {
            backgroundButton.setSubtitle(string: backgroundName, color: UIColor(red: 71/255.0, green: 203/255.0, blue: 71/255.0, alpha: 1))
            dynBackgroundButton.setSubtitle(string: "Set dynamic background", color: .white)
            profileButton.setSubtitle(string: "Set a profile", color: .white)
        } else if let backgroundName = delegate?.client.dynBackground?.name, delegate?.client.dynamic == true {
            dynBackgroundButton.setSubtitle(string: backgroundName, color: UIColor(red: 71/255.0, green: 203/255.0, blue: 71/255.0, alpha: 1))
            backgroundButton.setSubtitle(string: "Set static background", color: .white)
            profileButton.setSubtitle(string: "Set a profile", color: .white)
        } else {
            backgroundButton.setSubtitle(string: "Set static background", color: .white)
            dynBackgroundButton.setSubtitle(string: "Set dynamic background", color: .white)
            profileButton.setSubtitle(string: delegate?.client.lastProfile ?? "Set a profile", color: delegate?.client.lastProfile == nil ? .white : UIColor(red: 71/255.0, green: 203/255.0, blue: 71/255.0, alpha: 1))
        }
    }
    
    private func setPauseButton() {
        let barButton = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: self, action: #selector(stopColors))
        if delegate?.client.background != nil || delegate?.client.dynBackground != nil {
            navigationItem.setRightBarButton(barButton, animated: true)
        } else {
            navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
    private func enableSegmentedControl() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.segmentedControl.alpha = 1
        }) { [weak self] (_) in
            self?.segmentedControl.isUserInteractionEnabled = true
        }
    }
    
    private func disableSegmentedControl() {
        segmentedControl.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.segmentedControl.alpha = 0.3
        })
    }
    
    private func enableControls() {
        navigationItem.rightBarButtonItem = nil
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.segmentedControl.alpha = 1.0
            self?.backgroundButton.alpha = 1.0
            self?.profileButton.alpha = 1.0
        }) { [weak self] (_) in
            self?.segmentedControl.isUserInteractionEnabled = true
            self?.backgroundButton.isUserInteractionEnabled = true
            self?.profileButton.isUserInteractionEnabled = true
        }
    }
    
    private func disableControls() {
        segmentedControl.isUserInteractionEnabled = false
        backgroundButton.isUserInteractionEnabled = false
        profileButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.segmentedControl.alpha = 0.3
            self?.backgroundButton.alpha = 0.3
            self?.profileButton.alpha = 0.3
        })
    }

    private func setUpNavBar() {
        navigationItem.titleView = titleView
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = dismissBarButton
        titleView.addSubview(underlineTitleView)
        NSLayoutConstraint.activate(underlineTitleViewConstraints)
    }
    
    private func setError(_ text: String) {
        stopRefreshTimer()
        activityIndicator.stop()
        disableControls()
        var attr: [NSAttributedString.Key:Any]?
        if let font = UIFont(name: "SanFranciscoText-Light", size: 16) {
            attr = [.font: font, .foregroundColor: UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)]
        }
        let attrText = NSAttributedString.init(string: text, attributes: attr)
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.infoLabel.attributedText = attrText
            self?.infoLabel.alpha = 1
        }) { [weak self] (_) in
            self?.navigationItem.rightBarButtonItem = self?.refreshBarButton
            self?.errorTimer?.invalidate()
            self?.errorTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { [weak self] (_) in
                UIView.animate(withDuration: 0.5, animations: {
                    self?.infoLabel.alpha = 0
                })
            })
        }
    }
    
    private func launchRefreshTimer() {
        stopRefreshTimer()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { [weak self] (_) in
            // TODO: - Translate
            self?.setError("Connection problems")
        })
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // MARK: - getstatus completions
    
    private lazy var readyGetStatus: ((String) -> ()) = { [weak self] (readStr) in
        if readStr.count > 0 {
            let response = readStr.split(separator: ":")
            if response.count == 2 {
                if response[1].hasPrefix("on") {
                    self?.delegate?.client.getCountLeds()
                    self?.segmentedControl.selectedSegmentIndex = 0
                } else if response[1].hasPrefix("off") {
                    self?.delegate?.client.getCountLeds()
                    self?.segmentedControl.selectedSegmentIndex = 1
                } else if response[1].hasPrefix("unknown") {
                    // TODO: - Translate
                    self?.setError("Timeout")
                } else {
                    // TODO: - Translate
                    self?.setError("Connection problems")
                }
            }
        }
    }
    
    // MARK: - Connection completions

    private lazy var endConn: ((String) -> ()) = { [weak self] (readStr) in
        // TODO: - Translate
        self?.setError("Connection error")
    }
}

extension HomeViewController: SocketAPIProtocol {
    func getCountLedsOk(leds: Int) {
        delegate?.client.numLeds = leds
        enableControls()
        activityIndicator.stop()
    }

    func getCountLedsError() {
        // TODO: - Error label with timer
        activityIndicator.stop()
    }


    func setStatusOk() {
        errorTimer?.fire()
        activityIndicator.stop()
        stopRefreshTimer()
    }
    
    func setStatusError(_ error: SetStatusError) {
        setStatusError = true
        switch error {
        case .busy:
            // TODO: - Translate
            setError("Device busy")
        case .error:
            // TODO: - Translate
            setError("Error")
        }
    }
    
    func getStatusApiOk() {
        errorTimer?.fire()
        activityIndicator.stop()
        writeGetStatus()
        stopRefreshTimer()
    }
    
    func getStatusApiError(_ error: GetStatusApiError) {
        switch error {
        case .badConn:
            // TODO: - Translate
            setError("Connection problems")
        case .endConn:
            // TODO: - Translate
            setError("Impossible to connect")
        case .busy:
            // TODO: - Translate
            setError("Device busy")
        default:
            break
        }
    }

    func reconnectError(_ error: ReconnectError) {
        switch error {
        case .busy:
            // TODO: - Translate
            setError("Device busy")
        case .endConn:
            // TODO: - Translate
            setError("Impossible to connect")
        default:
            break
        }
    }
    
    func getProfilesOk(profiles: [String]) {
        activityIndicator.stop()
        let profilesViewController = ProfilesViewController.create(profiles: profiles)
        navigationController?.pushViewController(profilesViewController, animated: true)
    }
    
    func getProfilesError() {
        activityIndicator.stop()
        // MARK: - Translation
        setError("Error")
    }
}

extension HomeViewController: CustomButtonDelegate {
    func customButtontouchUpInside(_ sender: UIButton) {
        if let leds = delegate?.client.numLeds {
            switch sender {
            case dynBackgroundButton:
                let backgroundsViewController = BackgroundsViewController.create(leds: leds, dynamic: true)
                navigationController?.pushViewController(backgroundsViewController, animated: true)
            case backgroundButton:
                let backgroundsViewController = BackgroundsViewController.create(leds: leds)
                navigationController?.pushViewController(backgroundsViewController, animated: true)
            case profileButton:
                activityIndicator.start()
                delegate?.client.getProfiles()
            default:
                break
            }
        }
    }
}
