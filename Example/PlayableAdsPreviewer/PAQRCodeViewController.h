//
//  PAQRCodeViewController.h
//  PlayableAdsPreviewer_Example
//
//  Created by 王泽永 on 2017/10/11.
//  Copyright © 2017年 wzy2010416033@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAQRCodeViewController : UIViewController

- (id)initWithCompletion:(void(^)(BOOL succeeded, NSString * result))completion;

- (void)start;
- (void)stop;
- (void)cancel;

@end
