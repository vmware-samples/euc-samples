/*!
 *@header  Crittercism.h
 *  Crittercism iOS Library
 *
 *@copyright  Copyright © 2019 VMWare. All rights reserved.
*/
#import <Foundation/Foundation.h>
#import "CrittercismDelegate.h"
#import "CRFilter.h"
#import "CrittercismConfig.h"
#import "CrittercismConstants.h"

@class CrittercismConfig;

//In your application you can see data for a crash from the previous session:
//The data visible includes: Crash Name, Crash Reason and Crash TimeStamp
//
//Example:
//[[NSNotificationCenter defaultCenter] addObserverForName:CrittercismDidCrashOnLastLoadNotification
//                                                 object:nil
//                                             usingBlock:^(NSNotification *notification){
//                                                NSString *crashName = notification.userInfo[CrittercismCrashName];
//                                                NSString *crashReason = notification.userInfo[CrittercismCrashReason];
//                                                NSString *crashDate = notification.userInfo[CrittercismCrashDate];
//                                                NSArray *crashView = notification.userInfo[CrittercismCrashView];
//                                              }];
NS_ASSUME_NONNULL_BEGIN

/*!
 *@class Crittercism
 *
 * Operating System Support
 *
 * The Crittercism iOS library supports iOS v7.0+
 *
 * Additional Requirements:
 *
 * Crittercism requires that you link to the SystemConfiguration framework.
 *
 * Basic Integration
 *
 * In your Application Delegate's application:didFinishLaunchingWithOptions:
 * method, add a call to +[Crittercism enableWithAppID:], supplying the app ID
 * of an app you created via the Crittercism Web Portal.
 *
 * Example:
 *
 * [Crittercism enableWithAppID:@"YOURAPPIDGOESHERE"];
 *
 */
@interface Crittercism : NSObject


// You can pass in a delegate that conforms to the CrittercismDelegate protocol
// if you wish to be notified that your app crashed on the previous load.
// This protocol currently has only one method:
//
//   - (void)crittercismDidCrashOnLastLoad;
//
// Alternatively, you can check the didCrashOnLastLoad BOOL property.
//
// The filters parameter can be used to prevent sensitive URLs from being
// captured by the network instrumentation. To use this, pass in an
// NSArray of CRFilter objects that will be matched against URLs captured by the
// library.
//
// (Note - the filtering will take place off of your application's main thread.)

/*!
 * Enabling Crittercism, this method must be called before any other Crittercism functionality
 * @param appId NSString is your iOS Crittercism appId
 */
+ (void)enableWithAppID:(NSString *)appId;

//deprecated methods
+ (void)enableWithAppID:(NSString *)appId
            andDelegate:(nullable id <CrittercismDelegate>)critterDelegate
  DEPRECATED_MSG_ATTRIBUTE("Use enableWithAppID:andConfig instead");

+ (void)enableWithAppID:(NSString *)appId
            andDelegate:(nullable id <CrittercismDelegate>)critterDelegate
          andURLFilters:(nullable NSArray *)filters
  DEPRECATED_MSG_ATTRIBUTE("Use enableWithAppID:andConfig instead");

+ (void)enableWithAppID:(NSString *)appId
          andURLFilters:(NSArray *)filters
  DEPRECATED_MSG_ATTRIBUTE("Use enableWithAppID:andConfig instead");


+ (void)enableWithAppID:(NSString *)appId
            andDelegate:(nullable id <CrittercismDelegate>)critterDelegate
          andURLFilters:(nullable NSArray *)filters
 disableInstrumentation:(BOOL)disableInstrumentation
  DEPRECATED_MSG_ATTRIBUTE("Use enableWithAppID:andConfig instead");


/*!
 * Initializes Crittercism with the given App ID (found on the Crittercism web portal)
 * After this call completes, changes to the config object will have no affect on
 * the behavior of Crittercism.
 * @param appId NSString your iOS appId
 * @param config CrittercismConfig your custom CrittercismConfig
 */
+ (void)enableWithAppID:(NSString *)appId andConfig:(nullable CrittercismConfig *)config;

/*!
 * Adds an additional filter for network instrumentation.
 * @see  CRFilter header for additional details.
 * @param filter CRFilter filter to add
 */
+ (void)addFilter:(CRFilter *)filter;

/*!
 * Breadcrumbs provide the ability to track activity within your app.
 * A breadcrumb is a free form string you supply, which will be timestamped,
 * and stored in case a crash occurs. Crash reports will contain the breadcrumb
 * trail from the run of your app that crashed, as well as that of the prior run.
 *
 * Breadcrumbs are limited to 140 characters, and only the most recent 100 are
 * kept. Crittercism will automatically insert a breadcrumb marked "session_start"
 * on each initial launch, or foreground of your app.
 * @param breadcrumb NSString, the custom string to leave a breadcrumb max 140 characters
 */
+ (void)leaveBreadcrumb:(NSString *)breadcrumb;

/*!
 * By default, breadcrumbs are flushed to disk immediately when written.
 * This is by design - in order to provide an accurate record of everything
 * that happened up until the point your app crashed. To improve performance you can
 * instruct the library to perform all breadcrumb writes on a background thread.
 * @param writeAsync BOOL, YES to write breadcrumbs in a background thread
*/
+ (void)setAsyncBreadcrumbMode:(BOOL)writeAsync;

/*!
 * Inform Crittercism of the device's most recent location for use with
 * performance monitoring.
 * @param location CLLoation, insert location here
 */
+ (void)updateLocation:(id)location DEPRECATED_MSG_ATTRIBUTE("Please use updateLocationToLatitude:longitude:");

/*!
 * Inform Crittercism of the device's most recent location for use with
 * performance monitoring.
 * @param latitude double latitude value
 * @param longitude double longitude value
 */
+ (void)updateLocationToLatitude:(double)latitude longitude:(double)longitude;

/*!
 * Handled exceptions are a way of reporting exceptions your app intentionally
 * caught. If the passed in NSException object was thrown, the stack trace
 * of the thread that threw the exception will be displayed on the Crittercism
 * web portal.
 *
 * Reporting of handled exceptions is throttled to once per minute. During
 * that minute period, up to 5 handled exceptions will be buffered.
 *
 * @param exception NSException exception to log
 */
+ (BOOL)logHandledException:(NSException *)exception;

/*!
 * Logging errors is a way of reporting errors your app has received.  If
 * the method is passed an NSError *error, the stack trace of the thread that
 * is logging the error will be displayed on the Crittercism web portal.
 * @param error NSError error to log
 */
+ (BOOL)logError:(NSError *)error;

/*!
 * Logging errors is a way of reporting errors your app has received. This
 * method is the same as above, but allows a custom stack trace to be added
 * instead of collecting it automatically.
 * @param error NSError error to log
 * @param stacktrace NSArray an array of strings representing a stack trace
 */
+ (BOOL)logError:(NSError *)error
      stacktrace:(NSArray <NSString *> *)stacktrace;

/*!
 * Logging endpoints is a way of manually logging custom network library
 * network access to URL's which fall outside Crittercism's monitoring
 * of NSURLConnection and ASIHTTPRequest and NSURLSession method calls.
 * @param method NSString the connection method ex GET, POST
 * @param urlString NSString the url
 * @param latency NSTimeInterval, the time between data being sent and received
 * @param bytesRead NSUInteger the amout of data downloaded
 * @param bytesSent NSUInteger the amout of data uploaded
 * @param responseCode NSUInteger the response from the server
 * @param error NSError any error accociated with the network reqest
 * @return YES if the request was properly logged
 */
+ (BOOL)logNetworkRequest:(NSString *)method
                urlString:(NSString *)urlString
                  latency:(NSTimeInterval)latency
                bytesRead:(NSUInteger)bytesRead
                bytesSent:(NSUInteger)bytesSent
             responseCode:(NSInteger)responseCode
                    error:(nullable NSError *)error;

/*!
 * Logging endpoints is a way of manually logging custom network library
 * network access to URL's which fall outside Crittercism's monitoring
 * of NSURLConnection and ASIHTTPRequest and NSURLSession method calls.
 * @see + (BOOL)logNetworkRequest:(NSString *)method
 * urlString:(NSString *)urlString
 * latency:(NSTimeInterval)latency
 * bytesRead:(NSUInteger)bytesRead
 * bytesSent:(NSUInteger)bytesSent
 * responseCode:(NSInteger)responseCode
 * error:(NSError *)error;
 */
+ (BOOL)logNetworkRequest:(NSString *)method
                      url:(NSURL *)url
                  latency:(NSTimeInterval)latency
                bytesRead:(NSUInteger)bytesRead
                bytesSent:(NSUInteger)bytesSent
             responseCode:(NSInteger)responseCode
                    error:(nullable NSError *)error;

/*! If you wish to offer your users the ability to opt out of Crittercism
 * crash reporting, you can set the OptOutStatus to YES. If you do so, any
 * pending crash reports will be purged.
 * @param status BOOL YES to disable Crittercism
 */
+ (void)setOptOutStatus:(BOOL)status;

/*!
 * Retrieve current opt out status.
 */
+ (BOOL)getOptOutStatus;

// Set the maximum number of crash reports that will be stored on
// the local device if the device does not have internet connectivity. If
// more than |maxOfflineCrashReports| crashes occur, the oldest crash will be
// overwritten. Decreasing the value of this setting will not delete
// any offline crash reports. Unsent crash reports will be kept until they are
// successfully transmitted to Crittercism, hence there may be more than
// |maxOfflineCrashReports| stored on the device for a short period of time.
//
// The default value is 3, and there is an upper bound of 10.

+ (void)setMaxOfflineCrashReports:(NSUInteger)max DEPRECATED_MSG_ATTRIBUTE("This method will be removed in a future release");

// Get the maximum number of Crittercism crash reports that will be stored on
// the local device if the device does not have internet connectivity.

+ (NSUInteger)maxOfflineCrashReports DEPRECATED_MSG_ATTRIBUTE("This method will be removed in a future release");

/*!
 * Get the Crittercism generated unique identifier for this device.
 * !! This is NOT the device's UDID.
 *
 * If called before enabling the library, this will return an empty string.
 *
 * All Crittercism enabled apps on a device will share the UUID created by the
 * first installed Crittercism enabled app.
 *
 * If all Crittercism enabled applications are removed from a device, a new
 * UUID will be generated when the next one is installed.
 */
+ (NSString *)getUserUUID;

/*!
 * Associate a username string with the device's Crittercism UUID. This will
 * send the association to Crittercism's back end.
 * @param username NSString the new UUID
 */
+ (void)setUsername:(NSString *)username;

/*!
 * Associate an arbitrary key/value pair with the device's Crittercism UUID.
 * @param value NSString the value
 * @param key NSString the key
 */
+ (void)setValue:(NSString *)value forKey:(NSString *)key;

/*!
 *@return the CrittercismDelegate
 */
+ (nullable id <CrittercismDelegate>)delegate
DEPRECATED_MSG_ATTRIBUTE("Please listen to CrittercismDidCrashOnLastLoadNotification");

/*!
 * set the delegate to get a callback if the app crashed on last load
 * @param delegate id <CrittercismDelegate> to set the delegate to
 */
+ (void)setDelegate:(nullable id <CrittercismDelegate>)delegate
DEPRECATED_MSG_ATTRIBUTE("Please listen to CrittercismDidCrashOnLastLoadNotification");


/*!
 *@return YES if the app crashed on the last load
 */
+ (BOOL)didCrashOnLastLoad;

/*!
 * Init and begin a userflow with a default value.
 *@param name NSString the name of the userflow
 */
+ (void)beginUserflow:(NSString *)name;

/*!
 * Init and begin a userflow with an input value.
 * @param name NSString the name of the userflow
 * @param value int the value of the userflow
 */
+ (void)beginUserflow:(NSString *)name withValue:(int)value;

/*!
 * Cancel a userflow as if it never existed. The userflow will not be reported
 * @param name NSString the name of the userflow
 */
+ (void)cancelUserflow:(NSString *)name;

/*!
 * End an already begun userflow successfully.
 * @param name NSString the name of the userflow 
 */
+ (void)endUserflow:(NSString *)name;

/*!
 * End an already begun userflow as a failure.
 * @param name NSString the name of the userflow
 */
+ (void)failUserflow:(NSString *)name;

/*!
 * Get the currency cents value of a userflow.
 * @param name NSString the name of the userflow
 */
+ (int)valueForUserflow:(NSString*)name;

/*!
 * Set the currency cents value of a userflow.
 * @param name NSString the name of the userflow
 */
+ (void)setValue:(int)value forUserflow:(NSString*)name;

// Deprecated, please use beginUserflow:

+ (void)beginTransaction:(NSString *)name DEPRECATED_MSG_ATTRIBUTE("Please use beginUserflow:");

// Deprecated, please use beginUserflow:withValue:

+ (void)beginTransaction:(NSString *)name withValue:(int)value DEPRECATED_MSG_ATTRIBUTE("Please use beginUserflow:withValue:");

// Deprecated, please use cancelUserflow:

+ (void)cancelTransaction:(NSString *)name DEPRECATED_MSG_ATTRIBUTE("Please use cancelUserflow:");

// Deprecated, please use endUserflow:

+ (void)endTransaction:(NSString *)name DEPRECATED_MSG_ATTRIBUTE("Please use endUserflow:");

// Deprecated, please use failUserflow:

+ (void)failTransaction:(NSString *)name DEPRECATED_MSG_ATTRIBUTE("Please use failUserflow:");

// Deprecated, please use valueForUserflow:

+ (int)valueForTransaction:(NSString*)name DEPRECATED_MSG_ATTRIBUTE("Please use valueForUserflow:");

// Deprecated, please use setValue:forUserflow:

+ (void)setValue:(int)value forTransaction:(NSString*)name DEPRECATED_MSG_ATTRIBUTE("Please use setValue:forUserflow:");

/*!
 * Tell Crittercism to send app load event.
 * By default, Crittercism will send app load event automatically when your app is started
 * However, if you set delaySendingAppLoad flag to YES on config, you can call this method to
 * manually send app load event.
 */
+ (void)sendAppLoadData;

/*!
 * Set the logging level to tune the verbosity of Crittercism log messages
 * @param loggingLevel CRLoggingLevel the verbosity of logging
 */
+ (void)setLoggingLevel:(CRLoggingLevel) loggingLevel;

/*!
 * The current level of logging
 *@return the current logging level
 */
+ (CRLoggingLevel)loggingLevel;

/*!
 *Tell crittercism that your app is about to have exit() or abort() called on it
 *Likely will only be used by internally distributed or test applications
 */
+ (void)logAbort;
+ (void)logExit;

@end

NS_ASSUME_NONNULL_END
