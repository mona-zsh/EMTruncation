//
//  NSString+Truncate.m
//  EMLabel
//
//  Created by Mona Zhang on 3/31/15.
//  Copyright (c) 2015 Mona Zhang. All rights reserved.
//

#import "NSString+Truncate.h"

@implementation NSString (Truncate)

# pragma mark - Helper method

/*
 Returns whether string will fit in given size. Uses `boundingRectWithSize:options:attributes:context` to check if the max height of the string given a constraining width is greater than the height of the given size parameter.
 */
- (BOOL)willFitToSize:(CGSize)size trailingString:(NSString *)trailingString attributes:(NSDictionary *)attributes {
    return [[NSString stringWithFormat:@"%@%@", self, trailingString] boundingRectWithSize:CGSizeMake(size.width, CGFLOAT_MAX)
                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                           attributes:attributes
                              context:nil].size.height <= size.height;
}

/* 
 Uses one of three truncation modes to truncate string and append a trailing string.
 
 - EMTruncationModeSubtraction: subtracts a character from the string until it fits the constraining size.
 - EMTruncationModeAddition: appends a character to the string until it does not fit the constraining size, then constructs the string using the index of the last character that fit.
 - EMTruncationModeBinarySearch: uses a binary search to find the lower bound.
 
 The font size of trailing string is assumed to be the same as the font size of the string being truncated, or calculations would be too funny to calculate.
*/
- (NSAttributedString *)attributedStringByTruncatingToSize:(CGSize)size
                                                attributes:(NSDictionary *)attributes
                                            trailingString:(NSString *)trailingString
                                                     color:(UIColor *)color
                                            truncationMode:(EMTruncationMode)truncationMode {
    switch (truncationMode) {
        case EMTruncationModeAddition: {
            return [self stringUsingAdditionToTruncateToSize:size attributes:attributes trailingString:trailingString color:color];
            break;
        }
        case EMTruncationModeSubtraction: {
            return [self stringUsingSubtractionToTruncateToSize:size attributes:attributes trailingString:trailingString color:color];
            break;
        }
        case EMTruncationModeBinarySearch: {
            return [self stringUsingBinarySearchToTruncateToSize:size attributes:attributes trailingString:trailingString color:color];
            break;
        }
        default:
            // Default to binary search
            return [self stringUsingBinarySearchToTruncateToSize:size attributes:attributes trailingString:trailingString color:color];
            break;
        }
    
}

#pragma mark - Truncation methods

/*
 TruncationModeSubtraction
 
 Subtracts one character at a time from string (+ trailingString). Stops when height of bounds fits the constraining height and uses index to reconstruct string that fits.
 
 Performance: O(N), where N is length of the string 
 
 (this is a horrible method to use if you have long strings to truncate).
 */
- (NSAttributedString *)stringUsingSubtractionToTruncateToSize:(CGSize)size
                                                    attributes:(NSDictionary *)attributes
                                                trailingString:(NSString *)trailingString
                                                         color:(UIColor *)color {
    
    if (![self willFitToSize:size trailingString:@"" attributes:attributes]) {
        
        NSMutableString *string = [self mutableCopy];
        NSRange rangeOfLastCharacter = {string.length - 1, 1};
        
        while (![string willFitToSize:size trailingString:trailingString attributes:attributes]) {
            [string deleteCharactersInRange:rangeOfLastCharacter];
            rangeOfLastCharacter.location--;
        }
        
        NSInteger indexOfLastCharacter = rangeOfLastCharacter.location + rangeOfLastCharacter.length;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[string substringToIndex:indexOfLastCharacter] attributes:attributes];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:trailingString attributes:@{
                                                                                                                        NSForegroundColorAttributeName: color,
                                                                                                                        NSFontAttributeName: attributes[NSFontAttributeName]
                                                                                                                        }]];
        return attributedString;
    } else {
        return [[NSAttributedString alloc] initWithString:self attributes:attributes];
    }
}


/*
 TruncationModeAddition - adds one character at a time from string (+ trailingString). Stops when height of bounds exceeds the constraining height and uses index to reconstruct string that fits.
 
  Performance: constant in the size parameter
 */

- (NSAttributedString *)stringUsingAdditionToTruncateToSize:(CGSize)size
                                                 attributes:(NSDictionary *)attributes
                                             trailingString:(NSString *)trailingString
                                                      color:(UIColor *)color {
    
    if (![self willFitToSize:size trailingString:@"" attributes:attributes]) {

        NSMutableString *stringThatFits = [@"" mutableCopy];
        NSRange range = {0, 1};
        
        while ([stringThatFits willFitToSize:size trailingString:trailingString attributes:attributes]) {
            [stringThatFits insertString:[self substringWithRange:range] atIndex:range.location];
            range.location++;
        }
        
        NSInteger indexOfLastCharacterThatFits = range.location - range.length;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[stringThatFits substringToIndex:indexOfLastCharacterThatFits] attributes:attributes];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:trailingString attributes:@{
                                                                                                              NSForegroundColorAttributeName: color,
                                                                                                              NSFontAttributeName: attributes[NSFontAttributeName]
                                                                                                              }]];
        return attributedString;
    } else {
        return [[NSAttributedString alloc] initWithString:self attributes:attributes];
    }
}

/*
 TruncationModeBinarySearch - using 0 and N as starting indices, where N is the length of the string, perform a binary search that maintains the invariants that:
 
 - height at minIndex <= size.height
 - height at maxIndex > size.height
 
 Returns minIndex when minIndex and maxIndex are adjacent
 
 Performance: log(N)
 */
- (NSAttributedString *)stringUsingBinarySearchToTruncateToSize:(CGSize)size
                                                    attributes:(NSDictionary *)attributes
                                                trailingString:(NSString *)trailingString
                                                         color:(UIColor *)color {
    
    if (![self willFitToSize:size trailingString:@"" attributes:attributes]) {
        
        NSInteger indexOfLastCharacterThatFits = [self binarySearchForStringIndexThatFitsSize:size attributes:attributes minIndex:0 maxIndex:self.length trailingString:trailingString];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[self substringToIndex:indexOfLastCharacterThatFits] attributes:attributes];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:trailingString attributes:@{
                                                                                                              NSForegroundColorAttributeName: color,
                                                                                                              NSFontAttributeName: attributes[NSFontAttributeName]
                                                                                                              }]];
        return string;
    } else {
        return [[NSAttributedString alloc] initWithString:self attributes:attributes];
    }

}

- (NSInteger)binarySearchForStringIndexThatFitsSize:(CGSize)size attributes:(NSDictionary *)attributes minIndex:(NSInteger)minIndex maxIndex:(NSInteger)maxIndex trailingString:(NSString *)trailingString {
    /* 
     Invariants: 
     - height at minIndex <= size.height
     - height at maxIndex > size.height
    */
    
    NSInteger midIndex = (minIndex + maxIndex) / 2;
    NSString *subString = [self substringWithRange:NSMakeRange(0, midIndex)];
    
    /* Invariant assertions
    assert([[self substringWithRange:NSMakeRange(0, minIndex)] willFitToSize:size trailingString:trailingString attributes:attributes]);
    assert(![[self substringWithRange:NSMakeRange(0, maxIndex)] willFitToSize:size trailingString:trailingString attributes:attributes]);
     */
    
    if (maxIndex - minIndex == 1) {
        return minIndex;
    }
    
    // String is greater than constraining size, start search with minIndex as new maximum
    // The max index will always be greater than the size
    if (![subString willFitToSize:size trailingString:trailingString attributes:attributes]) {
        return [self binarySearchForStringIndexThatFitsSize:size attributes:attributes minIndex:minIndex maxIndex:midIndex trailingString:trailingString];
    }
    // String is less than constraining size, start search with midIndex as new minimum
    // The minimum index will be less than or equal to the size
    else {
        return [self binarySearchForStringIndexThatFitsSize:size attributes:attributes minIndex:midIndex maxIndex:maxIndex trailingString:trailingString];
    }
}

@end