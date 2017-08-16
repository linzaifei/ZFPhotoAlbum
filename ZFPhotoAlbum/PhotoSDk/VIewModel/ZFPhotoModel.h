//
//  ZFPhotoModel.h
//  ZFPhotoAlbum
//
//  Created by xinshiyun on 2017/8/4.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFAlbumConfig.h"
#import <Photos/Photos.h>
@interface ZFPhotoModel : NSObject

@property(assign,nonatomic)ZFPhotoModelMediaType type;

/** Asset */
@property(strong, nonatomic) PHAsset *asset;
/** AVAsset */
@property(strong, nonatomic) AVAsset *avAsset;

/** 在相册里下标 */
@property(assign, nonatomic) NSInteger albumListIndex;
/** 是否被选中 */
@property(assign, nonatomic) BOOL selected;
/** 图片下标 */
@property (assign, nonatomic) NSInteger photoIndex;
/** 当前相册下标 */
//@property (assign, nonatomic) NSInteger currentAlbumIndex;

/** 预览照片 */
@property (strong, nonatomic) UIImage *previewPhoto;

/** 视频时间 */
@property (copy, nonatomic) NSString *videoTime;
/** 视频下标 */
@property (assign, nonatomic) NSInteger videoIndex;

/** 拍照小图 */
@property (strong, nonatomic) UIImage *cameraPhoto;
/** 图片宽高 */
@property (assign, nonatomic) CGSize imageSize;
/** 缩小之后的图片宽高 */
@property (assign, nonatomic) CGSize endImageSize;
@end
