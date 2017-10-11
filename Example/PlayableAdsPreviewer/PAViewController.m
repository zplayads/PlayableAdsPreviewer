//
//  PAViewController.m
//  PlayableAdsPreviewer
//
//  Created by wzy2010416033@163.com on 09/29/2017.
//  Copyright (c) 2017 wzy2010416033@163.com. All rights reserved.
//

#import "PAViewController.h"
#import "QRCodeReaderViewController.h"
#import <TSMessages/TSMessage.h>
#import <PlayableAdsPreviewer/PlayableAdsPreviewer.h>

@interface PAViewController ()<QRCodeReaderDelegate>

@property (weak, nonatomic) IBOutlet UITextField *appIDText;
@property (weak, nonatomic) IBOutlet UITextField *URLText;

@property (nonatomic) PlayableAdsPreviewer *previewer;

@end

@implementation PAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appIDText.text = @"CABFFBFF-C5D6-D9B0-8A5C-60417538FC51";
}

- (IBAction)scanButtonDidPress:(id)sender {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *vc = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            vc                   = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        vc.delegate = self;
        
        [vc setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];
        
        [self presentViewController:vc animated:YES completion:NULL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

- (IBAction)requestButtonDidPress:(id)sender {
    if (!self.appIDText.text.length) {
        [TSMessage showNotificationInViewController:self
                                              title:@"Error"
                                           subtitle:@"Ad Unit ID and App ID should not be empty"
                                              image:nil
                                               type:TSMessageNotificationTypeWarning
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionTop
                               canBeDismissedByUser:YES];
        return;
    }
    [self requestAd];
}

- (void)requestAd{
    [self.previewer presentFromRootViewController:self withAdID:self.appIDText.text success:^{
    } dismiss:^{
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

- (IBAction)staticAdButtonDidPress:(id)sender {
    [self.previewer presentFromRootViewController:self withURL:self.URLText.text success:^{
    } dismiss:^{
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark - QRCodeReader Delegate Methods
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    self.appIDText.text = result;
    
    [reader stopScanning];
    [reader dismissViewControllerAnimated:YES completion:^{
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
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [reader dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - lazyLoad
- (PlayableAdsPreviewer *)previewer{
    if (!_previewer) {
        _previewer = [[PlayableAdsPreviewer alloc]init];
    }
    return _previewer;
}

@end
