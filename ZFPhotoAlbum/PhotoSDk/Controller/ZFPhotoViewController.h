//
//  ZFPhotoViewController.h
//  Summary
//
//  Created by xinshiyun on 2017/4/12.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPhotoManger.h"
@class ZFPhotoModel;
@protocol ZFPhotoPickerViewControllerDelegate;

@interface ZFPhotoViewController : UIViewController
@property(strong,nonatomic)ZFPhotoManger *photoManager;

@property (nonatomic,weak) id<ZFPhotoPickerViewControllerDelegate> delegate;



@property(copy,nonatomic)void(^didSelectPhotosBlock)(NSArray<ZFPhotoModel *> * photos);
//选中相机
@property(copy,nonatomic)void(^clickCamareBlock)();
@end

@protocol ZFPhotoPickerViewControllerDelegate <NSObject>

/**
 选择照片返回代理方法
 @param pickerViewController 图片选择控制器
 @param photos 选中的图片数组
 */
- (void)photoPickerViewController:(ZFPhotoViewController *)pickerViewController didSelectPhotos:(NSMutableArray<ZFPhotoModel *> *)photos;

@end



