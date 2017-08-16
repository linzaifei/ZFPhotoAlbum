
//  ZFCamareViewController.m
//  Summary
//
//  Created by xinshiyun on 2017/4/14.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "ZFPhotoHeadView.h"
#import "RemindView.h"
#import "ZFPhotoAlbum.h"
#import "ZFCommonTransition.h"
#import "ZFPhotoTools.h"
#import "ZFPhotoModel.h"
#import "ZFPhotoManger.h"

#define bottom_height 190


@interface ZFCameraViewController ()<UIGestureRecognizerDelegate,UIViewControllerTransitioningDelegate>


@property (nonatomic) dispatch_queue_t sessionQueue;

/** AVCaptureSession对象来执行输入设备和输出设备之间的数据传递 */
@property (nonatomic, strong) AVCaptureSession* session;
/** 输入设备 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/** 照片输出流*/
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/** 预览图层 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
/** 记录开始的缩放比例 */
@property(nonatomic,assign)CGFloat beginGestureScale;
/** 最后的缩放比例*/
@property(nonatomic,assign)CGFloat effectiveScale;
/** 相机背景 */
@property(nonatomic,strong)UIView *backView;
/** 拍照视图 */
@property(strong,nonatomic)ZFTakePhotoHeadView *takePhotoHeadView;
/** 拍照存储图片 */
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic)UIImage *image;

//上下两个动画背景
@property (nonatomic,strong)UIImageView *upImageView;
@property (nonatomic,strong)UIImageView *downImageView;
//转场动画
@property(strong,nonatomic)ZFCommonTransition *commonTransition;

/** 是否点击拍照或是视频 */
@property(assign,nonatomic)BOOL isTake;

@end

@implementation ZFCameraViewController{
    BOOL isUsingFrontFacingCamera;
    NSData *_data;
    CFDictionaryRef _dicRef;
}
-(instancetype)initWithCameraType:(ZFCameraPopType )type{
    if (self = [super init]) {
        if(type == ZFCameraPopTypeCustom){
            self.transitioningDelegate = self;
            self.modalPresentationStyle = UIModalPresentationCustom;
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    if (self.session) {
        [self.session startRunning];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.navigationController.navigationBar.hidden = NO;
    if (self.session) {
        [self.session stopRunning];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self zf_initAVCaptureSession];    
    [self zf_setting];
    [self zf_setUpGesture];
    
    isUsingFrontFacingCamera = NO;
    self.effectiveScale = self.beginGestureScale = 1.0f;
}

#pragma mark - 初始化设置
-(void)zf_setting{
    ZFCamareHeadView *camareHeadView = [ZFCamareHeadView new];
    camareHeadView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:camareHeadView];
    
    self.takePhotoHeadView = [ZFTakePhotoHeadView new];
    self.takePhotoHeadView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.takePhotoHeadView];
    
    _upImageView = [[UIImageView alloc] init];
    _upImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _upImageView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:_upImageView belowSubview:camareHeadView];
    
    _downImageView = [[UIImageView alloc] init];
    _downImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _downImageView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:_downImageView belowSubview:self.takePhotoHeadView];

    WeakSelf(ws);
    [camareHeadView setDidClickWithType:^(ZFClickType type,UIButton *btn) {
        [ws setBlockWithType:type WithBtn:btn];
    }];
    [self.takePhotoHeadView setDidClickWithType:^(ZFClickType type, UIButton *btn) {
        [ws setBlockWithType:type WithBtn:btn];
    }];
    
    ///------------布局--------
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[camareHeadView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(camareHeadView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_takePhotoHeadView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_takePhotoHeadView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_upImageView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_upImageView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_downImageView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_downImageView)]];
    
    CGFloat width = (kScreenHeight - bottom_height - kNavigationHeight) / 2.0;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[camareHeadView(==top_height)]-0-[_upImageView(==sppding)]" options:0 metrics:@{@"sppding":[NSNumber numberWithFloat:width],@"top_height":[NSNumber numberWithInteger:kNavigationHeight]} views:NSDictionaryOfVariableBindings(_upImageView,camareHeadView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_downImageView(==sppding)]-0-[_takePhotoHeadView(==bottomHeight)]-0-|" options:0 metrics:@{@"sppding":[NSNumber numberWithFloat:width],@"bottomHeight":[NSNumber numberWithInteger:bottom_height]} views:NSDictionaryOfVariableBindings(_downImageView,_takePhotoHeadView)]];
    [self zf_onpenAnnimation];
}
/** 点击事件 */
-(void)setBlockWithType:(ZFClickType)type WithBtn:(UIButton *)btn{
    switch (type) {
        case ZFClickTypeBack://返回
            [self zf_closeAnnimation];
            break;
        case ZFClickTypeFlash://却换闪光灯
            [self zf_AutoFlash:btn];
            break;
        case ZFClickTypeChangeCamera://却换摄像头
            if(!self.isTake){
                [self zf_chageCamera];
            }
            break;
        case ZFClickTypeTakePhoto://拍照
            [self zf_TakePhotoAction];
            break;
        case ZFClickTypeCancel://取消照片
            if(self.isTake){
                [self zf_cancel];
            }
            break;
        case ZFClickTypeSave://保存照片
            if (self.isTake) {
                [self zf_savePhoto];
            }
            break;
        default:
            break;
    }


}


#pragma mark private method
- (void)zf_initAVCaptureSession{
    self.session = [[AVCaptureSession alloc] init];
    NSError *error;
    /** 捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）*/
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    /** 更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃 */
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    /** 图片输出 */
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    /** 初始化预览图层 */
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    /** 设置预览图层充满屏幕*/
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.previewLayer];
    [self.view addSubview:self.backView];
    
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

#pragma 创建手势
- (void)zf_setUpGesture{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.backView addGestureRecognizer:pinch];
}
#pragma mark gestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

#pragma mark - 按钮触发事件
/*!
 *  开启关闭闪光灯
 */
-(void)zf_AutoFlash:(UIButton *)sender{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //修改前必须先锁定
    [device lockForConfiguration:nil];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([device hasFlash]) {
        if (device.flashMode == AVCaptureFlashModeOff) {
            device.flashMode = AVCaptureFlashModeOn;
            [sender setImage:[ZFPhotoTools zf_getPhotoWithImgName:@"camera_flashlight_open_disable"] forState:UIControlStateNormal];
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeAuto;
            [sender setImage:[ZFPhotoTools zf_getPhotoWithImgName:@"camera_flashlight_auto_disable"] forState:UIControlStateNormal];
        } else if (device.flashMode == AVCaptureFlashModeAuto) {
            device.flashMode = AVCaptureFlashModeOff;
            [sender setImage:[ZFPhotoTools zf_getPhotoWithImgName:@"camera_flashlight_disable"] forState:UIControlStateNormal];
        }
        
    } else {
        [RemindView showViewWithTitle:NSLocalizedString(@"设备不支持闪光灯", nil) location:LocationTypeMIDDLE];
    }
    [device unlockForConfiguration];
}
/*!
 *  却换前后摄像头
 */
-(void)zf_chageCamera {
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_videoInput];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.videoInput = newInput;
            } else {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}
/*!
 *  拍照
 */
-(void)zf_TakePhotoAction{
    AVCaptureConnection * videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,imageDataSampleBuffer,
kCMAttachmentMode_ShouldPropagate);
        
        PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
        if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied){
            //无权限
            [RemindView showViewWithTitle:NSLocalizedString(@"无权限", nil) location:LocationTypeMIDDLE];
            return ;
        }
        
        _data = imageData;
        _dicRef = attachments;
    
        self.image = [UIImage imageWithData:imageData];
        [self.session stopRunning];
        
        self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        [self.view insertSubview:_imageView atIndex:0];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.image = _image;
        self.isTake = YES;
    }];
}

//取消选中
-(void)zf_cancel {
    self.isTake = NO;
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        self.image = nil;
    }
    [self.session startRunning];
}


-(void)zf_savePhoto {
//    866771E8-990A-4897-93D8-8B4C7FB6BDEE/L0/001
    __weak ZFCameraViewController *ws = self;
    __block NSString *Str =nil;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:ws.image];
            PHObjectPlaceholder *assetPlaceholder = request.placeholderForCreatedAsset;
            Str = assetPlaceholder.localIdentifier;
            PHAssetCollectionChangeRequest *collectRequest = [[PHAssetCollectionChangeRequest alloc] init];
            
            [collectRequest addAssets:@[assetPlaceholder]];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    PHFetchOptions *option = [[PHFetchOptions alloc] init];
                    PHFetchResult *fetchReslut = [PHAsset fetchAssetsWithLocalIdentifiers:@[Str] options:option];
                    PHAsset *asset = fetchReslut.lastObject;
                    NSLog(@"asset lat =%@",asset.localIdentifier);
                    ZFPhotoModel *model = [[ZFPhotoModel alloc] init];
                    model.asset = asset;
                    model.selected = YES;
                    if([self.cameraDelegate respondsToSelector:@selector(zf_photoCapViewController:didFinishDismissWithPhoto:)]){
                        [self.cameraDelegate zf_photoCapViewController:ws didFinishDismissWithPhoto:model];
                    }
                    [ws zf_closeAnnimation];
                });
            }
        }];

    });
}

//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    if ( allTouchesAreOnThePreviewLayer ) {
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
//        NSLog(@"%f-------------->%f------------recognizerScale%f",self.effectiveScale,self.beginGestureScale,recognizer.scale);
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
//        NSLog(@"%f",maxScaleAndCropFactor);
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
}

-(void)zf_closeAnnimation{
    if (self.session) {
        [self.session stopRunning];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _upImageView.transform = CGAffineTransformIdentity;
        _downImageView.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)zf_onpenAnnimation {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.session) {
            [self.session startRunning];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat width = (kScreenHeight - bottom_height - kNavigationHeight) / 2.0;
            [UIView animateWithDuration:0.5 animations:^{
                _upImageView.transform = CGAffineTransformMakeTranslation(0, -width);
                _downImageView.transform = CGAffineTransformMakeTranslation(0, width);
            }];
        });
    });
}


#pragma mark - 懒加载
-(UIView *)backView {
    if (_backView == nil) {
        _backView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backView.layer.masksToBounds = YES;
    }
    return _backView;
    
}

-(ZFCommonTransition *)commonTransition{
    if (_commonTransition == nil) {
        _commonTransition = [[ZFCommonTransition alloc] init];
    }
    return _commonTransition;
}

#pragma mark -- UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{

    
    self.commonTransition.type = ZFTransitionTypeCameraPresent;
    return self.commonTransition;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.commonTransition.type = ZFTransitionTypeCameraDismess;
    return self.commonTransition;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"销毁%s",__FUNCTION__);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
