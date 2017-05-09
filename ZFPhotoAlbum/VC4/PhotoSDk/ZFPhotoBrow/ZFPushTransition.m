//
//  ZFPushTransition.m
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/9.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPushTransition.h"
#import "ZFBrowsePhotoViewController.h"
#import "ZFPhotoViewController.h"
#import "ZFPhotoCollectionViewCell.h"

@implementation ZFPushTransition

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.5;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{

    ZFBrowsePhotoViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    ZFPhotoViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = transitionContext.containerView;
    //创建一个View的截图 把原来的view隐藏
    UIView *snapshotView = [toVC.sourceView snapshotViewAfterScreenUpdates:NO];
    
    //获取这个假视图在toView上的位置
    //这边必须使用 toVC.sourceView  不能使用snapshotView 测试
    snapshotView.frame = [toVC.sourceView convertRect:toVC.sourceView.frame toView:containerView];
    toVC.sourceView.hidden = YES;//隐藏原来视图
    
    //获取最终视图位置
    UICollectionView *collectionView = [toVC valueForKey:@"collectionView"];
    UICollectionViewFlowLayout *layout =(UICollectionViewFlowLayout *) collectionView.collectionViewLayout;
    
    //设置控制器的位置
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    
    //添加到容器中
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapshotView];
    
    //执行动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        
        snapshotView.frame = CGRectMake(collectionView.frame.origin.x + 20, collectionView.frame.origin.y + 20, collectionView.frame.size.width - 40, collectionView.frame.size.height - 64);
        
        toVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            
            [snapshotView removeFromSuperview];
            
            [transitionContext completeTransition:YES];
        }
    }];
    
    
    NSLog(@"-----");
    
    
    
    


}
@end
