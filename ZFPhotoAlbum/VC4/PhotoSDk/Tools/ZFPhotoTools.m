//
//  ZFPhotoTools.m
//  ZFPhotoAlbum
//
//  Created by xinshiyun on 2017/8/4.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPhotoTools.h"

@implementation ZFPhotoTools
/** 获取图片 */
+(UIImage *)zf_getPhotoWithImgName:(NSString *)imgName;{
    UIImage *img = [UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:imgName]];
    return img;
}


/** 相册名称转换 */
+(NSString *)zf_tansFormPhotoTitle:(NSString *)efName{
    NSString *photoName;
    if ([efName isEqualToString:@"Bursts"]) {
        photoName = @"连拍快照";
    }else if([efName isEqualToString:@"Recently Added"]){
        photoName = @"最近添加";
    }else if([efName isEqualToString:@"Screenshots"]){
        photoName = @"屏幕快照";
    }else if([efName isEqualToString:@"Camera Roll"]){
        photoName = @"相机胶卷";
    }else if([efName isEqualToString:@"Selfies"]){
        photoName = @"自拍";
    }else if([efName isEqualToString:@"My Photo Stream"]){
        photoName = @"我的照片流";
    }else if([efName isEqualToString:@"Videos"]){
        photoName = @"视频";
    }else if([efName isEqualToString:@"All Photos"]){
        photoName = @"所有照片";
    }else if([efName isEqualToString:@"Slo-mo"]){
        photoName = @"慢动作";
    }else if([efName isEqualToString:@"Recently Deleted"]){
        photoName = @"最近删除";
    }else if([efName isEqualToString:@"Favorites"]){
        photoName = @"个人收藏";
    }else if([efName isEqualToString:@"Panoramas"]){
        photoName = @"全景照片";
    }else {
        photoName = efName;
    }
    return photoName;
}
/** 获取视频的时长 (00:00)*/
+(NSString *)zf_getTimeFromDurationSecond:(NSInteger)duration{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    [formatter setDateFormat:@"mm:ss"];
//    //设置时区,这个对于时间的处理有时很重要
//    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
//    [formatter setTimeZone:timeZone];
//    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
//    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
//    return timeSp;

    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"00:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"00:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

/** 获取PHAsset信息  */
+ (PHImageRequestID)zf_getPhotoFromPHAsset:(PHAsset *)asset size:(CGSize)size completion:(void(^)(UIImage *image,NSDictionary *info))completion{
     static PHImageRequestID requestID = -1;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, 500);
    if (requestID >= 1 && size.width / width == scale) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
    }
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
   
    return requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
       
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        
        if (downloadFinined && completion && result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result,info);
            });
        }
    }];
}
+(int32_t)zf_getfetchPhotoWithAsset:(id)asset photoSize:(CGSize)photoSize completion:(void (^)(UIImage *img,NSDictionary *info,BOOL isDegraded))completion{

    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    return [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:photoSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        }
    }];
}

+(PHImageRequestID)zf_getLivePhotoFormPHAsset:(PHAsset *)asset Size:(CGSize)size Completion:(void (^)(PHLivePhoto *livePhoto, NSDictionary *info))completion{
    PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
//    option.version = PHImageRequestOptionsVersionCurrent;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.networkAccessAllowed = YES;
    
    return [[PHCachingImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHLivePhotoInfoCancelledKey] boolValue] && ![[info objectForKey:PHLivePhotoInfoErrorKey] boolValue]);
        if (downloadFinined && completion && livePhoto) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(livePhoto,info);
            });
        }
    }];
}

@end
