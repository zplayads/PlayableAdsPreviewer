//
//  LeftViewController.m
//  ZPLAYAdsPreviewTool_Example
//
//  Created by lgd on 2017/11/24.
//  Copyright © 2017年 wzy2010416033@163.com. All rights reserved.
//

#import "LeftViewController.h"

@interface LeftViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *clickLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([@"zh-Hans-CN" isEqualToString: [self systemLanguage]]) {
        NSMutableAttributedString *label = [[NSMutableAttributedString alloc] initWithAttributedString:_clickLabel.attributedText];
        [label addAttribute:NSKernAttributeName value:@(1.5f) range:[_clickLabel.text rangeOfString:_clickLabel.text]];
        _clickLabel.attributedText = label;
        
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithAttributedString:_messageLabel.attributedText];
        [message addAttribute:NSKernAttributeName value:@(1.5f) range: [_messageLabel.text rangeOfString:_messageLabel.text]];
        _messageLabel.attributedText = message;
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
- (IBAction)gotoDetail:(id)sender {
//     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"官网连接", nil)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) systemLanguage {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    return allLanguages[0];
}

@end
