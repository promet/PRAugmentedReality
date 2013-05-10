Drupal iOS SDK - Connect your iOS/OS X app to Drupal
================================
###[http://workhabit.com](http://workhabit.com)
What you need to know
================================
The Drupal iOS SDK is a standard set of libraries for communicating to Drupal from any iOS device. Its extremely simple.
If you wanted to get a node you can do so calling some class methods on DIOSNode, creating an 
NSDictionary and running the nodeGet method.  Heres an example:

```obj-c
    NSMutableDictionary *nodeData = [NSMutableDictionary new];
    [nodeData setValue:@"12" forKey:@"nid"];
    [DIOSNode nodeGet:nodeData success:^(AFHTTPRequestOperation *operation, id responseObject) {
      //Do Something with the responseObject
      NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      //we failed, uh-oh lets error log this.
      NSLog(@"%@,  %@", [error localizedDescription], [operation responseString]);    
    }];
    
```
For every DIOS call you make, any method calls that are available to you use blocks. 
This allows us to define what happens when we have a request that fails or succeeds. 
If the request was successful the result would be something like this:

    {"vid":"9","uid":"57","title":"testtitle","log":"","status":"1".......
    
However if it failed, the error might look like this:

    Expected status code in (200-299), got 404,  "Node 5 could not be found"
    
What you need to get started
================================
* This library :) 
* AFNetwork which can be found [here](https://github.com/AFNetworking/AFNetworking)
* Be sure to follow the AFNetworking installation guide.
* Update Settings.h with the correct correct url and endpoints)
* [Services](http://drupal.org/project/services)

Demo App (Work in progress)
--------------------
[http://github.com/workhabitinc/drupal-ios-sdk-example](http://github.com/workhabitinc/drupal-ios-sdk-example)

Branches
--------------------
6.x-2.x 6.x-3.x and 7.x-3.x have all been moved to a  *DEPRECATED* version of their branch.
The new dev branch will be the become the new master and as things are added, versions will be tagged and published.
master will always be the latest and greatest for the most up to date version of everything(Services, Drupal, Services Api, DIOS).

Tags are in this format
`2.1-1.0` Which breaks down as, DIOSVersion 2.1, Services Api Version 1.0

Branches are in this format
`2.x-1.x`

OAuth
--------------------
If you want to use oAuth theres only one thing you need to do for 2-legged
```obj-c
  [DIOSSession sharedOauthSessionWithURL:@"http://d7.workhabit.com" consumerKey:@"yTkyapFEPAdjkW7G2euvJHhmmsURaYJP" secret:@"ZzJymFtvgCbXwFeEhivtF67M5Pcj4NwJ"];
```
This will create your shared session with the baseURL and attach your consumer key and secret.

3-legged requires that you get some request tokens, and convert them into access tokens.
DIOS provides methods to do this, as an Example, this code will grab some request tokens and load a webview to be displayed

```obj-c
  [DIOSSession getRequestTokensWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    requestTokens = [NSMutableDictionary new];
    NSArray *arr = [operation.responseString componentsSeparatedByCharactersInSet:
                    [NSCharacterSet characterSetWithCharactersInString:@"=&"]];
    if([arr count] == 4) {
      [requestTokens setObject:[arr objectAtIndex:1] forKey:[arr objectAtIndex:0]];
      [requestTokens setObject:[arr objectAtIndex:3] forKey:[arr objectAtIndex:2]];
    } else {
      NSLog(@"failed ahh");
    }
    [_window addSubview:oauthWebView];
    NSString *urlToLoad = [NSString stringWithFormat:@"%@/oauth/authorize?%@", [[DIOSSession sharedSession] baseURL], operation.responseString];
    NSURL *url = [NSURL URLWithString:urlToLoad];
    NSLog(@"loading url :%@", urlToLoad);
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];

    //Load the request in the UIWebView.
    [oauthWebView loadRequest:requestObj];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"failed");
  }];
```

If you want to get back a notificaiton when the request tokens have been authorized youll need to register a URL
for your application and make sure it is defined in your oAuth consumer which you created on your Drupal website

Again, another example here, we registered our app url and this method gets called when it does.

```obj-c
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
  //If our request tokens were validated, this will get called.
  if ([[url absoluteString] rangeOfString:[requestTokens objectForKey:@"oauth_token"]].location != NSNotFound) {
    [DIOSSession getAccessTokensWithRequestTokens:requestTokens success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSArray *arr = [operation.responseString componentsSeparatedByCharactersInSet:
                      [NSCharacterSet characterSetWithCharactersInString:@"=&"]];
      if([arr count] == 4) {
        //Lets set our access tokens now
        [[DIOSSession sharedSession] setAccessToken:[arr objectAtIndex:1] secret:[arr objectAtIndex:3]];
        NSDictionary *node = [NSDictionary dictionaryWithObject:@"1" forKey:@"nid"];
        [DIOSNode nodeGet:node success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"%@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", [error localizedDescription]);
        }];
      } else {
        NSLog(@"failed ahh");
      }
      NSLog(@"successfully added accessTokens");
      [oauthWebView removeFromSuperview];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"getting access tokens failed");
      [oauthWebView removeFromSuperview];
    }];
  }
  return YES;
}
```
Documentation
-----------
[Can be found here](https://github.com/workhabitinc/drupal-ios-sdk/wiki/drupal-ios-sdk-2.0)

Troubleshooting
----------
If you are getting Access denied, or API Key not valid, double check that your key settings are setup correctly at admin/build/services/keys and double check that permissions are correct for your user and anonymous.

X service doesnt exist in Drupal iOS SDK
----------
You no longer really need to subclass any existing DIOS classes, unless you want to override.
`[DIOSSession shared]` ensures that session information is stored for as long as the cookies are valid
If you do want to make your own object, just follow the pattern in the other files and everything should work fine.
Use the issue queue here on github if you have questions.

Questions
----------
Checkout the Issue queue, or email me
Email kyle@workhabit.com