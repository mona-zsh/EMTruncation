//
//  ViewController.m
//  EMLabel
//
//  Created by Mona Zhang on 3/31/15.
//  Copyright (c) 2015 Mona Zhang. All rights reserved.
//

#import "SVProgressHUD.h"

#import "NSString+Truncate.h"

#import "ViewController.h"

@interface ViewController ()

@property NSLayoutConstraint *labelHeightConstraint;
@property NSLayoutConstraint *expandedLabelHeightConstraint;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton *button;

@end

static NSMutableString *reallyLongString;
static NSInteger buttonMode = 0;
static NSString *text = @"'Begin at the beginning,' the King said, very gravely, 'and go on till you come to the end: then stop.'";

@implementation ViewController

+ (NSDictionary *)attributes {
    return @{NSFontAttributeName: [UIFont systemFontOfSize:20], NSForegroundColorAttributeName: [UIColor colorWithRed:136/255.0 green:119/255.0 blue:136/255.0 alpha:1]};
}

+ (UIColor *)color {
    return [UIColor colorWithRed:221/255.0 green:170/255.0 blue:119/255.0 alpha:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    reallyLongString = [NSMutableString stringWithString:text];
    for (int i = 0; i < 100; i++) {
        [reallyLongString appendString:text];
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    [self.view addSubview:self.label];
    [self.view addSubview:self.button];
    [self.view addSubview:self.timeLabel];

    /*
     Label Constraints:
     - Center X
     - Center Y
     - Width with 50pt margin
     - Height of 50pt
     */
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-45]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-100]];
    
    self.labelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:90];
    
    [self.label addConstraint:self.labelHeightConstraint];
    
    /*
     Button Constraints:
     - Center X
     - Top aligned with bottom of label
     - Width with 50pt margin
     - Height of 50pt
     */
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-100]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.label attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view setNeedsUpdateConstraints];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:50]];
    
    
    /*
     TimeLabel Constraints:
     - Center X
     - Top aligned with bottom of button
     - Width with 50pt margin
     - Height of 50pt
     */
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-100]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.button attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:50]];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)viewDidLayoutSubviews {
    if ([self.label.attributedText length] == 0) {
        [self updateViews];
    }
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        _button.backgroundColor = [UIColor colorWithRed:34/255.0 green:153/255.0 blue:221/255.0 alpha:1];
        [_button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [self.class attributes][NSFontAttributeName];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        _label.numberOfLines = 0;
        [_label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLabelTap:)]];
        _label.userInteractionEnabled = YES;
    }
    return _label;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:136/255.0 blue:136/255.0 alpha:1];
        _timeLabel.numberOfLines = 0;
    }
    return _timeLabel;
}

- (void)onLabelTap:(id)sender {
    if ([self.label.constraints containsObject:self.labelHeightConstraint]) {
        [self.label removeConstraint:self.labelHeightConstraint];
        float height = [text boundingRectWithSize:CGSizeMake(self.label.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:[self.class attributes] context:nil].size.height;
        self.expandedLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:ceil(height)];
        [self.label addConstraint:self.expandedLabelHeightConstraint];
    } else {
        [self.label removeConstraint:self.expandedLabelHeightConstraint];
        [self.label addConstraint:self.labelHeightConstraint];
    }
    [self.view setNeedsUpdateConstraints];
}

- (void)onButtonPress:(id)sender {
    buttonMode = (buttonMode + 1) % 3;
    [self updateViews];
}

- (void)updateViews {
    NSDate *start = [NSDate date];
    self.label.attributedText = [reallyLongString attributedStringByTruncatingToSize:self.label.frame.size attributes:[self.class attributes] trailingString:@"..." color:[self.class color] truncationMode:(buttonMode % 3)];
    
    switch (buttonMode % 3) {
        case (EMTruncationModeSubtraction): {
            [self.button setTitle:@"Subtraction" forState:UIControlStateNormal];
            break;
        }
        case (EMTruncationModeAddition): {
            [self.button setTitle:@"Addition" forState:UIControlStateNormal];
            break;
        }
        case (EMTruncationModeBinarySearch): {
            [self.button setTitle:@"Binary Search" forState:UIControlStateNormal];
            break;
        }
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%f seconds", [[NSDate date] timeIntervalSinceDate:start]];
}

@end
