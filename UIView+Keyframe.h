//
//  UIView+Keyframe.h
//  KeyframeSandbox
//
//  Created by Erik Amble on 6/7/14.
//  Copyright (c) 2014 Erik Amble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Keyframe)

@property IBInspectable double stepDuration;
@property IBInspectable double startDelay;
@property IBInspectable BOOL shouldBounce;

@property IBInspectable double minOffset;
@property IBInspectable double maxOffset;
@property IBInspectable NSString *dimension;
@property IBInspectable BOOL shouldExtendBeyondMin;
@property IBInspectable BOOL shouldExtendBeyondMax;

@property IBOutlet UIView *nextKeyframe;
@property IBOutlet UIScrollView *scrollController;

- (IBAction)advanceKeyframe:(id)sender;
- (IBAction)toggleKeyFrame:(id)sender;
- (IBAction)reverseKeyFrame:(id)sender;
@end
