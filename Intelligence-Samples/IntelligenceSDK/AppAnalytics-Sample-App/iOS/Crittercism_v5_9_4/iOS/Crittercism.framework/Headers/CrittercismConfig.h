/*!
*@header CrittercismConfig.h
* Crittercism-iOS
*
*@author Created by David Shirley on 1/8/15.
*@copyright  Copyright © 2019 VMWare. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "CrittercismDelegate.h"

@class CRFilter;


NS_ASSUME_NONNULL_BEGIN

/*!
 *@class CrittercismConfig
 * This object is used to specify various configuration options to Crittercism.
 * Once this object is setup, you can pass it to [Crittercism enableWithAppID:andConfig:].
 * After Crittercism is initialized, changes to this object will have no affect.
 */
@interface CrittercismConfig : NSObject

/*!
 * Determines whether Service Monitoring should capture network performance
 * information for network calls made through NSURLConnection.
 * Default value: YES
 */
@property (nonatomic, assign) BOOL monitorNSURLConnection;

/*!
 * Determines whether Service Monitoring should capture network performance
 * information for network calls made through NSURLSession.
 * Default value: YES
 */
@property (nonatomic, assign) BOOL monitorNSURLSession;

/*!
 * Determines whether the client will send data to Apteligent while on a cellular network
 * Default value: YES
 */
@property (nonatomic) BOOL allowsCellularAccess;

/*!
 * Report geo location information with Crittercism data. This setting is on by default,
 * but location information will only be reported if your app is already using location
 * services; in otherwords, your users will never receive a popup asking to use location
 * services on account of Crittercism.
 *
 * This setting is reserved for future use. Currently location information is not
 * reported unless you call [Crittercism setLocation:]. In the future that call
 * will be deprecated and this setting will be used instead.
 *
 * Default value: YES
 */
@property (nonatomic) BOOL reportLocationData;

/*!
 * Determine whether Service Monitoring should capture network performance
 * information for network calls made through a UIWebView or WKWebView. Currently
 * only page loads and page transitions are captured. Calls made via javascript
 * are currently not captured.
 *
 *
 * UIWebView and WKWebView monitoring are disabled on tvOS
 * The default value is "disabled" because use of the UIWebView or WKWebView
 * class has the side effect of calling [UIWebView initialize] or
 * [WKWebView initialize], both of which create new threads to manage webviews.
 * Since Crittercism cannot prevent these side effects from happening and many
 * apps do not use webviews, service monitoring for webviews must be explicitly
 * enabled.
 *
 * Default value: NO
 */
@property (nonatomic, assign) BOOL monitorUIWebView;

/*!
 * @see monitorUIWebView
 * Default value: NO
 */
@property (nonatomic, assign) BOOL monitorWKWebView;

@property (nonatomic, assign) BOOL monitorWCSession DEPRECATED_MSG_ATTRIBUTE("WCSession monitoring is discontinued. Setting this property will have no effect.  This property will be removed in a future release.");

/*!
 * Determines whether Crittercism service monitoring is enabled at all.
 * If this flag is set to NO, then no instrumentation will be installed AND
 * the thread that sends service monitoring data will be disabled.
 * Default value: YES (enabled)
 */
@property (nonatomic, assign) BOOL enableServiceMonitoring;

/*!
 * Determines whether Crittercism should automatically send app load request or
 * the app will decide when app load request should be sent by calling sendAppLoadData.
 * Default value: NO (Crittercism will automatically send app load request)
 */
@property (nonatomic, assign) BOOL delaySendingAppLoad;

/*!
 * An array of CRFilter objects. These filters are used to make it so certain
 * network performance information is not reported to Crittercism, for example
 * URLs that may contain sensitive information. These filters can also be used
 * to prevent URL query parameters from being stripped out (by default all query
 * parameters are removed before being sent to Crittercism).
 */
@property (nonatomic, strong) NSArray<CRFilter *> *urlFilters;


/*!
 * This object provides a callback that Crittercism will use to notify an app
 *that the app crashed on the last load.
 */
@property (nonatomic, strong, nullable) id<CrittercismDelegate> delegate;

/*!
 * By default mach exception handling is enabled.  This allows capturing additional 
 * crashes such as stack overflows. Since installing a mach exception handler can 
 * interfere with debuggers, this setting will not take effect when a debugger is attached.
 * You may choose to disable mach exception handling if you have some code that
 * already handles mach exceptions.  
 *
 * This configuration is always disabled in tvOS, setting it YES in tvOS will have no effect.
 */
@property (nonatomic, assign) BOOL enableMachExceptionHandling;

/*!
 * This enhances support for iMessage extensions. This configuration flag should be
 * set prior to initializing the SDK from inside the iMessage extension.
 */
@property (nonatomic, assign) BOOL iMessageExtension;

/*!
 * This enhances support for today extensions. This configuration flag should be
 * set prior to initializing the SDK from inside the today extension.
 */
@property (nonatomic, assign) BOOL todayExtension;

/*!
 * Creates a new CrittercismConfig object with the default values for the above
 * properties. You can modify the config values and pass this object into
 * [Crittercism enableWithAppID:andConfig]
 * @return CrittercismConfig with default values
 */
+ (CrittercismConfig *)defaultConfig;

/*! @return a print out of all config settings*/
- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
