//
//  ChangePasswordViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/5/20.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "pListController.h"
#import "GlobalInfo.h"
#import "LanguageViewController.h"
#import "Language.h"

#define RGB(R,G,B,Alpha) [UIColor colorWithRed:((R)/255.0) green:((G)/255.0) blue:((B)/255.0) alpha:(Alpha)]
#define UI_BORDER_WIDTH     1.5;
#define UI_BORDER_RADIUS    10.0;

#define CHAR_BUTTON_HEIGHT   74
#define CHAR_BUTTON_WIDTH    74

#define CONTROL_BUTTON_HEIGHT   55
#define CONTROL_BUTTON_WIDTH    181

@interface ChangePasswordViewController ()
{
    float x_Spacing;
    float y_Spacing;
    float x_padding;
    float y_padding;
    
    NSMutableString *Password_Character;
    NSMutableString *Confirm_Character;
    
    NSArray *default_Character;
    NSArray *Keyboard_Character;
    
    NSMutableArray *Keyboard;
    
    bool PasswordMode;
    bool ConfirmMode;
    
    UIButton *Confirm_Button;
    UIButton *Reset_Button;
}
@end

@implementation ChangePasswordViewController

@synthesize confirmPassword,OriginalPassword;


#pragma UI Compoment


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    PasswordMode = false;
    ConfirmMode = false;
    
    //Get current screen size
    float sHeight;
    float sWidth;
    sHeight = [[UIScreen mainScreen] bounds].size.height;
    sWidth  = [[UIScreen mainScreen] bounds].size.width;
    
    //StatusBar.Height = 20 && NavigationBar.Height = 44
    x_Spacing = (sWidth - (CHAR_BUTTON_WIDTH) * 4) / 5;
    x_padding = x_Spacing;
    
    y_padding = 20 + 44 + ((sHeight - 20 - 44) * 0.1);
    y_Spacing = (((sHeight - 20 - 44) * 0.8) - (CHAR_BUTTON_HEIGHT * 4) - (CONTROL_BUTTON_HEIGHT)) / 6;
    
    
    //Initial Keyboard Character
    default_Character  = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F"];
    
    Keyboard_Character = [NSArray arrayWithObject:@"0"];
    Keyboard_Character = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F"];
    
    Keyboard_Character = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F"];
    
    Password_Character = [[NSMutableString alloc]init];
    Confirm_Character = [[NSMutableString alloc]init];
    
    [self Random_Character];
    
    [self generateKeyboard];
}
//--hemly
- (void)viewWillAppear:(BOOL)animated {
    self.title = [Language get:@"SuperPassword_Title" alter:@"Change Super Password"];
    [self UpdateData];

}

#pragma Random Keyboard Generate
- (void)Random_Character{
    
    Keyboard = [[NSMutableArray alloc] initWithArray:Keyboard_Character];
    
    for(int i = 0 ; i < Keyboard_Character.count ;i++){
        int switchIndex = arc4random() % Keyboard_Character.count;
        NSString *switchBuffer;
        
        switchBuffer = Keyboard[i];
        
        Keyboard[i] = Keyboard[switchIndex];
        
        Keyboard[switchIndex] = switchBuffer;
    }
}

- (void)generateKeyboard{
    
    UIButton *cButton;
    int Character_Index = 0;
    
    UIImage *ButtonImage;
    
    //Add Character Button
    for ( int x = 0 , x_1 = 1; x < 4 ; x++ , x_1++)
    {
        for ( int y = 0 , y_1 = 1; y < 4 ; y++ , y_1++)
        {
            cButton = [[UIButton alloc]init];
            
            //X-Axis:
            //Y-Axis:
            //Height:
            //Width :
            cButton.frame = CGRectMake(CHAR_BUTTON_WIDTH  * x + (x_Spacing * x_1),
                                       CHAR_BUTTON_HEIGHT * y + (y_Spacing * y_1) + y_padding,
                                       CHAR_BUTTON_WIDTH, CHAR_BUTTON_HEIGHT);
            //Set Button Tag
            //Transfer ASCII to INT "BLOCK"
            cButton.tag = ^(NSString *input){
                int ascii = [input characterAtIndex:0];
                if(ascii >= 48 && ascii < 65)   ascii -= 48;
                if(ascii >= 65 && ascii <=90)   ascii -= 55;
                return ascii;
            }(Keyboard[Character_Index]);
            
            NSString *ImageName;
            //Visible A-F
            if(cButton.tag <= 9)
            {
                ImageName= [[NSString alloc]initWithFormat:@"%@_button",Keyboard[Character_Index]];
            }
            else
            {
                ImageName= [[NSString alloc]initWithFormat:@"space_button"];
            }
            //Set UIImage
            ButtonImage = [UIImage imageNamed:ImageName];
            //Set UIImage to background
            [cButton setBackgroundImage:ButtonImage forState:UIControlStateNormal];
            
            //            [cButton setBackgroundColor:[UIColor redColor]];
            //取消按下的特效
            cButton.adjustsImageWhenHighlighted = NO;
            
            [cButton addTarget:self action:@selector(Btn_Num_Click:) forControlEvents:UIControlEventTouchUpInside];
            
            
            
            Character_Index++;
            
            [self.view addSubview:cButton];
        }
    }
    
    //Add Confirm Button
    float Control_Key_X_Padding = [[UIScreen mainScreen] bounds].size.width;
    Control_Key_X_Padding /= 2;
    Control_Key_X_Padding  =  (Control_Key_X_Padding - CONTROL_BUTTON_WIDTH)/2;
    
    float screenWidth = [[UIScreen mainScreen]bounds].size.width;
    
//Original Password Text ---------------------------------------------------------------------
    OriginalPassword = [[UITextView alloc]init];
    OriginalPassword.frame = CGRectMake(x_padding,
                                        y_Spacing,
                                        screenWidth - x_padding * 2 ,
                                        44);
    //OriginalPassword.text = @"Enter Password";
     OriginalPassword.text = [Language get:@"SuperPassword_Text1" alter:@"Enter Password"] ;
    //[Language get:@"SuperPassword_Text2" alter:@"Confirm Password"]
    OriginalPassword.backgroundColor = [UIColor clearColor];
    
    OriginalPassword.layer.borderWidth  = UI_BORDER_WIDTH;
    OriginalPassword.layer.borderColor  = RGB(40.0, 114.0, 195.0, 0.8).CGColor;
    OriginalPassword.layer.cornerRadius = UI_BORDER_RADIUS;
    
    OriginalPassword.font = [UIFont systemFontOfSize:30];
    OriginalPassword.textAlignment = NSTextAlignmentCenter;
    
    OriginalPassword.textContainer.lineFragmentPadding = 0;
    OriginalPassword.textContainerInset = UIEdgeInsetsZero;
    
    OriginalPassword.editable = NO;
    
    [self.view addSubview:OriginalPassword];

//Confirm Password Text ---------------------------------------------------------------------
    confirmPassword = [[UITextView alloc]init];
    confirmPassword.frame = CGRectMake(x_padding,
                                       y_Spacing * 2 + 44,
                                       screenWidth - x_padding * 2,
                                       44);
    
  //  confirmPassword.text = @"Confirm Password";
    confirmPassword.text = [Language get:@"SuperPassword_Text1" alter:@"Enter Password"] ;

    confirmPassword.backgroundColor = [UIColor clearColor];
    
    confirmPassword.layer.borderWidth  = UI_BORDER_WIDTH;
    confirmPassword.layer.borderColor  = RGB(40.0, 114.0, 195.0, 0.8).CGColor;
    confirmPassword.layer.cornerRadius = UI_BORDER_RADIUS;
    
    confirmPassword.font = [UIFont systemFontOfSize:30];
    confirmPassword.textAlignment = NSTextAlignmentCenter;
    
    confirmPassword.editable = NO;
    
    [self.view addSubview:confirmPassword];

//Add Confirm Button ---------------------------------------------------------------------
    Confirm_Button = [[UIButton alloc]init];
    //Set posision
    Confirm_Button.frame = CGRectMake(x_Spacing,
                                      CHAR_BUTTON_HEIGHT * 4 + y_Spacing * 5 + y_padding,
                                      CHAR_BUTTON_WIDTH * 2 + x_Spacing,
                                      CONTROL_BUTTON_HEIGHT);

    Confirm_Button.layer.borderWidth  = UI_BORDER_WIDTH;
    Confirm_Button.layer.borderColor  = RGB(40.0, 114.0, 195.0, 0.8).CGColor;
    Confirm_Button.layer.cornerRadius = UI_BORDER_RADIUS;
    
    Confirm_Button.titleLabel.font = [UIFont systemFontOfSize:30];
    [Confirm_Button setTitleColor:RGB(0, 0, 0, 1) forState:UIControlStateNormal];
//    [Confirm_Button setTitle:@"Enter" forState:UIControlStateNormal];
    [Confirm_Button setTitle:[Language get:@"SuperPassword_Button_Enter" alter:@"Enter"] forState:UIControlStateNormal];
//[Language get:@"SuperPassword_Button_Reset" alter:@"Reset"]
    [Confirm_Button addTarget:self action:@selector(Btn_Confirm_Click:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:Confirm_Button];

//Add Reset Button ---------------------------------------------------------------------
    Reset_Button = [[UIButton alloc]init];
    //Set posision
    Reset_Button.frame = CGRectMake(CHAR_BUTTON_WIDTH * 2 + x_Spacing * 3,
                                    CHAR_BUTTON_HEIGHT * 4 + y_Spacing * 5 + y_padding,
                                    CHAR_BUTTON_WIDTH * 2 + x_Spacing,
                                    CONTROL_BUTTON_HEIGHT);
    
    Reset_Button.layer.borderWidth  = UI_BORDER_WIDTH;
    Reset_Button.layer.borderColor  = RGB(40.0, 114.0, 195.0, 0.8).CGColor;
    Reset_Button.layer.cornerRadius = UI_BORDER_RADIUS;
    
    Reset_Button.titleLabel.font = [UIFont systemFontOfSize:30];
    [Reset_Button setTitleColor:RGB(0, 0, 0, 1) forState:UIControlStateNormal];
 //   [Reset_Button setTitle:@"Reset" forState:UIControlStateNormal];
    [Reset_Button setTitle:[Language get:@"SuperPassword_Button_Reset" alter:@"Reset"] forState:UIControlStateNormal];

    [Reset_Button addTarget:self action:@selector(Btn_Reset_Click:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:Reset_Button];
}

-(void)Btn_Num_Click:(id)sender
{
    UIButton *current = sender;
    
    //Enter New Password
    if (!PasswordMode)
    {
        if(current.tag <= 9)
        {
            [Password_Character appendString:Keyboard_Character[current.tag]];
            
            OriginalPassword.font = [UIFont systemFontOfSize:60];
            
            //Display "Star" symbol
            OriginalPassword.text = ^(NSString *words){
                NSMutableString *result = [[NSMutableString alloc]init];
                for(int i = 0 ; i < [words length] ; i++)
                {
                    [result appendString:@"*"];
                }
                return result;
            }(Password_Character);
        }
    }
    else
    {
        if(current.tag <= 9)
        {
            [Confirm_Character appendString:Keyboard_Character[current.tag]];
            
            confirmPassword.font = [UIFont systemFontOfSize:60];
            
            //Display "Star" symbol
            confirmPassword.text = ^(NSString *words){
                NSMutableString *result = [[NSMutableString alloc]init];
                NSLog(@"%@",result);
                for(int i = 0 ; i < [words length] ; i++)
                {
                    [result appendString:@"*"];
                }
                return result;
            }(Confirm_Character);
        }
    }
}

-(void)Btn_Confirm_Click:(id)sender
{
    NSLog(@"%@",Password_Character);
    NSLog(@"%@",confirmPassword.text);
    
    
    if (!PasswordMode)
    {
        PasswordMode = true;
        ConfirmMode = true;
        
      //  [Confirm_Button setTitle:@"Confirm" forState:UIControlStateNormal];
        [Confirm_Button setTitle:[Language get:@"SuperPassword_Button_Enter" alter:@"Enter Password"]  forState:UIControlStateNormal];

    }
    else if (PasswordMode == true && ConfirmMode == true)
    {
        //如果其中一個欄位為Null,
        if (![Password_Character isEqualToString:@""] && ![Confirm_Character isEqualToString:@""])
        {
            if ([Password_Character isEqualToString:Confirm_Character])
            {
                pListController *pList = [[pListController alloc]init];
                NSLog(@"%d",[pList updateProperty:@"SuperPassword" Value:Password_Character]);
                
                GlobalInfo *GLOBAL_INFO = [GlobalInfo ShareGlobalInfo];
                GLOBAL_INFO.SuperPassword = [pList getProperty:@"SuperPassword"];
                
                NSLog(@"SUPER_PASSWORD:%@",GLOBAL_INFO.SuperPassword);
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[Language get:@"SuperPassword_Button_Enter" alter:@"Enter Password"] message:[Language get:@"SuperPassword_AlertView_msg4" alter:@"Change Success!"] delegate:self cancelButtonTitle:[Language get:@"SuperPassword_Button_Enter" alter:@"OK"] otherButtonTitles:nil];
                
                [alertView show];

                [[self navigationController] popViewControllerAnimated:YES];
            }
            else
            {
               // [Language get:@"SuperPassword_AlertView_msg3" alter:@"I got it"]
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[Language get:@"SuperPassword_AlertView_msg1" alter:@"Wrong password"]  message:[Language get:@"SuperPassword_AlertView_msg2" alter:@"Please try another password."] delegate:self cancelButtonTitle:[Language get:@"SuperPassword_AlertView_msg3" alter:@"I got it"]otherButtonTitles:nil];
                
                [alertView show];
                
                PasswordMode = false;
                
                OriginalPassword.text = @"";
                confirmPassword.text = @"";
                
                Password_Character = [[NSMutableString alloc] init];
                Confirm_Character = [[NSMutableString alloc] init];
            }
        }
        
       // [Confirm_Button setTitle:@"Enter" forState:UIControlStateNormal];
        [Confirm_Button setTitle:[Language get:@"SuperPassword_Button_Enter" alter:@"Enter Password"] forState:UIControlStateNormal];

    }
}

-(void)Btn_Reset_Click:(id)sender
{
    PasswordMode = false;
    
    Password_Character = [[NSMutableString alloc ]init];
    Confirm_Character = [[NSMutableString alloc]init];
    
    confirmPassword.text = @"";
    OriginalPassword.text = @"";
    
   // [Confirm_Button setTitle:@"Enter" forState:UIControlStateNormal];
    [Confirm_Button setTitle:[Language get:@"SuperPassword_Button_Enter" alter:@"Enter Password"] forState:UIControlStateNormal];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark update data
-(void)UpdateData
{
    [Confirm_Button setTitle:[Language get:@"SuperPassword_Button_Enter" alter:@"Enter"] forState:UIControlStateNormal];
    [Reset_Button setTitle:[Language get:@"SuperPassword_Button_Reset" alter:@"Reset"] forState:UIControlStateNormal];

    self.confirmPassword.text = [Language get:@"SuperPassword_Text1" alter:@"Enter Password"];
    self.OriginalPassword.text = [Language get:@"SuperPassword_Text2" alter:@"Confirm Password"];


}

@end
