//  Created by Oleg on 2015.
//  Copyright (c) 2015 Oleg Hnidets. All rights reserved.
//

#import "OHSubtitleParser.h"

NSString *const kIndex = @"kIndex";
NSString *const kStart = @"kStart";
NSString *const kEnd   = @"kEnd";
NSString *const kText  = @"kText";

@implementation OHSubtitleParser

+ (void)parseString:(NSString *)string
          subtitles:(NSMutableDictionary *)subtitlesParts
             parsed:(void (^)(BOOL parsed, NSError *error))completion {
    // Divide subtitles on parts
    NSArray *comps = [string componentsSeparatedByString:@"\n\n"];
    if (comps.count <= 1) {
        comps = [string componentsSeparatedByString:@"\r\n\r\n"];
    }
    
    NSInteger index = 1;
    for (NSString *component in comps) {
        NSScanner *scanner = [NSScanner scannerWithString:component];
        // Scan index
        NSString *indexString;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&indexString];
        if (!indexString.integerValue) {
            indexString = @(index).stringValue;
            index++;
            scanner = [NSScanner scannerWithString:component];
        }
        
        // Scan start
        NSString *startString;
        [scanner scanUpToString:@" --> " intoString:&startString];
        [scanner scanString:@"-->" intoString:nil];
        
        // Scan end
        NSString *endString;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&endString];
        NSArray *endComponents = [endString componentsSeparatedByString:@" "];
        endString = endComponents.count ? endComponents.firstObject : endComponents;
        
        // Scan text
        NSString *textString;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&textString];
        textString = [textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Scanning text to the end of string.
        NSRange range = NSMakeRange(0,  component.length);
        if (textString) {
            NSRange foundRange = [component rangeOfString:textString options:0 range:range];
            if (range.length) {
                textString = [component substringFromIndex:foundRange.location];
            }
        }
        
        NSError *error = nil;
        NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"[<|\\{][^>|\\^}]*[>|\\}]"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
        
        textString = [regExp stringByReplacingMatchesInString:textString.length > 0 ? textString : @""
                                                      options:0
                                                        range:NSMakeRange(0, textString.length)
                                                 withTemplate:@""];
        
        NSDictionary *tempInterval = @{ kIndex : indexString,
                                        kStart : @([OHSubtitleParser timeFromString:startString]),
                                        kEnd : @([OHSubtitleParser timeFromString:endString]),
                                        kText : textString ?: @"" };
        
        [subtitlesParts setObject:tempInterval forKey:indexString];
    }
    
    if (completion != NULL) {
        completion(subtitlesParts.count > 0, nil);
    }
}

+ (NSTimeInterval)timeFromString:(NSString *)timeString {
    NSScanner *scanner = [NSScanner scannerWithString:timeString];
    
    long long h, m, s, c;
    [scanner scanLongLong:&h];
    [scanner scanString:@":" intoString:nil];
    [scanner scanLongLong:&m];
    [scanner scanString:@":" intoString:nil];
    [scanner scanLongLong:&s];
    if ([timeString rangeOfString:@","].location != NSNotFound) {
        [scanner scanString:@"," intoString:nil];
    } else if ([timeString rangeOfString:@"."].location != NSNotFound) {
        [scanner scanString:@"." intoString:nil];
    }
    
    [scanner scanLongLong:&c];
    
    return (h * 3600) + (m * 60) + s + (c / 1000.0);
    
}

@end
