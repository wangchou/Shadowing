# https://github.com/fastlane/fastlane/issues/13401
lipo -remove x86_64 Carthage/Build/iOS/Alamofire.framework/Alamofire -o Carthage/Build/iOS/Alamofire.framework/Alamofire
lipo -remove i386 Carthage/Build/iOS/Alamofire.framework/Alamofire -o Carthage/Build/iOS/Alamofire.framework/Alamofire
lipo -remove x86_64 Carthage/Build/iOS/Charts.framework/Charts -o Carthage/Build/iOS/Charts.framework/Charts
lipo -remove i386 Carthage/Build/iOS/Charts.framework/Charts -o Carthage/Build/iOS/Charts.framework/Charts
lipo -remove x86_64 Carthage/Build/iOS/FBLPromises.framework/FBLPromises -o Carthage/Build/iOS/FBLPromises.framework/FBLPromises
lipo -remove i386 Carthage/Build/iOS/FBLPromises.framework/FBLPromises -o Carthage/Build/iOS/FBLPromises.framework/FBLPromises
lipo -remove x86_64 Carthage/Build/iOS/Promises.framework/Promises -o Carthage/Build/iOS/Promises.framework/Promises
lipo -remove i386 Carthage/Build/iOS/Promises.framework/Promises -o Carthage/Build/iOS/Promises.framework/Promises
lipo -remove x86_64 Carthage/Build/iOS/SQLite.framework/SQLite -o Carthage/Build/iOS/SQLite.framework/SQLite
lipo -remove i386 Carthage/Build/iOS/SQLite.framework/SQLite -o Carthage/Build/iOS/SQLite.framework/SQLite
lipo -remove x86_64 Carthage/Build/iOS/SwiftyJSON.framework/SwiftyJSON -o Carthage/Build/iOS/SwiftyJSON.framework/SwiftyJSON
lipo -remove i386 Carthage/Build/iOS/SwiftyJSON.framework/SwiftyJSON -o Carthage/Build/iOS/SwiftyJSON.framework/SwiftyJSON

