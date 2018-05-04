//
//  NotificationCenterExampleVC.swift
//  Switchcraft_Example
//
//  Created by Brendan Lensink on 2018-05-04.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SafariServices
import Switchcraft
import UIKit

class NotificationCenterExampleVC: UIViewController {
    @IBOutlet private var currentEndpointLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Switchcraft.shared.attachGesture(to: self)

        NotificationCenter.default.addObserver(self, selector: #selector(endpointChanged(_:)), name: Switchcraft.endpointDidChange, object: nil)
    }

    @IBAction func visitEndpoint(_ sender: UIButton) {
        guard let endpoint = Switchcraft.shared.endpoint else { return }
        self.present(SFSafariViewController(url: endpoint.url), animated: true, completion: nil)
    }

    @objc private func endpointChanged(_ sender: NSNotification) {
        guard let endpoint = sender.userInfo?[Switchcraft.endpointDidChangeUserInfoKey] as? Endpoint else {
            return
        }

        currentEndpointLabel.isHidden = endpoint == Switchcraft.shared.defaultEndpoint
        currentEndpointLabel.text = "Current Endpoint:\n\(endpoint.name)"
    }
}
