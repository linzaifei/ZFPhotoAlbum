//
//  ZFPersentTransition.m
//  Summary
//
//  Created by xsy on 2017/4/19.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPersentTransition.h"
#import "ZFPopShowPhotoViewController.h"
#import "ZFPhotoPresentationVC.h"
static NSString  *ZFCustomTransitionShow = @"CustomTransitionShow";
static NSString  *ZFCustomTransitionDismess = @"ZFCustomTransitionDismess";
@interface ZFPersentTransition()
@property(assign,nonatomic)BOOL ispresenting;
@end
@implementation ZFPersentTransition

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source NS_AVAILABLE_IOS(8_0){
    ZFPhotoPresentationVC *presentViewController = [[ZFPhotoPresentationVC alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return presentViewController;
    
}
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.ispresenting = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:ZFCustomTransitionShow object:self];
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.ispresenting = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:ZFCustomTransitionDismess object:self];
    return self;
}

// This is used for percent driven interactive transitions, as well as for
// container controllers that have companion animations that might need to
// synchronize with the main animation.
//动画时间
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.5;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    //    NSLog(@"%@",transitionContext.containerView);//容器
    //    NSLog(@"%@",[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]);
    //    NSLog(@"%@",[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]);
    
    if (self.ispresenting) {
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
    }else{
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

}

@end
