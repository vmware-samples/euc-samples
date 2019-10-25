/*!
 *@header  CrittercismConstants.h
 *  Crittercism iOS Library
 *@author  Created by Vera Lukman on 8/3/16.
 *@copyright  Copyright © 2019 VMWare. All rights reserved.
 */

#import <Foundation/Foundation.h>

extern NSString *const CrittercismDidCrashOnLastLoadNotification;
extern NSString *const CrittercismCrashName;
extern NSString *const CrittercismCrashReason;
extern NSString *const CrittercismCrashDate;
extern NSString *const CrittercismCrashView;

typedef NS_ENUM(NSInteger, CRLoggingLevel) {
  CRLoggingLevelSilent = 0,
  CRLoggingLevelError,
  CRLoggingLevelWarning,
  CRLoggingLevelInfo,
  CRLoggingLevelDebug
};
