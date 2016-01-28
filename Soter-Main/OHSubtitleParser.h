//  Created by Oleg on 2015.
//  Copyright (c) 2015 Oleg Hnidets. All rights reserved.
//

@import Foundation;

extern NSString *const kIndex;
extern NSString *const kStart;
extern NSString *const kEnd;
extern NSString *const kText;

@interface OHSubtitleParser : NSObject

//! Method parses .srt, .vtt subtitle formats.
+ (void)parseString:(NSString *)string
          subtitles:(NSMutableDictionary *)subtitlesParts
             parsed:(void (^)(BOOL parsed, NSError *error))completion;

@end
