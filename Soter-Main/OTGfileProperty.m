//
//  OTGfileProperty.m
//  iFDiskSDK_Demo
//
//  Created by 吳家炘 on 2015/7/23.
//  Copyright © 2015年 CECAprd. All rights reserved.
//

#import "OTGfileProperty.h"


//================================================================================
@interface OTGfileProperty ()
{
//    NSString _type, _name;
//    uint64_t size,;
//
//    type = "Null";
//    size = 0;
//    name = "Null";
}
@end

@implementation OTGfileProperty

@synthesize type,name;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.type       = [[NSString alloc] init];
        self.name       = [[NSString alloc] init];
        //self.size       = [[NSString alloc] init];
    }
    return self;
}
@end
