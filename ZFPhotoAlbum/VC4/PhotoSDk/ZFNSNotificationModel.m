//
//  NSNotificationModel.m
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/3.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFNSNotificationModel.h"

@implementation ZFNSNotificationModel


-(NSMutableArray <PHAsset *>*)seletedPhotos{
    if (_seletedPhotos == nil) {
        _seletedPhotos = [NSMutableArray array];
    }
    return _seletedPhotos;
}

@end
