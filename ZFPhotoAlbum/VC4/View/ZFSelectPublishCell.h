//
//  ZFCollectionViewCell.h
//  Summary
//
//  Created by xinshiyun on 2017/4/13.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PublishPhotoCellDelegate;

@interface ZFSelectPublishCell : UICollectionViewCell
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,weak) id<PublishPhotoCellDelegate> delegate;

@end

@protocol PublishPhotoCellDelegate  <NSObject>

- (void)cellClickCancel:(ZFSelectPublishCell *)cell;

@end
