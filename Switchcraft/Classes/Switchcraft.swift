//
//  Switchcraft.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

/**
 * Represents an endpoint that can be chosen using the `Switchcraft` picker
 */
public struct SwitchcraftEndpoint {

    /// A title that will be shown instead of the url in the UIAlertController. Defaults to the url
    public let title: String?

    /// The URL associated with the endpoint.
    public let url: String

    /// The title will be displayed with this style. Default is .default.
    public let style: UIAlertActionStyle

    /**
     * Create a new endpoint.
     *
     * - parameter title: An optional title to show instead of the url when selecting an endpoint.
     * - parameter url: The url to save and return when chosen
     * - parameter style: The style of cell to display in the UIAlertController.
     */
    public init(title: String?, url: String, style: UIAlertActionStyle = . default) {
        self.title = title
        self.url = url
        self.style = style
    }
}

/// Protocol to monitor changes to the selected endpoint
public protocol SwitchcraftDelegate {
    func switchcraft(_ switchcraft: Switchcraft, didChangeEndpoint endpoint: SwitchcraftEndpoint)
}

public class Switchcraft: UIViewController {

    private var alertController: UIAlertController?
    
    private var manager: SwitchcraftManager = SwitchcraftManager.shared

    private(set) var endpoints: [SwitchcraftEndpoint] = []

    private var textFieldDoneButton: UIAlertAction?

    public var delegate: SwitchcraftDelegate?

    public convenience init(manager: SwitchcraftManager = SwitchcraftManager.shared) {
        self.init(nibName: nil, bundle: nil)

        self.manager = manager

        modalPresentationStyle = .overCurrentContext
    }

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
                let newEndpoint = SwitchcraftEndpoint(title: nil, url: text)
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

    override public func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        alertController?.dismiss(animated: animated, completion: nil)
        super.dismiss(animated: animated, completion: completion)
    }

    public func addEndpoint(_ endpoint: SwitchcraftEndpoint) {
        endpoints.append(endpoint)
    }

    public func addEndpoints(_ endpoints: [SwitchcraftEndpoint]) {
        self.endpoints.append(contentsOf: endpoints)
    }

    public func endpoint() -> String? {
        return manager.endpoint
    }

    private func selected(endpoint: SwitchcraftEndpoint) {
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
