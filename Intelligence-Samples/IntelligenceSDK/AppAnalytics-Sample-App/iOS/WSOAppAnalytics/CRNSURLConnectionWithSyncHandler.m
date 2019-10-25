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


#import "CRNSURLConnectionWithSyncHandler.h"

@implementation CRNSURLConnectionWithSyncHandler

- (void)performRequest:(NSURLRequest *)request onQueue:(NSOperationQueue *)queue
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^(void) {
        NSURLResponse *response = nil;
        NSError *error = nil;

        [NSURLConnection sendSynchronousRequest:request
                              returningResponse:&response
                                          error:&error];

        [self.delegate requestFinishedWithResponse:response andError:error];
    }];

    [queue addOperation:op];
}

@end
