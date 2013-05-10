//
//  DIOSUser.m
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

#import "DIOSUser.h"
#import "DIOSSession.h"
@implementation DIOSUser


#pragma mark UserGets
+ (void)userGet:(NSDictionary *)user
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseUser, [user objectForKey:@"uid"]];

  if ([[DIOSSession sharedSession] signRequests]) {
    [[DIOSSession sharedSession] sendSignedRequestWithPath:path
                                                    method:@"GET"
                                                    params:user
                                                   success:success
                                                   failure:failure];
  }
  else {
    [[DIOSSession sharedSession] getPath:path
                               parameters:user
                                  success:success
                                  failure:failure];
  }
}


#pragma mark userSaves
+ (void)userSave:(NSDictionary *)user
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

  NSString *path = [NSString stringWithFormat:@"%@/%@", kDiosEndpoint, kDiosBaseUser];

  if ([[DIOSSession sharedSession] signRequests]) {
    [[DIOSSession sharedSession] sendSignedRequestWithPath:path
                                                    method:@"POST"
                                                    params:user
                                                   success:success
                                                   failure:failure];
  }
  else {
    [[DIOSSession sharedSession] postPath:path
                              parameters:user
                                 success:success
                                 failure:failure];
  }
}

#pragma mark userRegister
+ (void)userRegister:(NSDictionary *)user
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  NSString *path = [NSString stringWithFormat:@"%@/%@/register", kDiosEndpoint, kDiosBaseUser];

  if ([[DIOSSession sharedSession] signRequests]) {
    [[DIOSSession sharedSession] sendSignedRequestWithPath:path
                                                    method:@"POST"
                                                    params:user
                                                   success:success
                                                   failure:failure];
  }
  else {
    [[DIOSSession sharedSession] postPath:path
                               parameters:user
                                  success:success
                                  failure:failure];
  }
}

#pragma mark userUpdate
+ (void)userUpdate:(NSDictionary *)user
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseUser, [user objectForKey:@"uid"]];

  if ([[DIOSSession sharedSession] signRequests]) {
    [[DIOSSession sharedSession] sendSignedRequestWithPath:path
                                                    method:@"PUT"
                                                    params:user
                                                   success:success
                                                   failure:failure];
  }
  else {
    [[DIOSSession sharedSession] putPath:path
                              parameters:user
                                 success:success
                                 failure:failure];
  }
}

#pragma mark UserDelete
+ (void)userDelete:(NSDictionary *)user
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseUser, [user objectForKey:@"uid"]];

  if ([[DIOSSession sharedSession] signRequests]) {
    [[DIOSSession sharedSession] sendSignedRequestWithPath:path
                                                    method:@"DELETE"
                                                    params:user
                                                   success:success
                                                   failure:failure];
  }
  else {
    [[DIOSSession sharedSession] deletePath:path
                                 parameters:user
                                    success:success
                                    failure:failure];
  }
}


#pragma mark userIndex
//Simpler method if you didnt want to build the params :)
+ (void)userIndexWithPage:(NSString *)page
                   fields:(NSString *)fields 
               parameters:(NSArray *)parameteres 
                 pageSize:(NSString *)pageSize  
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure; {
  NSMutableDictionary *userIndexDict = [NSMutableDictionary new];
  [userIndexDict setValue:page forKey:@"page"];
  [userIndexDict setValue:fields forKey:@"fields"];
  [userIndexDict setValue:parameteres forKey:@"parameters"];
  [userIndexDict setValue:pageSize forKey:@"pagesize"];  
  [self userIndex:userIndexDict success:success failure:failure];
  [userIndexDict release];
}

+ (void)userIndex:(NSDictionary *)params
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

  NSString *path = [NSString stringWithFormat:@"%@/%@", kDiosEndpoint, kDiosBaseUser];

  if ([[DIOSSession sharedSession] signRequests]) {
    [[DIOSSession sharedSession] sendSignedRequestWithPath:path
                                                    method:@"GET"
                                                    params:params
                                                   success:success
                                                   failure:failure];
  }
  else {
    [[DIOSSession sharedSession] getPath:path
                              parameters:params
                                 success:success
                                 failure:failure];
  }
}

#pragma mark userLogin
+ (void)userLoginWithUsername:(NSString *)username andPassword:(NSString *)password
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:username, password, nil] forKeys:[NSArray arrayWithObjects:@"username", @"password", nil]];

  NSString *path = [NSString stringWithFormat:@"%@/%@/login", kDiosEndpoint, kDiosBaseUser];

  if ([[DIOSSession sharedSession] signRequests]) {
    [[DIOSSession sharedSession] sendSignedRequestWithPath:path
                                                    method:@"POST"
                                                    params:params
                                                   success:success
                                                   failure:failure];
  }
  else {
    [[DIOSSession sharedSession] postPath:path
                               parameters:params
                                  success:success
                                  failure:failure];
  }
}
+ (void)userLogin:(NSDictionary *)user
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  [self userLoginWithUsername:[user objectForKey:@"name"]
                  andPassword:[user objectForKey:@"pass"]
                      success:success
                      failure:failure];
}

#pragma mark userLogout
+ (void)userLogoutWithSuccessBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  NSString *path = [NSString stringWithFormat:@"%@/%@/logout", kDiosEndpoint, kDiosBaseUser];

  if ([[DIOSSession sharedSession] signRequests]) {
    [[DIOSSession sharedSession] sendSignedRequestWithPath:path
                                                    method:@"POST"
                                                    params:nil
                                                   success:success
                                                   failure:failure];
  }
  else {
    [[DIOSSession sharedSession] postPath:path
                               parameters:nil
                                  success:success
                                  failure:failure];
  }
}
@end