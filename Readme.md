![Test Status](https://img.shields.io/badge/documentation-100%25-brightgreen.svg)
![License: MIT](https://img.shields.io/badge/pod-v1.0.2-blue.svg)
[![CocoaPods](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](LICENSE)

# MBAudienceSwift

MBAudienceSwift is a plugin libary for [MBurger](https://mburger.cloud), that lets you track user data and behavior inside your and to target messages only to specific users or groups of users. This plugin is often used with the [MBMessagesSwift](https://github.com/Mumble-SRL/MBMessagesSwift) plugin to being able to send push and messages only to targeted users.

# Installation

# Installation with CocoaPods

CocoaPods is a dependency manager for iOS, which automates and simplifies the process of using 3rd-party libraries in your projects. You can install CocoaPods with the following command:

```ruby
$ gem install cocoapods
```

To integrate the MBurgerSwift into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
platform :ios, '12.0'

target 'TargetName' do
    pod 'MBAudienceSwift'
end
```

If you use Swift rememember to add `use_frameworks!` before the pod declaration.


Then, run the following command:

```
$ pod install
```

CocoaPods is the preferred methot to install the library.

# Manual installation

To install the library manually drag and drop the folder `MBAudience` to your project structure in XCode. 

Note that `MBAudienceSwift` has `MBurgerSwift (1.0.5)` and `MPushSwift (0.2.12)` as dependencies, so you have to install also those libraries.

# Initialization

To initialize the SDK you have to add `MBAudience` to the array of plugins of `MBurger`.

```swift
import MBurgerSwift
import MBMessagesSwift

...

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    MBManager.shared.apiToken = "YOUR_API_TOKEN"
    MBManager.shared.plugins = [MBAudience()]
        
    return true
}
```

You can set a delegate when initializing the `MBAudience` plugin, the delegate will be called when audience data are sent successfully to the sever or if the sync fails

```swift
let audiencePlugin = MBAudience(delegate: [the delegate])

```

