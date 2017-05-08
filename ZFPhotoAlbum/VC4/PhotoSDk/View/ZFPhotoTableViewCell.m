//
//  ZFPhotoTableViewCell.m
//  Summary
//
//  Created by xinshiyun on 2017/4/20.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPhotoTableViewCell.h"
#import <Photos/Photos.h>
@interface ZFPhotoTableViewCell()
@property(strong,nonatomic)UIImageView *photoImageView;
@property(strong,nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)UILabel *detailLabel;

@end
@implementation ZFPhotoTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

-(void)setUI{
    
    self.photoImageView = [UIImageView new];
    self.photoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.photoImageView];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.titleLabel];
   
    self.detailLabel = [UILabel new];
    self.detailLabel.font = [UIFont systemFontOfSize:15];
    self.detailLabel.textColor = [UIColor grayColor];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.detailLabel];
    

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_photoImageView]-5-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_photoImageView)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_photoImageView]-10-[_titleLabel]-10-[_detailLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_photoImageView,_detailLabel,_titleLabel)]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_photoImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_photoImageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}


-(void)setAssetCollection:(PHAssetCollection *)assetCollection{
    _assetCollection = assetCollection;
    self.titleLabel.text = assetCollection.localizedTitle;
    PHFetchResult<PHAsset *> * assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    PHAsset *ass = assets.firstObject;
    PHImageRequestOptions *optin = [[PHImageRequestOptions alloc] init];
    self.detailLabel.text = [NSString stringWithFormat:@"%ld",assets.count];
    
    __weak ZFPhotoTableViewCell *ws = self;
    [[PHImageManager defaultManager] requestImageForAsset:ass targetSize:CGSizeZero contentMode:PHImageContentModeDefault options:optin resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        ws.photoImageView.image = result;
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
