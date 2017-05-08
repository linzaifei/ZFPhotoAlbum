//
//  ZFPhotoBrowerViewController.m
//  Summary
//
//  Created by xinshiyun on 2017/4/12.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPhotoBrowerViewController.h"
#import "ZFPhotoViewController.h"
#import "ZFSelectView.h"
#import "Masonry.h"

#import "ZFPickerPhotoViewController.h"

@interface ZFPhotoBrowerViewController ()<ZFPublishViewDataSource,ZFPublishViewDelegate,ZFPhotoPickerViewControllerDelegate>
@property(strong,nonatomic)NSMutableArray *dataArr;
@property(strong,nonatomic)ZFSelectView *selectView;
@end

@implementation ZFPhotoBrowerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor grayColor];
    
    [self setUI];
}

-(void)setUI{
    self.selectView = [ZFSelectView new];
    self.selectView.delegate = self;
    self.selectView.dataSource = self;
    [self.view addSubview:self.selectView];
    
    [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@100);
        make.left.right.equalTo(self.view);
    }];
}

//删除
-(void)publishView:(ZFSelectView *)publishView deletePhotoAtIndex:(NSUInteger)index{
    if (self.dataArr.count == publishView.maxCount) {
        [self.dataArr removeObjectAtIndex:index];
        [self.selectView reloadData];
    }else {
        [self.dataArr removeObjectAtIndex:index];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [self.selectView.photoCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
}
//点击添加照片
-(void)publishViewClickAddPhoto:(ZFSelectView *)publishView{
    ZFPickerPhotoViewController *photoViewController = [[ZFPickerPhotoViewController alloc] init];
    photoViewController.pickerDelegate = self;
    photoViewController.selectItems = self.dataArr;
    [self presentViewController:photoViewController animated:YES completion:NULL];
}
//点击了item
-(void)publishView:(ZFSelectView *)publishView didClickPhotoViewAtIndex:(NSUInteger)index{

    
    
}

-(NSArray<PHAsset *> *)photosOfPublishView:(ZFSelectView *)publishView{
    return self.dataArr;
}


///////////
- (void)photoPickerViewControllerTapCameraAction:(ZFPhotoViewController *)pickerViewController{

    
    
}
- (void)photoPickerViewController:(ZFPhotoViewController *)pickerViewController didSelectPhotos:(NSArray<PHAsset *> *)photos{
    self.dataArr = [NSMutableArray arrayWithArray:photos];
    [self.selectView reloadData];
}
-(NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
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
