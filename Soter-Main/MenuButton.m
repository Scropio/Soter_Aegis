//
//  MenuButton.m
//  Soter-Main
//
//  Created by Neil on 2015/5/6.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "MenuButton.h"

#define RGB(R,G,B,Alpha) [UIColor colorWithRed:((R)/255.0) green:((G)/255.0) blue:((B)/255.0) alpha:(Alpha)]

//@interface MenuButton ()
//{
//    UIImage*    Btn_Icon;
//    NSString*   Btn_Text;
//    CGFloat     Btn_Text_Size;
//}
//@end

@implementation MenuButton
{
    UIImage *_image;
    NSString *_title;
    CGFloat _size;
}

@synthesize IconName,TitleText,TitleFontSize;

@synthesize Icon,IconMask,TextFrame,TextFrameMask,Title;

bool DebugMode = false;

- (id)initWithFrame:(CGRect)frame IconImageName:(NSString *)icon_image TitleText:(NSString *)title FontSize:(CGFloat)fontsize
{
    self = [super initWithFrame:frame];
    if(self){
        
        !(_image = [UIImage imageNamed:icon_image]) ? (_image = [UIImage imageNamed:@"menubutton_warning.png"]):
                                                      (_image = [UIImage imageNamed:icon_image]);
        
        !title ? (_title = @"Null Pointer"):
                 (_title = title);
        
        !fontsize ? (_size = 20):
                    (_size = fontsize);
    }
    return self;
}

//- (id)initWithFrame:(CGRect)frame Icon:(UIImage*)ICON Title:(NSString *)Text FontSize:(CGFloat)fSize
//{
//    if(self = [super init])
//    {
//        Icon = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 65, 65)];
//        IconMask = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 65, 65)];
//        Title = [[UILabel alloc]initWithFrame:CGRectMake(105, 20, 176, 32)];
//        TextFrame = [[UIImageView alloc] initWithFrame:CGRectMake(101, 15, 184, 42)];
//        TextFrameMask = [[UIImageView alloc] initWithFrame:CGRectMake(99.5, 13.5, 188, 45)];
//        
//        //Btn_Icon
//        @try{
//            Btn_Icon = ICON;
//        }
//        @catch (NSException *exception){
//            NSLog(@"MenuButton.initWithFrame: %@ : %@",exception.name,exception.reason);
//        }
//        @finally{
//            Btn_Icon = [UIImage imageNamed:@"menubutton_warning.png"];
//        }
//        
//        //Btn_Text
//        @try{
//            Btn_Text = Text;
//        }
//        @catch (NSException *exception){
//            NSLog(@"MenuButton.initWithFrame: %@ : %@",exception.name,exception.reason);
//        }
//        @finally {
//            Btn_Text = @"No Define Text";
//        }
//        
//        //Btn_Text_Size
//        @try {
//            Btn_Text_Size > 0 ? (Btn_Text_Size=fSize) : (Btn_Text_Size=12);
//        }
//        @catch (NSException *exception) {
//            NSLog(@"MenuButton.initWithFrame: %@ : %@",exception.name,exception.reason);
//        }
//        @finally {
//            Btn_Text_Size = 12;
//        }
//        
//        [self addSubview:TextFrame];
//        [self addSubview:Title];
//        [self addSubview:TextFrameMask];
//        
//        [self addSubview:Icon];
//        [self addSubview:IconMask];
//    }
//    return self;
//}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    Icon = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 65, 65)];
    [Icon setImage:_image];
    [Icon setContentMode:UIViewContentModeScaleAspectFit];
     [Icon setTag:1 ];

    IconMask = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 65, 65)];
    IconMask.layer.cornerRadius = 18.0f;
    [IconMask setBackgroundColor:[UIColor whiteColor]];
    [IconMask setAlpha:0.6];
    [IconMask setHidden:[self isEnabled]];
    [IconMask setTag:2];

    
//    if([self isEnabled])
//    {
//        [self.Icon setBackgroundColor:[UIColor redColor]];
//    }
//    else
//    {
//        [self.Icon setBackgroundColor:[UIColor blueColor]];
//    }

    Title = [[UILabel alloc]initWithFrame:CGRectMake(105, 20, 176, 32)];
    [Title setFont:[UIFont boldSystemFontOfSize:_size]];
    [Title setText:_title];
    [Title setTextAlignment:NSTextAlignmentCenter];
    [Title setTag:3];

    TextFrame = [[UIImageView alloc] initWithFrame:CGRectMake(101, 15, 184, 42)];
    TextFrame.layer.cornerRadius = 10.0f;
    TextFrame.layer.borderColor = RGB(40.0, 114.0, 195.0, 0.8).CGColor;
    TextFrame.layer.borderWidth = 1.5f;
    [TextFrame setTag:4];

    TextFrameMask = [[UIImageView alloc] initWithFrame:CGRectMake(99.5, 13.5, 188, 45)];
    [TextFrameMask.layer setCornerRadius:10.0f];
    [TextFrameMask setBackgroundColor:[UIColor whiteColor]];
    [TextFrameMask setAlpha:0.6];
    [TextFrameMask setHidden:[self isEnabled]];
       [TextFrameMask setTag:5];

    [self addSubview:TextFrame];
    [self addSubview:Title];
    [self addSubview:TextFrameMask];

    [self addSubview:Icon];
    [self addSubview:IconMask];
    
    [self bringSubviewToFront:TextFrameMask];
    [self bringSubviewToFront:IconMask];
    
//    [self bringSubviewToFront:IconMask];
}

//#pragma Neil set thumbnail
//- (void)setICON:(UIImage*)image
//{
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 65, 65)];
//    
//    [imgView setImage:image];
//    
//    [self addSubview:imgView];
//}
//
//- (void)setEmptyICON:(UIImage*)image
//{
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 65, 65)];
//    
//    [imgView setImage:image];
//    
//    [self addSubview:imgView];
//}
//
//- (void)setButtonEnable:(BOOL)Enable
//{
//    dispatch_async(dispatch_get_main_queue(),^{
//        if(Enable)
//        {
//            
//                TextFrameMask.backgroundColor = [UIColor greenColor];
//                TextFrameMask.alpha = 1.0;
//                
//                IconMask.backgroundColor = [UIColor greenColor];
//                IconMask.alpha = 1.0;
////                self.enabled = true;
//            
//        }
//        else
//        {
//            
//            TextFrameMask.backgroundColor = [UIColor blueColor];
//            TextFrameMask.alpha = 0.6;
//        
//        
//            
//            IconMask.backgroundColor = [UIColor blueColor];
//            IconMask.alpha = 0.6;
//                
////                self.enabled = false;
//        }
//    });
//}

//- (void)setButtonEnable:(id)target isEnable:(BOOL)Enable
//{
//    dispatch_async(dispatch_get_main_queue(),^{
//        if(Enable)
//        {
////            TextFrameMask.backgroundColor = [UIColor clearColor];
////            TextFrameMask.alpha = 1.0;
////            
////            IconMask.backgroundColor = [UIColor clearColor];
////            
//            [TextFrameMask setBackgroundColor:[UIColor clearColor]];
//            [TextFrameMask setAlpha:1.0];
//            
//            [IconMask setBackgroundColor:[UIColor clearColor]];
//            [IconMask setAlpha:1.0];
////            self.enabled = true;
//            
//            [self debugView:target Debug:@"Enable"];
//        }
//        else
//        {
//            [TextFrameMask setBackgroundColor:[UIColor whiteColor]];
//            [TextFrameMask setAlpha:0.6];
//            
//            [IconMask setBackgroundColor:[UIColor whiteColor]];
//            [IconMask setAlpha:0.6];
//            [self debugView:target Debug:@"Disable"];
//        }
//    });
//}

//#pragma Neil set title
//- (void)setTitle:(NSString*)TitleText FontSize:(CGFloat)Size
//{
//    Title = [[UILabel alloc]initWithFrame:CGRectMake(105, 20, 176, 32)];
//    [Title setFont:[UIFont boldSystemFontOfSize:Size]];
//    Title.text = TitleText;
//    Title.textAlignment = NSTextAlignmentCenter;
//    
//    [self addSubview:Title];
//}
//
//- (void)debugView:(id)target Debug:(NSString *)DebugMsg
//{
//    UIAlertView *debug = [[UIAlertView alloc] initWithTitle:@"Debug"
//                                                    message:DebugMsg
//                                                   delegate:target
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    
////    dispatch_async(dispatch_get_main_queue(),^{
//    if(DebugMode)
//    {
//        [debug show];
//    }
////    });
//    
//    
//}
//





@end
