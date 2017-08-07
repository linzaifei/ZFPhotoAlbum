//
//  ZFAblumModel.h
//  ZFPhotoAlbum
//
//  Created by xinshiyun on 2017/8/4.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface ZFAlbumModel : NSObject
/** 照片数目 */
@property(assign,nonatomic)NSInteger count;
/** 相册名称 */
@property(copy,nonatomic)NSString *albumName;
/** 封面Asset */
@property (strong, nonatomic) PHAsset *asset;
/** 照片集合对象 */
@property (strong, nonatomic) PHFetchResult *result;

@end
