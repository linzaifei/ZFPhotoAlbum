 //
//  ZFBrowCollectionCell.m
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/5.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFBrowCollectionCell.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "ZFPhotoModel.h"
#import "ZFPhotoTools.h"

@interface ZFBrowCollectionCell ()

@property(strong,nonatomic)PHAsset *asset;
@property (assign, nonatomic) PHImageRequestID requestID;
@property (assign, nonatomic) PHImageRequestID heightRequestId;
@end

@implementation ZFBrowCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

-(void)setUI{
    _photoScrollView = [[ZFPhotoScrollView alloc] initWithFrame:self.bounds];
    _photoScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_photoScrollView];


    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_photoScrollView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_photoScrollView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_photoScrollView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_photoScrollView)]];
    

}

/*设置高清图片*/
-(void)setHightImg{
    [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = self.model.imageSize.width;
    CGFloat imgHeight = self.model.imageSize.height;
    PHImageRequestID requestID;
    __weak typeof(self) weakSelf = self;
    
    CGSize size = CGSizeZero;
    if (imgHeight > imgWidth / 9 * 17) {
        size = CGSizeMake(width, height);
    }else {
        size = CGSizeMake(_model.endImageSize.width * 2.0, _model.endImageSize.height * 2.0);
    }
    
    requestID =[ZFPhotoTools zf_getHighQualityFromPHAsset:self.model.asset WithDeliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat size:size completion:^(UIImage *image, NSDictionary *info) {
        weakSelf.photoScrollView.photoImgView.image = image;
        
    } Progress:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
    }];
    if (self.heightRequestId != requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.heightRequestId];
        self.heightRequestId = requestID;
    }
}

-(void)setModel:(ZFPhotoModel *)model{
    _model = model;
 
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = model.imageSize.width;
    CGFloat imgHeight = model.imageSize.height;
    CGFloat w;
    CGFloat h;
    
    //等比例
    imgHeight = width / imgWidth * imgHeight;
    if (imgHeight > height) {
        w = height / model.imageSize.height * imgWidth;
        h = height;
    }else {
        w = width;
        h = imgHeight;
    }
    
    __weak typeof(self) weakSelf = self;
    CGSize size = CGSizeZero;
    if (imgHeight > imgWidth / 9 * 17) {
        size = CGSizeMake(width * 0.5, height * 0.5);
    }else {
        size = CGSizeMake(model.endImageSize.width * 0.8, model.endImageSize.height * 0.8);
    }
    PHImageRequestID requestID = [ZFPhotoTools zf_getPhotoFromPHAsset:model.asset size:size completion:^(UIImage *image, NSDictionary *info) {
        weakSelf.photoScrollView.photoImgView.image = image;
    }];
    
    if (self.requestID != requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
    }
    
    self.requestID = requestID;
}

@end



@interface ZFPhotoScrollView ()<UIScrollViewDelegate,PHLivePhotoViewDelegate>

@end

@implementation ZFPhotoScrollView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

-(void)setUI{
    //设置代理
    self.delegate = self;
    //设置缩放倍数
    self.maximumZoomScale = 3;
    self.minimumZoomScale = 1;
    
    //创建子视图
    _photoImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    //设置图片等比例缩放
    _photoImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_photoImgView];
    
//    self.livePhotoView = [[PHLivePhotoView alloc] initWithFrame:self.bounds];
//    self.livePhotoView.delegate =self;
//    self.livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
//    [self addSubview:self.livePhotoView];
    
    
    /**
     *  手势
     点击手势 UITapGestureRecognizer
     轻扫手势 UISwipeGestureRecognizer
     拖动手势 UIPanGestureRecognizer
     长按手势 UILongPressGestureRecognizer
     
     手势需要添加到视图上,才能触发
     */
    
    //双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    
    //1.设置点击的次数
    doubleTap.numberOfTapsRequired = 2;
    //2.手指的数量
    //        tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTap];
    //单击手势
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
//    [self addGestureRecognizer:singleTap];
//    双击手势触发时,让单击手势暂时失效
//    [singleTap requireGestureRecognizerToFail:doubleTap];
    
}

- (void)doubleTap:(UITapGestureRecognizer *)tap{
    NSLog(@"双击");
    if (self.zoomScale != 1) {//放大状态
        [self setZoomScale:1 animated:YES];
    }else {
        [self setZoomScale:3 animated:YES];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImgView;
}


#pragma mark - 代理方法
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle{
    
    NSLog(@"start--%ld",playbackStyle);
    
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle{
    NSLog(@"end--%ld",playbackStyle);
    [livePhotoView stopPlayback];
}

@end


@implementation ScrollLayout


/*!
 *  多次调用 只要滑出范围就会 调用
 *  当CollectionView的显示范围发生改变的时候，是否重新发生布局
 *  一旦重新刷新 布局，就会重新调用
 *  1.layoutAttributesForElementsInRect：方法
 *  2.preparelayout方法
 */
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
//    NSLog(@"%f",proposedContentOffset.x);
    CGRect rect ;
    rect.origin.x = proposedContentOffset.x;
    rect.origin.y = 0;
    rect.size = self.collectionView.frame.size;
    
    NSArray *attributesArr = [super layoutAttributesForElementsInRect:rect];
    
    //获取中心距离
    CGFloat CenterX = proposedContentOffset.x + self.collectionView.frame.size.width / 2;
    
    __block CGFloat minData = MAXFLOAT;
    [attributesArr enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(ABS(minData) > ABS(obj.center.x - CenterX)){
            minData = obj.center.x - CenterX;
        }
    }];
    
    // 修改原有的偏移量
    proposedContentOffset.x += minData;
    //如果返回的时zero 那个滑动停止后 就会立刻回到原地
    return proposedContentOffset;
    
}


@end

