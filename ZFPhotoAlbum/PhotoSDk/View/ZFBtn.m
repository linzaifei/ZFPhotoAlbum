//
//  ZFBtn.m
//  Summary
//
//  Created by xinshiyun on 2017/4/13.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFBtn.h"

@implementation ZFBtn
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.pointInsder = -30;
    }
    return self;
}

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
    [UIView animateWithDuration:0.1 animations:^{
        ws.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 animations:^{
                ws.transform = CGAffineTransformMakeScale(0.9, 0.9);
            } completion:^(BOOL finished) {
                if (finished) {
                    [UIView animateWithDuration:0.1 animations:^{
                        ws.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    }];
                }
            }];
        }
    }];
    
}

//用来扩大点击范围
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    //当前btn大小
    CGRect btnBounds = self.bounds;
    //扩大点击区域，想缩小就将-10设为正值
    btnBounds = CGRectInset(btnBounds, self.pointInsder, self.pointInsder);
    //CGRectInset(CGRect rect, CGFloat dx, CGFloat dy)作用是将rect坐标按照(dx,dy)进行平移，对size进行如下变换
//    新宽度 = 原宽度 - 2*dx；新高度 = 原高度 - 2*dy
//    即dx,dy为正，则为缩小点击范围；dx,dy为负的话，则为扩大范围
    //若点击的点在新的bounds里，就返回YES
    return CGRectContainsPoint(btnBounds, point);
}
-(void)setCount:(NSInteger)count{
    _count = count;
    [self setNeedsDisplay];
}

//-(void)drawRect:(CGRect)rect{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetRGBStrokeColor(context, 1, 0, 1, 1);
//////    UIFont *font = [UIFont systemFontOfSize:13];
////    [@"5" drawInRect:self.bounds withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13],NSForegroundColorAttributeName :[UIColor blueColor],NSStrokeColorAttributeName :[UIColor whiteColor]}];
////
//    CGRect drawRect = CGRectMake(5, 0, 20, 20);
//    UIImage *img = [UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"chooseInterest_uncheaked.png"]];
//    if (self.count >0) {
//        NSString *countStr = [NSString stringWithFormat:@"%ld",self.count];
//        [countStr drawInRect:drawRect withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],NSForegroundColorAttributeName :[UIColor whiteColor],NSBackgroundColorAttributeName :[UIColor orangeColor],NSStrokeWidthAttributeName : @3,NSStrokeColorAttributeName :[UIColor redColor]}];
//    }
//    [img drawInRect:drawRect];
//    CGContextDrawPath(context, kCGPathStroke);
//}

@end
