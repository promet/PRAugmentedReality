PRAugmentedReality
==================

PRAugmentedReality is an easy to use iOS Augmented Reality Library. It also includes communication protocols with a Custom Drupal Module (In the works).

==================

### What it provides

* An Augmented reality view out-of-the-box
* Customizable AR Overlays
* Simple and efficient Data Storing for AR Objects using SQLite DB
* Communication system with a Drupal module for simple creation of content on a site
* Custom Map Pin annotation


### Requirements

Several Libraries are required for PRAugmentedReality to work in your app:
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
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)   --> See notes for manual changes
* [DIOS](https://github.com/workhabitinc/drupal-ios-sdk)		--> See notes for manual changes

You are free to remove them and use the most up to date versions or use tools like cocoapods.

The `ARSettings.h` file is where all global constants are set. This is where you will set the URL of the site to get data from.


### Notes:

#### AFNetworking
Please note that AFNetworking only supports ARC. As PRAugmentedReality does not yet support ARC, you must manually flag AFNetworking files with "-fobjc-arc"

(in `Build Phases->Compile Sources`)

#### DIOS

Please note that in order to keep all the settings in one place, it is required to edit the `Settings.h` file in DIOS. 
(This only applies if you are downloading DIOS yourself instead of using the version given in this repo)

Replace the difinition of "kDiosBaseUrl" in DIOS's settings.h with an import of PRAugmentedReality's ARSettings.h:

Replace `#define kDiosBaseUrl @"http://d7.workhabit.com"` with `#import "ARSettings.h"`


### Version Requirements

PRAugmentedReality is compatible with iOS 5.0 or later.


### Documentation

To come
