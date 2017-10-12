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

@interface PAViewController ()

@property (nonatomic) NSString *appID;
@property (nonatomic) PlayableAdsPreviewer *previewer;
@property (nonatomic) PAQRCodeViewController *qrVC;
@property (weak, nonatomic) IBOutlet UIImageView *QRImage;
@property (nonatomic, assign) BOOL isShow;

@end

@implementation PAViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    if (!_isShow) {
        [self startScan];
        _isShow = YES;
    }
}

- (void)startScan{
    self.qrVC = [[PAQRCodeViewController alloc] initWithCompletion:^(BOOL succeeded, NSString *result) {
        if (succeeded) {
            self.appID = result;
            [TSMessage showNotificationInViewController:self
                                                  title:@"Successed"
                                               subtitle:result
                                                  image:nil
                                                   type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic
                                               callback:nil
                                            buttonTitle:nil
                                         buttonCallback:nil
                                             atPosition:TSMessageNotificationPositionTop
                                   canBeDismissedByUser:YES];
            [self requestAd];
        } else {
            [TSMessage showNotificationInViewController:self
                                                  title:@"Error"
                                               subtitle:result
                                                  image:nil
                                                   type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                               callback:nil
                                            buttonTitle:nil
                                         buttonCallback:nil
                                             atPosition:TSMessageNotificationPositionTop
                                   canBeDismissedByUser:YES];
        }
    }];
    [self presentViewController:self.qrVC animated:NO completion:NULL];
}

- (void)requestAd {
    [self.previewer presentFromRootViewController:self
        withAdID:self.appID
        success:^{
            [self.qrVC stop];
            [self.qrVC cancel];
        }
        dismiss:^{
            [self startScan];
        }
        failure:^(NSError *_Nonnull error) {
            [self startScan];
            [TSMessage showNotificationInViewController:self
                                                  title:@"Error"
                                               subtitle:nil
                                                  image:nil
                                                   type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                               callback:nil
                                            buttonTitle:nil
                                         buttonCallback:nil
                                             atPosition:TSMessageNotificationPositionTop
                                   canBeDismissedByUser:YES];
        }];
}

- (void)createQRCodeImage{
    UIImage *image = [[[PAQRCodeViewController alloc]init] generateQRCode:@"CABFFBFF-C5D6-D9B0-8A5C-60417538FC51" width:200.0 height:200.0];
    self.QRImage.image = image;
}

- (PlayableAdsPreviewer *)previewer{
    if (!_previewer) {
        _previewer = [[PlayableAdsPreviewer alloc]init];
    }
    return _previewer;
}

@end
