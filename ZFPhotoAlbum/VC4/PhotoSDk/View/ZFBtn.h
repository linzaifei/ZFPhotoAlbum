//
//  ZFBtn.h
//  Summary
//
//  Created by xinshiyun on 2017/4/13.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFBtn : UIButton
//是否选择
@property(assign,nonatomic)BOOL isCollect;
//设置可点击的范围 默认 -30
@property(assign,nonatomic)CGFloat pointInsder;
@end
