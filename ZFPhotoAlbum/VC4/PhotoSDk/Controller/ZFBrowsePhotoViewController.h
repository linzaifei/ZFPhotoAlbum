//
//  ZFBrowsePhotoViewController.h
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/3.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFBrowsePhotoViewController : UIViewController

@property(strong,nonatomic)NSMutableArray *photoItems;//图片数组
@property(assign,nonatomic)NSInteger corruntIndex;//当前选择的index 默认0

@end
