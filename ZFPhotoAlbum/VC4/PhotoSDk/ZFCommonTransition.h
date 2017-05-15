//
//  ZFCommonTransition.h
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/11.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,TransitionType){
    TransitionTypePush = 0,//push动画
    TransitionTypePop ,//pop动画
    TransitionTypePresent,//present动画
    TransitionTypeDismess,//dismess动画
};

@interface ZFCommonTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property(assign,nonatomic)TransitionType type;

@end
