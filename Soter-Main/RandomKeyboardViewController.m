//
//  RandomKeyboardViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/5/7.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "RandomKeyboardViewController.h"
#import "ExternalFileListViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "GlobalInfo.h"
#import "pListController.h"
#import "Language.h"
#import "LanguageViewController.h"

#define RGB(R,G,B,Alpha) [UIColor colorWithRed:((R)/255.0) green:((G)/255.0) blue:((B)/255.0) alpha:(Alpha)]
#define UI_BORDER_WIDTH     1.5;
#define UI_BORDER_RADIUS    10.0;
UIButton *Reset_Button;
UIAlertView *alertView;
UIButton *Confirm_Button;

@interface RandomKeyboardViewController ()
{
    float x_padding;
    float y_padding;
    
    float x_Spacing;
    float y_Spacing;
    
    float y_top;
    float y_bottom;
    
    NSMutableString *Password_Character;
    
    NSArray *default_Character;
    NSArray *Keyboard_Character;
    
    NSMutableArray *Keyboard;
}

@end

@implementation RandomKeyboardViewController

@synthesize Source,HomeBtn;

#define CHAR_BUTTON_HEIGHT   74
#define CHAR_BUTTON_WIDTH    74

#define CONTROL_BUTTON_HEIGHT   55
#define CONTROL_BUTTON_WIDTH    181

GlobalInfo *GLOBAL_INFO;



#pragma mark UI Compoment
//Password Box
UIImageView *TextImage;
UITextView *password;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popToRootViewControllerAnimated)
                                                 name:@"popToRoot"
                                               object:nil];
    
    GLOBAL_INFO = [GlobalInfo ShareGlobalInfo];
    
    //Get current screen size
    float sHeight;
    float sWidth;
    sHeight = [[UIScreen mainScreen] bounds].size.height;
    sWidth  = [[UIScreen mainScreen] bounds].size.width;
    
    //StatusBar.Height = 20 && NavigationBar.Height = 44
    x_Spacing = (sWidth - (CHAR_BUTTON_WIDTH) * 4) / 5;
    x_padding = x_Spacing;
    
    y_padding = 20 + 44 + ((sHeight - 20 - 44) * 0.1);
    y_Spacing = (((sHeight - 20 - 64) * 0.75) - (CHAR_BUTTON_HEIGHT * 4) - (CONTROL_BUTTON_HEIGHT)) / 6;
    
    
    //Initial Keyboard Character
    default_Character  = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F"];
    
    Keyboard_Character = [NSArray arrayWithObject:@"0"];
    Keyboard_Character = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F"];
    
    Keyboard_Character = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F"];
    
    Password_Character = [[NSMutableString alloc]init];
    
    [HomeBtn setImage:[[UIImage imageNamed:@"home.png"]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    [self Random_Character];
    
    [self generateKeyboard];
}

//Ray 20150921
//For RKB clean input text
-(void) viewWillAppear:(BOOL)animated
{
    [self UpdateData];

    [password setText:@""];
    Password_Character = [[NSMutableString alloc ]init];
}

- (IBAction)ReturnToRootView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Generate Keyboard Button

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
    
    //Add TextView
    password = [[UITextView alloc]init];
    password.frame = CGRectMake(x_padding ,y_padding - CHAR_BUTTON_HEIGHT,screenWidth - x_padding * 2,54);
    
    password.layer.cornerRadius = 10.0f;
    password.layer.borderWidth = 1.5f;
    password.backgroundColor = [UIColor clearColor];
    
    password.layer.borderColor = RGB(40.0, 114.0, 195.0, 0.8).CGColor;
    
    //Set text size
    password.font = [UIFont systemFontOfSize:60];

    //Set text horizontal align center
    password.textAlignment = NSTextAlignmentCenter;
    
    [password setEditable:false];
    
    //Set text vertical align middle
    password.textContainer.lineFragmentPadding = 0;
    password.textContainerInset = UIEdgeInsetsZero;
    
    [self.view addSubview:password];


    //Add Reset Button
//    UIButton *Reset_Button;
    Reset_Button = [[UIButton alloc]init];
    //Set posision
    Reset_Button.frame = CGRectMake(CHAR_BUTTON_WIDTH * 2 + x_Spacing * 3,
                                    CHAR_BUTTON_HEIGHT * 4 + y_Spacing * 6 + y_padding,
                                    CHAR_BUTTON_WIDTH * 2 + x_Spacing,
                                    CONTROL_BUTTON_HEIGHT);
    
    Reset_Button.layer.borderWidth  = UI_BORDER_WIDTH;
    Reset_Button.layer.borderColor  = RGB(40.0, 114.0, 195.0, 0.8).CGColor;
    Reset_Button.layer.cornerRadius = UI_BORDER_RADIUS;

    Reset_Button.titleLabel.font = [UIFont systemFontOfSize:30];
    [Reset_Button setTitleColor:RGB(0, 0, 0, 1) forState:UIControlStateNormal];
//    [Reset_Button setTitle:@"Reset" forState:UIControlStateNormal];
    
        [Reset_Button setTitle:[Language get:@"RandomKeyboard_Button_Reset" alter:@"Reset"] forState:UIControlStateNormal];
    //[Language get:@"RandomKeyboard_Button_Confirm" alter:@"Confirm"]
       [Reset_Button setTag:31];
    [Reset_Button addTarget:self action:@selector(Btn_Reset_Click:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:Reset_Button];
    
//    UIButton *Confirm_Button;
    Confirm_Button = [[UIButton alloc]init];
    //Set posision
    Confirm_Button.frame = CGRectMake(x_Spacing,
                                      CHAR_BUTTON_HEIGHT * 4 + y_Spacing * 6 + y_padding,
                                      CHAR_BUTTON_WIDTH * 2 + x_Spacing,
                                      CONTROL_BUTTON_HEIGHT);
    
    Confirm_Button.layer.borderWidth  = UI_BORDER_WIDTH;
    Confirm_Button.layer.borderColor  = RGB(40.0, 114.0, 195.0, 0.8).CGColor;
    Confirm_Button.layer.cornerRadius = UI_BORDER_RADIUS;
    
    Confirm_Button.titleLabel.font = [UIFont systemFontOfSize:30];
    [Confirm_Button setTitleColor:RGB(0, 0, 0, 1) forState:UIControlStateNormal];
 //   [Confirm_Button setTitle:@"Confirm" forState:UIControlStateNormal];
    [Confirm_Button setTitle:[Language get:@"RandomKeyboard_Button_Confirm" alter:@"Confirm"] forState:UIControlStateNormal];
    [Confirm_Button setTag:32];



    [Confirm_Button addTarget:self action:@selector(Btn_Confirm_Click:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:Confirm_Button];
}

-(void)Btn_Num_Click:(id)sender
{
    UIButton *current = sender;
    
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if(current.tag <= 9)
    {
        [Password_Character appendString:Keyboard_Character[current.tag]];
        
        //Display "Star" symbol
        password.text = ^(NSString *words){
            NSMutableString *result = [[NSMutableString alloc]init];
            for(int i = 0 ; i < [words length] ; i++)
            {
                [result appendString:@"*"];
            }
            return result;
        }(Password_Character);
    }
}

-(void)Btn_Confirm_Click:(id)sender
{
    NSLog(@"PASSWORD:%@",Password_Character);
    
//#pragma mark Debug
//    Password_Character = GLOBAL_INFO.SuperPassword;
    GlobalInfo *GLOBAL_INFO = [GlobalInfo ShareGlobalInfo];
    NSLog(@"SUPER:%@",GLOBAL_INFO.SuperPassword);
    
    pListController *a = [[pListController alloc] init];
    NSString *Pwd = [a getProperty:@"SuperPassword"];
    
    NSLog(@"%@",Pwd);
    
//    Password_Character = GLOBAL_INFO.SuperPassword;
    
    if([Password_Character isEqualToString:GLOBAL_INFO.SuperPassword])
    {
    
        if ([Source isEqual: @"OptionA"])
        {
            [self performSegueWithIdentifier:@"Rand2External" sender:self];
        }
        else if( [Source isEqual: @"OptionB"])
        {
            [self performSegueWithIdentifier:@"Rand2Cloud" sender:self];
        }
        else if( [Source isEqual: @"OptionC"])
        {
            [self performSegueWithIdentifier:@"Rand2Photo" sender:self];
        }
        else if( [Source isEqual: @"OptionD"])
        {
            [self performSegueWithIdentifier:@"Rand2Account" sender:self];
        }
        else if( [Source isEqualToString:@"OptionE"])
        {
            [self performSegueWithIdentifier:@"Rand2Setting" sender:self];
        }
    }
    else
    {
       // [Language get:@"RandomKeyboard_AlertView_msg3" alter:@"I got it"]
        alertView = [[UIAlertView alloc]initWithTitle:[Language get:@"RandomKeyboard_AlertView_msg1" alter:@"Wrong password"]message:[Language get:@"RandomKeyboard_AlertView_msg2" alter:@"Please try another password."]  delegate:self cancelButtonTitle:[Language get:@"RandomKeyboard_AlertView_msg3" alter:@"I got it"] otherButtonTitles:nil];
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[Language get:@"RandomKeyboard_AlertView_msg1" alter:@"Wrong password"] message:[Language get:@"RandomKeyboard_AlertView_msg2" alter:@"Please try another password."]   delegate:self cancelButtonTitle:[Language get:@"RandomKeyboard_AlertView_msg2" alter:@"I got it"] otherButtonTitles:nil];
        
        
        [password setText:@""];
        Password_Character = [[NSMutableString alloc ]init];
        [alertView show];
    }
}

-(void)Btn_Reset_Click:(id)sender
{
    password.text = @"";
    Password_Character = [[NSMutableString alloc ]init];
//    Password_Character =
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
//    if([[segue identifier] isEqualToString:@"Rand2External"])
//    {
//        [self performSegueWithIdentifier:@"Rand2External" sender:sender];
//    }
//    else if ([[segue identifier] isEqualToString:@"Rand2Cloud"])
//    {
//        [self performSegueWithIdentifier:@"Rand2Cloud" sender:sender];
//    }
//    else if ([[segue identifier] isEqualToString:@"Rand2Photo"])
//    {
//        [self performSegueWithIdentifier:@"Rand2Photo" sender:sender];
//    }
//    else if ([[segue identifier] isEqualToString:@"Rand2Account"])
//    {
//        [self performSegueWithIdentifier:@"Rand2Account" sender:sender];
//    }
//    else if ([[segue identifier] isEqualToString:@"Rand2Cloud"])
//    {
//        [self performSegueWithIdentifier:@"Rand2External" sender:sender];
//    }
}
- (IBAction)HomeBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)popToRootViewControllerAnimated
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark update data
-(void)UpdateData
{
    self.title = [Language get:@"RandomKeyboard_Title" alter:@"RandomKeyboard"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"RandomKeyboard_Title" alter:@"RandomKeyboard"];
    

    [Reset_Button setTitle:[Language get:@"RandomKeyboard_Button_Reset" alter:@"Reset"] forState:UIControlStateNormal];
    [Confirm_Button setTitle:[Language get:@"RandomKeyboard_Button_Confirm" alter:@"Confirm"] forState:UIControlStateNormal];


}
@end
