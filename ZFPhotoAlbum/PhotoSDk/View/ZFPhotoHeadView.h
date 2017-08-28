//
//  ZFPhotoHeadView.h
//  Summary
//
//  Created by xinshiyun on 2017/4/12.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFAlbumConfig.h"
@class ZFCamareHeadView;
@class ZFTakePhotoHeadView;
@class ZFBrowHeadViewBar;
@class ZFTitleView;

typedef void(^ClickTypeBlock)(ZFClickType type,UIButton *btn);

@interface PhotoNavigationBar : UINavigationBar
@property(assign,nonatomic)NSInteger count;
@property(copy,nonatomic)NSString *title;
-(void)setNavigationItem:(UINavigationItem *)item;
@property(assign,nonatomic,readonly)ZFClickType type;
/** 获取点击类型 */
-(void)setDidClickWithType:(ClickTypeBlock)clickBlock;
@end

/** 相册ZFPhotoHeadView */
@interface ZFPhotoHeadView : PhotoNavigationBar
-(void)zfScoll;
@end

/** 图片浏览头视图 */
@interface ZFBrowHeadViewBar : PhotoNavigationBar

@end
/** 相机NaviBar */
@interface ZFCamareHeadView : PhotoNavigationBar

@end

/** 相机拍照 */
@interface ZFTakePhotoHeadView : UIView
/** 获取点击类型 */
-(void)setDidClickWithType:(ClickTypeBlock)clickBlock;
@end






