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
@class ZFBrowHeadViewBar;
@class ZFTitleView;

typedef void(^CancelBlock)();
typedef void(^ChooseBlock)();
typedef void(^TitleBlock)();
typedef void(^FlashBlock)(UIButton *flashBtn);
typedef void(^ChangeBlock)();

//相册
@interface ZFPhotoHeadView : UINavigationBar
@property(copy,nonatomic)NSString *title;
@property(assign,nonatomic)NSInteger count;
-(void)zfScoll;
@property(copy,nonatomic)CancelBlock cancelBlock;
@property(copy,nonatomic)ChooseBlock chooseBlock;
@property(copy,nonatomic)TitleBlock titleBlock;
@end

@interface ZFTitleView : UIButton
@property(copy,nonatomic)NSString *title;
-(void)zfScoll;
@end

/** 相机NaviBar */
@interface ZFCamareHeadView : UINavigationBar
@property(copy,nonatomic)CancelBlock cancelBlock;
@property(copy,nonatomic)ChangeBlock changeBlock;
@property(copy,nonatomic)FlashBlock flashBlock;
@end

/** 相机拍照 */
@interface ZFTakePhotoHeadView : UIView
@property(copy,nonatomic)void(^takePhotoBlock)();
@property(copy,nonatomic)CancelBlock cancelBlock;
@property(copy,nonatomic)ChooseBlock chooseBlock;
@end


/** 图片浏览头视图 */
@interface ZFBrowHeadViewBar : UINavigationBar

@property(copy,nonatomic)NSString *title;
@property(copy,nonatomic)CancelBlock cancelBlock;
@property(copy,nonatomic)ChooseBlock chooseBlock;
@property(assign,nonatomic)NSInteger count;
@end



