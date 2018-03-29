//
//  Switchcraft.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

public struct SwitchcraftOption {
    public let title: String
    public let value: String
    public let style: UIAlertActionStyle

    public init(title: String, value: String, style: UIAlertActionStyle = . default) {
        self.title = title
        self.value = value
        self.style = style
    }
}

public class Switchcraft: UIViewController {

    private var alertController: UIAlertController?
    private var alertTitle: String?
    private var alertMessage: String?
    private var selectionHandler: ((SwitchcraftOption) -> Void)?
    private(set) var options: [SwitchcraftOption] = []

    public convenience init(title: String?, message: String?, selectionHandler: @escaping (SwitchcraftOption) -> Void) {
        self.init(nibName: nil, bundle: nil)

        alertTitle = title
        alertMessage = message
        self.selectionHandler = selectionHandler

        modalPresentationStyle = .overCurrentContext
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)

        for option in options {
            alertController?.addAction(
                UIAlertAction(title: option.title, style: option.style, handler: { [weak self] (action) in
                    self?.selectionHandler?(option)
                })
            )
        }

        alertController?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController!, animated: true, completion: nil)
    }

    override public func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        alertController?.dismiss(animated: animated, completion: nil)
        super.dismiss(animated: animated, completion: completion)
    }

    public func addOption(_ option: SwitchcraftOption) {
        options.append(option)
    }

    public func addOptions(_ options: [SwitchcraftOption]) {
        self.options.append(contentsOf: options)
    }
}
