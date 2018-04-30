//
//  AppDelegate.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

import Switchcraft
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var config = Config(endpoints: [
            Endpoint(title: nil, url: URL(string: "https://google.com")!),
            Endpoint(title: nil, url: URL(string: "http://apple.com")!),
            Endpoint(title: "Steamclock", url: URL(string: "http://steamclock.com")!)
        ])
        config.allowCustom = true
        Switchcraft.shared.setup(config: config)

        return true
    }
}
