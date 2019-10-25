/*!
*@header  CRFilter.h
*Crittercism iOS Library
*@author  Created by Sean Hermany on 7/16/13.
* Copyright © 2019 VMWare. All rights reserved.
*/

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CRFilterType) {
  CRFilterTypeScrubQuery, // Default
  CRFilterTypeBlacklist,
  CRFilterTypePreserveQuery,
  CRFilterTypePreserveFragment,
  CRFilterTypePreserveParameters,
  CRFilterTypePreserveAll,
  CRFilterTypeMax
};

/*!
 @class CRFilter
 Filters can be supplied to Crittercism to adjust the behavior of how URLs are
 captured and reported on for performance monitoring purposes.

 By default, all URLs captured by Crittercism will be reported when
 performance monitoring is enabled.

 By default, the credentials, query, fragment, and parameters portions of all URLs will be stripped.
 
 That is, a request for the URL:
 
 https://johnny:p4ssw0rd@www.example.com:443/script.ext;param=value?query=value#ref

 will be reported as: https://www.example.com:443/script.ext
 
 The following filters can be added to modify this behavior.
 
 - CRFilterTypeBlacklist - Blacklist filters: discard data pertaining to any matching URLs

    [CRFilter filterWithString:@"example.com"];
    [CRFilter filterWithString:@"example.com" andFilterType:CRFilterTypeBlacklist];
 
    These two methods are equivalent. Either of these filters will blacklist all URLs that
    match the provided string.
 
 
 - CRFilterTypePreserveQuery - Preserves the query portion of any matching URLs
 
   [CRFilter filterWithString:@"example.com" andFilterType:CRFilterTypePreserveQuery];
 
   Resulting URL: https://www.example.com:443/script.ext?query=value
 
 
 - CRFilterTypePreserveParameters - Preserves the parameters portion of any matching URLs
 
   [CRFilter filterWithString:@"example.com" andFilterType:CRFilterTypePreserveParameters];
 
   Resulting URL: https://www.example.com:443/script.ext;param=value
 
 
 - CRFilterTypePreserveFragment - Preserves the fragment portion of any matching URLs
 
   [CRFilter filterWithString:@"example.com" andFilterType:CRFilterTypePreserveFragment];
 
   Resulting URL: https://www.example.com:443/script.ext#ref
 
 
 - CRFilterTypePreserveAll - Preserves the query, fragment, and parameters portion of any matching URLs
 
   [CRFilter filterWithString:@"example.com" andFilterType:CRFilterTypePreserveAll];
 
   Resulting URL: https://www.example.com:443/script.ext;param=value?query=value#ref
 
 
 - Initializing Crittercism with the above filters:

    [Crittercism enableWithAppID:@"YOURAPPID" andConfig:config];
    [Crittercism addFilter:[CRFilter filterWithString:@"example.com" andFilterType:CRFilterTypeBlacklist]];

 Notes:

 * Filters match URLs via CASE SENSITIVE substring matching
 * Filters can either be supplied when Crittercism is enabled, as an array of
   CRFilter objects, or added dynamically at any time.
 * Username and password information is always stripped provided the input URL
   is RFC 1808 compliant.
*/

NS_ASSUME_NONNULL_BEGIN

@interface CRFilter : NSObject

@property (readonly, assign) CRFilterType filterType;

#pragma mark - Class Methods

/*!
 *Convenience method to create a blacklisting filter
 *@param matchToken An NSString of the url to filter
 *@return The CRFilter for matchToken
 */
+ (CRFilter *)filterWithString:(NSString *)matchToken;

/*!
 *Convenience method to create a filter with a certain type
 *@param matchToken An NSString of the url to filter
 *@param filterType CRFilterType specifies the filter type
 *@return The CRFilter for matchToken
 */
+ (CRFilter *)filterWithString:(NSString *)matchToken
                 andFilterType:(CRFilterType)filterType;

/*!
 *Convenience method to create a filter which preserves the query portion of
 * Convenience method to create a filter which preserves the query portion of
 */
+ (CRFilter *)queryPreservingFilterWithString:(NSString *)matchToken DEPRECATED_MSG_ATTRIBUTE("Query parameter preservation has been removed. Filters of this type will be ignored. This method will be removed in a future release");

/*!
 *Filter a URL, specifying which type of filter to use.
 *@param filterType CRFilterType specifies the filter type
 *@param url NSString specifies the url
 *@return nil when a blacklist filter is specified.
 */
+ (nullable NSString *)applyFilter:(CRFilterType)filterType ToURL:(NSString *)url DEPRECATED_MSG_ATTRIBUTE("This method will be removed in a future release");


#pragma mark - Instance Methods

/*!
 *Initialize a filter that blacklists all URLs that match the specified token
 *@param matchToken NSString the of the url to filter
 *@return CRFilter of type CRFilterTypeBlacklist
 */
- (id)initWithString:(NSString *)matchToken;

/*!
 *CRFilter designated initializer
 *@param matchToken NSString the of the url to filter
 *@param filterType CRFilterType indicates filter type CRFilterTypeScrubQuery, CRFilterTypeBlacklist, CRFilterTypePreserveQuery
 *@return CRFilter with the indicated filter type
 */
- (id)initWithString:(NSString *)matchToken
       andFilterType:(CRFilterType)filterType;

/*!
 *Checks if the url matches this filter
 *@param url NSString indicates the url to test
 *@return YES if the url matches, NO if it does not
 */
// Does specified URL match this filter?
- (BOOL)doesMatch:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
