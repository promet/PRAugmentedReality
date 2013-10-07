//
//  ARSettings.h
//  PrometAR v2.1.1
//
// Created by Geoffroy Lesage on 4/24/13.
// Copyright (c) 2013 Promet Solutions Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#define REFRESH_RATE            0.01    // 100hz
#define RADAR_ON                YES

/**
 * MAX_NUMBER_OF_TRIES
 *
 * The number of times the system will try to do an asynchronous action before it gives up.
 *
 * This is especially relevant in the ARController, whenever the system tries to get
 * network or location updates.
 */
#define MAX_NUMBER_OF_TRIES     5


// -- Accelerometer -- //

#define kFilteringFactor        0.05    // Filtering of noise for the accelerometer


// -- Overlays & Container View -- //

#define AR_VIEW_TAG             042313  // Random number to tag the view that contains the overlays with

/**
 * VERTICAL_SENS
 * The vertical sensitivity of the overlays --> How fast they move up & down with the accelerometer data
 */
#define VERTICAL_SENS           960

/**
 * HORIZ_SENS
 * Counterpart of the VERTICAL_SENS --> How fast they move left & right with the accelerometer data
 */
#define HORIZ_SENS              14

/**
 * OVERLAY_VIEW_WIDTH
 * The size of the view that contains the ar overlays, to simulate 360 view
 */
#define OVERLAY_VIEW_WIDTH      350*HORIZ_SENS

#define X_CENTER                160     // Vertical center value to use to position the overlays
#define Y_CENTER                170     // Horizontal center value to use to position the overlays

#define DEF_SCREEN_WIDTH        320.0
#define DEF_SCREEN_HEIGHT       460.0


// -- MATH -- //
// Some of the values below may seem redundant but they do in fact remove overhead floating-point calculations

/**
 * inc_avg
 * Average of the new inclination with the previous --> Rudimentary padding mechanism
 */
#define inc_avg(x)              (x+currentInclination)/2

#define max(x,y)                (x > y ? x : y)
#define min(x,y)                (x < y ? x : y)

#define METERS_TO_MILES         0.00062
#define POINT_ONE_MILE_METERS   161
#define METERS_TO_FEET          3.28084
#define lat_over_lon            1.33975031663

#define DEGREES( radians )      ((radians)*180/M_PI)
