//
//  ZFCommonTransition.m
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/11.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFCommonTransition.h"
#import "ZFBrowsePhotoViewController.h"
#import "ZFPhotoViewController.h"
#import "ZFPhotoCollectionViewCell.h"
#import "ZFBrowCollectionCell.h"
#import <Photos/Photos.h>
#import "ZFPhotoModel.h"
#import "ZFPhotoTools.h"
#import "ZFPhotoAlbum.h"

@implementation ZFCommonTransition

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.5;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    switch (self.type) {
        case ZFTransitionTypePush:
            [self zf_pushAnnimationTransition:transitionContext];
            break;
        case ZFTransitionTypePop:
            [self zf_popAnnimationTransition:transitionContext];
            break;
        case ZFTransitionTypePopMenuPresent:
            [self zf_PresentAnimationTransition:transitionContext];
            break;
        case ZFTransitionTypePopMenuDismess:
            [self zf_DismessAnimationTransition:transitionContext];
            break;
        case ZFTransitionTypeCameraPresent:
            [self zf_CameraPresentAnimationTransition:transitionContext];
            break;
        case ZFTransitionTypeCameraDismess:
            [self zf_CameraDisMessAnimationTransition:transitionContext];
            break;
            
            
        default:
            break;
    }
}
/** 相机present动画 */
-(void)zf_CameraPresentAnimationTransition:(id <UIViewControllerContextTransitioning>)transitionContext{

    //
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
//    NSLog(@"toVC == %@",toVC);
//    NSLog(@"fromVC == %@",fromVC);
    //截图
    UIView *naviView = [fromVC.view snapshotViewAfterScreenUpdates:YES];
    naviView.frame = fromVC.view.frame;
    fromVC.view.hidden = YES;
    //自定义动画后要重新加入容器中
    [transitionContext.containerView addSubview:toVC.view];
    [transitionContext.containerView addSubview:naviView];
    
    //初始相机的frame
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    toVC.view.frame = CGRectMake(0, -height, width, height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        naviView.frame = CGRectMake(0, height, width, height);
        toVC.view.frame = CGRectMake(0, 0, width, height);

    } completion:^(BOOL finished) {
        [naviView removeFromSuperview];
        fromVC.view.hidden = NO;
        [transitionContext completeTransition:YES];
    }];
    

}

/** 相机DisMess动画 */
-(void)zf_CameraDisMessAnimationTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    
    UIView *naviView = [toVC.view snapshotViewAfterScreenUpdates:NO];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    naviView.frame = CGRectMake(0, height, width, height);
    [transitionContext.containerView addSubview:naviView];
    toVC.view.hidden = YES;
    //动画吧
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromVC.view.frame = CGRectMake(0, -height, width, height);
        naviView.frame = CGRectMake(0, 0, width, height);
    } completion:^(BOOL finished) {
        [naviView removeFromSuperview];
        toVC.view.hidden = NO;
        [transitionContext completeTransition:YES];
    }];

}

/** 菜单栏present动画 */
-(void)zf_PresentAnimationTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    [transitionContext.containerView addSubview:toView];
    toView.transform = CGAffineTransformMakeScale(1.0, 0.0);
    toView.layer.anchorPoint = CGPointMake(0.5, 0);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:3 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        toView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (finished) {
            [transitionContext completeTransition:YES];
        }
    }];

}


/** 菜单栏dismess动画 */
-(void)zf_DismessAnimationTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    // 添加一个动画，让要消失的 view 向下移动，离开屏幕
    fromView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:5.0f initialSpringVelocity:3 options: UIViewAnimationOptionTransitionFlipFromBottom | UIViewAnimationOptionCurveLinear animations:^{
        fromView.transform = CGAffineTransformMakeScale(1.0, 0.00001);
    } completion:^(BOOL finished) {
        if (finished) {
            [transitionContext completeTransition:YES];
        }
    }];
}


/** push动画 */
-(void)zf_pushAnnimationTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    ZFBrowsePhotoViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    ZFPhotoViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
    //私有方法获取方法 （小图）
    UICollectionView *collectionView = [fromVC valueForKey:@"collectionView"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:toVC.currentIndex inSection:0];
    //获取cell上的视图
    ZFPhotoCollectionViewCell *cell = (ZFPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    ZFPhotoModel *model = cell.model;
    
    [ZFPhotoTools zf_getHighQualityFromPHAsset:model.asset size:CGSizeMake(model.endImageSize.width * 0.8, model.endImageSize.height * 0.8)  completion:^(UIImage *image, NSDictionary *info) {
        [self pushAnimation:transitionContext Cell:cell Image:image Model:model FromVC:fromVC ToVC:toVC];
        
    } error:^(NSDictionary *info) {
        [self pushAnimation:transitionContext Cell:cell Image:model.cameraPhoto Model:model FromVC:fromVC ToVC:toVC];
    }];

}

-(void)pushAnimation:(id <UIViewControllerContextTransitioning>)transitionContext Cell:(ZFPhotoCollectionViewCell *)cell Image:(UIImage *)image Model:(ZFPhotoModel *)model FromVC:(ZFPhotoViewController *)fromVC ToVC:(UIViewController *)toVC{
    UIView *containerView = transitionContext.containerView;
    UIImageView *photoImgView = cell.photoimgView;
    
    //创建一个View的截图 把原来的view隐藏
    UIView *snapshotView = [photoImgView snapshotViewAfterScreenUpdates:NO];

    //这边必须使用 toVC.sourceView  不能使用snapshotView 测试
    snapshotView.frame = [photoImgView convertRect:photoImgView.frame toView:containerView];
    //设置控制器的位置
//    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    //添加到容器中
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapshotView];
    ZFBrowsePhotoViewController *browVC = (ZFBrowsePhotoViewController *)toVC;
    //私有方法获取方法 （小图）
    UICollectionView *collectionView = [browVC valueForKey:@"collectionView"];
    collectionView.hidden = YES;
    CGFloat imgWidht = model.endImageSize.width;
    CGFloat imgHeight = model.endImageSize.height;

    //执行动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        snapshotView.frame = CGRectMake((kScreenWidth - imgWidht) / 2, (kScreenHeight - imgHeight) / 2 + 32, imgWidht, imgHeight);;
    } completion:^(BOOL finished) {
        if (finished) {
            collectionView.hidden = NO;
            snapshotView.hidden = YES;
            [transitionContext completeTransition:YES];
        }
        
    }];

}




-(void)zf_popAnnimationTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    ZFBrowsePhotoViewController *fromVC = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
    ZFPhotoViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;

    //私有方法获取方法
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:fromVC.currentIndex inSection:0];
    UICollectionView *fromCollectionView = [fromVC valueForKey:@"collectionView"];
    ZFBrowCollectionCell *fromCell = (ZFBrowCollectionCell *)[fromCollectionView cellForItemAtIndexPath:indexPath];
    
    UIImageView *tempView = [[UIImageView alloc] initWithImage:fromCell.photoScrollView.photoImgView.image];
    tempView.clipsToBounds = YES;
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    
    ZFPhotoModel *model = fromVC.photoItems[fromVC.currentIndex];

    UICollectionView *toCollectionView = [toVC valueForKey:@"collectionView"];
    ZFPhotoCollectionViewCell *toCell = (ZFPhotoCollectionViewCell *)[toCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:fromVC.currentIndex inSection:0]];
    
    NSLog(@"currentIndex == %ld",fromVC.currentIndex);
    
    if (!toCell) {
//        if (model.currentAlbumIndex == toVC.albumModel.index) {
            [toCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:fromVC.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            [toCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:fromVC.currentIndex inSection:0]]];
            toCell = (ZFPhotoCollectionViewCell *)[toCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:fromVC.currentIndex inSection:0]];
//        }
    }
    
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    [containerView insertSubview:toVC.view atIndex:0];
    [containerView addSubview:tempView];
    
    tempView.frame = CGRectMake(0, 0, model.endImageSize.width, model.endImageSize.height);
    tempView.center = CGPointMake(containerView.frame.size.width / 2, (height - 64) / 2 + 64);
    CGRect rect = [toCollectionView convertRect:toCell.frame toView:[UIApplication sharedApplication].keyWindow];
    if (rect.origin.y < 64) {
        [toCollectionView setContentOffset:CGPointMake(0, toCell.frame.origin.y - 65)];
        rect = CGRectMake(toCell.frame.origin.x, 65, toCell.frame.size.width, toCell.frame.size.height);
    }else if (rect.origin.y + rect.size.height > height) {
        [toCollectionView setContentOffset:CGPointMake(0, toCell.frame.origin.y - height + rect.size.height)];
        rect = CGRectMake(toCell.frame.origin.x, height  - toCell.frame.size.height, toCell.frame.size.width, toCell.frame.size.height);
    }
    
    toCell.hidden = YES;
    fromVC.view.hidden = YES;
//    if (toVC.albumModel.index != model.currentAlbumIndex && toVC.isPreview) {
        toCell.hidden = NO;
        fromVC.view.hidden = NO;
//    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        if (toVC.albumModel.index == model.currentAlbumIndex) {
            tempView.frame = rect;
//        }else {
            fromVC.view.alpha = 0;
//            tempView.alpha = 0;
//        }
    } completion:^(BOOL finished) {
        toCell.hidden = NO;
//        toVC.isPreview = NO;
        [tempView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
    
}

@end
