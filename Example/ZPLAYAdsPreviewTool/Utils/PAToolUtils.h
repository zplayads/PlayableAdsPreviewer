//
//  PAToolUtils.h
//  ZPLAYAdsPreviewTool
//
//  Created by Michael Tang on 2018/11/13.
//  Copyright © 2018 wzy2010416033@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PAToolUtils : NSObject

+ (instancetype)shareToolUtils;

- (void)deletePlayableAdsSDKCache;

@end

NS_ASSUME_NONNULL_END
