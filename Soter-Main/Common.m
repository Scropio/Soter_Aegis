//
//  Common.m
//  Soter-Main
//
//  Created by Neil on 2015/8/26.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "Common.h"

@implementation Common
{
    NSMutableArray *nsmaAccessoryList;
    NSArray *nsaProtocolString;
    
    DBRestClient *restClient;
}

@synthesize ErrorMap;

+(void) AddFileToDevice:(NSData*)resource
{
    UIImage* image = [UIImage imageWithData:resource];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    
    [self CopyPhotoFromFile:nil];
    
    [self copy];
}

+(void) CopyPhotoFromFile:(NSString*)path
{
    NSData *resource = [[NSFileManager defaultManager] contentsAtPath:path];
    
    UIImage* image = [UIImage imageWithData:resource];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}


+(NSString*) SaveNSDataToStorage:(NSString *)Filename Image:(UIImage *)image
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *path = [paths firstObject];
    
    path = [path stringByAppendingString:@"/"];
    
    path = [path stringByAppendingString:@"test.txt"];
    
    NSString *data = @"test file data";
    [data writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    NSLog(@"File:%@",path);
    
    if(fileExist)
    {
        NSLog(@"File exist");
    }
    else
    {
        NSLog(@"File donot exist");
    }

    return path;
}

+(Boolean) CheckInternet
{
    Reachability *myNetwork = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [myNetwork currentReachabilityStatus];
    
    if (internetStatus == NotReachable)
    {
        return false;
    }
    
    return true;
}

#pragma mark - Service Mapping
+(NSString *) ServiceMapping:(NSString *)ServiceName
{
         if ([ServiceName isEqual: @"Dropbox"])     return @"Dropbox_Icon.png";
    else if ([ServiceName isEqual: @"Facebook"])    return @"Facebook_Icon.png";
    else if ([ServiceName isEqual: @"Gmail"])       return @"Gmail_Icon.png";
    else if ([ServiceName isEqual: @"GoogleDrive"]) return @"Google_Drive_Icon.png";
    else if ([ServiceName isEqual: @"Google"])      return @"Google_Icon.png";
    else if ([ServiceName isEqual: @"GooglePlus"])  return @"Google_Plus_Icon.png";
    else if ([ServiceName isEqual: @"Line"])        return @"Line_Icon.png";
    else if ([ServiceName isEqual: @"Ruten"])       return @"Ruten_Icon.png";
    else if ([ServiceName isEqual: @"OneDrive"])    return @"OneDrive_Icon.png";
    else if ([ServiceName isEqual: @"PCHome"])      return @"PCHome_Icon.png";
    else if ([ServiceName isEqual: @"Twitter"])     return @"Twitter_Icon.png";
    else if ([ServiceName isEqual: @"WeChat"])      return @"WeChat_Icon.png";
    else if ([ServiceName isEqual: @"Yahoo"])       return @"Yahoo_Icon.png";
    else if ([ServiceName isEqual: @"YouTube"])     return @"YouTube_Icon.png";
    else return @"empty.png";
}

#pragma mark - Detect OTG & Internet Status
-(NSDictionary *) UpdateDeviceStatus
{    
    NSMutableDictionary *Result = [[NSMutableDictionary alloc] init];
    
    BOOL OTG_Plugin;
    BOOL Internet;
    BOOL Cloud;
    
    nsaProtocolString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    OTG_Plugin  = ([nsmaAccessoryList count] != 0      ? (true) : (false));
    Internet    = ([Common CheckInternet]              ? (true) : (false));
    Cloud       = ([[DBSession sharedSession] isLinked]? (true) : (false));
    
    [Result setObject:@(OTG_Plugin) forKey:@"OTG"];
    [Result setObject:@(Internet)   forKey:@"Internet"];
    [Result setObject:@(Cloud)      forKey:@"Cloud"];
    
    return Result;
}

#pragma mark - Converter
+(NSData *) ConvertALAssetToNSData : (ALAsset *)PhotoAsset
{
    NSLog(@"ConvertALAssetToNSData");
    
    ALAssetRepresentation *ALAssetRep = [PhotoAsset defaultRepresentation];
    
    NSString *PhotoFileName = [ALAssetRep filename];
    
    UIImage *Photo = [UIImage imageWithCGImage:[[PhotoAsset defaultRepresentation]fullScreenImage]];
    
    NSData *returnNSData;
    
    if ([[PhotoFileName pathExtension] isEqualToString:@"jpg"])
        returnNSData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(Photo,1)];
    else
        returnNSData = [[NSData alloc] initWithData:UIImagePNGRepresentation(Photo)];
    
    return returnNSData;
}

+(NSString *) SaveNSDataToLocalAppFolder : (NSString *)FileName RawData:(NSData *) RawData
{
    NSString *FullFilePath = [NSTemporaryDirectory() stringByAppendingString:FileName];
    
    NSError *error = nil;
    
    BOOL Result = [RawData writeToFile:FullFilePath
                               options:NSASCIIStringEncoding
                                 error:&error];
    
    if (Result)
        return FullFilePath;
    else
        return [NSString stringWithFormat:@"ERROR:%@",error];
}

+(Boolean) isValidPhoto : (NSString*) Extension
{
//    NSString *_Extension = [FileName pathExtension];
    
    if([Extension isEqualToString:@"png"] ||
       [Extension isEqualToString:@"jpg"])
    {
        return true;
    }
    
    return false;
}

#pragma mark - Error Code
+(NSString *) ErrorCode:(NSString*)Code
{
    return @"";
}

//#pragma mark - OverWrite Log
//-(void) NSLog
//{
//    [super NSLog];
//    
//}


@end
