//
//  PAQRCodeViewController.m
//  PlayableAdsPreviewer_Example
//
//  Created by 王泽永 on 2017/10/11.
//  Copyright © 2017年 wzy2010416033@163.com. All rights reserved.
//

#import "PAQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface PAQRCodeViewController ()
<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    void(^_completion)(BOOL, NSString *);
    NSMutableArray *_observers;
    UIView *_viewPreview;
    UIImageView * _lineImageView;
    CGRect _lineRect0;
    CGRect _lineRect1;
}
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) UIImage *scanImage;
@property (nonatomic, strong) UIImage *lineImage;
@property (nonatomic, strong) UIButton *albumButton;
@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, strong) UILabel *warningLabel;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) BOOL needsScanAnnimation;
@property (nonatomic) BOOL isReading;

@end

@implementation PAQRCodeViewController

- (void)dealloc{
    [self cleanNotifications];
    _observers = nil;
    _viewPreview = nil;
    _lineImageView = nil;
    _completion = NULL;
    self.imagePicker = nil;
    self.captureSession = nil;
    self.videoPreviewLayer = nil;
    self.lineImage = nil;
}

- (void)setupNotifications{
    if (!_observers) {
        _observers = [NSMutableArray array];
    }
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    __weak typeof(self) weakSelf = self;
    id o;
    
    o = [center addObserverForName:UIApplicationDidEnterBackgroundNotification
                            object:nil
                             queue:nil
                        usingBlock:^(NSNotification *note) {
                            [weakSelf.imagePicker dismissViewControllerAnimated:NO completion:NULL];
                            [weakSelf dismissViewControllerAnimated:NO completion:nil];
                        }];
    [_observers addObject:o];
}

- (void)cleanNotifications{
    for (id o in _observers) {
        [[NSNotificationCenter defaultCenter] removeObserver:o];
    }
    [_observers removeAllObjects];
}

- (id)initWithCompletion:(void (^)(BOOL, NSString *))completion{
    self = [super init];
    if (self) {
        _needsScanAnnimation = YES;
        _completion = completion;
        _scanImage = [UIImage imageNamed:@"img_animation_scan_pic" inBundle:[NSBundle bundleForClass:[PAQRCodeViewController class]] compatibleWithTraitCollection:nil];
        _lineImage = [UIImage imageNamed:@"img_animation_scan_line" inBundle:[NSBundle bundleForClass:[PAQRCodeViewController class]] compatibleWithTraitCollection:nil];
       
    }
    return self;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self startReading];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_needsScanAnnimation) {
        [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionRepeat animations:^{
            [_lineImageView setFrame:_lineRect1];
        } completion:^(BOOL finished) {
            [_lineImageView setFrame:_lineRect0];
        }];
    }
    
    [self checkCameraPermission];
}

- (void)checkCameraPermission{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        BOOL atLeastOne = NO;
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if (device) {
                atLeastOne = YES;
            }
        }
        if (!atLeastOne) {
            authStatus = AVAuthorizationStatusRestricted;
        }
    }else{
        self.hud.mode = MBProgressHUDModeText;
        self.hud.label.text = @"please check camera permission";
        self.hud.hidden = NO;
        [self.hud hideAnimated:YES afterDelay:5];
        self.hud = nil;
    }
}

- (MBProgressHUD *)hud{
    if (!_hud) {
        UIView *view = self.view;
        _hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
    }
    return _hud;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startReading];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopReading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNotifications];
    
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    
    // Initially make the captureSession object nil.
    _captureSession = nil;
    // Set the initial value of the flag to NO.
    _isReading = NO;
    
    _viewPreview = [[UIView alloc] init];
    [self.view addSubview:_viewPreview];
    [_viewPreview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_viewPreview
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_viewPreview
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_viewPreview
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_viewPreview
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0.0]];
    if (_needsScanAnnimation) {
        UIView * scanView = [[UIView alloc] init];
        [scanView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
        [self.view addSubview:scanView];
        [scanView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:scanView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_viewPreview
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:scanView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_viewPreview
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:scanView
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_viewPreview
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:scanView
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_viewPreview
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        CGFloat frameWidth = SCREEN_WIDTH * 2 / 3;
        //create path
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(SCREEN_WIDTH / 6, SCREEN_HEIGHT / 2 - SCREEN_WIDTH / 3, frameWidth, frameWidth) cornerRadius:0] bezierPathByReversingPath]];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        [scanView.layer setMask:shapeLayer];
        
        UIImageView * imageView = [[UIImageView alloc] init];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setImage:_scanImage];
        [self.view addSubview:imageView];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[imageView(==%f)]", frameWidth]
                                                                          options:0
                                                                          metrics:0
                                                                            views:@{@"imageView":imageView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[imageView(==%f)]", frameWidth]
                                                                          options:0
                                                                          metrics:0
                                                                            views:@{@"imageView":imageView}]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_viewPreview
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_viewPreview
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        
        _lineImageView = [[UIImageView alloc] init];
        CGFloat lineHeight = frameWidth * _lineImage.size.height / _lineImage.size.width;
        _lineRect0 = CGRectMake(0, 0, frameWidth, lineHeight);
        _lineRect1 = CGRectMake(0, frameWidth - lineHeight, frameWidth, lineHeight);
        [_lineImageView setFrame:_lineRect0];
        [_lineImageView setImage:_lineImage];
        [imageView addSubview:_lineImageView];
        
        [self addAlbumButtonConstraint];
        [self addBottomLabelConstraint];
        [self addTopLabelConstraint];
        [self addWarningLabelConstraint];
    }
}

- (void)addAlbumButtonConstraint{
    CGFloat frameWidth = SCREEN_WIDTH * 2 / 3;
    
    _albumButton = [[UIButton alloc]init];
    _albumButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:15];
    //attribute
    NSString *str = @"您可在Zplay Ads广告平台获得二维码或者前往相册选择二维码";
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:str];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, str.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(25, 2)];
    [_albumButton setAttributedTitle:attrStr forState:UIControlStateNormal];
    
    _albumButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _albumButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [_albumButton addTarget:self action:@selector(pickImage) forControlEvents:UIControlEventTouchUpInside];
    [_albumButton setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_albumButton];
    
    [_albumButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[_albumButton(==%f)]", 60.0]
                                                                      options:0
                                                                      metrics:0
                                                                        views:@{@"_albumButton":_albumButton}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[_albumButton(==%f)]", frameWidth]
                                                                      options:0
                                                                      metrics:0
                                                                        views:@{@"_albumButton":_albumButton}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_albumButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_viewPreview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_albumButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_viewPreview
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:frameWidth/2 + 30]];
}

- (void)addBottomLabelConstraint{
    _bottomLabel = [[UILabel alloc]init];
    _bottomLabel.text = @"© 2010 ～ 2017 Power By Zplay Ads";
    _bottomLabel.font = [UIFont fontWithName:@"Arial" size:12];
    _bottomLabel.textColor = [UIColor whiteColor];
    _bottomLabel.textAlignment = NSTextAlignmentCenter;
    _bottomLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:_bottomLabel];
    
    [_bottomLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[_bottomLabel(==%f)]", 30.0]
                                                                      options:0
                                                                      metrics:0
                                                                        views:@{@"_bottomLabel":_bottomLabel}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[_bottomLabel(==%f)]", SCREEN_WIDTH]
                                                                      options:0
                                                                      metrics:0
                                                                        views:@{@"_bottomLabel":_bottomLabel}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomLabel
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
}

- (void)addTopLabelConstraint{
    _topLabel = [[UILabel alloc]init];
    _topLabel.text = @"Zplay Ads 可玩广告";
    _topLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    _topLabel.textColor = [UIColor whiteColor];
    _topLabel.textAlignment = NSTextAlignmentCenter;
    _topLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:_topLabel];
    
    [_topLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[_topLabel(==%f)]", 60.0]
                                                                      options:0
                                                                      metrics:0
                                                                        views:@{@"_topLabel":_topLabel}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[_topLabel(==%f)]", SCREEN_WIDTH]
                                                                      options:0
                                                                      metrics:0
                                                                        views:@{@"_topLabel":_topLabel}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_topLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_topLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)addWarningLabelConstraint{
    CGFloat frameWidth = SCREEN_WIDTH * 2 / 3;
    
    _warningLabel = [[UILabel alloc]init];
    _warningLabel.text = @"将二维码／条码放入框内，即可自动扫描";
    _warningLabel.numberOfLines = 0;
    _warningLabel.font = [UIFont fontWithName:@"Arial" size:15];
    _warningLabel.textColor = [UIColor whiteColor];
    _warningLabel.textAlignment = NSTextAlignmentCenter;
    _warningLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_warningLabel];
    
    [_warningLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[_warningLabel(==%f)]", frameWidth]
                                                                      options:0
                                                                      metrics:0
                                                                        views:@{@"_warningLabel":_warningLabel}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_warningLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_viewPreview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_warningLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_viewPreview
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:-(frameWidth/2)-17]];
    [_warningLabel sizeToFit];
}

- (void)cancel{
    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (void)pickImage{
    [self presentViewController:_imagePicker animated:YES completion:NULL];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:NO completion:NULL];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:context
                                              options:@{CIDetectorAccuracy:CIDetectorAccuracyLow}];
    CIImage *cgImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:cgImage];
    CIQRCodeFeature *feature = [features firstObject];
    
    NSString *result = feature.messageString;
    if (_completion) {
        _completion(result != nil, result);
    }
    [self dealWithResult:result];
    [self cancel];
}

- (void)start {
    [self startReading];
}

- (void)stop {
    [self stopReading];
}

- (void)dealWithResult:(NSString *)result {
    
}

#pragma mark - Private method implementation

- (void)startReading {
    if (!_isReading) {
        NSError *error;
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        
        if (input) {
            _captureSession = [[AVCaptureSession alloc] init];
            [_captureSession addInput:input];
            
            AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
            [_captureSession addOutput:captureMetadataOutput];
            
            dispatch_queue_t dispatchQueue;
            dispatchQueue = dispatch_queue_create("myQueue", NULL);
            [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
            [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
            
            _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
            [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
            [_viewPreview.layer addSublayer:_videoPreviewLayer];
            
            // Start video capture.
            [_captureSession startRunning];
            _isReading = !_isReading;
        } else {
            NSLog(@"%@", [error localizedDescription]);
            return;
        }
    }
}

- (void)stopReading {
    if (_isReading) {
        [_captureSession stopRunning];
        _captureSession = nil;
        
        [_videoPreviewLayer removeFromSuperlayer];
        _isReading = !_isReading;
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            void(^block)() = ^(void) {
                [self stopReading];
                [self cancel];
                if (![metadataObj stringValue] || [[metadataObj stringValue] length] == 0) {
                    if (_completion) {
                        _completion(NO, nil);
                    }
                    [self dealWithResult:nil];
                } else {
                    if (_completion) {
                        _completion(YES, [metadataObj stringValue]);
                    }
                    [self dealWithResult:[metadataObj stringValue]];
                }
            };
            
            if ([NSThread isMainThread]) {
                block();
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    block();
                });
            }
        }
    }
}

#pragma mark - 生成条形码以及二维码

// 参考文档
// https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html

- (UIImage *)generateQRCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height {
    
    // 生成二维码图片
    CIImage *qrcodeImage;
    NSData *data = [code dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:false];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    qrcodeImage = [filter outputImage];
    
    // 消除模糊
    CGFloat scaleX = width / qrcodeImage.extent.size.width; // extent 返回图片的frame
    CGFloat scaleY = height / qrcodeImage.extent.size.height;
    CIImage *transformedImage = [qrcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:transformedImage];
}

- (UIImage *)generateBarCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height {
    // 生成二维码图片
    CIImage *barcodeImage;
    NSData *data = [code dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:false];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    
    [filter setValue:data forKey:@"inputMessage"];
    barcodeImage = [filter outputImage];
    
    // 消除模糊
    CGFloat scaleX = width / barcodeImage.extent.size.width; // extent 返回图片的frame
    CGFloat scaleY = height / barcodeImage.extent.size.height;
    CIImage *transformedImage = [barcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:transformedImage];
}
@end
