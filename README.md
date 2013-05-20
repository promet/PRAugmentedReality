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


[![](https://dl.dropboxusercontent.com/u/30415492/Device-AR-thumb.png)](https://dl.dropboxusercontent.com/u/30415492/Device-AR.png)
[![](https://dl.dropboxusercontent.com/u/30415492/Device-Map-thumb.png)](https://dl.dropboxusercontent.com/u/30415492/Device-Map.png)
[![](https://dl.dropboxusercontent.com/u/30415492/Device-List_Distance-thumb.png)](https://dl.dropboxusercontent.com/u/30415492/Device-List_Distance.png)
[![](https://dl.dropboxusercontent.com/u/30415492/Device-List_Name-thumb.png)](https://dl.dropboxusercontent.com/u/30415492/Device-List_Name.png)

### Version Requirements

PRAugmentedReality is compatible with iOS 5.0 or later.


### Installation
#### Using Cocoapods

Put this line in your podfile:
`pod 'PRAugmentedReality',	'~> 1.0.2'`

Note:
As the DIOS Framework requried for PRAugmentedReality is not yet in CocoaPods, it is included for your convenience.
[DIOS](https://github.com/workhabitinc/drupal-ios-sdk)				--> See notes for manual change done


#### Manually

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

3 Frameworks are required and included in the git repo for your convenience:
* [fmdb](https://github.com/ccgus/fmdb)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)   	--> See notes for manual changes
* [DIOS](https://github.com/workhabitinc/drupal-ios-sdk)			--> See notes for manual changes

You are free to remove them and download them manually... although CocoaPods would do this all for you (:

The `ARSettings.h` file is where all global constants (preprocessor directives actually) are set.
This is where you will set:
* The URL of the site to get data from

And can modify:
* The refresh rate
* Delays/Timeouts for udpates and timers
* Radius of region that is considered "near" the user
* DB files & tables


### Notes:
#### AFNetworking (only if manual install - no cocoapods)
As AFNetworking requires ARC but PRAugmentedReality does not yet support it, you must manually flag AFNetworking source files with "-fobjc-arc"

(in `Build Phases->Compile Sources`)


#### DIOS

In order to keep all the settings in one place, it is required to edit the `Settings.h` file in DIOS. 
(This only applies if you are downloading DIOS yourself instead of using the version given in this repo)

Replace the difinition of "kDiosBaseUrl" in DIOS's settings.h with an import of PRAugmentedReality's ARSettings.h:

Replace `#define kDiosBaseUrl @"http://d7.workhabit.com"` with `#import "ARSettings.h"`



### Documentation

To come
