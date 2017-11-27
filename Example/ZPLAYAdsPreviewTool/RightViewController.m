//
//  RightViewController.m
//  ZPLAYAdsPreviewTool_Example
//
//  Created by lgd on 2017/11/26.
//  Copyright © 2017年 wzy2010416033@163.com. All rights reserved.
//

#import "RightViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface RightViewController () <UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIImageView *androidQRCodeImage;
@property (weak, nonatomic) IBOutlet UIImageView *iosQRCodeImage;
@property (weak, nonatomic) IBOutlet UILabel *paragraph23;

@property (weak, nonatomic) MBProgressHUD *hud;

@end

@implementation RightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableAttributedString *login = [[NSMutableAttributedString alloc] initWithAttributedString:_loginLabel.attributedText];
    [login addAttribute:NSKernAttributeName value:@(1.5f) range: [_loginLabel.text rangeOfString:_loginLabel.text]];
    _loginLabel.attributedText = login;
    
    NSMutableAttributedString *paragraph = [[NSMutableAttributedString alloc] initWithAttributedString:_paragraph23.attributedText];
    [paragraph addAttribute:NSKernAttributeName value:@(1.5) range:[_paragraph23.text rangeOfString:_paragraph23.text]];
    _paragraph23.attributedText = paragraph;
}

- (IBAction)androidQRCTapped:(UITapGestureRecognizer *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存图片" message:@"将Android示例二维码保存至相册" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"保存" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        // todo: save picture
        [self savePicture:_androidQRCodeImage.image];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        // nothing to do, just dismiss the dialog
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)iosQRCTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存图片" message:@"将iOS示例二维码保存至相册" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"保存" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        // todo: save picture
        [self savePicture: _iosQRCodeImage.image];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        // nothing to do, just dismiss the dialog
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) savePicture: (UIImage *) image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:),nil);
    self.hud.label.text = @"正在保存...";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.hidden = NO;
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    self.hud.mode = MBProgressHUDModeText;
    if (error == nil) {
        self.hud.label.text = @"已保存";
    }else{
        self.hud.label.text = @"失败";
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hud.hidden = YES;
    });
}


- (IBAction)gotoLogin:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.zplayads.com"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        UIView *view = self.view;
        _hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    return _hud;
}

@end
