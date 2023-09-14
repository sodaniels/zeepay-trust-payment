//
//  ObjectiveCTest.m
//  Example
//

#import "ObjectiveCTest.h"
#import <PassKit/PassKit.h>
#import <ExampleKeys.h>

@implementation ObjectiveCTest

- (instancetype)init {
    @try {
        self.transactionManager = [[PaymentTransactionManager alloc] initWithJwt:@"" cardinalStyleManager:NULL cardinalDarkModeStyleManager:NULL error:NULL];
    } @catch (NSException *exception) {
        //
    }
    return self;
}

- (void) testTransactionManager {

    [self.transactionManager performTransactionWithJwt: @"" card: NULL transactionResponseClosure:^(NSArray<NSString *> * jwt, TPAdditionalTransactionResult * transactionResult, NSError * error) {
    }];
}

- (void) testDropInViewController {

    NSArray *visibleFields = [NSArray array];
    @try {
        self.dropInViewController = [[ViewControllerFactory shared] dropInViewControllerWithJwt:@"" customDropInView:NULL visibleFields:visibleFields applePayConfiguration:NULL apmsConfiguration:NULL dropInViewStyleManager:NULL dropInViewDarkModeStyleManager:NULL cardinalStyleManager:NULL cardinalDarkModeStyleManager:NULL error:NULL payButtonTappedClosureBeforeTransaction:^(id<DropInController> dropInController) {
        } transactionResponseClosure:^(NSArray<NSString *> * jwt, TPAdditionalTransactionResult * transactionResult, NSError * error) {
        }];
    } @catch (NSException *exception) {
        //
    }
}

/// Test setting custom translation
-(void) testTranslations {
    NSString *username = [[ExampleKeys alloc]init].mERCHANT_USERNAME;

    [[TrustPayments instance] configureWithUsername:username
                                            gateway:GatewayTypeEu
                                        environment:TPEnvironmentStaging
                                             locale:[NSLocale localeWithLocaleIdentifier: @"fr_FR"]
                                 customTranslations: @{
                                   [NSLocale localeWithLocaleIdentifier: @"en_GB"]: @{
                                           @(LocalizableKeysObjc_payButton_title): @"Giv me da mona",
                                   },
                                   [NSLocale localeWithLocaleIdentifier: @"fr_FR"]: @{
                                           @(LocalizableKeysObjc_payButton_title): @"Payez",
                                   },
                               }];
}

/// Test apple pay
-(void) testApplePayConfig {

    NSArray *visibleFields = [NSArray array];
    PKPaymentRequest *request = [[PKPaymentRequest alloc]init];
    request.supportedNetworks = @[PKPaymentNetworkVisa];
    request.merchantCapabilities = PKMerchantCapability3DS;
    request.merchantIdentifier = @"";
    request.countryCode = @"GB";
    request.currencyCode = @"GBP";
    PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount: [NSDecimalNumber zero]];
    request.paymentSummaryItems = @[item];

    NSString *applePayJWT = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJqd3QiLCJpYXQiOjE1OTU1ODc2NDguMTU0NjUyLCJwYXlsb2FkIjp7ImJhc2VhbW91bnQiOjI5OSwid2FsbGV0c291cmNlIjoiQVBQTEVQQVkiLCJhY2NvdW50dHlwZWRlc2NyaXB0aW9uIjoiRUNPTSIsImN1cnJlbmN5aXNvM2EiOiJHQlAiLCJzaXRlcmVmZXJlbmNlIjoidGVzdCJ9fQ.1vZbCJdl9OiMa0ppnjP_BsbAXeZI4ScslDhAl7Th7aQ";

    TPApplePayConfiguration *appleConfig = [[TPApplePayConfiguration alloc]initWithHandler:self request:request buttonStyle:PKPaymentButtonStyleBlack buttonDarkModeStyle:PKPaymentButtonStyleWhite buttonType:PKPaymentButtonTypePlain];
    
    self.dropInViewController = [[ViewControllerFactory shared] dropInViewControllerWithJwt:applePayJWT customDropInView:NULL visibleFields:visibleFields applePayConfiguration:appleConfig apmsConfiguration:NULL dropInViewStyleManager:NULL dropInViewDarkModeStyleManager:NULL cardinalStyleManager:NULL cardinalDarkModeStyleManager:NULL error:NULL payButtonTappedClosureBeforeTransaction:^(id<DropInController> dropInController) {
    } transactionResponseClosure:^(NSArray<NSString *> * jwt, TPAdditionalTransactionResult * transactionResult, NSError * error) {
    }];

    // [[[[UIApplication sharedApplication] keyWindow]rootViewController]presentViewController: self.dropInViewController animated:TRUE completion:NULL];
}

// MARK: TPApplePayConfigurationHandler
- (void)didAuthorizedPaymentWithPayment:(PKPayment * _Nonnull)payment updatedRequestParameters:(void (^ _Nonnull)(NSString * _Nullable, NSString * _Nullable, NSArray<NSError *> * _Nullable))updatedRequestParameters {
    updatedRequestParameters(@"JWT", @"token", NULL);
}
- (void)didCancelPaymentAuthorization {
    NSLog(@"Apple pay authorization dismissed");
}
- (void)shippingAddressChangedTo:(CNPostalAddress * _Nonnull)address updatedWith:(void (^ _Nonnull)(NSArray<NSError *> * _Nullable, NSArray<PKPaymentSummaryItem *> * _Nonnull))updatedWith {
    PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount: [NSDecimalNumber zero]];
    updatedWith(NULL, @[item]);
}
- (void)shippingMethodChangedTo:(PKShippingMethod * _Nonnull)method updatedWith:(void (^ _Nonnull)(NSArray<PKPaymentSummaryItem *> * _Nonnull))updatedWith {
    updatedWith(@[]);
}
@end
