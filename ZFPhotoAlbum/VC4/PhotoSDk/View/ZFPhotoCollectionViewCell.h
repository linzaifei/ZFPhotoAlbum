//
//  ZFPhotoCollectionViewCell.h
//  Summary
//
//  Created by xinshiyun on 2017/4/12.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset;


@interface ZFPhotoCollectionViewCell : UICollectionViewCell

//设置数据
-(void)zf_setAssest:(id)data;

//点击后回调
@property(copy,nonatomic)void(^btnSelectBlock)(PHAsset *asset,BOOL isSelect);
//是否被点击
@property(assign,nonatomic)BOOL isSelect;

@end
