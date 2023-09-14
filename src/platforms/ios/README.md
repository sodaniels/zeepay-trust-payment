# TrustPayments iOS SDK

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License MIT](https://img.shields.io/cocoapods/l/TrustKit.svg?style=flat)](https://en.wikipedia.org/wiki/MIT_License)
[![Cocoapods compatible](https://img.shields.io/cocoapods/v/TrustPayments)](https://github.com/CocoaPods/CocoaPods)

The Trust Payments iOS SDK allows you to accept card payments in your iOS app.

We provide a prebuilt and customisable UI which is SCA ready.

## Requirements
For requirements you must meet in order to install our iOS SDK please visit: [iOS SDK requirements](https://help.trustpayments.com/hc/en-us/articles/4402990317201-iOS-SDK-requirements)


## Documentation
For integration guides and official documentation please visit: [Getting started with iOS SDK](https://help.trustpayments.com/hc/en-us/articles/4404014691985-Getting-started-with-iOS-SDK)

## Support
If you need assistance with your integration or are experiencing issues with our payments SDK, please contact our Technical Support Team at support@trustpayments.com.

## Demo

Required tools: [CocoaPods](https://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage), [Cocoapods-keys](https://github.com/orta/cocoapods-keys).

A demo app is included in the project. To run it, run: 
1. `pod install` - you will be asked by the cocoapods-keys for 7 keys. The first 3 
```xml
JWTSecret
MERCHANT_USERNAME
MERCHANT_SITEREFERENCE
```
will be delivered to you by Trust Payments, the rest is not required to run Example App project and can have any value. 

2. `carthage update --platform ios --use-xcframeworks`
3. then open `TrustPayments.xcworkspace` in Xcode and run the `Development` scheme.

In the prepared production application, the initialization keys should be stored in a safer way than through the cocoapods-key (we recommend storing in your private backend, only the user with the appropriate privileges can receive the key).

## License

The Trust Payments iOS SDK is open source and available under the MIT license. See the [LICENSE](LICENSE) file for more info.