//
//  ZFCamareViewController.m
//  Summary
//
//  Created by xinshiyun on 2017/4/14.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFCamareViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "ZFPhotoHeadView.h"
#import "RemindView.h"
#import "ZFPhotoAlbum.h"


#define bottom_height 130 //微博距离
#define top_height 64 //顶部距离

@interface ZFCamareViewController ()<UIGestureRecognizerDelegate>

//AVFoundation

@property (nonatomic) dispatch_queue_t sessionQueue;

/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */

@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;
/**
 *  最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;


/*!
 *  相机背景
 */
@property(nonatomic,strong)UIView *backView;

@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic)UIImage *image;

//上下两个动画背景
@property (nonatomic,strong)UIImageView *upImageView;
@property (nonatomic,strong)UIImageView *downImageView;
///
@property(strong,nonatomic)ZFTakePhotoHeadView *takePhotoHeadView;

@end

@implementation ZFCamareViewController{
    BOOL isUsingFrontFacingCamera;
    NSData *_data;
    CFDictionaryRef _dicRef;
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
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//权限
-(void)zf_camare{
    __weak ZFCamareViewController *ws = self;
    // iOS 8 后，全部都要授权
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            switch (status) {
                case AVAuthorizationStatusNotDetermined:{
                    // 许可对话没有出现，发起授权许可
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        
                        if (granted) {
                            //第一次用户接受
                        }else{
                            //用户拒绝
                            [ws zf_showPremission];
                        }
                    }];
                    break;
                }
                case AVAuthorizationStatusAuthorized:{
                    // 已经开启授权，可继续
                    if(!self.session){
//                        [ws zf_initAVCaptureSession];
                        
                    }
                    break;
                }
                case AVAuthorizationStatusDenied:
                case AVAuthorizationStatusRestricted:{
                    // 用户明确地拒绝授权，或者相机设备无法访问
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ws zf_showPremission];
                    });
                }break;
                default:
                    break;
            }
}

-(void)zf_showPremission{
    __weak ZFCamareViewController *ws = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancal = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [ws dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"]];
    }];
    
    [alertController addAction:action];
    [alertController addAction:cancal];
    [self presentViewController:alertController animated:YES completion:nil];
    
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

    __weak ZFCamareViewController *ws = self;
    //退出
    camareHeadView.cancelBlock = ^(){
        [ws zf_backAction];
    };
    //闪光灯
    camareHeadView.flashBlock = ^(UIButton *changeBtn){
        [ws zf_AutoFlash:changeBtn];
    };
    //切换摄像头
    camareHeadView.changeBlock = ^(){
        if(ws.image){
        [ws zf_cancel];
        }
        [ws zf_chageCamera];
    };
    //拍照
    self.takePhotoHeadView.takePhotoBlock = ^{
        [ws zf_TakePhotoAction];
    };
    //取消相册
    self.takePhotoHeadView.cancelBlock = ^(){
        if(ws.image){
        [ws zf_cancel];
        }
    };
    //选择相册
    self.takePhotoHeadView.chooseBlock = ^(){
        if (ws.image) {
        [ws zf_savePhoto];
        }
    };
    ///------------布局--------
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[camareHeadView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(camareHeadView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_takePhotoHeadView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_takePhotoHeadView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_upImageView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_upImageView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_downImageView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_downImageView)]];
    
    CGFloat width = (kScreenHeight - bottom_height - top_height) / 2.0;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[camareHeadView(==top_height)]-0-[_upImageView(==sppding)]" options:0 metrics:@{@"sppding":[NSNumber numberWithFloat:width],@"top_height":[NSNumber numberWithInteger:top_height]} views:NSDictionaryOfVariableBindings(_upImageView,camareHeadView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_downImageView(==sppding)]-0-[_takePhotoHeadView(==bottomHeight)]-0-|" options:0 metrics:@{@"sppding":[NSNumber numberWithFloat:width],@"bottomHeight":[NSNumber numberWithInteger:bottom_height]} views:NSDictionaryOfVariableBindings(_downImageView,_takePhotoHeadView)]];

}

#pragma mark private method
- (void)zf_initAVCaptureSession{
    self.session = [[AVCaptureSession alloc] init];
    NSError *error;
    /*!
     *  捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
     */
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    /*!
     图片输出

     - returns:
     */
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
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    /*!
     *  设置预览图层充满屏幕
     */
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
            [sender setImage:[UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"camera_flashlight_open_disable.png"]] forState:UIControlStateNormal];
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeAuto;
            [sender setImage:[UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"camera_flashlight.png"]] forState:UIControlStateNormal];
        } else if (device.flashMode == AVCaptureFlashModeAuto) {
            device.flashMode = AVCaptureFlashModeOff;
            [sender setImage:[UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"camera_flashlight_auto.png"]] forState:UIControlStateNormal];
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
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
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
        
       _takePhotoHeadView.isTake = YES;
    }];
}

//取消选中
-(void)zf_cancel {
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        self.image = nil;
    }
    _takePhotoHeadView.isTake = NO;
    [self.session startRunning];
}
//返回
-(void)zf_backAction{
    
    [self zf_closeAnnimation];
    [self performSelector:@selector(zf_dey) withObject:self afterDelay:0.5];
}
-(void)zf_dey{
    if (self.backBlock) {
        self.backBlock();
    }
}

-(void)zf_savePhoto {
    [self zf_backAction];
    __weak ZFCamareViewController *ws = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:ws.image];
        PHObjectPlaceholder *assetPlaceholder = request.placeholderForCreatedAsset;
        
        PHAssetCollectionChangeRequest *collectRequest = [[PHAssetCollectionChangeRequest alloc] init];
        
        [collectRequest addAssets:@[assetPlaceholder]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
           ws.takePhotoHeadView.isTake = NO;
        }
    }];
    
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
    }];
}

-(void)zf_onpenAnnimation {
    if (self.session) {
        [self.session startRunning];
    }
    
    [self zf_camare];//判断相机权限
    CGFloat width = (kScreenHeight - bottom_height - top_height) / 2.0;
    [UIView animateWithDuration:0.3 animations:^{
        _upImageView.transform = CGAffineTransformMakeTranslation(0, -width);
        _downImageView.transform = CGAffineTransformMakeTranslation(0, width);
    }];
}


#pragma mark - ---
-(UIView *)backView {
    if (_backView == nil) {
        _backView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backView.layer.masksToBounds = YES;
    }
    return _backView;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"销毁%s",__FUNCTION__);
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
