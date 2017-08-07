//
//  ZFCommonTransition.h
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/11.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFAlbumConfig.h"
@interface ZFCommonTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property(assign,nonatomic)ZFTransitionType type;

@end
