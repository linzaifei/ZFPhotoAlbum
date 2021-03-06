//
//  ZFPhotoAlbum.h
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/5.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#ifndef ZFPhotoAlbum_h
#define ZFPhotoAlbum_h

static NSString *ZFPopDismessNotfcation = @"ZFPopDismessNotfcation";
//弱引用
#define WeakSelf(ws)  __weak __typeof(&*self)ws = self;
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height
#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kNavigationHeight 64

#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "RemindView.h"


#endif /* ZFPhotoAlbum_h */
