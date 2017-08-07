//
//  ZFPhotoManger.h
//  ZFPhotoAlbum
//
//  Created by xinshiyun on 2017/8/4.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "ZFAlbumConfig.h"

@interface ZFPhotoManger : NSObject
/** 照片类型 */
@property(assign,nonatomic)ZFPhotoMangerSelectType type;
/** 最多选择 默认9 张 */
@property(assign,nonatomic)NSInteger maxCount;
/** 排显示数目 默认 3 (3 - 5) */
@property(assign,nonatomic)NSInteger columnCount;
/** 列间距，默认是1 */
@property(assign,nonatomic)NSInteger columnSpacing;
/** 行间距，默认是1 */
@property(assign,nonatomic)NSInteger rowSpacing;
/** section与collectionView的间距，默认是（5，5，5，5）*/
@property(assign,nonatomic)UIEdgeInsets sectionInset;
/** 是不是满屏相机 */
@property(assign,nonatomic)BOOL showFullScreenCamera;


@property(strong,nonatomic)NSMutableArray *albums;//存储所有相册
@property(strong,nonatomic)NSMutableArray *selectList;//存放所有选中的图片视频等(预留)
@property(strong,nonatomic)NSMutableArray *selectedPhotos;//存储选择中的图片


/** 初始化 */
-(instancetype)initPhotoMangerWithSelectType:(ZFPhotoMangerSelectType)selectType;
/** 获取相册list */
-(void)zf_getAlbumList:(void(^)(NSArray *albums))albums;
/** 取某个相册里面的所有图片和视频 isAdd 是否需要添加相机图片 */
-(void)zf_getPhotoForPHFetchResult:(PHFetchResult *)result WithIsAddCamera:(BOOL)isAdd PhotosList:(void(^)(NSArray *photos,NSArray *videos,NSArray *allObjs))photoBlock;

@end
