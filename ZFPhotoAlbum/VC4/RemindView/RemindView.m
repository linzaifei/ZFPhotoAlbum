//
//  RemindView.m
//  Live
//
//  Created by xsy on 16/8/5.
//  Copyright © 2016年 林再飞. All rights reserved.
//

#import "RemindView.h"

#define kScreenHeight   [UIScreen mainScreen].bounds.size.height
#define kScreenWidth    [UIScreen mainScreen].bounds.size.width

@interface RemindView()


@end
@implementation RemindView

+(void)showViewWithTitle:(NSString *)title location:(LocationType)location{

    UIFont *font = [UIFont systemFontOfSize:15];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    CGSize size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    UILabel *remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width+20,size.height+10)];
    if (size.width>kScreenWidth) {
        remindLabel.frame = CGRectMake(0, 0,size.width/2+40,size.height*2+10);
    }
    CGPoint center = CGPointMake(kScreenWidth/2, kScreenHeight-90);
    if (location == LocationTypeTOP) {
        center = CGPointMake(kScreenWidth/2, 80);
    }
    if (location == LocationTypeMIDDLE) {
        center = CGPointMake(kScreenWidth/2, kScreenHeight/2);
    }
    remindLabel.text = title;
    remindLabel.numberOfLines = 0;
    remindLabel.textAlignment = NSTextAlignmentCenter;
    remindLabel.font = font;
    remindLabel.backgroundColor = [UIColor blackColor];
    remindLabel.textColor = [UIColor whiteColor];
    remindLabel.center = center;
    remindLabel.layer.masksToBounds = YES;
    remindLabel.layer.cornerRadius = 4.0f;
    [[UIApplication sharedApplication].keyWindow addSubview:remindLabel];
    [UIView animateWithDuration:3 animations:^{
        remindLabel.alpha = 0;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [remindLabel removeFromSuperview];
    });
}
@end
