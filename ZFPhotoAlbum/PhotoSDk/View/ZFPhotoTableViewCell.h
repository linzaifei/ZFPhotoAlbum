//
//  ZFPhotoTableViewCell.h
//  Summary
//
//  Created by xinshiyun on 2017/4/20.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFAlbumModel;
//展示视图popCell
@interface ZFPhotoTableViewCell : UITableViewCell
@property(strong,nonatomic)ZFAlbumModel *model;
@end
