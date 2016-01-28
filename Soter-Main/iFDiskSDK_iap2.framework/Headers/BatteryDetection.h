//
//  BatteryDetection.h
//  iFDiskSDK
//
//  Created by CECAPRD on 2014/5/13.
//  Copyright (c) 2014年 CECAPRD. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IFDISKBATTERY   @"iFDiskBattery"
#define BATTERY_LOWPOWER        @"lowPower"

@interface BatteryDetection : NSObject

//Init or share the BatteryDetection Controller
+ (BatteryDetection *)sharedController;

//Return the battery ADC value.
- (int)getBatteryValue;

//Return the battery level.
- (int)getBatteryState;

//Return the battery Voltage (V)
- (float)getBatteryVoltage;

//Power off the iFDisk device. (return (YES: Success) ; (NO: fail))
- (BOOL)shutDownPower;
@end

/*
 //============================================================================================================================
 If iFDisk support function to automatically return electricity. Refer to the following description:
 
 If the iFDisk battery status changes, it will automatically return the battery state to the iOS system by local notification.
 
 Gets the notification from App Delegate method:
 
 //============================================================================================================================
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
 if (notification){
 NSDictionary *userInfo =  notification.userInfo;
 
 if ([userInfo objectForKey:IFDISKBATTERY]!=nil){
 if ([[userInfo objectForKey:IFDISKBATTERY] isEqualToString:BATTERY_LOWPOWER]) {
 UIAlertView *alert;
 alert = [[UIAlertView alloc] initWithTitle:@"Battery state"
 message:NSLocalizedString(@"Low Battery Warning", nil)
 delegate:self
 cancelButtonTitle:NSLocalizedString(@"OK", nil)
 otherButtonTitles:nil];
 alert.alertViewStyle = UIAlertViewStyleDefault;
 [alert show];
 }
 }
 }
 }
 //============================================================================================================================
 */


