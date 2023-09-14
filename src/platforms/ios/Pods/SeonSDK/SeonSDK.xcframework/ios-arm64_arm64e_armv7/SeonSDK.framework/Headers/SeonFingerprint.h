//
//  SeonFingerprint.h
//  iosSdk
//
//  Created by Balak Ram Sharma on 8/8/17.
//  Copyright © 2017 SEON Technologies Kft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SeonFingerprint : NSObject<UIApplicationDelegate>

+ (id)sharedManager;

-(void)setLoggingEnabled:(BOOL)logginEnabled;

-(NSString *)fingerprintBase64;

#pragma mark - Properties

//Session Id
@property(nonatomic) NSString *sessionId;

@end
