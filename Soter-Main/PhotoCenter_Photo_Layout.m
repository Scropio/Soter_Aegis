//
//  PhotoCenter_Photo_Layout.m
//  Soter
//
//  Created by Neil on 2015/4/23.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "PhotoCenter_Photo_Layout.h"

@implementation PhotoCenter_Photo_Layout

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.itemSize                = CGSizeMake(75, 82);
        self.sectionInset            = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
        self.minimumInteritemSpacing = 4.0f;
        self.footerReferenceSize     = CGSizeMake(100, 100);
        self.minimumLineSpacing      = 4.0f;
    }
    
    return self;
}


@end
