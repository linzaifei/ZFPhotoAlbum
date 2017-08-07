//
//  ZFBrowCollectionCell.h
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/5.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFPhotoScrollView;
@class ScrollLayout;
@class PHLivePhotoView;
@class PHAsset;

@interface ZFBrowCollectionCell : UICollectionViewCell

//设置数据
-(void)zf_setAssest:(id)data;
//点击后回调
@property(copy,nonatomic)void(^btnSelectBlock)(PHAsset *asset,BOOL isSelect);
//是否被点击
@property(assign,nonatomic)BOOL isSelect;

@property (nonatomic,strong)ZFPhotoScrollView *zf_photoScrollView;

@end

@interface ZFPhotoScrollView : UIScrollView

@property (nonatomic,strong)UIImageView *zf_photoImgView;
@property(strong,nonatomic)PHLivePhotoView *livePhotoView;


@end

@interface ScrollLayout : UICollectionViewFlowLayout

@end

