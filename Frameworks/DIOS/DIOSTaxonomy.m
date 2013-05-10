//
//  DIOSTaxonomy.m
//
// ***** BEGIN LICENSE BLOCK *****
// Version: MPL 1.1/GPL 2.0
//
// The contents of this file are subject to the Mozilla Public License Version
// 1.1 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
// for the specific language governing rights and limitations under the
// License.
//
// The Original Code is Kyle Browning, released June 27, 2010.
//
// The Initial Developer of the Original Code is
// Kyle Browning
// Portions created by the Initial Developer are Copyright (C) 2010
// the Initial Developer. All Rights Reserved.
//
// Contributor(s):
//
// Alternatively, the contents of this file may be used under the terms of
// the GNU General Public License Version 2 or later (the "GPL"), in which
// case the provisions of the GPL are applicable instead of those above. If
// you wish to allow use of your version of this file only under the terms of
// the GPL and not to allow others to use your version of this file under the
// MPL, indicate your decision by deleting the provisions above and replacing
// them with the notice and other provisions required by the GPL. If you do
// not delete the provisions above, a recipient may use your version of this
// file under either the MPL or the GPL.
//
// ***** END LICENSE BLOCK *****

#import "DIOSTaxonomy.h"
#import "DIOSSession.h"
@implementation DIOSTaxonomy


+ (void)getTreeWithVid:(NSString *)vid
            withParent:(NSString *)parent 
           andMaxDepth:(NSString *)maxDepth  
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  NSMutableDictionary *params = [NSMutableDictionary new];
  [params setValue:vid forKey:@"vid"];
  [params setValue:parent forKey:@"parent"];
  [params setValue:maxDepth forKey:@"max_depth"];
  [self getTreeWithParams:params success:success failure:failure];
  [params release];
}
+ (void)getTreeWithParams:(NSDictionary *)params
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

  NSString *path = [NSString stringWithFormat:@"%@/%@/getTree", kDiosEndpoint, kDiosBaseTaxonmyVocabulary];
  
  if ([[DIOSSession sharedSession] signRequests]) {
    [[DIOSSession sharedSession] sendSignedRequestWithPath:path
                                                    method:@"POST"
                                                    params:params
                                                   success:success
                                                   failure:failure];
  } else {
    [[DIOSSession sharedSession] postPath:path
                               parameters:params
                                  success:success
                                  failure:failure];
  }

}
+ (void)selectNodesWithTid:(NSString *)tid
                  andLimit:(NSString *)limit 
                  andPager:(NSString *)pager
                  andOrder:(NSString *)order  
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  NSMutableDictionary *params = [NSMutableDictionary new];
  [params setValue:tid forKey:@"tid"];
  [params setValue:limit forKey:@"limit"];
  [params setValue:pager forKey:@"pager"];
  [params setValue:order forKey:@"prder"];
  [self selectNodesWithParams:params success:success failure:failure];
  [params release];
}
+ (void)selectNodesWithParams:(NSDictionary *)params
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

  NSString *path = [NSString stringWithFormat:@"%@/%@/selectNodes", kDiosEndpoint, kDiosBaseTaxonmyTerm];

  if ([[DIOSSession sharedSession] signRequests]) {
    [[DIOSSession sharedSession] sendSignedRequestWithPath:path
                                                    method:@"POST"
                                                    params:params
                                                   success:success
                                                   failure:failure];
  } else {
    [[DIOSSession sharedSession] postPath:path
                               parameters:params
                                  success:success
                                  failure:failure];
  }
}
+ (void)getTermWithTid:(NSString *)tid
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseTaxonmyTerm, tid];

  if ([[DIOSSession sharedSession] signRequests]) {
    [[DIOSSession sharedSession] sendSignedRequestWithPath:path
                                                    method:@"GET"
                                                    params:nil
                                                   success:success
                                                   failure:failure];
  } else {
    [[DIOSSession sharedSession] getPath:path
                               parameters:nil
                                  success:success
                                  failure:failure];
  }
}
@end
