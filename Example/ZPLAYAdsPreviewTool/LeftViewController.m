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

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableAttributedString *label = [[NSMutableAttributedString alloc] initWithAttributedString:_clickLabel.attributedText];
    [label addAttribute:NSKernAttributeName value:@(1.5f) range:[_clickLabel.text rangeOfString:_clickLabel.text]];
    _clickLabel.attributedText = label;
    
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithAttributedString:_messageLabel.attributedText];
    [message addAttribute:NSKernAttributeName value:@(1.5f) range: [_messageLabel.text rangeOfString:_messageLabel.text]];
    _messageLabel.attributedText = message;
    
}
- (IBAction)gotoDetail:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.zplayads.com"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
