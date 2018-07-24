//
//  PAViewController.m
//  PlayableAdsPreviewer
//
//  Created by wzy2010416033@163.com on 09/29/2017.
//  Copyright (c) 2017 wzy2010416033@163.com. All rights reserved.
//

#import "PAViewController.h"
#import <PlayableAdsPreviewer/PlayableAdsPreviewer.h>
#import <TSMessages/TSMessage.h>
#import "PAQRCodeViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface PAViewController () <QRCodeDelegate>

@property (nonatomic) NSString *appID;
@property (nonatomic) PlayableAdsPreviewer *previewer;
@property (nonatomic) PAQRCodeViewController *qrVC;
@property (weak, nonatomic) IBOutlet UIImageView *QRImage;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic) MBProgressHUD *hud;
@property (nonatomic) int count;

@end

@implementation PAViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self addObserver];
    if (!_isShow) {
        [self startScan];
//        [self createQRCodeImage];
        _isShow = YES;
    }
}

- (void)startScan{
    __weak typeof(self) weakSelf = self;
    self.qrVC = [[PAQRCodeViewController alloc] initWithCompletion:^(BOOL succeeded, NSString *result) {
        if (succeeded) {
            weakSelf.appID = result;
            
            self.hud.label.text = NSLocalizedString(@"正在加载中...", nil);
            self.hud.hidden = NO;
            
            [TSMessage showNotificationInViewController:weakSelf
                                                  title:@"Successed"
                                               subtitle:NSLocalizedString(@"二维码解析成功", nil)
                                                  image:nil
                                                   type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic
                                               callback:nil
                                            buttonTitle:nil
                                         buttonCallback:nil
                                             atPosition:TSMessageNotificationPositionTop
                                   canBeDismissedByUser:YES];
            [weakSelf requestAd];
        } else {
            [TSMessage showNotificationInViewController:weakSelf
                                                  title:@"Error"
                                               subtitle:NSLocalizedString(@"解析二维码失败", nil)
                                                  image:nil
                                                   type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                               callback:nil
                                            buttonTitle:nil
                                         buttonCallback:nil
                                             atPosition:TSMessageNotificationPositionTop
                                   canBeDismissedByUser:YES];
            
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*NSEC_PER_SEC));
            dispatch_queue_t queue = dispatch_get_main_queue();
            dispatch_after(time, queue, ^{
                weakSelf.qrVC = nil;
                [weakSelf startScan];
            });
        }
    }];
    _qrVC.delegate = self;
    [self presentViewController:self.qrVC animated:NO completion:nil];
}

- (void)requestAd {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.previewer presentFromRootViewController:self
                                             withAdID:self.appID
                                              success:^{
                                                  weakSelf.qrVC = nil;
                                                  [weakSelf.qrVC cancel];
                                                  weakSelf.hud.hidden = YES;
                                              }
                                              dismiss:^{
                                                  [weakSelf startScan];
                                              }
                                              failure:^(NSError *_Nonnull error) {
                                                  [TSMessage showNotificationInViewController:weakSelf
                                                                                        title:@"Error"
                                                                                     subtitle:NSLocalizedString(@"广告加载失败", nil)
                                                                                        image:nil
                                                                                         type:TSMessageNotificationTypeError
                                                                                     duration:TSMessageNotificationDurationEndless
                                                                                     callback:nil
                                                                                  buttonTitle:nil
                                                                               buttonCallback:nil
                                                                                   atPosition:TSMessageNotificationPositionTop
                                                                         canBeDismissedByUser:YES];
                                                  [TSMessage dismissActiveNotificationWithCompletion:^{
                                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                                                                     dispatch_get_main_queue(), ^{
                                                                         weakSelf.qrVC = nil;
                                                                         [weakSelf startScan];
                                                                     });
                                                  }];
                                              }];
    });
}

- (void)closeQRViewController {
    [self.presentingViewController dismissViewControllerAnimated:NO completion: nil];
}

- (void)createQRCodeImage{
    UIImage *image = [[[PAQRCodeViewController alloc]init] generateQRCode:@"CABFFBFF-C5D6-D9B0-8A5C-60417538FC51" width:200.0 height:200.0];
    self.QRImage.image = image;
}

- (void)addObserver{
    [[NSNotificationCenter defaultCenter]addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self startScan];
    }];
}

- (PlayableAdsPreviewer *)previewer{
    if (!_previewer) {
        _previewer = [[PlayableAdsPreviewer alloc]init];
    }
    return _previewer;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        UIView *view = self.view;
        _hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
    }
    return _hud;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
@end
