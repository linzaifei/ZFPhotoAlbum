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
#import "ZFPhotoManger.h"
#import "ZFPhotoViewController.h"
#import "ZFCameraViewController.h"
@interface ZFPhotoBrowerViewController ()<ZFPublishViewDataSource,ZFPublishViewDelegate,ZFPhotoPickerViewControllerDelegate,ZFCameraViewDelegate>
@property(strong,nonatomic)NSMutableArray *dataArr;
@property(strong,nonatomic)ZFSelectView *selectView;
@property(strong,nonatomic)ZFPhotoManger *photoManager;
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
  
    
    __weak  ZFPhotoBrowerViewController *ws = self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ZFCameraViewController *photoBrowerViewController = [[ZFCameraViewController alloc] initWithCameraType:ZFCameraPopTypeSystom];
        photoBrowerViewController.cameraDelegate = self;
        [ws presentViewController:photoBrowerViewController animated:YES completion:NULL];
    }];
    
    UIAlertAction *album = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ZFPhotoViewController *photoViewController = [[ZFPhotoViewController alloc] init];
        photoViewController.delegate = ws;
        if(ws.dataArr){
            ws.photoManager.selectedPhotos = ws.dataArr;
        }
        photoViewController.photoManager = ws.photoManager;
        
        [ws presentViewController:[[UINavigationController alloc] initWithRootViewController:photoViewController] animated:YES completion:NULL];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:camera];
    [alertVC addAction:album];
    [alertVC addAction:cancel];
    
    [self presentViewController:alertVC animated:YES completion:NULL];
    
    
    
}
//点击了item
-(void)publishView:(ZFSelectView *)publishView didClickPhotoViewAtIndex:(NSUInteger)index{

    
    
}

-(NSArray<ZFPhotoModel *> *)photosOfPublishView:(ZFSelectView *)publishView{
    return self.dataArr;
}


///////////
- (void)photoPickerViewControllerTapCameraAction:(ZFPhotoViewController *)pickerViewController{

    
    
}
- (void)photoPickerViewController:(ZFPhotoViewController *)pickerViewController didSelectPhotos:(NSMutableArray<ZFPhotoModel *> *)photos{
    self.dataArr = [NSMutableArray arrayWithArray:photos];
    [self.selectView reloadData];
}
-(void)zf_photoCapViewController:(UIViewController *)viewController didFinishDismissWithPhoto:(ZFPhotoModel *)model{
    
    if (self.dataArr) {
        [self.dataArr addObject:model];
        [self.selectView reloadData];
    }
}
#pragma mark - 懒加载
//-(NSMutableArray *)dataArr{
//    if (_dataArr == nil) {
//        _dataArr = [NSMutableArray array];
//    }
//    return _dataArr;
//}
-(ZFPhotoManger *)photoManager{
    if (_photoManager == nil) {
        _photoManager = [[ZFPhotoManger alloc] initPhotoMangerWithSelectType:ZFPhotoMangerSelectTypePhoto];

    }
    return _photoManager;
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
