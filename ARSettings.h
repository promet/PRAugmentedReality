//
//  ARSettings.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/24/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//


#define REFRESH_RATE            1/30    //30hz
#define DELAY_FOR_UPDATE        2       // How long to wait for everything to be started before going to look for updated places


// -- Location & Heading -- //

#define MIN_LOCATION_ACCURACY   100     // Minimum accuracy of the user location required - 100 meters
#define kFilteringFactor        0.05    // Filtering of noise for the accelerometer


// -- Overlays & Container View -- //

#define AR_VIEW_TAG             042313  // Random number to tag the view with

#define TOOLBAR_HEIGHT          40
#define OVERLAY_VIEW_WIDTH      350*HORIZ_SENS

#define VERTICAL_SENS           960     // The sensitivity of the overlays, basically
#define HORIZ_SENS              14      // how fast/slow the overlays move with the accelerometer

#define X_CENTER                160
#define Y_CENTER                150

#define MAP_OVERLAY_X           20
#define MAP_OVERLAY_Y           184

#define MAXIMUM_DISTANCE        10.0    // The maximum distance the "distance" label should show, in Miles


// -- Database -- //

#define DB_FILE_NAME            @"db.sqlite"

#define AR_COORDINATES_TABLE    @"arct"
#define AR_DETAILS_TABLE        @"ardt"


// -- Update Timestamp -- //

#define TIMESTAMP_FILE          @"timestamp.time"


// -- MATH -- //

#define inc_avg(x) (x+currentInclination)/2 // Average of the new inclination with the previous

#define max(x,y) (x > y ? x : y)
#define min(x,y) (x < y ? x : y)

#define meterToMiles        0.00062137
#define latitudeToMeters    111072
#define longitudeToMeters   82905
#define lat_over_lon        1.33975031663

#define METERS_PER_MILE_OVER_2 1609.344/2

#define DEGREES( radians ) ((radians)*180/M_PI)


// -- Drupal Connectivity -- //

#define BaseARNode @"ar_object"
#define Endpoint @"prar"
