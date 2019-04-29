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


#import "CROtherViewController.h"
#import <Crittercism/Crittercism.h>
#import "GlobalLog.h"
#import "CRCrashOnNextAppLoad.h"

typedef enum {
    CROtherViewControllerSectionUsername = 0,
    CROtherViewControllerSectionMetaData,
    CROtherViewControllerSectionBreadcrumbs,
    CROtherViewControllerSectionOptOutStatus,
    CROtherViewControllerSectionCrashOnNextAppLoad,
    CROtherViewControllerSectionTotal,
} CROtherViewControllerSection;

@interface CROtherViewController ()
@property (nonatomic) NSArray *usernames;
@property (nonatomic) NSArray *metadata;
@property (nonatomic) NSArray *breadcrumbs;
@property (nonatomic) NSArray *optOut;
@property (nonatomic) NSArray *crashOnNextAppLoadButtons;
@property (nonatomic) BOOL isPaymentSuccessful;
@property (nonatomic) CRCrashOnNextAppLoad* crashOnNextAppLoad;
@end

@implementation CROtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _usernames = @[@"Bob", @"Jim", @"Sue"];
    _metadata = @[@"5", @"30", @"50"];
    _breadcrumbs = @[@"hello world", @"abc", @"123"];
    _optOut = @[@"Opt Out", @"Opt In"];
    _crashOnNextAppLoadButtons = @[@"Crash on next app load", @"Start normally"];
    _crashOnNextAppLoad = [[CRCrashOnNextAppLoad alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return CROtherViewControllerSectionTotal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case CROtherViewControllerSectionUsername:
            return _usernames.count;
        case CROtherViewControllerSectionMetaData:
            return _metadata.count;
        case CROtherViewControllerSectionBreadcrumbs:
            return _breadcrumbs.count;
        case CROtherViewControllerSectionOptOutStatus:
            return _optOut.count;
        case CROtherViewControllerSectionCrashOnNextAppLoad:
            return _crashOnNextAppLoadButtons.count;
        default:
            assert(NO);
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell" forIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.textColor = [UIColor blueColor];
    switch (indexPath.section) {
        case CROtherViewControllerSectionUsername:
        {
            NSString *username = _usernames[(NSUInteger)indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"Set Username: %@", username];
            break;
        }
        case CROtherViewControllerSectionMetaData:
        {
            NSString *gameLevel = _metadata[(NSUInteger)indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"Set Level: %@", gameLevel];
            break;
        }
        case CROtherViewControllerSectionBreadcrumbs:
        {
            NSString *breadcrumb = _breadcrumbs[(NSUInteger)indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"Leave: '%@'", breadcrumb];
            break;
        }
        case CROtherViewControllerSectionOptOutStatus:
            cell.textLabel.text = _optOut[(NSUInteger)indexPath.row];
            break;
        case CROtherViewControllerSectionCrashOnNextAppLoad:
            cell.textLabel.text = _crashOnNextAppLoadButtons[(NSUInteger)indexPath.row];
            break;
        default:
            break;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case CROtherViewControllerSectionUsername:
            return @"Set Username:";
        case CROtherViewControllerSectionMetaData:
            return @"Set Metadata:";
        case CROtherViewControllerSectionBreadcrumbs:
            return @"Leave Breadcrumb:";
        case CROtherViewControllerSectionOptOutStatus:
        {
            BOOL isOptedOut = [Crittercism getOptOutStatus];
            return [NSString stringWithFormat:@"Opt-out Status: %@", isOptedOut ? @"YES":@"NO"];
        }
        case CROtherViewControllerSectionCrashOnNextAppLoad:
        {
            BOOL shouldCrashOnNextAppLoad = [self.crashOnNextAppLoad shouldCrashOnNextAppLoad];
            return [NSString stringWithFormat:@"Next App Load: %@", shouldCrashOnNextAppLoad ? @"Crash" : @"Normal Start"];
        }
        default:
            assert(NO);
            return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CROtherViewControllerSectionUsername:
            [Crittercism setUsername:_usernames[indexPath.row]];
            break;
        case CROtherViewControllerSectionMetaData:
            [Crittercism setValue:_metadata[indexPath.row] forKey:@"Game Level"];
            break;
        case CROtherViewControllerSectionBreadcrumbs:
            [Crittercism leaveBreadcrumb:_breadcrumbs[indexPath.row]];
            break;
        case CROtherViewControllerSectionOptOutStatus:
        {
            BOOL optOutStatus = (indexPath.row == 0);
            [Crittercism setOptOutStatus:optOutStatus];
            [tableView reloadData];
            break;
        }
        case CROtherViewControllerSectionCrashOnNextAppLoad:
        {
            BOOL shouldCrashOnNextAppLoad = (indexPath.row == 0);
            if (shouldCrashOnNextAppLoad) {
                [self.crashOnNextAppLoad setCrashOnNextAppLoad];
            }
            else {
                [self.crashOnNextAppLoad setNormalStartOnNextAppLoad];
            }
            [tableView reloadData];
            break;
        }
        default:
            break;
    }
    [self performSelector:@selector(fadeSelection:)
               withObject:@(YES)
               afterDelay:0.3];
}

- (void)fadeSelection:(BOOL)animated {
    NSIndexPath *selection = [self.tView indexPathForSelectedRow];
    if (selection) {
        [self.tView deselectRowAtIndexPath:selection animated:animated];
    }
}

@end
