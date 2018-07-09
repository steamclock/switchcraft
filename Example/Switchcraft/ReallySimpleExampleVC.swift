//
//  ReallySimpleExampleVC.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

import SafariServices
import Switchcraft
import UIKit

class ReallySimpleExampleVC: UIViewController {
    @IBOutlet private var currentEndpointLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Switchcraft.shared.delegate = self
        Switchcraft.shared.attachGesture(to: self)
    }

    @IBAction func visitEndpoint(_ sender: UIButton) {
        guard let endpoint = Switchcraft.shared.endpoint else { return }
        self.present(SFSafariViewController(url: endpoint.url), animated: true, completion: nil)
    }
}

extension ReallySimpleExampleVC: SwitchcraftDelegate {
    func switchcraft(_ switchcraft: Switchcraft, didSelectEndpoint endpoint: Endpoint) {
        currentEndpointLabel.isHidden = endpoint == switchcraft.defaultEndpoint
        currentEndpointLabel.text = "Current Endpoint:\n\(endpoint.name)"
    }

    func switchcraft(_ switchcraft: Switchcraft, didTapAction action: Action) {
        guard let action = Actions(rawValue: action.actionId) else {
            return
        }

        switch action {
        case .custom1:
            print("tapped action 1")
        case .custom2:
            print("tapped action 2")
        }

    }
}
