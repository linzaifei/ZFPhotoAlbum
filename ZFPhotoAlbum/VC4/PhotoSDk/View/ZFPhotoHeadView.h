//
//  ZFPhotoHeadView.h
//  Summary
//
//  Created by xinshiyun on 2017/4/12.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFCamareHeadView;
@class ZFTakePhotoHeadView;

typedef void(^CancelBlock)();
typedef void(^ChooseBlock)();
typedef void(^TitleBlock)();
typedef void(^FlashBlock)(UIButton *flashBtn);
typedef void(^ChangeBlock)();

//相册
@interface ZFPhotoHeadView : UINavigationBar
@property(copy,nonatomic)NSString *title;
@property(assign,nonatomic)NSInteger count;
@property(copy,nonatomic)CancelBlock cancelBlock;
@property(copy,nonatomic)ChooseBlock chooseBlock;
@property(copy,nonatomic)TitleBlock titleBlock;
@end

//相机NaviBar
@interface ZFCamareHeadView : UINavigationBar
@property(copy,nonatomic)CancelBlock cancelBlock;
@property(copy,nonatomic)ChangeBlock changeBlock;
@property(copy,nonatomic)FlashBlock flashBlock;
@end

//相机拍照
@interface ZFTakePhotoHeadView : UIView
@property(assign,nonatomic)BOOL isTake;//是否可以取消或是采用
@property(copy,nonatomic)void(^takePhotoBlock)();
@property(copy,nonatomic)CancelBlock cancelBlock;
@property(copy,nonatomic)ChooseBlock chooseBlock;
@end


