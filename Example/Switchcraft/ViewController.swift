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

    override func viewDidLoad() {
        Switchcraft.shared.attachGesture(to: self)
    }

    @IBAction func visitEndpoint(_ sender: UIButton) {
        guard let url = Switchcraft.shared.endpoint else { return }
        self.present(SFSafariViewController(url: url), animated: true, completion: nil)
    }
}
