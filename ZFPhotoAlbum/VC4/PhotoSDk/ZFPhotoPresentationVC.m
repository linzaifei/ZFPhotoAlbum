//
//  ZFPhotoPresentationVC.m
//  Summary
//
//  Created by xsy on 2017/4/19.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPhotoPresentationVC.h"


#define frameOffset 240 //距离顶部高度
@interface ZFPhotoPresentationVC()
@property(strong,nonatomic)UIView *coverView;
@end
@implementation ZFPhotoPresentationVC
-(instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController{
    if (self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
        self.height = frameOffset;
    }
    return self;
}

-(void)presentationTransitionWillBegin{
    CGRect toFrame = self.presentingViewController.view.bounds;
    [self.containerView insertSubview:self.coverView atIndex:0];
    self.coverView.frame = toFrame;

    self.coverView.alpha = 0.0;
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.coverView.alpha = 0.1;
    } completion:nil];
    
}

- (BOOL)shouldRemovePresentersView{
    return NO;
}

//如果呈现没有完成，那就移除背景 View
- (void)presentationTransitionDidEnd:(BOOL)completed{
    if (!completed) {
        [self.coverView removeFromSuperview];
    }
}
- (void)dismissalTransitionWillBegin{
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.coverView.alpha = 0.0;
    } completion:nil];
}
- (void)dismissalTransitionDidEnd:(BOOL)completed{
    if (completed) {
        [self.coverView removeFromSuperview];
    }
    [[[UIApplication sharedApplication]keyWindow]addSubview:self.presentingViewController.view];
}

- (void)containerViewWillLayoutSubviews;{
    CGRect toFrame = self.presentingViewController.view.bounds;
    self.presentedView.frame = CGRectMake(toFrame.origin.x,64, toFrame.size.width, self.height);
}

-(UIView *)coverView{
    if (_coverView == nil) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        _coverView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

-(void)close{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
}

-(void)dealloc{
    NSLog(@"销毁--%s",__FUNCTION__);
}

@end
