//
//  CRCrashOnNextAppLoad.h
//  Crittercism-iOS
//
//

#import <Foundation/Foundation.h>

@interface CRCrashOnNextAppLoad : NSObject

- (BOOL)shouldCrashOnNextAppLoad;
- (void)setCrashOnNextAppLoad;
- (void)setNormalStartOnNextAppLoad;

@end
