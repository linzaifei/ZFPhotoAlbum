//
//  ZFPhotoCollectionViewCell.m
//  Summary
//
//  Created by xinshiyun on 2017/4/12.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPhotoCollectionViewCell.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "ZFBtn.h"
#import "ZFPhotoModel.h"
#import "ZFPhotoTools.h"
@interface ZFPhotoCollectionViewCell()<PHLivePhotoViewDelegate>
@property(strong,nonatomic)ZFBtn *selectBtn;

@property(strong,nonatomic)UIImageView *liveImgView;
@property (strong, nonatomic) UIImageView *videoIcon;
//live
@property(strong,nonatomic)PHLivePhotoView *livePhotoView;
@property(strong,nonatomic)UIView *liveView;
@property(strong,nonatomic)UILabel *liveLabel;
@property(copy,nonatomic)ZFClickItemBlock clickBlock;


@end

@implementation ZFPhotoCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

-(void)setUI{
    [self.contentView addSubview:self.photoimgView];
    [self.contentView addSubview:self.liveImgView];
    [self.contentView addSubview:self.selectBtn];
    [self.contentView addSubview:self.videoIcon];
    [self setSubviewLayout];
}

-(void)setModel:(ZFPhotoModel *)model{
    _model = model;
    if (model.cameraPhoto) {
        self.selectBtn.hidden = YES;
        self.photoimgView.image = model.cameraPhoto;
    }else {
        self.selectBtn.hidden = NO;
        self.localIdentifier = model.asset.localIdentifier;
        __weak typeof(self) ws = self;
        
        
        int32_t requestID = [ZFPhotoTools zf_getfetchPhotoWithAsset:model.asset photoSize:[self getPhotoSize] completion:^(UIImage *img, NSDictionary *info, BOOL isDegraded) {
            if ([ws.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                ws.photoimgView.image = img;
            } else {
                [[PHImageManager defaultManager] cancelImageRequest:ws.requestID];
            }
            if (!isDegraded) {
                ws.requestID = 0;
            }
        }];
        if (requestID && self.requestID && requestID != self.requestID) {
            [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        }
        self.requestID = requestID;
    }
    
    self.liveImgView.hidden = YES;
    self.videoIcon.hidden = YES;
    
    if (model.type == ZFPhotoModelMediaTypeVideo) {
        self.videoIcon.hidden = NO;
    }else if (model.type == ZFPhotoModelMediaTypeLivePhoto){
        self.liveImgView.hidden = NO;
        self.liveImgView.image = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
    }
    
    self.selectBtn.selected = model.selected;
}

-(void)clickCollect:(ZFBtn *)btn{
    btn.selected = !btn.selected;
    if (self.clickBlock) {
        self.clickBlock(self,self.model,btn.selected);
    }
}

-(void)startLivePhoto{
    [self.contentView insertSubview:self.livePhotoView aboveSubview:self.photoimgView];
    __weak ZFPhotoCollectionViewCell *ws = self;
    self.liveRequestID = [ZFPhotoTools zf_getLivePhotoFormPHAsset:self.model.asset Size:[self getPhotoSize] Completion:^(PHLivePhoto *livePhoto, NSDictionary *info) {
        ws.livePhotoView.livePhoto = livePhoto;
        [ws.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
    }];
}

-(void)stopLivePhoto{
    [[PHCachingImageManager defaultManager] cancelImageRequest:self.liveRequestID];
    [self.livePhotoView stopPlayback];
    [self.livePhotoView removeFromSuperview];
}

-(CGSize)getPhotoSize{
    CGFloat width = self.frame.size.width;
    CGSize size;
    if (self.model.imageSize.width > self.model.imageSize.height / 9 * 15) {
        size = CGSizeMake(width, width * 1.5);
    }else if (self.model.imageSize.height > self.model.imageSize.width / 9 * 15) {
        size = CGSizeMake(width * 1.5, width);
    }else {
        size = CGSizeMake(width, width);
    }
    return size;
}


-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    self.selectBtn.selected = isSelected;
}

/** 点击cell回调 */
-(void)zf_setClickItem:(ZFClickItemBlock)clickBlock{
    self.clickBlock = clickBlock;
}

#pragma mark - PHLivePhotoViewDelegate
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle{

    [self stopLivePhoto];
}

#pragma mark - 布局
-(void)setSubviewLayout{
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_livePhotoView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_livePhotoView)]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_livePhotoView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_livePhotoView)]];
    

//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_liveView(==52)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_liveView)]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_liveView(==21)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_liveView)]];
    
//    [self.liveView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label]-2-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_liveLabel)]];
//    [self.liveView addConstraint:[NSLayoutConstraint constraintWithItem:_liveLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_liveView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_selectBtn]-5-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_selectBtn)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_selectBtn]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_selectBtn)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_liveImgView]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_liveImgView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_liveImgView]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_liveImgView)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_videoIcon]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_videoIcon)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_videoIcon]-5-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_videoIcon)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_photoimgView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_photoimgView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_photoimgView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_photoimgView)]];

}



#pragma mark - 懒加载
-(UIImageView *)photoimgView{
    if (_photoimgView ==nil) {
        _photoimgView = [UIImageView new];
        _photoimgView.translatesAutoresizingMaskIntoConstraints = NO;
        _photoimgView.contentMode = UIViewContentModeScaleAspectFill;
        _photoimgView.clipsToBounds = YES;
    }
    return _photoimgView;
}
-(ZFBtn *)selectBtn{
    if (_selectBtn == nil) {
        _selectBtn = [ZFBtn new];
       _selectBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _selectBtn.frame = CGRectMake(0, 0, 30, 30);
        [_selectBtn setImage:[UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"compose_guide_check_box_default"]] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"compose_guide_check_box_right"]] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(clickCollect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}

-(PHLivePhotoView *)livePhotoView{
    if (_livePhotoView == nil) {
        _livePhotoView = [PHLivePhotoView new];
        _livePhotoView.delegate =self;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
        _livePhotoView.frame = self.bounds;
        _livePhotoView.clipsToBounds = YES;
    }
    return _livePhotoView;
}
- (UIImageView *)videoIcon {
    if (!_videoIcon) {
        _videoIcon = [[UIImageView alloc] initWithImage:[ZFPhotoTools zf_getPhotoWithImgName:@"VideoSendIcon"]];
        _videoIcon.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _videoIcon;
}
-(UIView *)liveView{
    if (_liveView == nil) {
        _liveView= [UIView new];
        _liveView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
        _liveView.layer.masksToBounds = YES;
        _liveView.layer.cornerRadius = 3;
        _liveView.translatesAutoresizingMaskIntoConstraints = NO;
        self.liveView.hidden = YES;
    }
    return _liveView;
}
-(UIImageView *)liveImgView{
    if (_liveImgView == nil) {
        _liveImgView= [UIImageView new];
        _liveImgView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _liveImgView;
}
-(UILabel *)liveLabel{
    if (_liveLabel == nil) {
        _liveLabel = [UILabel new];
        _liveLabel.font = [UIFont systemFontOfSize:11];
        _liveLabel.textColor = [UIColor darkGrayColor];
        _liveLabel.textAlignment = NSTextAlignmentRight;
        _liveLabel.text = @"LIVE";
        _liveLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _liveLabel;
}

- (void)dealloc {
    [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
}

/*
 //设置数据
 -(void)zf_setAssest:(id)data{
 [super zf_setAssest:data];
 
 UIImage *badge = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
 self.liveImageView.image = badge;
 
 [self zf_playLivePhotoWithAssest:data];
 
 }


*/

@end


