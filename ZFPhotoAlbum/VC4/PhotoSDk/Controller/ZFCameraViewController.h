//
//  ZFCamareViewController.h
//  Summary
//
//  Created by xinshiyun on 2017/4/14.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZFAlbumConfig.h"
@class ZFPhotoManger;
@class ZFPhotoModel;

@protocol ZFCameraViewDelegate <NSObject>

@optional
-(void)zf_photoCapViewController:(UIViewController *)viewController didFinishDismissWithPhoto:(ZFPhotoModel *)model;

@end

@interface ZFCameraViewController : UIViewController
-(instancetype)initWithCameraType:(ZFCameraPopType)type;
@property(assign,nonatomic)ZFCameraType type;
@property(assign,nonatomic)ZFPhotoManger *photoManager;
@property(weak,nonatomic)id<ZFCameraViewDelegate> cameraDelegate;


@end
