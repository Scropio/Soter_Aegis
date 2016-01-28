//  Created by Oleg on 2015.
//  Copyright (c) 2015 Oleg Hnidets. All rights reserved.
//

#import "OHSubtitleLabel.h"

@implementation OHSubtitleLabel

- (void)setText:(NSString *)text {
    if ([self.attributedText.string isEqualToString:text]) {
        return ;
    }
    
    super.text = text;
    if (!text) {
        return ;
    }
    
    if (!_attributes) {
        _attributes = @{ NSStrokeWidthAttributeName : @-4.0,
                        NSStrokeColorAttributeName : [UIColor blackColor],
                        NSForegroundColorAttributeName : self.textColor };
    }
    
    self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:_attributes];
}

@end
