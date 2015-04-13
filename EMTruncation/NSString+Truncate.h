//
//  NSString+Truncate.h
//  EMLabel
//
//  Created by Mona Zhang on 3/31/15.
//  Copyright (c) 2015 Mona Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum {
    EMTruncationModeSubtraction = 0,
    EMTruncationModeAddition = 1,
    EMTruncationModeBinarySearch = 2
} EMTruncationMode;

@interface NSString (Truncate)

- (NSAttributedString *)attributedStringByTruncatingToSize:(CGSize)size
                                            attributes:(NSDictionary *)attributes
                                            trailingString:(NSString *)trailingString
                                                     color:(UIColor *)color
                                            truncationMode:(EMTruncationMode)truncationMode;


@end
