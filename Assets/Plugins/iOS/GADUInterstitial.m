// Copyright 2014 Google Inc. All Rights Reserved.

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "GoogleMobileAds/GoogleMobileAds.h"
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#import "GADUInterstitial.h"

#import "UnityAppController.h"

@interface GADUInterstitial () <GADInterstitialDelegate, GADAppEventDelegate, SKStoreProductViewControllerDelegate>
@end

@implementation GADUInterstitial

+ (UIViewController *)unityGLViewController {
  return ((UnityAppController *)[UIApplication sharedApplication].delegate).rootViewController;
}

- (id)initWithInterstitialClientReference:(GADUTypeInterstitialClientRef *)interstitialClient
                                 adUnitID:(NSString *)adUnitID {
  self = [super init];
  if (self) {
    _interstitialClient = interstitialClient;
    _interstitial = [[DFPInterstitial alloc] init];
    _interstitial.adUnitID = adUnitID;
    _interstitial.delegate = self;
    [_interstitial setAppEventDelegate:self];
  }
  return self;
}

- (void)dealloc {
  _interstitial.delegate = nil;
}

- (void)loadRequest:(GADRequest *)request {
  [self.interstitial loadRequest:request];
}

- (BOOL)isReady {
  return self.interstitial.isReady;
}

- (void)show {
  if (self.interstitial.isReady) {
    UIViewController *unityController = [GADUInterstitial unityGLViewController];
    [self.interstitial presentFromRootViewController:unityController];
  } else {
    NSLog(@"GoogleMobileAdsPlugin: Interstitial is not ready to be shown.");
  }
}

#pragma mark GADInterstitialDelegate implementation

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
  if (self.adReceivedCallback) {
    self.adReceivedCallback(self.interstitialClient);
  }
}
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
  NSString *errorMsg = [NSString
      stringWithFormat:@"Failed to receive ad with error: %@", [error localizedFailureReason]];
  self.adFailedCallback(self.interstitialClient,
                        [errorMsg cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
  if (self.willPresentCallback) {
    self.willPresentCallback(self.interstitialClient);
  }
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
  if (self.willDismissCallback) {
    self.willDismissCallback(self.interstitialClient);
  }
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
  if (self.didDismissCallback) {
    self.didDismissCallback(self.interstitialClient);
  }
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
  if (self.willLeaveCallback) {
    self.willLeaveCallback(self.interstitialClient);
  }
}

/// Below lines added for receive Admob app event

- (UIViewController *)topMostViewController
{
    UIViewController *vc = [GADUInterstitial unityGLViewController];
    while (vc.presentedViewController)
    {
        vc = vc.presentedViewController;
    }
    return vc;
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


/// Called when the interstitial receives an app event.
- (void)interstitial:(GADInterstitial *)interstitial
  didReceiveAppEvent:(NSString *)name
            withInfo:(NSString *)info
{
    NSLog(@"Received appEvent: %@", name);
    if([name isEqualToString:@"appstore"]) {
        NSLog(@"URL opening: %@", info);
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [indicatorView setCenter:CGPointMake([self topMostViewController].view.frame.size.width /2 ,
                                             [self topMostViewController].view.frame.size.height / 2)];
        [[[self topMostViewController] view] addSubview:indicatorView];
        [indicatorView startAnimating];
        [[[self topMostViewController] view] setUserInteractionEnabled:false];
        
        SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
        
        // Configure View Controller
        [storeProductViewController setDelegate:self];
        [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : info} completionBlock:^(BOOL result, NSError *error) {
            [indicatorView stopAnimating];
            [indicatorView removeFromSuperview];
            [[[self topMostViewController] view] setUserInteractionEnabled:true];
            
            if (error) {
                NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
                
            } else {
                // Present Store Product View Controller
                [[self topMostViewController] presentViewController:storeProductViewController animated:YES completion:nil];
                
            }
        }];
    }
}

@end
