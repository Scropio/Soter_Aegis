//
//  AccountEditViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/6/12.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "ViewController.h"
#import "Account.h"
#import "Common.h"

@interface AccountEditViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,strong) Account *CurrentAccount;

@property (weak, nonatomic) IBOutlet UIImageView *Image_Type;
@property (weak, nonatomic) IBOutlet UILabel *Label_Name;
@property (weak, nonatomic) IBOutlet UITextField *Text_Username;
@property (weak, nonatomic) IBOutlet UITextField *Text_Password;
@property (weak, nonatomic) IBOutlet UITextView *TextField_Comment;

@property (weak, nonatomic) IBOutlet UIPickerView *ServicePicker;
@property (weak, nonatomic) IBOutlet UIButton *StartSelectBtn;
@property (weak, nonatomic) IBOutlet UIView *PickerView;
@property (weak, nonatomic) IBOutlet UIButton *FinishBtn;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *Save_Account_Btn;
@property (weak, nonatomic) IBOutlet UIButton *Delete_Account_Btn;
@property (weak, nonatomic) IBOutlet UILabel *Service;
@property (weak, nonatomic) IBOutlet UILabel *UserName;
@property (weak, nonatomic) IBOutlet UILabel *Password;
@property (weak, nonatomic) IBOutlet UILabel *Comment;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *Savea;

//- (void)PickViewControl:(Boolean)Invisible;

@end
