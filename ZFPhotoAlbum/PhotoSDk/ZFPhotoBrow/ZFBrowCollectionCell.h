//
//  ZFBrowCollectionCell.h
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/5.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@class ZFPhotoScrollView;
@class ScrollLayout;
@class PHLivePhotoView;
@class ZFPhotoModel;


@interface ZFBrowCollectionCell : UICollectionViewCell

@property(strong,nonatomic)ZFPhotoModel *model;

//是否被点击
@property(assign,nonatomic)BOOL isSelect;

@property (nonatomic,strong)ZFPhotoScrollView *photoScrollView;

@property (assign, nonatomic, readonly) PHImageRequestID requestID;

@end

@interface ZFPhotoScrollView : UIScrollView

@property (nonatomic,strong)UIImageView *photoImgView;
//@property(strong,nonatomic)PHLivePhotoView *livePhotoView;
@end

@interface ScrollLayout : UICollectionViewFlowLayout

@end

