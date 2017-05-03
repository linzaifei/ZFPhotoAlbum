//
//  ZFBtn.m
//  Summary
//
//  Created by xinshiyun on 2017/4/13.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFBtn.h"

@implementation ZFBtn
//点击动画效果
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [super addTarget:target action:action forControlEvents:controlEvents];
    self.transform = CGAffineTransformIdentity;
 [self annimation];
}

//选择动画效果
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        [self annimation];
    }
}
-(void)annimation{
     __weak ZFBtn *ws = self;
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations: ^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 / 3.0 animations: ^{
            ws.transform = CGAffineTransformMakeScale(1.3, 1.3);
        }];
        [UIView addKeyframeWithRelativeStartTime:1/3.0 relativeDuration:1/3.0 animations: ^{
            ws.transform = CGAffineTransformMakeScale(0.8, 0.8);
        }];
        [UIView addKeyframeWithRelativeStartTime:2/3.0 relativeDuration:1/3.0 animations: ^{
            ws.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    } completion:nil];
}

//用来扩大点击范围
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    //当前btn大小
    CGRect btnBounds = self.bounds;
    //扩大点击区域，想缩小就将-10设为正值
    btnBounds = CGRectInset(btnBounds, -30, -30);
    //CGRectInset(CGRect rect, CGFloat dx, CGFloat dy)作用是将rect坐标按照(dx,dy)进行平移，对size进行如下变换
//    新宽度 = 原宽度 - 2*dx；新高度 = 原高度 - 2*dy
//    即dx,dy为正，则为缩小点击范围；dx,dy为负的话，则为扩大范围
    //若点击的点在新的bounds里，就返回YES
    return CGRectContainsPoint(btnBounds, point);
}

@end
