//
//  ZFPickerPhotoViewController.m
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/3.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPickerPhotoViewController.h"
#import "ZFPhotoViewController.h"

@interface ZFPickerPhotoViewController ()

@property(strong,nonatomic)ZFPhotoViewController *photoViewController;
@end

@implementation ZFPickerPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self zf_addChildrenView];
}
-(void)zf_addChildrenView{
    self.viewControllers = @[self.photoViewController];
}

-(void)setMaxCount:(NSInteger)maxCount{
    _maxCount = maxCount;
    self.photoViewController.maxCount = maxCount;
}

-(void)setRowSpacing:(NSInteger)rowSpacing{
    _rowSpacing = rowSpacing;
    self.photoViewController.rowSpacing = rowSpacing;
}

-(void)setColumnCount:(NSInteger)columnCount{
    _columnCount = columnCount;
    self.photoViewController.columnCount = columnCount;
}
-(void)setSelectItems:(NSArray<PHAsset *> *)selectItems{
    _selectItems = selectItems;
    self.photoViewController.selectItems = selectItems;
}
-(void)setSectionInset:(UIEdgeInsets)sectionInset{
    _sectionInset = sectionInset;
    self.photoViewController.sectionInset = sectionInset;
}
-(void)setColumnSpacing:(NSInteger)columnSpacing{
    _columnSpacing = columnSpacing;
    self.photoViewController.columnSpacing = columnSpacing;
}

#pragma mark - 懒加载
-(ZFPhotoViewController *)photoViewController{
    if (_photoViewController == nil) {
        _photoViewController = [[ZFPhotoViewController alloc] init];
        _photoViewController.delegate = _pickerDelegate;
    }
    return _photoViewController;
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
