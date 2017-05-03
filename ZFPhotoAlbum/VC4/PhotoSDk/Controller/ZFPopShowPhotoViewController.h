//
//  ZFPopPhotoViewController.h
//  Summary
//
//  Created by xsy on 2017/4/19.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFPopShowPhotoViewController : UIViewController

@property(strong,nonatomic)NSArray *dataArr;
@property(copy,nonatomic)void(^didSelectBlock)(NSArray *dataArr,NSInteger index);

@end
