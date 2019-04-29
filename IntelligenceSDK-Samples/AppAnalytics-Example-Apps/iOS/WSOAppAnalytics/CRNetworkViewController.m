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

#import "CRNSURLConnectionWithAsyncHandler.h"
#import "CRNSURLConnectionWithDelegate.h"
#import "CRNSURLConnectionWithSyncHandler.h"
#import "CRNSURLSessionDataTaskWithDelegate.h"
#import "CRNSURLSessionDataTaskWithHandler.h"
#import "CRNSURLSessionDownloadTaskWithHandler.h"
#import "CRNetworkViewController.h"
#import "CRTextViewTableViewCell.h"
#import "ThreeButtonTableViewCell.h"

#define kConnectionSection 0
#define kProtocolSection 1
#define kPunchItSection 2
#define kTextViewSection 3
#define kNumberOfSections (kTextViewSection + 1)

@interface CRNetworkViewController () <NSURLConnectionDelegate>
@property (nonatomic) NSString *protocol;
// Array of integers, same length as the number of sections (one row can be selected per section)
@property (nonatomic) NSMutableArray *selectedRows;
@property (nonatomic) NSArray *cellNames;
@property (nonatomic) NSArray *networkAPIs;
@property (nonatomic) NSOperationQueue *queue;
@property (nonatomic) NSMutableString *textViewContents;
@end

@implementation CRNetworkViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _textViewContents = [[NSMutableString alloc] init];
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = 1;
    _selectedRows = [NSMutableArray arrayWithObjects:@(0), @(0), @(0), nil];
    _networkAPIs = @[
                     [[CRNSURLConnectionWithDelegate alloc] initWithDelegate:self],
                     [[CRNSURLConnectionWithAsyncHandler alloc] initWithDelegate:self],
                     [[CRNSURLConnectionWithSyncHandler alloc] initWithDelegate:self],
                     [[CRNSURLSessionDataTaskWithHandler alloc] initWithDelegate:self],
                     [[CRNSURLSessionDownloadTaskWithHandler alloc] initWithDelegate:self],
                     [[CRNSURLSessionDataTaskWithDelegate alloc] initWithDelegate:self]
                     ];
    _cellNames = @[
                   @[@"[NSURLConnection connectionWithRequest]",
                     @"[NSURLConnection sendAsynchronousRequest]",
                     @"[NSURLConnection sendSynchronousRequest]",
                     @"[NSURLSession dataTask]",
                     @"[NSURLSession downloadTask]",
                     @"[NSURLSession dataTask:withDelegate]"],
                   @[@"HTTP",
                     @"HTTPS"],
                   @[
                       @[@"GET 100b", @"GET 5Kb", @"GET 7MB"],
                       @[@"POST 100b", @"POST 4Kb", @"POST 3Mb"],
                       @[@"Latency 1s", @"Latency 3s", @"Latency 10s"],
                       @[@"Do 202", @"Do 404", @"Do 500"]],
                   @[@"UIWebView"],
                   @[@"PLACEHOLDER, NOT USED"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tView registerNib:[UINib nibWithNibName:@"ThreeButtonTableViewCell" bundle:nil] forCellReuseIdentifier:@"ThreeButtonTableViewCell"];
    self.protocol = @"HTTP";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *cellsInSection = _cellNames[section];
    return cellsInSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == kConnectionSection || indexPath.section == kProtocolSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"
                                               forIndexPath:indexPath];
        cell.textLabel.text = _cellNames[(NSUInteger)indexPath.section][(NSUInteger)indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if ([self isCellSelectedAtIndexPath:indexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if (indexPath.section == kPunchItSection) {
        id buttonCell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"ThreeButtonTableViewCell"
                                               forIndexPath:indexPath];
        buttonCell = (id)cell;
        [[buttonCell aButton] setTitle:_cellNames[(NSUInteger)indexPath.section][(NSUInteger)indexPath.row][0]
                              forState:UIControlStateNormal];
        [[buttonCell aButton] addTarget:self
                                 action:@selector(hitButton:)
                       forControlEvents:UIControlEventTouchUpInside];
        [[buttonCell bButton] setTitle:_cellNames[(NSUInteger)indexPath.section][(NSUInteger)indexPath.row][1]
                              forState:UIControlStateNormal];
        [[buttonCell bButton] addTarget:self
                                 action:@selector(hitButton:)
                       forControlEvents:UIControlEventTouchUpInside];
        [[buttonCell cButton] setTitle:_cellNames[(NSUInteger)indexPath.section][(NSUInteger)indexPath.row][2]
                              forState:UIControlStateNormal];
        [[buttonCell cButton] addTarget:self
                                 action:@selector(hitButton:)
                       forControlEvents:UIControlEventTouchUpInside];
    } else if (indexPath.section == kTextViewSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
        CRTextViewTableViewCell *textViewCell = (CRTextViewTableViewCell *)cell;
        [self updateTextViewContents:textViewCell.textView];
    }
    NSAssert(cell, @"bad index path: %@", indexPath);
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == kConnectionSection) {
        return @"Choose Connection Type:";
    } else if (section == kProtocolSection) {
        return @"Choose Protocol:";
    } else if (section == kPunchItSection) {
        return @"Punch It:";
    } else if (section == kTextViewSection) {
        return @"Responses:";
    }
    return nil;
}

#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != kPunchItSection) {
        _selectedRows[(NSUInteger)indexPath.section] = @(indexPath.row);
    }
    if (indexPath.section == kProtocolSection) {
        self.protocol = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    }
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kTextViewSection) {
        return 120.0;
    }
    return 44.0;
}

#pragma mark Button Action Methods

- (void)hitButton:(UIButton *)sender {
    [self performCommand:sender.titleLabel.text];
}

- (void)performCommand:(NSString *)command {
    NSArray *components = [command componentsSeparatedByString:@" "];
    NSString *action = [components objectAtIndex:0];
    NSString *modifier = [components objectAtIndex:1];
    //GET
    //http://httpbin.org/bytes/:n
    //POST
    //http://httpbin.org/post
    //GET delay
    //http://httpbin.org/delay/:n
    //GET codes
    //http://httpbin.org/status/:code
    NSLog(@"ACTION = %@, MODIFIER = %@", action, modifier);
    NSString *url = @"";
    long bytes = 1;
    int latency = 0;
    NSString *http = [self.protocol lowercaseString];
    if ([action isEqualToString:@"GET"] || [action isEqualToString:@"POST"]) {
        NSString *mb = [modifier stringByReplacingOccurrencesOfString:@"Mb" withString:@" 1000 1000"];
        NSString *kb = [mb stringByReplacingOccurrencesOfString:@"Kb" withString:@" 1000"];
        NSString *b = [kb stringByReplacingOccurrencesOfString:@"b" withString:@""];
        for (NSString *comp in[b componentsSeparatedByString : @" "]) {
            if (comp.length > 0)
                bytes = bytes * (long)[comp longLongValue];
        }
        if ([action isEqualToString:@"GET"]) {
            url = [NSString stringWithFormat:@"%@://httpbin.org/bytes/%lu", http, bytes];
        } else {
            url = [NSString stringWithFormat:@"%@://httpbin.org/post", http];
        }
    } else if ([action isEqualToString:@"Latency"]) {
        latency = [[modifier stringByReplacingOccurrencesOfString:@"s" withString:@""] intValue];
        url = [NSString stringWithFormat:@"%@://httpbin.org/delay/%i", http, latency];
        action = @"GET";
    } else if ([action isEqualToString:@"Do"]) {
        url = [NSString stringWithFormat:@"%@://httpbin.org/status/%@", http, modifier];
        action = @"GET";
    }
    NSLog(@"URL = %@", url);
    NSLog(@"action = %@", action);
    NSLog(@"Bytes = %lu", bytes);
    NSLog(@"Latency = %i", latency);
    NSMutableURLRequest *reg = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    if ([action isEqualToString:@"POST"]) {
        [reg setHTTPMethod:@"POST"];
        if (bytes == 1) {
            [reg setHTTPBody:[@"HELLO WORLD" dataUsingEncoding : NSUTF8StringEncoding]];
        } else {
            NSMutableData *theData = [NSMutableData dataWithCapacity:bytes];
            for (unsigned int i = 0; i < bytes / 4; ++i) {
                u_int32_t randomBits = arc4random();
                [theData appendBytes:(void *)&randomBits length:4];
            }
            [reg setHTTPBody:theData];
        }
    }
    [[self selectedNetworkApi] performRequest:reg onQueue:_queue];
}

- (BOOL)isCellSelectedAtIndexPath:(NSIndexPath *)path {
    return (path.section != kPunchItSection) && (path.section != kTextViewSection) &&
    ([_selectedRows[(NSUInteger)path.section] isEqual:@(path.row)]);
}

- (CRNetworkAPI *)selectedNetworkApi {
    NSNumber *index = _selectedRows[kConnectionSection];
    return _networkAPIs[[index integerValue]];
}

- (void)requestFinishedWithResponse:(NSURLResponse *)response
                           andError:(NSError *)error {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *output = nil;
    if (!error) {
        output = [NSString stringWithFormat:@"(%@) %@\n",
                  @(httpResponse.statusCode), httpResponse.URL];
    } else {
        output = [NSString stringWithFormat:@"(err %@) %@\n",
                  @(error.code), httpResponse.URL];
    }
    NSLog(@"%@", output);
    @synchronized(_textViewContents) {
        CRTextViewTableViewCell *cell = [self textViewCell];
        [_textViewContents appendString:output];
        [self performSelectorOnMainThread:@selector(updateTextViewContents:)
                               withObject:cell.textView
                            waitUntilDone:NO];
    }
}

- (CRTextViewTableViewCell *)textViewCell {
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:kTextViewSection];
    return (CRTextViewTableViewCell *)[_tView cellForRowAtIndexPath:path];
}

- (void)updateTextViewContents:(UITextView *)textView {
    textView.text = _textViewContents;
    NSRange range = NSMakeRange(textView.text.length - 1, 1);
    [textView scrollRangeToVisible:range];
}

@end
