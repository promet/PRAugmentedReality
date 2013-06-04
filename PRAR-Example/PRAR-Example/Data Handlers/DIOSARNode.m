//
//  DIOSARNode.m
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/29/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import "DIOSARNode.h"
#import "DIOSSession.h"

@implementation DIOSARNode

+ (void)getUpdatedARNodes:(NSString *)timestamp
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseNode, timestamp];
    
    [[DIOSSession sharedSession] getPath:path
                               parameters:nil
                                  success:success
                                  failure:failure];
}

@end
