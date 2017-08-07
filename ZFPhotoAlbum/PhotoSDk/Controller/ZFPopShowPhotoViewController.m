//
//  ZFPopPhotoViewController.m
//  Summary
//
//  Created by xsy on 2017/4/19.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPopShowPhotoViewController.h"
#import "ZFPhotoAlbum.h"
#import "ZFPhotoTableViewCell.h"
#import "ZFPhotoPresentationVC.h"
#import "ZFCommonTransition.h"
@interface ZFPopShowPhotoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)ZFCommonTransition *commonTransition;

@end

@implementation ZFPopShowPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self zf_setUI];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom; //自己定义弹出动画 不使用系统的
        self.transitioningDelegate  = self;
        
    }
    return self;
}


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom; //自己定义弹出动画 不使用系统的
        self.transitioningDelegate  = self;
    }
    return self;
}

-(void)zf_setUI{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView registerClass:[ZFPhotoTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ZFPhotoTableViewCell class])];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.separatorColor = [UIColor clearColor];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(tableView)]];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZFPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFPhotoTableViewCell class])];
    
    cell.model = self.dataArr[indexPath.row];;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.didSelectBlock) {
        self.didSelectBlock(self.dataArr,indexPath.row);
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark - NavigationDelegate

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source NS_AVAILABLE_IOS(8_0){
    ZFPhotoPresentationVC *presentViewController = [[ZFPhotoPresentationVC alloc] initWithPresentedViewController:presented presentingViewController:presenting];
      presentViewController.height = self.dataArr.count * 60 > kScreenHeight /2.0 ? kScreenHeight / 2.0 : self.dataArr.count * 60;
    return presentViewController;
    
}
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    self.commonTransition.type = ZFTransitionTypePopMenuPresent;
    return self.commonTransition;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.commonTransition.type = ZFTransitionTypePopMenuDismess;
    return self.commonTransition;
}

-(ZFCommonTransition *)commonTransition{
    if (_commonTransition == nil) {
        _commonTransition = [[ZFCommonTransition alloc] init];
    }
    return _commonTransition;
}

-(void)dealloc{
    NSLog(@"销毁--%s",__FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
