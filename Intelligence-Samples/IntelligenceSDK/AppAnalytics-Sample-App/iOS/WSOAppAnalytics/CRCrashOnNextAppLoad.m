//
//  CRCrashOnNextAppLoad.m
//  Crittercism-iOS
//
//

#import "CRCrashOnNextAppLoad.h"

NSString* const crashOnNextAppLoadKey = @"shouldCrashOnNextAppLoad";

@interface CRCrashOnNextAppLoad ()
@property (nonatomic) BOOL shouldCrashCache;
@end

@implementation CRCrashOnNextAppLoad

- (id)init {
  self = [super init];
  if (self) {
    [self setup];
  }
  return self;
}

- (void)setup {
  self.shouldCrashCache = [self readShouldCrashOnNextAppLoadFromFile];
}

- (BOOL)shouldCrashOnNextAppLoad {
  return self.shouldCrashCache;
}

- (void)setCrashOnNextAppLoad
{
  if (!self.shouldCrashCache) {
    self.shouldCrashCache = YES;
    [self writeShouldCrashOnNextAppLoadToFile:YES];
  }
}

- (void)setNormalStartOnNextAppLoad
{
  if (self.shouldCrashCache) {
    self.shouldCrashCache = NO;
    [self writeShouldCrashOnNextAppLoadToFile:NO];
  }
}

- (BOOL)readShouldCrashOnNextAppLoadFromFile
{
  BOOL shouldCrash = [[NSUserDefaults standardUserDefaults] boolForKey:crashOnNextAppLoadKey];
  return shouldCrash;
}

- (void)writeShouldCrashOnNextAppLoadToFile:(BOOL)shouldCrash {
  [[NSUserDefaults standardUserDefaults] setBool:shouldCrash forKey:crashOnNextAppLoadKey];
}

@end
