//
//  UIView+Keyframe.m
//  KeyframeSandbox
//
//  Created by Erik Amble on 6/7/14.
//  Copyright (c) 2014 Erik Amble. All rights reserved.
//

#import "UIView+Keyframe.h"
#import <objc/runtime.h>


static const char *kKeyframeShim;
static const char *kOriginalFrame;
static const char *kOriginalAlpha;
static const char *kNextKeyframe;

static const char *kStepDuration;
static const char *kStartDelay;

static const char *kScrollController;
static const char *kMinOffset;
static const char *kMaxOffset;
static const char *kShouldExtendBeyondMin;
static const char *kShouldExtendBeyondMax;
static const char *kDimension;


@interface KeyframeShim : NSObject
@property (weak) UIView *parent;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
@end

@implementation KeyframeShim
@synthesize parent;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // This really should be in a separate file/class but it's so much easier here!
    if ([parent isKindOfClass:[UIPageControl class]]) {
        [((UIPageControl *) parent) setCurrentPage:(int)(((UIScrollView *)object).contentOffset.x/((UIScrollView *)object).frame.size.width + 0.5)];
        return;
    }
    
    float k = (([parent.dimension isEqualToString:@"y"] ? ((UIScrollView *)object).contentOffset.y : ((UIScrollView *)object).contentOffset.x) - parent.minOffset)/(parent.maxOffset - parent.minOffset);
    BOOL shouldExtendBeyondMin = parent.shouldExtendBeyondMin;
    if (!shouldExtendBeyondMin) {
        k = k < 0.0 ? 0.0 : k;
    }
    BOOL shouldExtendBeyondMax = parent.shouldExtendBeyondMax;
    if (!shouldExtendBeyondMax) {
        k = k > 1.0 ? 1.0 : k;
    }

    
    
    CGRect sourceValue = [objc_getAssociatedObject(parent, &kOriginalFrame) CGRectValue];
    CGRect targetValue = parent.nextKeyframe.frame;
    
    CGRect finalValue;
    finalValue.origin.x = sourceValue.origin.x * (1.0 - k) + targetValue.origin.x * k;
    finalValue.origin.y = sourceValue.origin.y * (1.0 - k) + targetValue.origin.y * k;
    finalValue.size.width = sourceValue.size.width * (1.0 - k) + targetValue.size.width * k;
    finalValue.size.height = sourceValue.size.height * (1.0 - k) + targetValue.size.height * k;
    
    parent.frame = finalValue;
    
    
    double sourceAlpha = [objc_getAssociatedObject(parent, &kOriginalAlpha) doubleValue];
    double targetAlpha = parent.nextKeyframe.alpha;
    
    parent.alpha = sourceAlpha * (1.0 - k) + targetAlpha * k;
}
@end


@implementation UIView (Keyframe)


- (void)setNextKeyframe:(UIView *)keyframe
{
    // Store the current frame so we can more easily animate between
    objc_setAssociatedObject(self, &kOriginalFrame, [NSValue valueWithCGRect:self.frame], OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, &kOriginalAlpha, [NSNumber numberWithDouble:self.alpha], OBJC_ASSOCIATION_RETAIN);
    
    keyframe.hidden = YES;
    objc_setAssociatedObject(self, &kNextKeyframe, keyframe, OBJC_ASSOCIATION_RETAIN);
}

- (UIView*)nextKeyframe {
    return objc_getAssociatedObject(self, &kNextKeyframe);
}


/*
 * Event-based keyframing
 */

- (void)setStepDuration:(double)stepDuration
{
    objc_setAssociatedObject(self, &kStepDuration, [NSNumber numberWithDouble:stepDuration], OBJC_ASSOCIATION_RETAIN);
}

- (double)stepDuration
{
    return ((NSNumber *) objc_getAssociatedObject(self, &kStepDuration)).doubleValue;
}

- (void)setStartDelay:(double)startDelay
{
    objc_setAssociatedObject(self, &kStartDelay, [NSNumber numberWithDouble:startDelay], OBJC_ASSOCIATION_RETAIN);
}

- (double)startDelay
{
    return ((NSNumber *) objc_getAssociatedObject(self, &kStartDelay)).doubleValue;
}




- (IBAction)advanceKeyframe:(id)sender
{
    
}

- (IBAction)toggleKeyFrame:(id)sender
{
    NSValue *original = objc_getAssociatedObject(self, &kOriginalFrame);
    if (original) {
        objc_setAssociatedObject(self, &kOriginalFrame, nil, OBJC_ASSOCIATION_RETAIN);
    } else {
        objc_setAssociatedObject(self, &kOriginalFrame, [NSValue valueWithCGRect:self.frame], OBJC_ASSOCIATION_RETAIN);
    }
    
    [UIView animateWithDuration:self.stepDuration delay:self.startDelay options:0 animations:^{
        if (original) {
            self.frame = [original CGRectValue];
        } else {
            self.frame = self.nextKeyframe.frame;
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)reverseKeyFrame:(id)sender
{
    
}


/*
 * Scroll-based keyframing
 */

- (void)setScrollController:(UIScrollView *)scrollController
{
    objc_setAssociatedObject(self, &kScrollController, scrollController, OBJC_ASSOCIATION_RETAIN);
    
    KeyframeShim *shim = [[KeyframeShim alloc] init];
    shim.parent = self;
    objc_setAssociatedObject(self, &kKeyframeShim, shim, OBJC_ASSOCIATION_RETAIN);
    [scrollController addObserver:shim forKeyPath:@"contentOffset" options:0 context:0];
}

- (UIScrollView *)scrollController
{
    return objc_getAssociatedObject(self, &kScrollController);
}


- (void)setMinOffset:(double)minOffset
{
    objc_setAssociatedObject(self, &kMinOffset, [NSNumber numberWithDouble:minOffset], OBJC_ASSOCIATION_RETAIN);
}

- (double)minOffset
{
    return ((NSNumber *) objc_getAssociatedObject(self, &kMinOffset)).doubleValue;
}

- (void)setMaxOffset:(double)maxOffset
{
    objc_setAssociatedObject(self, &kMaxOffset, [NSNumber numberWithDouble:maxOffset], OBJC_ASSOCIATION_RETAIN);
}

- (double)maxOffset
{
    return ((NSNumber *) objc_getAssociatedObject(self, &kMaxOffset)).doubleValue;
}


- (void)setShouldExtendBeyondMin:(BOOL)shouldExtendBeyondMin
{
    objc_setAssociatedObject(self, &kShouldExtendBeyondMin, [NSNumber numberWithBool:shouldExtendBeyondMin], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)shouldExtendBeyondMin
{
    return ((NSNumber *) objc_getAssociatedObject(self, &kShouldExtendBeyondMin)).boolValue;
}

- (void)setShouldExtendBeyondMax:(BOOL)shouldExtendBeyondMax
{
    objc_setAssociatedObject(self, &kShouldExtendBeyondMax, [NSNumber numberWithBool:shouldExtendBeyondMax], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)shouldExtendBeyondMax
{
    return ((NSNumber *) objc_getAssociatedObject(self, &kShouldExtendBeyondMax)).boolValue;
}

- (void)setDimension:(NSString *)dimension
{
    objc_setAssociatedObject(self, &kDimension, dimension, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)dimension
{
    return objc_getAssociatedObject(self, &kDimension);
}



@end
