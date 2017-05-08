//
//  ZFSelectView.h
//  Summary
//
//  Created by xinshiyun on 2017/4/13.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset;
@protocol ZFPublishViewDelegate;
@protocol ZFPublishViewDataSource;

@interface ZFSelectView : UIView

/*!
 * 最大选择数量 默认9
 */
@property(assign,nonatomic)NSInteger maxCount;
@property (nonatomic,strong) UICollectionView *photoCollectionView;
@property (nonatomic,weak) id<ZFPublishViewDelegate> delegate;
@property (nonatomic,weak) id<ZFPublishViewDataSource> dataSource;

-(void)reloadData;

@end

@protocol ZFPublishViewDelegate <NSObject>
//删除
-(void)publishView:(ZFSelectView *)publishView deletePhotoAtIndex:(NSUInteger)index;
//点击添加照片
-(void)publishViewClickAddPhoto:(ZFSelectView *)publishView;
//点击了item
-(void)publishView:(ZFSelectView *)publishView didClickPhotoViewAtIndex:(NSUInteger)index;

@end

@protocol ZFPublishViewDataSource <NSObject>

-(NSArray<PHAsset *> *)photosOfPublishView:(ZFSelectView *)publishView;

@end
