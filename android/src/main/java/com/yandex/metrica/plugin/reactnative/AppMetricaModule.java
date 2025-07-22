/*
 * Version for React Native
 * © 2025 NCode
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * https://yandex.com/legal/appmetrica_sdk_agreement/
 */

package com.yandex.metrica.plugin.reactnative;

import android.app.Activity;
import android.util.Log;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableArray;
import io.appmetrica.analytics.AppMetrica;
import io.appmetrica.analytics.ecommerce.ECommerceAmount;
import io.appmetrica.analytics.ecommerce.ECommerceCartItem;
import io.appmetrica.analytics.ecommerce.ECommerceEvent;
import io.appmetrica.analytics.ecommerce.ECommerceOrder;
import io.appmetrica.analytics.ecommerce.ECommercePrice;
import io.appmetrica.analytics.ecommerce.ECommerceProduct;
import io.appmetrica.analytics.ecommerce.ECommerceReferrer;
import io.appmetrica.analytics.ecommerce.ECommerceScreen;
import java.util.ArrayList;
import java.lang.*;

public class AppMetricaModule extends ReactContextBaseJavaModule {

    private static final String TAG = "AppMetricaModule";

    private final ReactApplicationContext reactContext;

    public AppMetricaModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "AppMetrica";
    }

    @ReactMethod
    public void activate(ReadableMap configMap) {
        AppMetrica.activate(reactContext, Utils.toYandexMetricaConfig(configMap));
        enableActivityAutoTracking();
    }

    private void enableActivityAutoTracking() {
        Activity activity = getCurrentActivity();
        if (activity != null) { // TODO: check
            AppMetrica.enableActivityAutoTracking(activity.getApplication());
        } else {
            Log.w(TAG, "Activity is not attached");
        }
    }

    @ReactMethod
    public void getLibraryApiLevel(Promise promise) {
        promise.resolve(AppMetrica.getLibraryApiLevel());
    }

    @ReactMethod
    public void getLibraryVersion(Promise promise) {
        promise.resolve(AppMetrica.getLibraryVersion());
    }

    @ReactMethod
    public void pauseSession() {
        AppMetrica.pauseSession(getCurrentActivity());
    }

    @ReactMethod
    public void reportAppOpen(String deeplink) {
        AppMetrica.reportAppOpen(deeplink);
    }

    @ReactMethod
    public void reportError(String message) {
        try {
            Integer.valueOf("00xffWr0ng");
        } catch (Throwable error) {
            AppMetrica.reportError(message, error);
        }
    }

    @ReactMethod
    public void reportEvent(String eventName, ReadableMap attributes) {
        if (attributes == null) {
            AppMetrica.reportEvent(eventName);
        } else {
            AppMetrica.reportEvent(eventName, attributes.toHashMap());
        }
    }

    @ReactMethod
    public void reportReferralUrl(String referralUrl) {
        AppMetrica.reportReferralUrl(referralUrl);
    }

    @ReactMethod
    public void requestAppMetricaDeviceID(Callback listener) {
        AppMetrica.getDeviceId(this.reactContext);
    }

    @ReactMethod
    public void resumeSession() {
        AppMetrica.resumeSession(getCurrentActivity());
    }

    @ReactMethod
    public void sendEventsBuffer() {
        AppMetrica.sendEventsBuffer();
    }

    @ReactMethod
    public void setLocation(ReadableMap locationMap) {
        AppMetrica.setLocation(Utils.toLocation(locationMap));
    }

    @ReactMethod
    public void setLocationTracking(boolean enabled) {
        AppMetrica.setLocationTracking(enabled);
    }

    @ReactMethod
    public void setStatisticsSending(boolean enabled) {
            return;
    }

    @ReactMethod
    public void setUserProfileID(String userProfileID) {
        AppMetrica.setUserProfileID(userProfileID);
    }

      public ECommerceScreen createScreen(ReadableMap params) {
             ECommerceScreen screen = new ECommerceScreen().setName(params.getString("screenName")).setSearchQuery(params.getString("searchQuery"));
             return screen;
         }

         public ECommerceProduct createProduct(ReadableMap params) {
             ECommercePrice actualPrice = new ECommercePrice(new ECommerceAmount(Double.parseDouble(params.getString("price")), params.getString("currency")));
             ECommerceProduct product = new ECommerceProduct(params.getString("sku")).setActualPrice(actualPrice).setName(params.getString("name"));
             return product;
         }

         public ECommerceCartItem createCartItem(ReadableMap params) {
             ECommerceScreen screen = this.createScreen(params);
             ECommerceProduct product = this.createProduct(params);
             ECommercePrice actualPrice = new ECommercePrice(new ECommerceAmount(Double.parseDouble(params.getString("price")), params.getString("currency")));
             ECommerceReferrer referrer = new ECommerceReferrer().setScreen(screen);
             ECommerceCartItem cartItem = new ECommerceCartItem(product, actualPrice, Integer.parseInt(params.getString("quantity"))).setReferrer(referrer);
             return cartItem;
         }

         @ReactMethod
         public void showScreen(ReadableMap params, Promise promise) {
             ECommerceScreen screen = this.createScreen(params);
             ECommerceEvent showScreenEvent = ECommerceEvent.showScreenEvent(screen);
             AppMetrica.reportECommerce(showScreenEvent);
                 promise.resolve("OK");
         }

         @ReactMethod
         public void showProductCard(ReadableMap params) {
             ECommerceScreen screen = this.createScreen(params);
             ECommerceProduct product = this.createProduct(params);
             ECommerceEvent showProductCardEvent = ECommerceEvent.showProductCardEvent(product, screen);
             AppMetrica.reportECommerce(showProductCardEvent);
         }

         @ReactMethod
         public void addToCart(ReadableMap params) {
             ECommerceCartItem cartItem = this.createCartItem(params);
             ECommerceEvent addCartItemEvent = ECommerceEvent.addCartItemEvent(cartItem);
             AppMetrica.reportECommerce(addCartItemEvent);
         }

         @ReactMethod
         public void removeFromCart(ReadableMap params) {
             ECommerceCartItem cartItem = this.createCartItem(params);
             ECommerceEvent removeCartItemEvent = ECommerceEvent.removeCartItemEvent(cartItem);
             AppMetrica.reportECommerce(removeCartItemEvent);
         }

         @ReactMethod
         public void beginCheckout(ReadableArray products, String identifier) {
             ArrayList<ECommerceCartItem> cartItems = new ArrayList<>();
             for (int i = 0; i < products.size(); i++) {
                 ReadableMap productData = products.getMap(i);
                 cartItems.add(this.createCartItem(productData));
             }
             ECommerceOrder order = new ECommerceOrder(identifier, cartItems);
             ECommerceEvent beginCheckoutEvent = ECommerceEvent.beginCheckoutEvent(order);
             AppMetrica.reportECommerce(beginCheckoutEvent);
         }

         @ReactMethod
         public void finishCheckout(ReadableArray products, String identifier) {
             ArrayList<ECommerceCartItem> cartItems = new ArrayList<>();
             for (int i = 0; i < products.size(); i++) {
                 ReadableMap productData = products.getMap(i);
                 cartItems.add(this.createCartItem(productData));
             }
             ECommerceOrder order = new ECommerceOrder(identifier, cartItems);
             ECommerceEvent purchaseEvent = ECommerceEvent.purchaseEvent(order);
             AppMetrica.reportECommerce(purchaseEvent);
         }
}
