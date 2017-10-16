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

@interface PAViewController ()

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
        _isShow = YES;
    }
}

- (void)startScan{
    __weak typeof(self) weakSelf = self;
    self.qrVC = [[PAQRCodeViewController alloc] initWithCompletion:^(BOOL succeeded, NSString *result) {
        if (succeeded) {
            weakSelf.appID = result;
            NSString *str = @"CABFFBFF-C5D6-D9B0-8A5C-60417538FC51";
            if (self.appID.length != str.length ) {
                [TSMessage showNotificationInViewController:weakSelf
                                                      title:@"Error"
                                                   subtitle:@"QRCode Error"
                                                      image:nil
                                                       type:TSMessageNotificationTypeError
                                                   duration:TSMessageNotificationDurationAutomatic
                                                   callback:nil
                                                buttonTitle:nil
                                             buttonCallback:nil
                                                 atPosition:TSMessageNotificationPositionTop
                                       canBeDismissedByUser:YES];
                [self.qrVC cancel];
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*NSEC_PER_SEC));
                dispatch_queue_t queue = dispatch_get_main_queue();
                dispatch_after(time, queue, ^{
                    weakSelf.qrVC = nil;
                    [weakSelf startScan];
                });
                return;
            }
            
            self.hud.label.text = @"Loading";
            self.hud.hidden = NO;
            
            [TSMessage showNotificationInViewController:weakSelf
                                                  title:@"Successed"
                                               subtitle:nil
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
                                               subtitle:@"QRCode Error"
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
                                                                                     subtitle:@"Load Error"
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
                                              }];
    });
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
