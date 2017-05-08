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
#import "ZFBtn.h"
@interface ZFBrowCollectionCell ()
@property(strong,nonatomic)ZFBtn *selectBtn;
@property(strong,nonatomic)PHAsset *asset;
@end

@implementation ZFBrowCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

-(void)setUI{
    _zf_photoScrollView = [[ZFPhotoScrollView alloc] initWithFrame:self.bounds];
    [self.contentView addSubview:_zf_photoScrollView];

    self.selectBtn = [ZFBtn new];
    self.selectBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectBtn.frame = CGRectMake(0, 0, 60, 30);
    [self.selectBtn setImage:[UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"Asset_checked_no.png"]] forState:UIControlStateNormal];
    [self.selectBtn setImage:[UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"Asset_checked.png"]] forState:UIControlStateSelected];
    [self.selectBtn addTarget:self action:@selector(clickCollect:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.selectBtn];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_selectBtn]-5-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_selectBtn)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_selectBtn]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_selectBtn)]];


}

//设置数据
-(void)zf_setAssest:(id)data{
    if ([data isKindOfClass:[PHAsset class]]) {
        PHAsset *asset = (PHAsset *)data;
        self.asset = asset;
        __weak ZFBrowCollectionCell *ws = self;
        //判断是不是live视图
        if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
            self.zf_photoScrollView.livePhotoView.hidden = NO;
            self.zf_photoScrollView.zf_photoImgView.hidden = YES;
            PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
            option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            option.networkAccessAllowed = YES;
            option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                NSLog(@"%f",progress);
            };
            [[PHImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeDefault options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                ws.zf_photoScrollView.livePhotoView.livePhoto = livePhoto;
                [ws.zf_photoScrollView.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
            }];
        }else{
            self.zf_photoScrollView.livePhotoView.hidden = YES;
            self.zf_photoScrollView.zf_photoImgView.hidden = NO;
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            // 同步获得图片, 只会返回1张图片
            options.synchronous = YES;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                if(result != nil){
                    ws.zf_photoScrollView.zf_photoImgView.image = result;
                }
            }];
        }
    }else if([data isKindOfClass:[UIImage class]]){
        _zf_photoScrollView.zf_photoImgView.image = data;
    }else if([data isKindOfClass:[NSString class]]){
        
        
    }
}

-(void)setIsSelect:(BOOL)isSelect{
    self.selectBtn.selected = isSelect;
    
}

-(void)clickCollect:(ZFBtn *)btn{
    if (self.btnSelectBlock) {
        self.btnSelectBlock(self.asset, btn.selected);
    }
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
    _zf_photoImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    //设置图片等比例缩放
    _zf_photoImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_zf_photoImgView];
    
    self.livePhotoView = [[PHLivePhotoView alloc] initWithFrame:self.bounds];
    self.livePhotoView.delegate =self;
    self.livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.livePhotoView];
    
    
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
    return _zf_photoImgView;
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

