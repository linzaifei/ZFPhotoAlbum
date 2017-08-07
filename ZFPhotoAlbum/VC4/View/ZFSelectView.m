//
//  ZFSelectView.m
//  Summary
//
//  Created by xinshiyun on 2017/4/13.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFSelectView.h"
#import "ZFSelectPublishCell.h"
#import <Photos/Photos.h>
#import "Masonry.h"
#import "ZFPhotoModel.h"
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height
#define kScreenWidth    [UIScreen mainScreen].bounds.size.width

@interface ZFSelectView()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PublishPhotoCellDelegate>


@end
static NSString *cellIdentify = @"cellIdentify";
static void *publishViewContext = &publishViewContext;
@implementation ZFSelectView

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        self.maxCount = 9;
        [self setUI];
    }
    return self;
}

-(void)setUI{

    CGFloat photoW = (kScreenWidth - 15*2 - 5*3)/4;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(photoW, photoW);
    layout.minimumLineSpacing = 5.0;
    layout.minimumInteritemSpacing = 5.0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _photoCollectionView.scrollEnabled = NO;
    _photoCollectionView.backgroundColor = [UIColor whiteColor];
    [_photoCollectionView registerClass:[ZFSelectPublishCell class] forCellWithReuseIdentifier:cellIdentify];
    _photoCollectionView.dataSource = self;
    _photoCollectionView.delegate = self;
    [self addSubview:_photoCollectionView];


//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_photoCollectionView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_photoCollectionView)]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_photoCollectionView(==110)]-10-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_photoCollectionView)]];
//    
    [_photoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.left.equalTo(@0);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@110);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
    }];
    
    [self.photoCollectionView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:publishViewContext];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == publishViewContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            [_photoCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(self.photoCollectionView.contentSize.height));
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)reloadData {
    [self.photoCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger count = 1;
    if ([self.dataSource respondsToSelector:@selector(photosOfPublishView:)]) {
        NSArray *photos = [self.dataSource photosOfPublishView:self];
        if (photos!=nil) {
            count = (photos.count>=self.maxCount)?self.maxCount:photos.count+1;
        }
    }
    return count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 15, 0,15);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFSelectPublishCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentify forIndexPath:indexPath];
    BOOL ret = [self isAddPhotoViewAtIndex:indexPath];
    if (ret) {
        cell.cancelButton.hidden = YES;
        cell.imageView.image = [UIImage imageNamed:@"publish_add"];
    }else {
        cell.cancelButton.hidden = NO;
        ZFPhotoModel *model = [self.dataSource photosOfPublishView:self][indexPath.row];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        CGSize size = CGSizeMake(model.asset.pixelWidth * 0.06 < 200 ? 200 :model.asset.pixelWidth * 0.06, model.asset.pixelHeight * 0.06 <200 ? 200 :model.asset.pixelHeight * 0.06 );
        __weak ZFSelectPublishCell *weakCell = cell;
        [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            weakCell.imageView.image = result;
        }];
        
        cell.delegate = self;
    }
    return cell;
}

-(void)cellClickCancel:(ZFSelectPublishCell *)cell {
    NSIndexPath *indexPath = [self.photoCollectionView indexPathForCell:cell];
    if ([self.delegate respondsToSelector:@selector(publishView:deletePhotoAtIndex:)]) {
        [self.delegate publishView:self deletePhotoAtIndex:indexPath.row];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isAddPhotoViewAtIndex:indexPath]) {
        if ([self.delegate respondsToSelector:@selector(publishViewClickAddPhoto:)]) {
            [self.delegate publishViewClickAddPhoto:self];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(publishView:didClickPhotoViewAtIndex:)]) {
            [self.delegate publishView:self didClickPhotoViewAtIndex:indexPath.row];
        }
    }
}

- (BOOL)isAddPhotoViewAtIndex:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(photosOfPublishView:)]) {
        NSArray *photos = [self.dataSource photosOfPublishView:self];
        if (photos==nil||photos.count==0) {
            return YES;
        }
        if (photos.count == self.maxCount) {
            return NO;
        }
        if (indexPath.row<photos.count) {
            return NO;
        }
    }
    return YES;
}

- (void)dealloc {
    [self.photoCollectionView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
}


@end
