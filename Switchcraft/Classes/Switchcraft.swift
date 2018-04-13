//
//  Switchcraft.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

/// Protocol to monitor changes to the selected endpoint
public protocol SwitchcraftDelegate {
    func switchcraft(_ switchcraft: Switchcraft, didChangeEndpoint endpoint: Endpoint)
}

public class Switchcraft: UIViewController {

    private var alertController: UIAlertController?
    
    private var manager: SwitchcraftManager = SwitchcraftManager.shared

    private(set) var endpoints: [Endpoint] = []

    private var textFieldDoneButton: UIAlertAction?

    public var delegate: SwitchcraftDelegate?

    /**
     * Get the current selected endpoint.
     * Defaults to getting the endpoint stored in the singleton SwitchcraftManager.
     */
    public var endpoint: String? {
        return manager.endpoint
    }

    // MARK: Initializers

    /**
     * Create a new Switchcraft instance
     *
     * - parameter manager: Assign a new `SwitchcraftManager` with configuration options. Default is the singleton instance.
     */
    public convenience init(manager: SwitchcraftManager = SwitchcraftManager.shared, endpoints: [Endpoint]) {
        self.init(nibName: nil, bundle: nil)

        self.manager = manager
        self.endpoints = endpoints
        modalPresentationStyle = .overCurrentContext
    }

    // MARK: View Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertController = UIAlertController(title: manager.alertTitle, message: manager.alertMessage, preferredStyle: manager.allowCustom ? .alert : .actionSheet)

        if manager.allowCustom {
            textFieldDoneButton = UIAlertAction(title: manager.textFieldDoneTitle, style: .default, handler: { _ in
                guard let textField = self.alertController?.textFields?.first, let text = textField.text else {
                    return
                }
                let newEndpoint = Endpoint(title: nil, url: text)
                self.selected(endpoint: newEndpoint)
            })
            alertController?.addAction(textFieldDoneButton!)

            alertController?.addTextField (configurationHandler: { textField in
                textField.placeholder = self.manager.textFieldPlaceholder
                textField.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
                textField.text = self.manager.endpoint
            })
        }

        for endpoint in endpoints {
            alertController?.addAction(
                // TODO: Better default value for title, can atleast strip http, etc
                UIAlertAction(title: endpoint.title ?? endpoint.url, style: endpoint.style, handler: { [weak self] (action) in
                    self?.selected(endpoint: endpoint)
                })
            )
        }

        alertController?.addAction(UIAlertAction(title: manager.cancelTitle, style: .cancel, handler: nil))

        present(alertController!, animated: true, completion: nil)
    }

    // MARK: Public Functions

    override public func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        alertController?.dismiss(animated: animated, completion: nil)
        super.dismiss(animated: animated, completion: completion)
    }

    /**
     * Add a new endpoint to the manager to display as an option.
     * This endpoint is appended to the current list of endpoints.
     *
     * - parameter endpoint: The endpoint to add
     */
    public func addEndpoint(_ endpoint: Endpoint) {
        endpoints.append(endpoint)
    }

    /**
     * Add a set of new endpoints to the manager to display as an option.
     * New endpoints are appended to the list of current endpoints.
     *
     * - parameter endpoint: The endpoint to add
     */
    public func addEndpoints(_ endpoints: [Endpoint]) {
        self.endpoints.append(contentsOf: endpoints)
    }

    /**
     * Clears a given endpoint from the current list.
     *
     * - return: The endpoint if it was removed, otherwise `nil`.
     */
    public func removeEndpoint(_ endpoint: Endpoint) -> Endpoint? {
        return endpoints.index(of: endpoint).map { endpoints.remove(at: $0) }
    }

    /**
     * Clear the current list of endpoints.
     */
    public func clearEndpoints() {
        self.endpoints.removeAll()
    }

    // MARK: Helper Functions

    private func selected(endpoint: Endpoint) {
        manager.endpoint = endpoint.url
        delegate?.switchcraft(self, didChangeEndpoint: endpoint)
    }

    @objc private func textFieldChanged(_ sender: UITextField) {
        guard let url = URL(string: sender.text ?? "") else {
            return
        }

        self.textFieldDoneButton?.isEnabled = UIApplication.shared.canOpenURL(url)
    }
}
