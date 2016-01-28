//
//  MainViewElement.m
//  Soter-Main
//
//  Created by Neil on 2015/6/1.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "MainViewElement.h"

@implementation MainViewElement

@synthesize StatusIcon;

- (UIImageView*)AddStatusImage
{
    float sWidth = [[UIScreen mainScreen] bounds].size.width;
    
    StatusIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Unlink"]];
    StatusIcon.frame = CGRectMake(sWidth-36, 22, 32, 32);
    
    return StatusIcon;
}

//#pragma mark TestingView
//- (void)TestView_Action:(NSString *)Text{
//    
//    if([NSThread isMainThread])
//    {
//        [self TestView_Show:Text];
//    }
//    else
//    {
//        [self performSelectorOnMainThread:@selector(TestView_Show:) withObject:Text waitUntilDone:NO];
//    }
//}
//
//- (void)TestView_Show:(NSString *)Text
//{
//    
//    [[self textVeiwMSG] setText:@"TESTVIEW_SHOW"];
//}
//
//- (void)textViewMSG_Action:(NSString *)nssMessage
//{
//    if([NSThread isMainThread]){
//        [self textViewMSG_Display:nssMessage];
//    } else{
//        [self performSelectorOnMainThread:@selector(textViewMSG_Display:) withObject:nssMessage waitUntilDone:NO];
//    }
//}
//
//- (void)textViewMSG_Display:(NSString *)nssMessage
//{
//    NSString *nssText = [[self textVeiwMSG] text];
//    [[self textVeiwMSG] setText:[nssText stringByAppendingFormat:@"\r%@", nssMessage]];
//    [[self textVeiwMSG] scrollRangeToVisible:NSMakeRange([[[self textVeiwMSG] text] length], 0)];
//}

- (void)ChangeStatus_Link:(NSString *)nssMessage
{
    [self textViewMSG_Action:@"ChangeStatus"];
    
    if([NSThread isMainThread]){
        [self Status_Display:nssMessage];
    } else{
        [self performSelectorOnMainThread:@selector(Status_Display:) withObject:nssMessage waitUntilDone:NO];
    }
    
}

- (void)Status_Display:(NSString *)nssMessage
{
    if ([nssMessage  isEqual: @"true"])
    {
        [self.StatusIcon setImage:[UIImage imageNamed:@"Link"]];
    }
    else
    {
        [self.StatusIcon setImage:[UIImage imageNamed:@"Unlink"]];
    }
}

- (void)ChangeStatus_Unlink
{
    [self.StatusIcon setImage:[UIImage imageNamed:@"Unlink"]];
}

//================================================================================
- (void)textViewMSG_Action:(NSString *)nssMessage
{
    if([NSThread isMainThread]){
        [self textViewMSG_Display:nssMessage];
    } else{
        [self performSelectorOnMainThread:@selector(textViewMSG_Display:) withObject:nssMessage waitUntilDone:NO];
    }
}

//================================================================================
- (void)textViewMSG_ActionBuffer:(uint8_t *)buffer bumpLength:(uint32_t)length
{
    if([NSThread isMainThread]){
        [self textViewMSG_DisplayBuffer:buffer bumpLength:length];
    } else{
        // I don,t know how to used.
    }
}

//================================================================================
- (void)textViewMSG_Display:(NSString *)nssMessage
{
    NSString *nssText = [[self textView] text];
    [[self textView] setText:[nssText stringByAppendingFormat:@"\r%@", nssMessage]];
    [[self textView] scrollRangeToVisible:NSMakeRange([[[self textView] text] length], 0)];
}

//================================================================================
- (void)textViewMSG_DisplayBuffer:(uint8_t *)buffer bumpLength:(uint32_t)length
{
    NSString *nssData = @"";
    for(uint32_t uintI = 0; uintI < length; uintI++){
        nssData = [nssData stringByAppendingString:[NSString stringWithFormat:@"%02X ",buffer[uintI]]];
        if(((uintI + 1) % 16) == 0){ nssData = [nssData stringByAppendingString:@"\n"];}
    }
    //nssData = [nssData stringByAppendingString:@"\n"];
    
    NSString *nssText = [[self textView] text];
    [[self textView] setText:[nssText stringByAppendingFormat:@"\r%@", nssData]];
    [[self textView] scrollRangeToVisible:NSMakeRange([[[self textView] text] length], 0)];
}



@end
