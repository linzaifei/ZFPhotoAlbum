//
//  ZFAlbumConfig.h
//  ZFPhotoAlbum
//
//  Created by xinshiyun on 2017/8/4.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#ifndef ZFAlbumConfig_h
#define ZFAlbumConfig_h

/** 选择需要显示类型 */
typedef NS_ENUM(NSInteger,ZFPhotoMangerSelectType){
    ZFPhotoMangerSelectTypePhoto = 0,//照片
    ZFPhotoMangerSelectTypeVideo,//视频
    ZFPhotoMangerSelectTypePhotoAndVideo,//视频和照片
};
/** 照片类型 */
typedef NS_ENUM(NSInteger,ZFPhotoModelMediaType){
    ZFPhotoModelMediaTypePhoto = 0,//照片
    ZFPhotoModelMediaTypeLivePhoto,//动态照片
    ZFPhotoModelMediaTypeVideo,//视频
    ZFPhotoModelMediaTypeCamera,//显示相机(跳转相机)
};
/** 相机类型 */
typedef NS_ENUM(NSInteger,ZFCameraType){
    ZFCameraTypePhoto = 0,//照片
    ZFCameraTypeVideo,//视频
    ZFCameraTypePhotoAndVideo,//照片和视频
};
/** 相机弹出类型 */
typedef NS_ENUM(NSInteger,ZFCameraPopType){
    ZFCameraPopTypeSystom = 0,//系统类型
    ZFCameraPopTypeCustom,//自定义类型
};
/** Transition动画类型 */
typedef NS_ENUM(NSInteger,ZFTransitionType){
    ZFTransitionTypePush = 0,//push动画
    ZFTransitionTypePop ,//pop动画
    ZFTransitionTypePopMenuPresent,//菜单栏present动画
    ZFTransitionTypePopMenuDismess,//菜单栏dismess动画
    ZFTransitionTypeCameraPresent,//相机present动画
    ZFTransitionTypeCameraDismess,//相机dismess动画
};





#endif /* ZFAlbumConfig_h */
