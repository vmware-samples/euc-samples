/*
 * Copyright 2019 VMware
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#import "AppDelegate.h"
#import <Crittercism/Crittercism.h>
#import "GlobalLog.h"
#import "CRCrashOnNextAppLoad.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

// The Managed app configuration dictionary pushed down from an MDM server are stored in this key.
static NSString * const kConfigurationKey = @"com.apple.configuration.managed";

// This sample application allows for a server url and cloud document switch to be configured via MDM
// Application developers should document feedback dictionary keys, including data types and valid value ranges.
static NSString * const kAppIDKey = @"AppID";
static NSString * const kSandboxKey = @"Sandbox";

NSString *appID = @"";
BOOL *sandbox;

- (void)readDefaultsValues {
    
    NSDictionary *serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigurationKey];
    NSString *appIDString = serverConfig[kAppIDKey];
    BOOL sandboxBOOL = (BOOL)serverConfig[kSandboxKey];
    
    // Data coming from MDM server should be validated before use.
    // If validation fails, be sure to set a sensible default value as a fallback, even if it is nil.
    
    NSLog( @"AppID from Application Configuration is %@", appIDString);
    NSLog( @"Environment from Application Configuration is %i", sandboxBOOL);
    
    if (appIDString && [appIDString isKindOfClass:[NSString class]]) {
        appID = appIDString;
    } else {
        // You may want to use a Default AppID in case nothing is defined by Workspace ONE UEM
        appID = @"";
    }
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /**
     * If you'd like to test against your own developer account, create an app
     * (https://app.crittercism.com/developers/register_application) and replace the app ID 
     * below with the new ID found on the app's settings page.
     *
     * Documentation for the iOS SDK can be found here:
     * http://docs.crittercism.com/ios/ios.html
     *
     */
    
    
    // Add Notification Center observer to be alerted of any change to NSUserDefaults.
    // Managed app configuration changes pushed down from an MDM server appear in NSUSerDefaults.
    [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self readDefaultsValues];
                                                  }];

    // Call readDefaultsValues to make sure default values are read at least once.
    [self readDefaultsValues];
    //appID = @"644fc3fbd22f49958679b434a92d46dc00555300"; my company
    //appID = @"5f556d20fe5347c5858e2e388f85629d00555300";
    
    //NSLog( @"App ID Received from the app %@", appID);
    
    if ([appID isEqualToString:@""]) {
//           [[[UIAlertView alloc] initWithTitle:@"Configuration Error" message:@"AppID has not been provided by Workspace ONE UEM" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
          UIAlertController* alert =[UIAlertController alertControllerWithTitle:@"Configuration Error"
          message:@"AppID has not been provided by Workspace ONE UEM"
          preferredStyle:UIAlertControllerStyleAlert];
        
          UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
             handler:^(UIAlertAction * action) {}];
           
          [alert addAction:defaultAction];
          [self.window.rootViewController presentViewController:alert animated:YES completion:nil];

    } else
    {
    
        [Crittercism enableWithAppID:appID];
        [Crittercism setLoggingLevel:CRLoggingLevelDebug];
    //    [[GlobalLog sharedLog] logActionString:appID];

        if([Crittercism didCrashOnLastLoad])
        {
            [[GlobalLog sharedLog] logActionString:@" !!!!!!!! Crash happen !!!!!!!! "];
        }
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
    CRCrashOnNextAppLoad* crashOnNextAppLoad = [[CRCrashOnNextAppLoad alloc] init];
    BOOL shouldCrash = [crashOnNextAppLoad shouldCrashOnNextAppLoad];
 
    // [AppDelegate applicationDidBecomeActive:] is called first before NSNotification is fired.
    // This is the perfect place to test crash during app load
    if (shouldCrash) {
        [crashOnNextAppLoad setNormalStartOnNextAppLoad];
        [self crashApp];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)crashApp {
    int *nullVariable = NULL;
    NSLog(@"%d", *nullVariable);
}

@end
