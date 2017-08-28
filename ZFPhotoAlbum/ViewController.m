//
//  ViewController.m
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/4/25.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ViewController.h"
#import "ZFPhotoBrowerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 30);
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitle:@"相册" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

}

-(void)click{
    
    ZFPhotoBrowerViewController *photoBrowerViewController = [[ZFPhotoBrowerViewController alloc] init];
    [self.navigationController pushViewController:photoBrowerViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-设置状态栏的样式
-(UIStatusBarStyle)preferredStatusBarStyle{
    //设置为白色
    return UIStatusBarStyleLightContent;
    //默认为黑色
//    return UIStatusBarStyleDefault;
}
#pragma mark-设置状态栏是否隐藏（否）
-(BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
