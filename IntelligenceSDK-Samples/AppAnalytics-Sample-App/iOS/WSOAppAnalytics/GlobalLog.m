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


#import "GlobalLog.h"


@interface GlobalLog ()
@property (nonatomic, retain) NSMutableArray *log;
@end

@implementation GlobalLog


+ (id)sharedLog {
    static GlobalLog *sharedLog = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLog = [[self alloc] init];
        NSArray *maybe = [[NSUserDefaults standardUserDefaults] arrayForKey:@"log"];
        if(maybe)
            sharedLog.log = [NSMutableArray arrayWithArray:maybe];
        else
            sharedLog.log = [NSMutableArray array];
    });
    return sharedLog;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc {
}


- (void) logActionString:(NSString *)action
{
    [self.log addObject:action];
    [[NSUserDefaults standardUserDefaults] setObject:self.log forKey:@"log"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int) logCount
{
    
    return (int)[self.log count];
}
- (NSString *) logItemAtIndex:(int) index
{
    return [self.log objectAtIndex:index];
}
- (void) clearLog
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"log"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.log = [NSMutableArray array];
}
@end
