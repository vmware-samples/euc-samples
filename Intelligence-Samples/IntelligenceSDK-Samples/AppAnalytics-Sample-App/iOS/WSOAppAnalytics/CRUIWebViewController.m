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

#import "CRUIWebViewController.h"
#import <Crittercism/Crittercism.h>

@implementation WebController

#pragma mark - Life Cycle

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
  if (_uiWebView) {
    _uiWebView.delegate = nil;
  }
  if (_wkWebView) {
    _wkWebView.navigationDelegate = nil;
    _wkWebView.UIDelegate = nil;
  }
}

#pragma mark - Managing the View

- (void)addWKWebView {
  NSAssert([NSThread isMainThread],@"Call on Main Thread");
  // IB doesn't know about WKWebView, so we have to push it in dynamically.
  // Original "dummyView" child is a UIView placed into IB storyboard in lieu
  // of the WKWebView we are just now creating.
  Class clss = NSClassFromString(@"WKWebView");
  if (clss) {
    _wkWebView = [[clss alloc] initWithFrame:self.uiWebView.frame];
    _wkWebView.contentMode = _uiWebView.contentMode;
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    _wkWebView.hidden = YES;
    UIView *parent = [self.uiWebView superview];
    [parent addSubview:_wkWebView];
  }
}

- (void)viewDidLoad {
  // "Called after the controller’s view is loaded into memory."
  // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
  [super viewDidLoad];
  self.uiWebView.delegate = self;
  [self addWKWebView];
  [self synchUI];
}

#pragma mark - Responding to View Events

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self synchUI];
  if (!self.withURL) {
    self.withURL = @"http://www.google.com";
  }
  [self loadAddress:_withURL];
}

- (void)viewWillDisappear:(BOOL)animated {
  // "Notifies the view controller that its view was added to a view hierarchy."
  [super viewWillDisappear:animated];
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout:) object:nil];
  if ([_uiWebView isLoading]) {
    [_uiWebView stopLoading];
  }
  if (_wkWebView.loading) {
    [_uiWebView stopLoading];
  }
}

#pragma mark - Configuring the View Rotation Settings

- (BOOL)shouldAutorotate:(UIInterfaceOrientation)interfaceOrientation {
  // Returns a Boolean value indicating whether the view controller
  // supports the specified orientation. (Deprecated in iOS 6.0.
  // Override the supportedInterfaceOrientations (page 1450) and
  // preferredInterfaceOrientationForPresentation (page 1440) methods
  // instead.)
  return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
  // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
  if (theTextField == _textField) {
    [_textField resignFirstResponder];
    [self loadAddress:_textField.text];
  }
  return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  // Dismiss the keyboard when the view outside the text field is touched.
  [_textField resignFirstResponder];
  // Revert the text field to the previous value.
  [self synchUI];
  [super touchesBegan:touches withEvent:event];
}

#pragma mark - UIToolbarDelegate
// "This protocol declares no methods of its own but conforms to
// the UIBarPositioningDelegate protocol to support the positioning
// of a toolbar when it is moved to a window."

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
  if (bar == _topToolBar) {
    return UIBarPositionTopAttached;
  } else {
    return UIBarPositionBottom;
  }
}

#pragma mark - UIWebViewDelegate

- (void)timeout:(id)sender {
  NSLog(@"timeout");
}

- (NSString*)stringWithUIWebViewNavigationType:(UIWebViewNavigationType)navigationType {
  NSString* answer=@"???";
  switch (navigationType) {
      case UIWebViewNavigationTypeLinkClicked:
          answer=@"LinkClicked";
          break;
      case UIWebViewNavigationTypeFormSubmitted:
          answer=@"FormSubmitted";
          break;
      case UIWebViewNavigationTypeBackForward:
          answer=@"BackForward";
          break;
      case UIWebViewNavigationTypeReload:
          answer=@"Reload";
          break;
      case UIWebViewNavigationTypeFormResubmitted:
          answer=@"FormResubmitted";
          break;
      case UIWebViewNavigationTypeOther:
          answer=@"Other";
          break;
  };
  return answer;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  NSString *navigationTypeString = [self stringWithUIWebViewNavigationType:navigationType];
  NSLog(@"webView:shouldStartLoadWithRequest:navigationType: navigationType == %@", navigationTypeString);
  NSLog(@"webView:shouldStartLoadWithRequest:navigationType: request.URL == %@", request.URL);
  return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
  NSLog(@"webViewDidStartLoad");
  // timeout in case no network
  [self performSelector:@selector(timeout:) withObject:nil afterDelay:15];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
  NSLog(@"webViewDidFinishLoad mainDocumentURL == %@", webView.request.mainDocumentURL);
  NSLog(@"webViewDidFinishLoad URL == %@", webView.request.URL);
  [self synchUI];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  NSLog(@"webView:didFailLoadWithError mainDocumentURL == %@", webView.request.mainDocumentURL);
  NSLog(@"webView:didFailLoadWithError URL == %@", webView.request.URL);
  [self synchUI];
}

#pragma mark - WKNavigationDelegate Deciding Load Policy

- (NSString*)stringWithWKNavigationType:(WKNavigationType)navigationType {
  NSString* answer=@"???";
  switch (navigationType) {
      case WKNavigationTypeLinkActivated:
          answer=@"LinkActivated";
          break;
      case WKNavigationTypeFormSubmitted:
          answer=@"FormSubmitted";
          break;
      case WKNavigationTypeBackForward:
          answer=@"BackForward";
          break;
      case WKNavigationTypeReload:
          answer=@"Reload";
          break;
      case WKNavigationTypeFormResubmitted:
          answer=@"FormResubmitted";
          break;
      case WKNavigationTypeOther:
          answer=@"Other";
          break;
  };
  return answer;
}

- (void)                  webView:(WKWebView *)webView
  decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                  decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  NSString *navigationTypeString = [self stringWithWKNavigationType:navigationAction.navigationType];
  NSLog(@"webView:decidePolicyForNavigationAction:decisionHandler: navigationType == %@", navigationTypeString);
  NSLog(@"webView:decidePolicyForNavigationAction:decisionHandler: request.URL == %@", navigationAction.request.URL);
  //[Crittercism leaveBreadcrumb:@"webView:decidePolicyForNavigationAction:decisionHandler:"];
  [self synchUI];
  ////////////////////////////////////////////////////////////////
  // decisionHandler
  // A block to be called when your app has decided whether to allow
  // or cancel the navigation. The block takes a single parameter,
  // which must be one of the constants of the enumerated type
  // WKNavigationActionPolicy.
  // SEE: https://developer.apple.com/library/IOs/documentation/WebKit/Reference/WKNavigationDelegate_Ref/index.html
  ////////////////////////////////////////////////////////////////
  decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)                    webView:(WKWebView *)webView
  decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
                    decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
  NSLog(@"webView:decidePolicyForNavigationResponse:decisionHandler:");
  NSLog(@"webView:decidePolicyForNavigationResponse:decisionHandler: allHeaderFields == %@",
      ((NSHTTPURLResponse*)navigationResponse.response).allHeaderFields
  );
  //[Crittercism leaveBreadcrumb:@"webView:decidePolicyForNavigationResponse:decisionHandler:"];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  [self synchUI];
  ////////////////////////////////////////////////////////////////
  // decisionHandler
  // A block to be called when your app has decided whether to allow
  // or cancel the navigation. The block takes a single parameter,
  // which must be one of the constants of the enumerated type
  // WKNavigationResponsePolicy.
  // SEE: https://developer.apple.com/library/IOs/documentation/WebKit/Reference/WKNavigationDelegate_Ref/index.html
  ////////////////////////////////////////////////////////////////
  decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - WKNavigationDelegate Tracking Load Progress

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  // "Invoked when a main frame page load starts."
  NSLog(@"webView:didStartProvisionalNavigation:");
  //[Crittercism leaveBreadcrumb:@"webView:didStartProvisionalNavigation:"];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  // "Invoked when a main frame load completes."
  NSLog(@"webView:didFinishNavigation: URL == %@", webView.URL);
  //[Crittercism leaveBreadcrumb:@"webView:didFinishNavigation:"];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  [self synchUI];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  // "Invoked when an error occurs during a committed main frame navigation."
  NSLog(@"webView:didFailNavigation:withError: URL == %@", webView.URL);
  //[Crittercism leaveBreadcrumb:@"webView:didFailNavigation:withError:"];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  [self synchUI];
}

#pragma mark - WKUIDelegate Protocol

-                    (void)webView:(WKWebView *)webView
runJavaScriptAlertPanelWithMessage:(NSString *)message
                  initiatedByFrame:(WKFrameInfo *)frame
                 completionHandler:(void (^)(void))completionHandler
{
    // Displays a JavaScript alert panel.
    // NOTE: WKWebView will not show JavaScript "alert"s unless we implement this method.
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

#pragma mark - Top ToolBar Button Actions

- (void)synchUI {
  if (_wkWebView) {
    _wkWebView.frame = _uiWebView.frame;
  }
  if ((!_wkWebView) || _wkWebView.isHidden) {
    _uiButton.title = @"UIWebView";
    _textField.text = [[_uiWebView.request URL] absoluteString];
  } else {
    _uiButton.title = @"WKWebView";
    _textField.text = [_wkWebView.URL absoluteString];
  }
  [_backButton setEnabled:([self canGoBack]?YES:NO)];
  [_forwardButton setEnabled:([self canGoForward]?YES:NO)];
}

- (IBAction)uiAction:(id)sender {
  @try {
    if (_wkWebView) {
      _wkWebView.hidden = (!_wkWebView.hidden);
    }
    // When one webview disappears, the other is loadRequest'ed to the url
    // of the disappearing webview .
    if ((!_wkWebView) || _wkWebView.isHidden) {
      [_uiWebView loadRequest:[NSURLRequest requestWithURL:_wkWebView.URL]];
    } else {
      [_wkWebView loadRequest:[NSURLRequest requestWithURL:[_uiWebView.request URL]]];
    }
    [self synchUI];
  } @catch (NSException *exception) {
    NSLog(@"EXCEPTION: %@ %@", exception.name, exception.reason);
    NSLog(@"");
  }
}

- (IBAction)jsAction:(id)sender {
  @try {
    // Load JavaScript demo page into visible webview .
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if ((!_wkWebView) || _wkWebView.isHidden) {
      [_uiWebView loadHTMLString:htmlString baseURL:nil];
    } else {
      [_wkWebView loadHTMLString:htmlString baseURL:nil];
    }
    [self synchUI];
  } @catch (NSException *exception) {
    NSLog(@"EXCEPTION: %@ %@", exception.name, exception.reason);
    NSLog(@"");
  }
}

#pragma mark - Webview Actions

- (void)loadAddress:(NSString*)address {
  if ((!_wkWebView) || _wkWebView.isHidden) {
    [_uiWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:address]]];
  } else {
    [_wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:address]]];
  }
  [self synchUI];
}

- (BOOL)canGoBack {
  if ((!_wkWebView) || _wkWebView.isHidden) {
    return [_uiWebView canGoBack];
  } else {
    return [_wkWebView canGoBack];
  }
}

- (BOOL)canGoForward {
  if ((!_wkWebView) || _wkWebView.isHidden) {
    return [_uiWebView canGoForward];
  } else {
    return [_wkWebView canGoForward];
  }
}

- (void)goBack {
  if ((!_wkWebView) || _wkWebView.isHidden) {
    [_uiWebView goBack];
  } else {
    [_wkWebView goBack];
  };
  [self synchUI];
}

- (void)goForward {
  if ((!_wkWebView) || _wkWebView.isHidden) {
    [_uiWebView goForward];
  } else {
    [_wkWebView goForward];
  };
  [self synchUI];
}

#pragma mark - Bottom ToolBar Button Actions

- (IBAction)backHit:(id)sender {
  NSLog(@"");
  //[Crittercism leaveBreadcrumb:@"backHit:"];
  if ([self canGoBack]) {
    [self goBack];
  }
}

- (IBAction)forwardHit:(id)sender {
  NSLog(@"");
  //[Crittercism leaveBreadcrumb:@"forwardHit:"];
  if ([self canGoForward]) {
    [self goForward];
  }
}

@end
