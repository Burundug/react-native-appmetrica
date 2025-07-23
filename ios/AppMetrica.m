/*
 * Version for React Native
 * © 2020 YANDEX
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * https://yandex.com/legal/appmetrica_sdk_agreement/
 */

#import "AppMetrica.h"
#import "AppMetricaUtils.h"
#import <AppMetricaCrashes/AppMetricaCrashes.h>

static NSString *const kYMMReactNativeExceptionName = @"ReactNativeException";

@implementation AppMetrica

@synthesize methodQueue = _methodQueue;

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(activate:(NSDictionary *)configDict)
{
    [AMAAppMetrica activateWithConfiguration:[AppMetricaUtils configurationForDictionary:configDict]];
}

RCT_EXPORT_METHOD(getLibraryApiLevel)
{
    // It does nothing for iOS
}

RCT_EXPORT_METHOD(getLibraryVersion:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([AMAAppMetrica libraryVersion]);
}

RCT_EXPORT_METHOD(pauseSession)
{
    [AMAAppMetrica pauseSession];
}

RCT_EXPORT_METHOD(reportAppOpen:(NSString *)deeplink)
{
    [AMAAppMetrica trackOpeningURL:[NSURL URLWithString:deeplink]];

}

RCT_EXPORT_METHOD(reportError:(NSString *)message) {
    NSException *exception = [[NSException alloc] initWithName:message reason:nil userInfo:nil];
    AMAError *underlyingError = [AMAError errorWithIdentifier:@"Underlying AMAError"];
    AMAError *error = [AMAError errorWithIdentifier:@"error"
                                            message:message
                                         parameters:@{ @"foo": @"bar" }
                                          backtrace:NSThread.callStackReturnAddresses
                                    underlyingError:underlyingError];
    [[AMAAppMetricaCrashes crashes] reportError:error  onFailure:nil];

}

RCT_EXPORT_METHOD(reportEvent:(NSString *)eventName:(NSDictionary *)attributes)
{
    if (attributes == nil) {
        [AMAAppMetrica reportEvent:eventName onFailure:^(NSError *error) {
            NSLog(@"error: %@", [error localizedDescription]);
        }];
    } else {
        [AMAAppMetrica reportEvent:eventName parameters:attributes onFailure:^(NSError *error) {
            NSLog(@"error: %@", [error localizedDescription]);
        }];
    }
}

RCT_EXPORT_METHOD(reportReferralUrl:(NSString *)referralUrl)
{
   
}

RCT_EXPORT_METHOD(requestAppMetricaDeviceID:(RCTResponseSenderBlock)listener)
{
  NSArray *keys = @[ @"appmetrica_device_id" ];
  
  [AMAAppMetrica requestStartupIdentifiersWithKeys:keys
                                   completionQueue:dispatch_get_main_queue()
                                   completionBlock:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
    NSString *deviceID = result[@"appmetrica_device_id"];
    NSString *errorString = [AppMetricaUtils stringFromRequestDeviceIDError:error];
    
    listener(@[
      deviceID ? deviceID : [NSNull null],
      errorString ? errorString : [NSNull null]
    ]);
  }];
}

RCT_EXPORT_METHOD(resumeSession)
{
    [AMAAppMetrica resumeSession];
}

RCT_EXPORT_METHOD(sendEventsBuffer)
{
    [AMAAppMetrica sendEventsBuffer];
}

RCT_EXPORT_METHOD(setLocation:(NSDictionary *)locationDict)
{
    CLLocation *location = [[self class] locationForDictionary:locationDict];
    AMAAppMetrica.customLocation = location;
}

RCT_EXPORT_METHOD(beginCheckout:(NSArray<NSDictionary *> *)products identifier:(NSString *)identifier) {
     NSMutableArray *cartItems = [[NSMutableArray alloc] init];
     for(int i=0; i< products.count; i++){
        [cartItems addObject:[self createCartItem:products[i]]];
     }

    AMAECommerceOrder *order = [[AMAECommerceOrder alloc] initWithIdentifier:identifier
                                                                    cartItems:cartItems
                                                                      payload:@{}];

     [AMAAppMetrica reportECommerce:[AMAECommerce beginCheckoutEventWithOrder:order] onFailure:nil];
 }

- (AMAECommerceScreen *)createScreen:(NSDictionary *)screen {
    AMAECommerceScreen *screenObj = [[AMAECommerceScreen alloc] initWithName:screen[@"screenName"] categoryComponents:@[] searchQuery:screen[@"searchQuery"] payload:@{}];
    return screenObj;
}

- (AMAECommerceProduct *)createProduct:(NSDictionary *)product {
    AMAECommerceAmount *actualFiat = [[AMAECommerceAmount alloc] initWithUnit:product[@"currency"] value:[NSDecimalNumber decimalNumberWithString:product[@"price"]]];
    AMAECommercePrice *actualPrice = [[AMAECommercePrice alloc] initWithFiat:actualFiat internalComponents:@[]];
    AMAECommerceProduct *productObj = [[AMAECommerceProduct alloc] initWithSKU:product[@"sku"] name:product[@"name"] categoryComponents:@[] payload:@{} actualPrice:actualPrice originalPrice:actualPrice promoCodes:@[]];

    return productObj;
}

- (AMAECommercePrice *)createPrice:(NSDictionary *)product {
    AMAECommerceAmount *priceObj = [[AMAECommerceAmount alloc] initWithUnit:product[@"currency"] value:[NSDecimalNumber decimalNumberWithString:product[@"price"]]];
    AMAECommercePrice *actualPrice = [[AMAECommercePrice alloc] initWithFiat:priceObj internalComponents:@[]];

    return actualPrice;
}

- (AMAECommerceCartItem *)createCartItem:(NSDictionary *)product {
    AMAECommerceScreen *screen = [self createScreen:@{}];

    AMAECommerceProduct *productObj = [self createProduct:product];

    AMAECommerceReferrer *referrer = [[AMAECommerceReferrer alloc] initWithType:@"" identifier:@"" screen:screen];

    NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithString:product[@"quantity"]];

    AMAECommercePrice *actualPrice = [self createPrice:product];

    AMAECommerceCartItem *cartItem = [[AMAECommerceCartItem alloc]  initWithProduct:productObj quantity:quantity revenue:actualPrice referrer:referrer];

    return cartItem;
}

 RCT_EXPORT_METHOD(finishCheckout:(NSArray<NSDictionary *> *)products identifier:(NSString *)identifier) {
     NSMutableArray *cartItems = [[NSMutableArray alloc] init];
     for(int i=0; i< products.count; i++){
        [cartItems addObject:[self createCartItem:products[i]]];
     }
     AMAECommerceOrder *order = [[AMAECommerceOrder alloc] initWithIdentifier:identifier
                                                                    cartItems:cartItems
                                                                      payload:@{}];

     [AMAAppMetrica reportECommerce:[AMAECommerce purchaseEventWithOrder:order] onFailure:nil];
 }

RCT_EXPORT_METHOD(addToCart:(NSDictionary *)product) {
    AMAECommerceCartItem *cartItem = [self createCartItem:product];

     [AMAAppMetrica reportECommerce:[AMAECommerce addCartItemEventWithItem:cartItem] onFailure:nil];
 }

 RCT_EXPORT_METHOD(removeFromCart:(NSDictionary *)product) {
     AMAECommerceCartItem *cartItem = [self createCartItem:product];

     [AMAAppMetrica reportECommerce:[AMAECommerce removeCartItemEventWithItem:cartItem] onFailure:nil];
 }

RCT_EXPORT_METHOD(showScreen:(NSDictionary *)screen) {
    AMAECommerceScreen *screenObj = [self createScreen:screen];

     [AMAAppMetrica reportECommerce:[AMAECommerce showScreenEventWithScreen:screenObj] onFailure:nil];
 }

RCT_EXPORT_METHOD(showProductCard:(NSDictionary *)product ) {
    AMAECommerceScreen *screen = [self createScreen:@{}];
    AMAECommerceProduct *productObj = [self createProduct:product];

     [AMAAppMetrica reportECommerce:[AMAECommerce showProductCardEventWithProduct:productObj screen:screen] onFailure:nil];
 }

RCT_EXPORT_METHOD(setLocationTracking:(BOOL)enabled)
{
    AMAAppMetrica.locationTrackingEnabled = enabled;
}

RCT_EXPORT_METHOD(setStatisticsSending:(BOOL)enabled)
{
    [AMAAppMetrica setDataSendingEnabled:enabled];
}

RCT_EXPORT_METHOD(setUserProfileID:(NSString *)userProfileID)
{
    [AMAAppMetrica setUserProfileID:userProfileID];
}

- (NSObject *)wrap:(NSObject *)value
{
    if (value == nil) {
        return [NSNull null];
    }
    return value;
}

@end
