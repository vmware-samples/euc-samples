//
//  CrittercismDelegate.h
//  Crittercism-iOS
//
//  Created by Sean Hermany on 10/19/12.
//  Copyright © 2019 VMWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CrittercismDelegate <NSObject>

@optional

// Will be called if your app crashed the last time it was running.
- (void)crittercismDidCrashOnLastLoad DEPRECATED_MSG_ATTRIBUTE("Please listen to CrittercismDidCrashOnLastLoadNotification notifications, see Crittercism.h for details");

@end
