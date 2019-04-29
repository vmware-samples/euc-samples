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


#import "CRNSURLConnectionWithDelegate.h"
#import "CRNetworkAPI.h"

@interface CRNSURLConnectionDelegate : NSObject
@property (nonatomic) NSURLResponse *response;
@property (nonatomic) id<NetworkAPIDelegate> delegate;

- (id)initWithNetworkApiDelegate:(id<NetworkAPIDelegate>)delegate;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
@end

@implementation CRNSURLConnectionWithDelegate

- (void)performRequest:(NSURLRequest *)request onQueue:(NSOperationQueue *)queue;
{
    CRNSURLConnectionDelegate *delegate = [[CRNSURLConnectionDelegate alloc] initWithNetworkApiDelegate:self.delegate];

    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request
                                                            delegate:delegate
                                                    startImmediately:NO];

    [conn setDelegateQueue:queue];
    [conn start];
}

@end

@implementation CRNSURLConnectionDelegate

- (id)initWithNetworkApiDelegate:(id<NetworkAPIDelegate>)delegate {
    self = [super init];

    if (self) {
        _delegate = delegate;
    }

    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_delegate requestFinishedWithResponse:_response andError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [_delegate requestFinishedWithResponse:_response andError:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _response = response;
}
@end
