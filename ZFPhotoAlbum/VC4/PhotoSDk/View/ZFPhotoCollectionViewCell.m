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
@interface ZFPhotoCollectionViewCell()<PHLivePhotoViewDelegate>
@property(strong,nonatomic)UIImageView *imageView;
@property(strong,nonatomic)UIImageView *liveImageView;
@property(strong,nonatomic)PHLivePhotoView *livePhotoView;

@property(strong,nonatomic)ZFBtn *selectBtn;
@property(strong,nonatomic)PHAsset *asset;

@end

@implementation ZFPhotoCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

-(void)setUI{
    self.imageView = [UIImageView new];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    
    self.livePhotoView = [PHLivePhotoView new];
    self.livePhotoView.delegate =self;
    self.livePhotoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
    self.livePhotoView.clipsToBounds = YES;
    [self.contentView addSubview:self.livePhotoView];
    
    self.liveImageView = [UIImageView new];
    self.liveImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.liveImageView];
    
    
    self.selectBtn = [ZFBtn new];
    self.selectBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectBtn.frame = CGRectMake(0, 0, 60, 30);
    [self.selectBtn setImage:[UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"Asset_checked_no.png"]] forState:UIControlStateNormal];
    [self.selectBtn setImage:[UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"Asset_checked.png"]] forState:UIControlStateSelected];
    [self.selectBtn addTarget:self action:@selector(clickCollect:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.selectBtn];
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_livePhotoView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_livePhotoView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_livePhotoView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_livePhotoView)]];
    

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_imageView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_imageView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_imageView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_imageView)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[_liveImageView]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_liveImageView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[_liveImageView]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_liveImageView)]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_selectBtn]-5-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_selectBtn)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_selectBtn]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_selectBtn)]];
 
    
}
-(void)zf_setAssest:(id)data{
    if ([data isKindOfClass:[UIImage class]]) {//显示第一张相机
        self.selectBtn.hidden = YES;
        self.liveImageView.hidden = YES;
        self.imageView.image = data;
    }else{
        self.selectBtn.hidden = NO;
        self.asset = (PHAsset *)data;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        CGSize size = CGSizeMake(self.asset.pixelWidth * 0.06 < 200 ? 200 :self.asset.pixelWidth * 0.06, self.asset.pixelHeight * 0.06 <200 ? 200 :self.asset.pixelHeight * 0.06 );
        // 从asset中获得图片
        __weak ZFPhotoCollectionViewCell *ws = self;
        
        // 如果是Live图片增加一个标记
        if (self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
            self.liveImageView.hidden = NO;
            self.imageView.hidden = YES;
            self.livePhotoView.hidden = NO;
            UIImage *badge = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
            self.liveImageView.image = badge;
            
            [self zf_playLivePhoto];

        }else{
            self.liveImageView.hidden = YES;
            self.livePhotoView.hidden = YES;
            self.imageView.hidden = NO;
        }
        
        
       /*
        //会缓存在内存中
        [[PHCachingImageManager defaultManager] requestImageForAsset:self.asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            ws.imageView.image = result;
        }];
        */
        
        //不会缓存在内存中（获取图片）
        [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                ws.imageView.image = result;
        }];
        
    }
}

//加载live视图
-(void)zf_playLivePhoto{
   
    //判断是不是live视图
    if (self.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
        option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        option.networkAccessAllowed = YES;
        option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            NSLog(@"%f",progress);
        };
        
        __weak ZFPhotoCollectionViewCell *ws = self;
        [[PHImageManager defaultManager] requestLivePhotoForAsset:self.asset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeDefault options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            ws.livePhotoView.livePhoto = livePhoto;
        }];
    }
}


- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle{
    NSLog(@"开始");
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle{
    NSLog(@"结束");
}

-(void)setIsSelect:(BOOL)isSelect{
    self.selectBtn.selected = isSelect;
   
}

-(void)clickCollect:(ZFBtn *)btn{
    if (!btn.selected) {
        if (self.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }
    }
    if (self.btnSelectBlock) {
        self.btnSelectBlock(self.asset, btn.selected);
    }
}

@end
