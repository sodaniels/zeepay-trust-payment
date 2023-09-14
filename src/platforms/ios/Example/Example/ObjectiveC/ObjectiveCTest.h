//
//  ObjectiveCTest.h
//  Example
//

#import <Foundation/Foundation.h>

@import TrustPaymentsCore;
@import TrustPaymentsUI;
@import TrustPayments3DSecure;
@import TrustPaymentsCard;

@protocol APIClient;

@interface ObjectiveCTest : NSObject <TPApplePayConfigurationHandler>

@property (nonatomic, strong, readwrite) PaymentTransactionManager *transactionManager;
@property (nonatomic, strong, readwrite) id<DropInController> dropInViewController;

- (void) testTransactionManager;
- (void) testDropInViewController;
- (void) testTranslations;
- (void) testApplePayConfig;
@end

