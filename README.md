# Switchcraft

[![Version](https://img.shields.io/cocoapods/v/Switchcraft.svg?style=flat)](http://cocoapods.org/pods/Switchcraft)
[![License](https://img.shields.io/cocoapods/l/Switchcraft.svg?style=flat)](http://cocoapods.org/pods/Switchcraft)
[![Platform](https://img.shields.io/cocoapods/p/Switchcraft.svg?style=flat)](http://cocoapods.org/pods/Switchcraft)

## Contents

- [Description](#description)
- [Usage](#usage)
- [Example](#example)
- [Requirements](#requirements)
- [Installation](#installation)
- [Author](#author)
- [License](#license)

## Description

Switchcraft is a simple tool designed to make switching between different endpoints a breeze.

It is designed to be dropped in to an exsting project and forgot about, but also supports configuring multiple instances and lots of other neat things.

## Usage

### Managing a Single Instance

The simplest way to use Switchcraft is to declare a single global instance, we recommend in your `AppDelegate.swift`, as follows:
```swift
extension Switchcraft {
    static let shared = Switchcraft(config: /*..*/)
}
```
Then, from your ViewController where you'd like to show the picker, all you need to do is attach the `Switchcraft` gesture recognizer to a view controller:
```swift
Switchcraft.shared.attachGesture(to: self)
```
Then you can retrieve the current endpoint from anywhere with
```swift
Switchcraft.shared.endpoint
```

To see this in action, check out the [ReallySimpleExampleVC](https://github.com/steamclock/switchcraft/blob/master/Example/Switchcraft/ReallySimpleExampleVC.swift).

### Keeping Current

To get updates whenever an endpoint is changed, you've got two options:

1. Delegation

    If you only need to keep track of changes to the current endpoint in a single place, this is probably the way to go.
    Classes that want to recieve updates only need to register your `viewController` as a delegate and conform to the `SwitchcraftDelegate` protocol.

    ```
    class MyVC: UIViewController {
        // ...
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            Switchcraft.delegate = self
        }
    }
    
    extension MyVC: SwitchcraftDelegate {
        func switchcraft(_ switchcraft: Switchcraft, didChangeEndpointTo newEndpoint: Endpoint) {
            // Handle your endpoint changing here
        }
    }
    ```

2. `NotificationCenter`

    Changes to the current endpoint are also broadcast to the `NotificationCenter`. 
    
    ```
    NotificationCenter.default.addObserver(self, selector: #selector(endpointChanged(_:)), name: .SwitchCraftDidChangeEndpoint, object: nil)
    
    ...
    
    @objc private func endpointChanged(_ sender: NSNotification) {
        guard let endpoint = sender.userInfo?[Notification.Key.Endpoint] as? Endpoint else {
            return
        }
        // Handle endpoint changed here
    }
    ```
    
### Getting Fancy

There are lots of knobs to tweak in your config. See [Config.swift](https://github.com/steamclock/switchcraft/blob/master/Switchcraft/Classes/Config.swift) for a full list.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 9.3 or above
- Xcode 8.2.1 or above
- Swift 3.2 or above

## Installation

Switchcraft is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Switchcraft'
```

## Author

brendan@steamclock.com

## License

Switchcraft is available under the MIT license. See the [LICENSE](https://github.com/steamclock/switchcraft/blob/master/README.md) file for more info.
