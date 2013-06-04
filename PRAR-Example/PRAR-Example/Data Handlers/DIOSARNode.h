//
//  DIOSARNode.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/29/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface DIOSARNode : NSObject

+ (void)getUpdatedARNodes:(NSString *)timestamp
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

@end
