//
//  PAViewController.m
//  PlayableAdsPreviewer
//
//  Created by wzy2010416033@163.com on 09/29/2017.
//  Copyright (c) 2017 wzy2010416033@163.com. All rights reserved.
//

#import "PAViewController.h"

@interface PAViewController ()

@property (weak, nonatomic) IBOutlet UITextField *appIDText;
@property (weak, nonatomic) IBOutlet UITextField *unitIDText;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIButton *requestButton;
@property (weak, nonatomic) IBOutlet UIButton *presentButton;
@property (weak, nonatomic) IBOutlet UIButton *staticAdButton;

@end

@implementation PAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpUI];
	
}

- (void)setUpUI{
    
    self.presentButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
