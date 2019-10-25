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

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WebController : UIViewController <UITextFieldDelegate,UIToolbarDelegate,UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate>
@property (strong, nonatomic) IBOutlet UIToolbar *topToolBar;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *uiButton;
@property (strong, nonatomic) IBOutlet UIWebView *uiWebView;
@property (strong, nonatomic) WKWebView *wkWebView;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *jsButton;
@property (nonatomic, strong) NSString *withURL;
- (IBAction)backHit:(id)sender;
- (IBAction)forwardHit:(id)sender;
- (IBAction)uiAction:(id)sender;
- (IBAction)jsAction:(id)sender;
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;
@end
