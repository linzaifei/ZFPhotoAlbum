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
    
    UIView *containerView = transitionContext.containerView;
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
    PHAsset *asset = [cell valueForKey:@"asset"];
    UIView *view = nil;
    if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        view = cell.contentView.subviews[1];
    }else{
        view = [cell.contentView.subviews firstObject];
    }
    /*
    //获取展示的图片
    UICollectionView *browCollectionView = [toVC valueForKey:@"collectionView"];
    //获取cell上的视图
    ZFBrowCollectionCell *browCell = (ZFBrowCollectionCell *)[browCollectionView cellForItemAtIndexPath:indexPath];
    PHAsset *borwAsset = [cell valueForKey:@"asset"];
    UIView *browView = nil;
    if (borwAsset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        browView = (UIView *)browCell.zf_photoScrollView.livePhotoView;
    }else{
        browView = browCell.zf_photoScrollView.zf_photoImgView;
    }
    
    
    
    //创建一个View的截图 把原来的view隐藏
    UIView *snapshotView = [view snapshotViewAfterScreenUpdates:NO];
    //获取这个假视图在toView上的位置
    //这边必须使用 toVC.sourceView  不能使用snapshotView 测试
    snapshotView.frame = [view convertRect:view.frame toView:containerView];
    
    //设置控制器的位置
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    
    //添加到容器中
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapshotView];
    //执行动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.9 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^{
        snapshotView.frame = browView.frame;
        toVC.view.alpha = 1;
        
    } completion:^(BOOL finished) {
        if (finished) {
            snapshotView.hidden = YES;
            //            toVC.showImageView.image = cell.imageView.image;
            [transitionContext completeTransition:YES];
        }
        
    }];
     */
}




-(void)zf_popAnnimationTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
//    ZFViewController *toVC = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
//    ViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIView *containerView = transitionContext.containerView;
//    
//    //私有方法获取方法
//    UICollectionView *collectionView = [fromVC valueForKey:@"collectionView"];
//    ZFCollectionViewCell *cell = (ZFCollectionViewCell *)[collectionView cellForItemAtIndexPath:toVC.indexPath];
//    
//    //创建一个View的截图 把原来的view隐藏
//    UIView *snapshotView = [toVC.showImageView snapshotViewAfterScreenUpdates:NO];
//    //获取这个假视图在toView上的位置
//    //这边必须使用 toVC.sourceView  不能使用snapshotView 测试
//    snapshotView.frame = [toVC.showImageView convertRect:toVC.showImageView.frame toView:containerView];
//    //设置控制器的位置
//    //    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
//    //    toVC.view.alpha = 0;
//    //添加到容器中
//    [containerView addSubview:fromVC.view];
//    [containerView addSubview:toVC.view];
//    [containerView addSubview:snapshotView];
//    //执行动画
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.9 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^{
//        snapshotView.frame = [cell.imageView convertRect:cell.imageView.frame toView:containerView];
//        toVC.view.alpha = 0;
//    } completion:^(BOOL finished) {
//        if (finished) {
//            snapshotView.hidden = YES;
//            //            toVC.showImageView.image = cell.imageView.image;
//            [transitionContext completeTransition:YES];
//        }
//    }];
    
}

@end
