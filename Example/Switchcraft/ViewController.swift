//
//  ViewController.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

import SafariServices
import Switchcraft
import UIKit

class ViewController: UIViewController {
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

extension ViewController: SwitchcraftDelegate {
    func switchcraft(_ switchcraft: Switchcraft, didChangeEndpointTo newEndpoint: Endpoint) {
        currentEndpointLabel.isHidden = newEndpoint == switchcraft.defaultEndpoint
        currentEndpointLabel.text = "Current Endpoint:\n\(newEndpoint.name)"
    }
}
