//
//  ZFCollectionViewCell.m
//  Summary
//
//  Created by xinshiyun on 2017/4/13.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFSelectPublishCell.h"

@implementation ZFSelectPublishCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3;
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.imageView];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.cancelButton setImage:[UIImage imageNamed:@"publish_del"] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(btnDown) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.cancelButton];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_imageView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_imageView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_imageView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_imageView)]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_cancelButton(==19)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_cancelButton)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cancelButton(==19)]-2-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_cancelButton)]];

    }
    return self;
}

- (void)btnDown {
    if ([self.delegate respondsToSelector:@selector(cellClickCancel:)]) {
        [self.delegate cellClickCancel:self];
    }
}
@end
