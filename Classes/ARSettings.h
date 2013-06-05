//
//  ARSettings.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/24/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//


#define REFRESH_RATE            1/30    // 30hz
#define DELAY_FOR_UPDATE        5       // How long to wait for everything to be started before going to look for updated places

#define MAX_NUMBER_OF_TRIES     5       // How many times the system will try to do an asynchronous action before it gives up
// this is especially relevant in the ARController, whenever the system tries to get
// updates from the network or location.


// -- Location & Heading -- //

#define MIN_LOCATION_ACCURACY   100     // Minimum accuracy of the user location required - 100 meters
#define kFilteringFactor        0.05    // Filtering of noise for the accelerometer


// -- Overlays & Container View -- //

#define AR_VIEW_TAG             042313  // Random number to tag the view that contains the overlays with

#define VERTICAL_SENS           960     // The vertical sensitivity of the overlays --> How fast they move up & down with the accelerometer data
#define HORIZ_SENS              14      // Counterpart of the VERTICAL_SENS --> How fast they move left & right with the accelerometer data

#define OVERLAY_VIEW_WIDTH      350*HORIZ_SENS  // The size of the view that contains the overlays, simulates a 360 view

#define X_CENTER                160     // Vertical center value to use to position the overlays
#define Y_CENTER                170     // Horizontal center value to use to position the overlays

#define OVERLAY_WIDTH           240


// -- MATH -- //                // Some of the values below may seem redundant but they do in fact remove overhead floating-point calculations

#define inc_avg(x)              (x+currentInclination)/2    // Average of the new inclination with the previous --> Rudimentary padding mechanism

#define max(x,y)                (x > y ? x : y)
#define min(x,y)                (x < y ? x : y)

#define METERS_TO_MILES         0.00062
#define lat_over_lon            1.33975031663

#define METERS_PER_MILE_OVER_2  804

#define DEGREES( radians )      ((radians)*180/M_PI)
