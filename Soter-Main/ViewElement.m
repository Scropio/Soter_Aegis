//
//  ViewElement.m
//  iFDiskSDK
//
//  Created by Mac_ohm on 12/8/9.
//
//

#import "ViewElement.h"

//================================================================================
@interface ViewElement ()
{
    UIAlertView *uiavAlertShow;
    
    FileSystemAPI *fsaAPI;
}
@end

@implementation ViewElement

@synthesize textVeiwMSG;
@synthesize buttonMSG;

//================================================================================
- (void)dealloc
{
    [self setButtonMSG:nil];
    [self setTextVeiwMSG:nil];
}

//================================================================================
- (IBAction)buttonMSG_Action:(id)sender
{
    [[self textVeiwMSG] setText:@"View Message"];
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
    NSString *nssText = [[self textVeiwMSG] text];
    [[self textVeiwMSG] setText:[nssText stringByAppendingFormat:@"\r%@", nssMessage]];
    [[self textVeiwMSG] scrollRangeToVisible:NSMakeRange([[[self textVeiwMSG] text] length], 0)];
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
    
    NSString *nssText = [[self textVeiwMSG] text];
    [[self textVeiwMSG] setText:[nssText stringByAppendingFormat:@"\r%@", nssData]];
    [[self textVeiwMSG] scrollRangeToVisible:NSMakeRange([[[self textVeiwMSG] text] length], 0)];
}

//================================================================================
- (void)alertTitle:(NSString *)nssTitle alertMessage:(NSString *)nssMessage object:(NSObject *)nsoObject
{
    if(uiavAlertShow != nil){ [self alertFinish];}
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(140, 90);
    [indicator startAnimating];
    uiavAlertShow = [[UIAlertView alloc]initWithTitle:nssTitle message:nssMessage delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [uiavAlertShow addSubview:indicator];
	[uiavAlertShow show];
}

//================================================================================
- (void)alertFinish
{
    if(uiavAlertShow != nil){
        [uiavAlertShow dismissWithClickedButtonIndex:0 animated:YES];
    }
}
//================================================================================
- (void)clearDebugMessage
{
    [[self textVeiwMSG] setText:@"View Message"];
    
}
@end
