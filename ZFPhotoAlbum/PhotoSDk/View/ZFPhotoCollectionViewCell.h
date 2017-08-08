//
//  ZFPhotoCollectionViewCell.h
//  Summary
//
//  Created by xinshiyun on 2017/4/12.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class ZFPhotoModel;
@class ZFPhotoCollectionViewCell;

typedef void(^ZFClickItemBlock)(ZFPhotoCollectionViewCell *selectCell,ZFPhotoModel *model,BOOL isSelect);


@interface ZFPhotoCollectionViewCell : UICollectionViewCell
@property(strong,nonatomic)UIImageView *photoimgView;
@property(strong,nonatomic)ZFPhotoModel *model;
@property(copy,nonatomic)NSString *localIdentifier;
@property(assign,nonatomic)int32_t requestID;
@property(assign,nonatomic)BOOL isSelected;//这只选中状态

@property (assign, nonatomic) PHImageRequestID liveRequestID;

-(void)startLivePhoto;
-(void)stopLivePhoto;
/** 点击cell回调 */
-(void)zf_setClickItem:(ZFClickItemBlock)clickBlock;
@end

