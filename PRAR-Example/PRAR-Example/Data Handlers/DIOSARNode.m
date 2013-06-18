//
//  DIOSARNode.m
//  PrometAR
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
