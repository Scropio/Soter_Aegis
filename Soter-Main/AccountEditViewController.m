//
//  AccountEditViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/6/12.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "AccountEditViewController.h"
#import "Common.h"
#import "Database.h"
#import "Language.h"
#import "LanguageViewController.h"

#define RGB(R,G,B,Alpha) [UIColor colorWithRed:((R)/255.0) green:((G)/255.0) blue:((B)/255.0) alpha:(Alpha)]


@interface AccountEditViewController () <UITextViewDelegate>
{
    Database *db;
    
    NSArray *ServiceList;
}
@end

@implementation AccountEditViewController

@synthesize CurrentAccount;

@synthesize PickerView,ServicePicker,FinishBtn;
@synthesize Save_Account_Btn,Delete_Account_Btn;
@synthesize StartSelectBtn;
//----------hemly
@synthesize Service;
@synthesize UserName;
@synthesize Password;
@synthesize Comment;
@synthesize Savea;

//-----------
//@synthesize TextField_Comment;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ServiceList = @[@"Dropbox",@"Facebook",@"Gmail",@"GoogleDrive",@"Google",@"GooglePlus",
                    @"Line",@"Ruten",@"OneDrive",@"PCHome",@"Twitter",@"WeChat",@"Yahoo",@"YouTube"];
    
    NSLog(@"Account.Edit.Name:%@",CurrentAccount.Name);

    db = [[Database alloc]init];
    
//UIElement Control
    //Set Border
    UIColor *BorderColor = RGB(40.0, 114.0, 195.0, 1);
    
    self.StartSelectBtn.layer.borderWidth       = 2.0f;
    self.Text_Username.layer.borderWidth        = 2.0f;
    self.Text_Password.layer.borderWidth        = 2.0f;
    self.TextField_Comment.layer.borderWidth    = 2.0f;
    
    self.StartSelectBtn.layer.borderColor       = [BorderColor CGColor];
    self.Text_Username.layer.borderColor        = [BorderColor CGColor];
    self.Text_Password.layer.borderColor        = [BorderColor CGColor];
    self.TextField_Comment.layer.borderColor    = [BorderColor CGColor];
    
    self.StartSelectBtn.layer.cornerRadius      = 10.0f;
    self.Text_Username.layer.cornerRadius       = 10.0f;
    self.Text_Password.layer.cornerRadius       = 10.0f;
    self.TextField_Comment.layer.cornerRadius   = 10.0f;
    
//    NSString* ServiceIconName = [Common ServiceMapping:[ServiceList objectAtIndex:row]];
//    
//    [self.Image_Type setImage:[UIImage imageNamed:ServiceIconName]];
//    self.Label_Name.text = [ServiceList objectAtIndex:row];
    
    if(CurrentAccount != nil)
    {
        [self.Image_Type setImage:[UIImage imageNamed:[Common ServiceMapping:CurrentAccount.Name]]];
        self.Label_Name.text        = CurrentAccount.Name;
        self.Text_Username.text     = CurrentAccount.Username;
        self.Text_Password.text     = CurrentAccount.Password;
        self.TextField_Comment.text = CurrentAccount.Comment;

           }
    else
    {
        Delete_Account_Btn.hidden = true;
        [self.Save_Account_Btn setEnabled:[self CheckDataField]];
    }
    
    self.ServicePicker.delegate = self;
    self.ServicePicker.dataSource = self;
    
    self.TextField_Comment.delegate = self;
    
    //UIControl
    [PickerView setFrame:CGRectMake(0,
                                    self.view.frame.size.height,
                                    self.view.frame.size.width,
                                    self.view.frame.size.height/4)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    
    OriginY = self.view.frame.origin.y + 66;
    
    NSLog(@"OriginY:%f",OriginY);
}

- (void)viewWillAppear:(BOOL)animated
{
   [self UpdateData];
    
}



CGFloat OriginY;
CGFloat KeyboardHeight;
CGFloat KeyboardDuration;
CGFloat ViewDisplacement;

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"%f", [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
    
    KeyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    KeyboardDuration = [duration doubleValue];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self moveFrameToVerticalPosition:OriginY forDuration:KeyboardDuration];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    CGFloat Original = self.TextField_Comment.frame.origin.y + self.TextField_Comment.frame.size.height;
    
    CGFloat Padding = 44;
    
    if ((Original + 44) > KeyboardHeight)
    {
        ViewDisplacement = self.view.frame.size.height - Original - Padding - KeyboardHeight;
        
        [self moveFrameToVerticalPosition:ViewDisplacement forDuration:KeyboardDuration];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self moveFrameToVerticalPosition:OriginY forDuration:KeyboardDuration];
    
    [self.Save_Account_Btn setEnabled:[self CheckDataField]];
}

- (IBAction)UsernameDidBeginEditing:(id)sender
{
    CGFloat Original = self.Text_Username.frame.origin.y + self.Text_Username.frame.size.height;
    
    CGFloat Padding = 44;
    
    ViewDisplacement = self.Text_Username.frame.origin.y - Original + KeyboardHeight + Padding;
    
    if (ViewDisplacement < 0)
    {
        [self moveFrameToVerticalPosition:ViewDisplacement forDuration:KeyboardDuration];
    }
}

- (IBAction)UsernameDidEndEditing:(id)sender
{
    [self moveFrameToVerticalPosition:OriginY forDuration:KeyboardDuration];
    
    [self.Save_Account_Btn setEnabled:[self CheckDataField]];
}

- (IBAction)PasswordDidBeginEditing:(id)sender
{
    CGFloat Original = self.Text_Password.frame.origin.y + self.Text_Password.frame.size.height;
    
    CGFloat Padding = 44;
    
    if ((ViewDisplacement =(self.view.frame.size.height - Original - Padding - KeyboardHeight) < 0))
    {
        [self moveFrameToVerticalPosition:ViewDisplacement forDuration:KeyboardDuration];
    }
}

- (IBAction)PasswordDidEndEditing:(id)sender {
    [self moveFrameToVerticalPosition:OriginY forDuration:KeyboardDuration];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (void)moveFrameToVerticalPosition:(float)position forDuration:(float)duration {
    
    NSLog(@"Displacement:%f",position);
    
    CGRect frame = self.view.frame;
    frame.origin.y = position;
    
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = frame;
    }];
}

#pragma mark - PickerView Control
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return ServiceList.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ServicePicker.frame.size.width, 44)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"ArialMT" size:30];
    
    label.text = [ServiceList objectAtIndex:row];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString* ServiceIconName = [Common ServiceMapping:[ServiceList objectAtIndex:row]];
    
    [self.Image_Type setImage:[UIImage imageNamed:ServiceIconName]];
    self.Label_Name.text = [ServiceList objectAtIndex:row];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIControl
- (IBAction)FinishBtnCilck:(id)sender {
    
    [self ControlPickView:false];
}
- (IBAction)StartSelectBtnClick:(id)sender {
    
    [self ControlPickView:true];
    
    [[self view] endEditing:YES];
}

- (void)ControlPickView:(Boolean)Invisible
{
    if(Invisible)
    {
        [UIView animateWithDuration:0.6 animations:^{
            [PickerView setFrame:CGRectMake(0,
                                            self.view.frame.size.height - PickerView.frame.size.height + 20,
                                            self.view.frame.size.width,
                                            self.view.frame.size.height/4)];
        }];
        
        
    }
    else
    {
        [UIView animateWithDuration:0.6 animations:^{
            [PickerView setFrame:CGRectMake(0,
                                            self.view.frame.size.height,
                                            self.view.frame.size.width,
                                            self.view.frame.size.height/4)];
        }];
    }
}
- (IBAction)Delete_Account_Btn_Click:(id)sender {
    [db open];
        [db deleteData:CurrentAccount.ID];
    [db close];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)Save_Account_Btn_Click:(id)sender {
    [db open];
    if(CurrentAccount.ID == nil)
    {
        [db insertData:self.Label_Name.text
              Username:self.Text_Username.text
              Password:self.Text_Password.text
               Comment:self.TextField_Comment.text];
    }
    else
    {
        [db updataData:CurrentAccount.ID
           ServiceName:self.Label_Name.text
              Username:self.Text_Username.text
              Password:self.Text_Password.text
               Comment:self.TextField_Comment.text];
        
        
    }
    [db close];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)CheckDataField
{
    BOOL Checkmark1 = false;
    BOOL Checkmark2 = false;
    BOOL Checkmark3 = false;
    
    if (self.Label_Name.text.length    > 0) Checkmark1 = true;
    if (self.Text_Username.text.length > 0) Checkmark2 = true;
    if (self.Text_Password.text.length > 0) Checkmark3 = true;
    
    return Checkmark1 && Checkmark2 && Checkmark3;
}
- (IBAction)ShowPassword:(id)sender {
    self.Text_Password.secureTextEntry = !self.Text_Password.secureTextEntry;
}

#pragma mark - Service Mapping
- (NSString *) ServiceMapping:(NSString *)ServiceName
{
    if      ([ServiceName isEqual: @"Google"]  )   return @"Google_Icon";
    else if ([ServiceName isEqual: @"Dropbox"] )   return @"Dropbox_Icon";
    else if ([ServiceName isEqual: @"Yahoo"]   )   return @"Icon_Yahoo";
    else if ([ServiceName isEqual: @"WeChat"]  )   return @"Icon_Wechat";
    else if ([ServiceName isEqual: @"Line"]    )   return @"Icon_Line";
    else if ([ServiceName isEqual: @"WhatsApp"])   return @"WhatsApp";
    else return @"empty";
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark update data
-(void)UpdateData
{
    self.title = [Language get:@"AccountManager_Title" alter:@"Account Manager"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"AccountManager_Title" alter:@"Account Manager"];
    self.Service.text = [Language get:@"AccountManager_Service" alter:@"Service"];
    self.UserName.text = [Language get:@"AccountManager_UserName" alter:@"UserName"];
    self.Password.text = [Language get:@"AccountManager_Password" alter:@"Password"];
    self.Comment.text = [Language get:@"AccountManager_Comment" alter:@"Comment"];
    [Delete_Account_Btn setTitle:[Language get:@"AccountManager_Delete" alter:@"Delete"] forState:UIControlStateNormal];
    [FinishBtn setTitle:[Language get:@"AccountManager_Finish" alter:@"Finish"] forState:UIControlStateNormal];
    [self.Savea setTitle:[Language get:@"AccountManager_Save" alter:@"Save"]];

}

@end
