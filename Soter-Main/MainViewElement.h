//
//  MainViewElement.h
//  Soter-Main
//
//  Created by Neil on 2015/6/1.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewElement : UIView

@property (strong, nonatomic) IBOutlet UITextView *textView;
    - (void)textViewMSG_Action:(NSString *)nssMessage;

@property (strong, nonatomic) IBOutlet UIImageView *StatusIcon;

- (UIImageView*)AddStatusImage;

- (void)ChangeStatus_Link:(NSString *)nssMessage;

@end
