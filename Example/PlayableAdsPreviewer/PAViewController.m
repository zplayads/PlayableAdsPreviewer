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

@end

@implementation PAViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startScan];
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
    [self presentViewController:self.qrVC animated:YES completion:NULL];
}

- (void)requestAd {
    [self.previewer presentFromRootViewController:self
        withAdID:self.appID
        success:^{
            [self.qrVC stop];
        }
        dismiss:^{
            [self startScan];
        }
        failure:^(NSError *_Nonnull error) {
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

@end
