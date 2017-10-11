//
//  PAQRCodeViewController.m
//  PlayableAdsPreviewer_Example
//
//  Created by 王泽永 on 2017/10/11.
//  Copyright © 2017年 wzy2010416033@163.com. All rights reserved.
//

#import "PAQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

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
                            [weakSelf cancel];
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
       
        _albumButton = [[UIButton alloc]init];
        _albumButton.titleLabel.text = @"Album";
        [_albumButton addTarget:self action:@selector(pickImage) forControlEvents:UIControlEventAllEvents];
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
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Zplay Ads 可玩广告";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
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
                                                               constant:50.0]];
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
    }
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
                                              options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
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
            [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
            
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

@end
