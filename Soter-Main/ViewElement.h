//
//  ViewElement.h
//  iFDiskSDK
//
//  Created by Mac_ohm on 12/8/9.
//
//

#import <Foundation/Foundation.h>
#import "FileSystemAPI.h"

//================================================================================
@interface ViewElement : UIAlertView<UITableViewDelegate, UIAlertViewDelegate>
    @property (retain, nonatomic) IBOutlet UIButton *buttonMSG;
    @property (strong, nonatomic) IBOutlet UITextView *textVeiwMSG;

    - (void)clearDebugMessage;

    - (void)textViewMSG_Action:(NSString *)nssMessage;
    - (void)textViewMSG_ActionBuffer:(uint8_t *)buffer bumpLength:(uint32_t)length;

    - (void)alertTitle:(NSString *)nssTitle alertMessage:(NSString *)nssMessage object:(NSObject *)nsoObject;
    - (void)alertFinish;

@end
