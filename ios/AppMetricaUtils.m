/*
 * Version for React Native
 * © 2020 YANDEX
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * https://yandex.com/legal/appmetrica_sdk_agreement/
 */

#import "AppMetricaUtils.h"

@implementation AppMetricaUtils

+ (AMAAppMetricaConfiguration *)configurationForDictionary:(NSDictionary *)configDict
{
    NSString *apiKey = configDict[@"apiKey"];
    AMAAppMetricaConfiguration *configuration = [[AMAAppMetricaConfiguration alloc] initWithAPIKey:apiKey];

    if (configDict[@"appVersion"] != nil) {
        configuration.appVersion = configDict[@"appVersion"];
    }
    if (configDict[@"activationAsSessionStart"] != nil) {
        configuration.handleActivationAsSessionStart = [configDict[@"activationAsSessionStart"] boolValue];
    }
    if (configDict[@"firstActivationAsUpdate"] != nil) {
        configuration.handleFirstActivationAsUpdate = [configDict[@"firstActivationAsUpdate"] boolValue];
    }
    if (configDict[@"locationTracking"] != nil) {
        configuration.locationTracking = [configDict[@"locationTracking"] boolValue];
    }
    if (configDict[@"preloadInfo"] != nil) {
        configuration.preloadInfo = [[self class] preloadInfoForDictionary:configDict[@"preloadInfo"]];
    }
    if (configDict[@"sessionsAutoTracking"] != nil) {
        configuration.sessionsAutoTracking = [configDict[@"sessionsAutoTracking"] boolValue];
    }
    if (configDict[@"sessionTimeout"] != nil) {
        configuration.sessionTimeout = [configDict[@"sessionTimeout"] unsignedIntegerValue];
    }

    return configuration;
}

+ (CLLocation *)locationForDictionary:(NSDictionary *)locationDict
{
    if (locationDict == nil) {
        return nil;
    }

    NSNumber *latitude = locationDict[@"latitude"];
    NSNumber *longitude = locationDict[@"longitude"];
    NSNumber *altitude = locationDict[@"altitude"];
    NSNumber *horizontalAccuracy = locationDict[@"accuracy"];
    NSNumber *verticalAccuracy = locationDict[@"verticalAccuracy"];
    NSNumber *course = locationDict[@"course"];
    NSNumber *speed = locationDict[@"speed"];
    NSNumber *timestamp = locationDict[@"timestamp"];

    NSDate *locationDate = timestamp != nil ? [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue] : [NSDate date];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate
                                                         altitude:altitude.doubleValue
                                               horizontalAccuracy:horizontalAccuracy.doubleValue
                                                 verticalAccuracy:verticalAccuracy.doubleValue
                                                           course:course.doubleValue
                                                            speed:speed.doubleValue
                                                        timestamp:locationDate];

    return location;
}

+ (AMAAppMetricaPreloadInfo *)preloadInfoForDictionary:(NSDictionary *)preloadInfoDict
{
    if (preloadInfoDict == nil) {
        return nil;
    }

    NSString *trackingId = preloadInfoDict[@"trackingId"];
    AMAAppMetricaPreloadInfo *preloadInfo = [[AMAAppMetricaPreloadInfo alloc] initWithTrackingIdentifier:trackingId];

    NSDictionary *additionalInfo = preloadInfoDict[@"additionalInfo"];
    if (additionalInfo != nil) {
        for (NSString *key in additionalInfo) {
            [preloadInfo setAdditionalInfo:additionalInfo[key] forKey:key];
        }
    }

    return preloadInfo;
}

+ (NSString *)stringFromRequestDeviceIDError:(NSError *)error
{
    if (error == nil) {
        return nil;
    }
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        return @"NETWORK";
    }
    return @"UNKNOWN";
}

@end
