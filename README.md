PRAugmentedReality
==================

PRAugmentedReality is an easy to use iOS AR Library. It also includes communication protocols with a Custom Drupal Services AR Module (In the works).

==================

### What it provides

* An Augmented reality view out-of-the-box
* Customizable AR Overlays
* Simple and efficient Data Storing for AR Objects using SQLite DB
* Communication system with a Drupal module for simple creation of content on a site
* Custom Map Pin annotation


### Requirements

Several frameworks are required for PRAugmentedReality to work in your app:
* AVFoundation
* CoreGraphics
* CoreLocation
* CoreMotion
* MapKit
* MobileCoreServices
* SystemConfiguration
* libz
* libsqlite

3 Frameworks are included in the Library for your convenience:
* [fmdb](https://github.com/ccgus/fmdb)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* [DIOS](https://github.com/workhabitinc/drupal-ios-sdk)

You are free to remove them and use the most up to date versions or use tools like cocoapods.

Please note that AFNetworking only supports ARC. As PRAugmentedReality does not yet support ARC, you must manually flag AFNetworking files with "-fobjc-arc"

(in `Build Phases->Compile Sources`)


### Version Requirements

PRAugmentedReality is compatible with iOS 5.0 or later.

### Documentation
To come
