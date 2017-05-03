//
//  NSNotificationModel.h
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/3.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <Foundation/Foundation.h>
@class  PHAsset;

//用来监听数组变化
@interface NSNotificationModel : NSObject

@property(strong,nonatomic)NSMutableArray <PHAsset *>*seletedPhotos;


@end
