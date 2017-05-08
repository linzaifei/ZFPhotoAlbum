//
//  ZFBrowsePhotoViewController.h
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/3.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFNSNotificationModel;
typedef NS_ENUM(NSInteger,ZFBrowsePhotoType){
    ZFBrowsePhotoTypeImage = 0,//图片类型
    ZFBrowsePhotoTypePHasset ,//相册类型 (PHAsset类型 > 8.0)
    ZFBrowsePhotoTypeURL ,//网络链接
};

typedef void(^CancelBrowBlock)(NSIndexPath *indexPath);
@interface ZFBrowsePhotoViewController : UIViewController

@property(strong,nonatomic)NSMutableArray *photoItems;//图片数组
@property(assign,nonatomic)NSInteger currentIndex;//当前选择的index 默认0

@property(assign,nonatomic)ZFBrowsePhotoType browType;
@property(copy,nonatomic)CancelBrowBlock cancelBrowBlock;//取消


@property(strong,nonatomic)NSMutableDictionary *selectedAssetsDic;//选择assest
@property(strong,nonatomic)ZFNSNotificationModel *notificationModel;//监听数组
@property(assign,nonatomic)NSInteger maxCount;//
@end
