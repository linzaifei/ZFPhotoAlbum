//
//  ZFPhotoManger.m
//  ZFPhotoAlbum
//
//  Created by xinshiyun on 2017/8/4.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPhotoManger.h"
#import <Photos/Photos.h>
#import "ZFAlbumModel.h"
#import "ZFPhotoModel.h"
#import "ZFPhotoTools.h"

#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
@implementation ZFPhotoManger
-(instancetype)initPhotoMangerWithSelectType:(ZFPhotoMangerSelectType)selectType{
    if (self = [super init]) {
        self.type = selectType;
        [self setUI];
    }
    return self;
}
-(instancetype)init{
    if (self = [super init]) {
        [self setUI];
    }
    return self;
}

-(void)setUI{

    self.maxCount = 9;
    self.columnCount = 3;
    self.columnSpacing = 1;
    self.rowSpacing = 1;
    self.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    self.albums = [NSMutableArray array];
    self.selectList = [NSMutableArray array];
    self.selectedPhotos = [NSMutableArray array];
    
}

/** 获取相册list */
-(void)zf_getAlbumList:(void(^)(NSArray *albums))albums{
    if (self.albums.count > 0) [self.albums removeAllObjects];
    // 获取系统智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        // 是否按创建时间排序
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        if (self.type == ZFPhotoMangerSelectTypePhoto) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }else if (self.type == ZFPhotoMangerSelectTypeVideo) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
        // 获取照片集合
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        // 过滤掉空相册
        if (result.count > 0 && ![[ZFPhotoTools zf_tansFormPhotoTitle:collection.localizedTitle] isEqualToString:@"最近删除"]) {
            ZFAlbumModel *albumModel = [[ZFAlbumModel alloc] init];
            albumModel.count = result.count;
            albumModel.albumName = [ZFPhotoTools zf_tansFormPhotoTitle:collection.localizedTitle];
            albumModel.asset = result.lastObject;
            albumModel.result = result;
            if ([[ZFPhotoTools zf_tansFormPhotoTitle:collection.localizedTitle] isEqualToString:@"相机胶卷"] || [[ZFPhotoTools zf_tansFormPhotoTitle:collection.localizedTitle] isEqualToString:@"所有照片"]) {
                [self.albums insertObject:albumModel atIndex:0];
            }else {
                [self.albums addObject:albumModel];
            }
            /*
            if (isShow) {
                if (self.selectedList.count > 0) {
                    HXPhotoModel *photoModel = self.selectedList.firstObject;
                    for (PHAsset *asset in result) {
                        if ([asset.localIdentifier isEqualToString:photoModel.asset.localIdentifier]) {
                            albumModel.selectedCount++;
                            break;
                        }
                    }
                }
            }
             */
        }
    }];
    
    // 获取用户相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        // 是否按创建时间排序
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        if (self.type == ZFPhotoMangerSelectTypePhoto) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }else if (self.type == ZFPhotoMangerSelectTypeVideo) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
        // 获取照片集合
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        
        // 过滤掉空相册
        if (result.count > 0) {
            ZFAlbumModel *albumModel = [[ZFAlbumModel alloc] init];
            albumModel.count = result.count;
            albumModel.albumName = [ZFPhotoTools zf_tansFormPhotoTitle:collection.localizedTitle];
            albumModel.asset = result.lastObject;
            albumModel.result = result;
            [self.albums addObject:albumModel];
            /*
            if (isShow) {
                if (self.selectedList.count > 0) {
                    ZFPhotoModel *photoModel = self.selectedList.firstObject;
                    for (PHAsset *asset in result) {
                        if ([asset.localIdentifier isEqualToString:photoModel.asset.localIdentifier]) {
                            albumModel.selectedCount++;
                            break;
                        }
                    }
                }
            }
             */
        }
    }];
    /*
    for (int i = 0 ; i < self.albums.count; i++) {
        HXAlbumModel *model = self.albums[i];
        model.index = i;
        if (isShow) {
            if (i == 0) {
                model.selectedCount += self.selectedCameraList.count;
            }
        }
    }
     */
    if (albums) {
        albums(self.albums);
    }
}

/** 取某个相册里面的所有图片和视频 isAdd 是否需要添加相机图片 */
-(void)zf_getPhotoForPHFetchResult:(PHFetchResult *)result WithIsAddCamera:(BOOL)isAdd PhotosList:(void(^)(NSArray *photos,NSArray *videos,NSArray *allObjs))photoBlock{
    
    NSMutableArray *photoAy = [NSMutableArray array];
    NSMutableArray *videoAy = [NSMutableArray array];
    NSMutableArray *objAy = [NSMutableArray array];
    __block NSInteger photoIndex = 0, videoIndex = 0, albumIndex = 0;
    __block NSInteger cameraIndex = 1;//预留相机界面
    
    [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        ZFPhotoModel *photoModel = [[ZFPhotoModel alloc] init];
        photoModel.asset = asset;
        photoModel.albumListIndex = albumIndex + cameraIndex;
        if (self.selectedPhotos.count > 0) {
            for (ZFPhotoModel *model in self.selectedPhotos) {
                if ([model.asset.localIdentifier isEqualToString:photoModel.asset.localIdentifier]) {
                    photoModel.selected = YES;
                }
            }
        }
        if (asset.mediaType == PHAssetMediaTypeImage) {

                if (iOS9Later) {
                    if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                            photoModel.type = ZFPhotoModelMediaTypeLivePhoto;
                    }else {
                        photoModel.type = ZFPhotoModelMediaTypePhoto;
                    }
                }else {
                    photoModel.type = ZFPhotoModelMediaTypePhoto;
                }
    
            photoModel.photoIndex = photoIndex;
            [photoAy addObject:photoModel];
            photoIndex++;
        }else if (asset.mediaType == PHAssetMediaTypeVideo) {
            photoModel.type = ZFPhotoModelMediaTypeVideo;
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                photoModel.avAsset = asset;
            }];
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",asset.duration];
            photoModel.videoTime = [ZFPhotoTools zf_getTimeFromDurationSecond:timeLength.integerValue];
            photoModel.videoIndex = videoIndex;
            [videoAy addObject:photoModel];
            videoIndex++;
        }
        albumIndex++;
        //photoModel.currentAlbumIndex = index;
        [objAy addObject:photoModel];
    }];
    if (isAdd) {//添加拍照相机
        ZFPhotoModel *model = [[ZFPhotoModel alloc] init];
        model.type = ZFPhotoModelMediaTypeCamera;
        if (photoAy.count == 0 && videoAy.count != 0) {
            model.cameraPhoto = [ZFPhotoTools zf_getPhotoWithImgName:@"AssetsCamera"];
        }else if (videoAy.count == 0) {
            model.cameraPhoto = [ZFPhotoTools zf_getPhotoWithImgName:@"AssetsCamera"];
        }else {
            model.cameraPhoto = [ZFPhotoTools zf_getPhotoWithImgName:@"AssetsCamera"];
        }
        [objAy insertObject:model atIndex:0];
    }
//    if (1) {
//        if (self.cameraList.count > 0) {
//            NSInteger listCount = self.cameraList.count;
//            if (self.outerCamera) {
//                listCount = self.cameraList.count - 1;
//            }
//            for (int i = 0; i < self.cameraList.count; i++) {
//                ZFPhotoModel *phMD = self.cameraList[i];
//                phMD.albumListIndex = listCount--;
//                [objAy insertObject:phMD atIndex:cameraIndex];
//            }
//            NSInteger photoCount = self.cameraPhotos.count - 1;
//            for (int i = 0; i < self.cameraPhotos.count; i++) {
//                ZFPhotoModel *phMD = self.cameraPhotos[i];
//                phMD.photoIndex = photoCount--;
//                [photoAy insertObject:phMD atIndex:0];
//            }
//            NSInteger videoCount = self.cameraVideos.count - 1;
//            for (int i = 0; i < self.cameraVideos.count; i++) {
//                HXPhotoModel *phMD = self.cameraVideos[i];
//                phMD.videoIndex = videoCount--;
//                [videoAy insertObject:phMD atIndex:0];
//            }
//        }
//    }
    if (photoBlock) {
        photoBlock(photoAy,videoAy,objAy);
    }
}


@end
