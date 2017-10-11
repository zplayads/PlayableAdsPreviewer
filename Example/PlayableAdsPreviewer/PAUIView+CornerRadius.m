//
//  PAUIView+CornerRadius.m
//  PlayableAdsPreviewer_Example
//
//  Created by 王泽永 on 2017/9/29.
//  Copyright © 2017年 wzy2010416033@163.com. All rights reserved.
//

#import "PAUIView+CornerRadius.h"

@implementation UIView (CornerRadius)

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

@end
