//
//  UIView+Layout.m
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 21..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "UIView+Layout.h"

@implementation UIView (Layout)

- (CGFloat)putBelow:(UIView *)upper withTopMargin:(CGFloat)margin
{
    CGRect frame = self.frame;
    frame.origin.y = upper.frame.origin.y + upper.frame.size.height + margin;
    self.frame = frame;
    return frame.origin.y + frame.size.height;
}

@end
