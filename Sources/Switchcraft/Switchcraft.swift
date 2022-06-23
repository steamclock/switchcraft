//
//  Switchcraft.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

import UIKit

/**
 * Protocol allowing conforming objects to monitor endpoint selection.
 */
public protocol SwitchcraftDelegate: AnyObject {

    /**
     * Called when an endpoint is selected.
     */
    func switchcraft(_ switchcraft: Switchcraft, didSelectEndpoint endpoint: Endpoint)

    /**
     * Called when an action is tapped.
     */
    func switchcraft(_ switchcraft: Switchcraft, didTapAction action: Action)
}

// provides a default extension, so other applications don't have to override the action handling
public extension SwitchcraftDelegate {
    func switchcraft(_ switchcraft: Switchcraft, didTapAction action: Action) {
        // no-op, allowing this method to be optional
    }
}

/**
 * Switchcraft is a simple manager to make switching endpoints easier.
 *
 * If you only plan on using a single instance of Switchcraft, we recommend following the ReallySimpleVC example.
 * In your `AppDelegate.swift`, create a global extension as follows:
 *     extension Switchcraft {
 *        static let shared = Switchcraft(config: /*..*/)
 *    }
 * You can then get the current from anywhere as `Switchcraft.shared.endpoint`.
 */
public class Switchcraft {

    // MARK: - Initializers

    /**
     * Create a new Switchcraft instance with the provided config.
     *
     * - parameter config: The configuration to use when setting up a new instance.
     */
    public init(config: Config) {
        guard !config.endpoints.isEmpty else {
            fatalError("Switchcraft.init called with no endpoints set. You probably didn't mean to do that.")
        }
        
        guard config.endpoints.indices.contains(config.defaultEndpointIndex) else {
            fatalError("Switchcraft.init called with a default endpoint index that's out of bounds. You probably didn't mean to do that.")
        }

        self.config = config
        let newEndpoints = config.endpoints
        
        /*
         * Set current endpoint if it's not found (could be the first time, could be a different key).
         * If it's a different key, which is considered as a deprecation of the current UserDefaults,
         * then it's a full reset to the config's default endpoint,
         * regardless of whether the list of endpoints remain the same or not.
         */
        guard let currentEndpoint = endpoint else {
            selectAndCache(endpoint: newEndpoints[config.defaultEndpointIndex])
            return
        }
        
        /*
         * If current endpoint exists, we also need to evaluate whether the config has updated just the url or just the name for this endpoint.
         * If only the url or the name has changed, it is essentially the same record but updated. Therefore, we don't actually want
         * to reset the current selection back to the default endpoint, but rather just update the current endpoint in UserDefaults,
         * so that in case the default endpoint is different, the user does not need to repick the endpoint just because the name or the url got updated.
         */
        if let newEndpointWithSameName = config.endpoints.first(where: { $0.name == currentEndpoint.name }) {
            if currentEndpoint.url != newEndpointWithSameName.url {
                selectAndCache(endpoint: newEndpointWithSameName)
                return
            }
        }
        if let newEndpointWithSameUrl = config.endpoints.first(where: { $0.url == currentEndpoint.url }) {
            if currentEndpoint.name != newEndpointWithSameUrl.name {
                selectAndCache(endpoint: newEndpointWithSameUrl)
                return
            }
        }
        
        /*
         * However, if the current endpoint does not match any endpoints specified in the config (both name and url),
         * then we do want to reset to the config's default.
         */
        if !config.endpoints.contains(currentEndpoint) {
            selectAndCache(endpoint: newEndpoints[config.defaultEndpointIndex])
        }
        
        /*
         * If the code reaches this point and no selectAndCache call was made,
         * that means the currently cached endpoint is still valid,
         * so no needs to update the UserDefault, and no needs to reset to the config's default endpoint.
         */
    }

    // MARK: - Private Declarations

    /**
     * User defined configuration options.
     */
    private var config: Config

    /**
     * Convenience shortcut to UserDefaults.
     */
    private let defaults = UserDefaults.standard

    /**
     * The action triggered by the tap gesture recognizer when pressed.
     */
    private var showSwitcher: (() -> Void)?

    /**
     * A reference to the action sheet text field submit button.
     * Needed to toggle enabled for the button as text is entered.
     */
    private var textFieldDoneButton: UIAlertAction?

    // MARK: - Public Declarations

    /**
     * Delegate to receive updates for endpoint selection.
     */
    public weak var delegate: SwitchcraftDelegate?

    /**
     * The currently selected endpoint.
     */
    public private(set) var endpoint: Endpoint? {
        get {
            if let data = UserDefaults.standard.data(forKey: config.defaultsKey),
                    let endpoint = try? JSONDecoder().decode(Endpoint.self, from: data) {
                return endpoint
            }
            return nil
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: config.defaultsKey)
            }
        }
    }

    /**
     * Check if the current endpoint is the default one.
     */
    public var isDefaultEndpoint: Bool {
        return endpoint == config.endpoints[config.defaultEndpointIndex]
    }

    /**
     * Convenience function to get the default endpoint.
     */
    public var defaultEndpoint: Endpoint {
        return config.endpoints[config.defaultEndpointIndex]
    }

    /**
     * Link the Switchcraft instance with a view controller for presentation
     * Optionally, provide a custom view and gesture recognizer to handle showing the switcher.
     *
     * - parameter parent: The view controller to show the switcher in.
     * - parameter gestureView: An optional view to attach the switcher's gesture recognizer to.
     * - parameter gestureRecognizer: An optional custom gesture recognizer to show the switcher.
     */
    public func attachGesture(to parent: UIViewController, gestureView: UIView? = nil, gestureRecognizer: UITapGestureRecognizer? = nil) {
        guard let view = gestureView ?? parent.view else {
            fatalError("Called `attachGesture` without a valid view. `parent`'s view is probably nil.")
        }

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gestureRecognizer ?? makeDefaultGestureRecognizer(forVC: parent))

        // Notify the delegate of the current endpoint after attaching to it.
        if let currentEndpoint = endpoint {
            selectAndCache(endpoint: currentEndpoint)
        }
    }

    /**
     * Show the switcher within the given view controller.
     *
     * - parameter parentVC: The view controller to show the switcher in.
     */
    public func display(from parentVC: UIViewController) {
        let viewController = UIViewController()
        viewController.modalPresentationStyle = .overCurrentContext
        parentVC.present(viewController, animated: true, completion: nil)

        let alertController = UIAlertController(
            title: config.alertTitle,
            message: config.alertMessage,
            preferredStyle: config.allowCustom ? .alert : .actionSheet
        )

        func handleDismiss() {
            if config.changeRequiresRestart {
                presentRestartNotice(parentVC)
            } else {
                viewController.dismiss(animated: false, completion: nil)
            }
        }

        for endpoint in config.endpoints {
            let newAction = UIAlertAction(
                title: endpoint.name,
                style: .default,
                handler: { [weak self] _ in
                    self?.selectAndCache(endpoint: endpoint)
                    handleDismiss()
                }
            )

            if endpoint == self.endpoint,
                    let bundleURL = Bundle(for: Switchcraft.self).url(forResource: "Switchcraft", withExtension: "bundle"),
                    let bundle = Bundle(url: bundleURL),
                    let checkmark = UIImage(named: "checkmark", in: bundle, compatibleWith: nil) {
                newAction.setValue(checkmark, forKey: "image")
            }

            alertController.addAction(newAction)
        }

        if config.allowCustom {
            textFieldDoneButton = UIAlertAction(
                title: config.textFieldDoneTitle,
                style: .default,
                handler: { _ in
                    guard let textField = alertController.textFields?.first,
                            let text = textField.text,
                            let url = URL(string: text) else {
                        return
                    }

                    self.selectAndCache(endpoint: Endpoint(title: "Custom URL", url: url))
                    handleDismiss()
                }
            )
            alertController.addAction(textFieldDoneButton!)

            alertController.addTextField (configurationHandler: { textField in
                textField.placeholder = self.config.textFieldPlaceholder
                textField.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
                textField.text = self.endpoint?.url.absoluteString
            })
        }

        for action in config.actions {
            alertController.addAction(
                UIAlertAction(
                    title: action.title,
                    style: .default,
                    handler: { [weak self] _ in
                        self?.tapped(action: action)
                        viewController.dismiss(animated: false, completion: nil)
                    }
                )
            )
        }

        alertController.addAction(
            UIAlertAction(
                title: config.cancelTitle,
                style: .cancel,
                handler: { _ in viewController.dismiss(animated: false, completion: nil) }
            )
        )

        viewController.present(alertController, animated: true, completion: nil)
    }

    private func presentRestartNotice(_ parentVC: UIViewController) {
        let alertController = UIAlertController(
            title: "Restart Required",
            message: "An endpoint change requires a restart to take effect. Force quit now?",
            preferredStyle: .alert
        )

        alertController.addAction(
            UIAlertAction(
                title: "Don't Restart",
                style: .cancel,
                handler: { _ in parentVC.dismiss(animated: false, completion: nil) }
            )
        )

        alertController.addAction(
            UIAlertAction(
                title: "Force Restart",
                style: .destructive,
                handler: { _ in fatalError("Restarting for endpoint change.") }
            )
        )
        parentVC.dismiss(animated: true, completion: nil)
        parentVC.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Actions

    /**
     * Called by the gesture recognizer when it is triggered.
     * This will in turn call `showSwitcher` if it is defined, showing the switcher.
     *
     * - parameter sender: A reference to the `UITapGestureRecognizer` that sent the event.
     */
    @objc private func tapHandler(_ sender: UITapGestureRecognizer) {
        showSwitcher?()
    }

    /**
     * Text field event listener, updates the "Use Custom" button as the text field is modified.
     *
     * - parameter sender: A reference to the text field.
     */
    @objc private func textFieldChanged(_ sender: UITextField) {
        guard var text = sender.text else {
            textFieldDoneButton?.isEnabled = false
            return
        }

        if !text.contains("http://") && !text.contains("https://") {
            text = "https://" + text
        }

        self.textFieldDoneButton?.isEnabled = canOpenURL(text)
    }

    // MARK: - Private Helpers

    /**
     * Checks if a given string is a valid url and can be opened.
     *
     * - parameter string: The string to check
     *
     * - returns: True if the string is a well formed URL, false if not.
     */
    private func canOpenURL(_ string: String) -> Bool {
        // Adapted from https://stackoverflow.com/a/36012850/6718381
        guard let url = URL(string: string), UIApplication.shared.canOpenURL(url) else {
            return false
        }

        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+(:[0-9]+)?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
        return predicate.evaluate(with: string)
    }

    /**
     * Called when a new endpoint is selected, broadcast the selection and store the new endpoint.
     *
     * - parameter endpoint: The new endpoint to save.
     */
    private func selectAndCache(endpoint: Endpoint) {
        self.endpoint = endpoint
        delegate?.switchcraft(self, didSelectEndpoint: endpoint)
        NotificationCenter.default.post(name: .SwitchcraftDidSelectEndpoint, object: self, userInfo: [Notification.Key.Endpoint: endpoint])
    }

    /**
     * Called when an action is tapped.
     *
     * - parameter action: The action tapped.
     */
    private func tapped(action: Action) {
        delegate?.switchcraft(self, didTapAction: action)
    }

    /**
     * Create and return the default UITapGestureRecognizer recognizer to attach to a view.
     * The default gesture is a three finger double tap unless built with the simulator,
     * in which case it uses a single tap.
     *
     * - parameter viewController: The view controller the switcher will be attached to when displayed.
     *
     * - returns: The new `UITapGestureRecognizer`.
     */
    private func makeDefaultGestureRecognizer(forVC viewController: UIViewController) -> UITapGestureRecognizer {
        showSwitcher = { [weak viewController] in
            if let viewController = viewController {
                self.display(from: viewController)
            }
        }

        let defaultGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))

        // Change default tap behaviour if running on the simulator to use a single tap
        let isSimulator = TARGET_OS_SIMULATOR != 0
        defaultGesture.numberOfTapsRequired = isSimulator ? 1 : 2
        defaultGesture.numberOfTouchesRequired = isSimulator ? 1 : 3
        return defaultGesture
    }
}
