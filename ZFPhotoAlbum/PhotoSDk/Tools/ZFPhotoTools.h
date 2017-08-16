//
//  ZFPhotoTools.h
//  ZFPhotoAlbum
//
//  Created by xinshiyun on 2017/8/4.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@interface ZFPhotoTools : NSObject
/** 获取图片 */
+(UIImage *)zf_getPhotoWithImgName:(NSString *)imgName;

/** 相册名称转换 */
+(NSString *)zf_tansFormPhotoTitle:(NSString *)efName;
/** 获取视频的时长 (00:00)*/
+(NSString *)zf_getTimeFromDurationSecond:(NSInteger)duration;

/** 获取PHAsset信息  */
+(PHImageRequestID)zf_getPhotoFromPHAsset:(PHAsset *)asset size:(CGSize)size completion:(void(^)(UIImage *image,NSDictionary *info))completion;
+(int32_t)zf_getfetchPhotoWithAsset:(id)asset photoSize:(CGSize)photoSize completion:(void (^)(UIImage *image,NSDictionary *info,BOOL isDegraded))completion;
+(PHImageRequestID)zf_getLivePhotoFormPHAsset:(PHAsset *)asset Size:(CGSize)size Completion:(void (^)(PHLivePhoto *livePhoto, NSDictionary *info))completion;
/** 此方法只会回调一次 */
+(void)zf_getHighQualityFromPHAsset:(PHAsset *)asset size:(CGSize)size completion:(void(^)(UIImage *image,NSDictionary *info))completion error:(void(^)(NSDictionary *info))error;

/** 加载高清图片 显示加载提示 */
+(PHImageRequestID)zf_getHighQualityFromPHAsset:(PHAsset *)asset WithDeliveryMode:(PHImageRequestOptionsDeliveryMode)deliveryMode size:(CGSize)size completion:(void(^)(UIImage *image,NSDictionary *info))completion Progress:(void(^)(double progress,NSError * error, BOOL * stop, NSDictionary * info))progressCompletion;



@end
