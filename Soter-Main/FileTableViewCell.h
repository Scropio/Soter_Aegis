//
//  FileTableViewCell.h
//  Soter-Main
//
//  Created by Neil on 2015/9/22.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *Thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *Filename;
@property (weak, nonatomic) IBOutlet UILabel *Filesize;

@end
