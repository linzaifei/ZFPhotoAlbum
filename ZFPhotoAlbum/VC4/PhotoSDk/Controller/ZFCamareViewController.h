//
//  ZFCamareViewController.h
//  Summary
//
//  Created by xinshiyun on 2017/4/14.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class  PHAsset;
@protocol CameraViewDelegate <NSObject>

@optional
- (void)photoCapViewController:(UIViewController *)viewController didFinishDismissWithPhotoImage:(PHAsset *)alasset;

@end

@interface ZFCamareViewController : UIViewController
//关闭
-(void)zf_closeAnnimation;
//开启
-(void)zf_onpenAnnimation;

@property(weak,nonatomic)id<CameraViewDelegate> cameraDelegate;
//取消回调
@property(copy,nonatomic)void(^backBlock)();
@end
