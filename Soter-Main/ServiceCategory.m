//
//  ServiceCategory.m
//  Soter-Main
//
//  Created by Neil on 2015/6/15.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "ServiceCategory.h"

@implementation ServiceCategory

@synthesize ID,Name,Pic;

-(id)init
{
    if (self =[super init])
    {
        self.ID     = -1;
        self.Name   = [[NSString alloc]init];
        self.Pic    = [[NSString alloc]init];
    }
    return self;
}

-(id)init:(int)_ServiceID NAME:(NSString*)_Name PIC:(NSString*)_Pic
{
    if (self = [super init])
    {
        self.ID     = _ServiceID;
        self.Name   = _Name;
        self.Pic    = _Pic;
    }
    
    return self;
}

@end
