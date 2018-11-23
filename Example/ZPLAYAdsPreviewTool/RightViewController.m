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
@property (weak, nonatomic) IBOutlet UIImageView *iosQRCodeImage;
@property (weak, nonatomic) IBOutlet UILabel *paragraph23;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (weak, nonatomic) MBProgressHUD *hud;

@end

@implementation RightViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([@"zh-Hans-CN" isEqualToString: [self systemLanguage]]) {
        NSMutableAttributedString *login = [[NSMutableAttributedString alloc] initWithAttributedString:_loginLabel.attributedText];
        [login addAttribute:NSKernAttributeName value:@(1.5f) range: [_loginLabel.text rangeOfString:_loginLabel.text]];
        _loginLabel.attributedText = login;
        
        NSMutableAttributedString *paragraph = [[NSMutableAttributedString alloc] initWithAttributedString:_paragraph23.attributedText];
        [paragraph addAttribute:NSKernAttributeName value:@(1.5) range:[_paragraph23.text rangeOfString:_paragraph23.text]];
        _paragraph23.attributedText = paragraph;
    }
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 200, 40)];
    tlabel.text = self.navigationItem.title;
    tlabel.textAlignment = NSTextAlignmentCenter;
    tlabel.textColor=[UIColor blackColor];
    tlabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 17.0];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
}

- (IBAction)iosQRCTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"保存图片", nil) message:NSLocalizedString(@"将示例二维码保存至相册", nil) preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"保存", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        // todo: save picture
        [self savePicture: _iosQRCodeImage.image];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        // nothing to do, just dismiss the dialog
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) savePicture: (UIImage *) image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:),nil);
    self.hud.label.text = NSLocalizedString(@"正在保存...", nil);
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.hidden = NO;
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    self.hud.mode = MBProgressHUDModeText;
    if (error == nil) {
        self.hud.label.text = NSLocalizedString(@"已保存", nil);
    }else{
        self.hud.label.text = NSLocalizedString(@"失败", nil);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hud.hidden = YES;
    });
}


- (IBAction)gotoLogin:(id)sender {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"官网连接", nil)]];
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

- (NSString *) systemLanguage {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    return allLanguages[0];
}

@end
