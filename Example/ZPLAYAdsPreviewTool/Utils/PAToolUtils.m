//
//  PAToolUtils.m
//  ZPLAYAdsPreviewTool
//
//  Created by Michael Tang on 2018/11/13.
//  Copyright © 2018 wzy2010416033@163.com. All rights reserved.
//

#import "PAToolUtils.h"

#define SYSTEM_VERSION_LESS_THAN(v)                                                                                    \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation PAToolUtils

+ (instancetype)shareToolUtils{
    static PAToolUtils *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (NSURL *)baseDirectoryURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cacheDirectoryURL = [fileManager URLForDirectory:NSCachesDirectory
                                                   inDomain:NSUserDomainMask
                                          appropriateForURL:nil
                                                     create:NO
                                                      error:nil];
    // 10.0以下使用tmp的目录做缓存，因为WKWebview在10.0以下只能加载tmp的资源
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        cacheDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    }
    
    return [cacheDirectoryURL URLByAppendingPathComponent:@"PlayableAdsCache" isDirectory:YES];
}

- (void)deletePlayableAdsSDKCache{
    NSURL *directoryURL = [self baseDirectoryURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryURL.path]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:directoryURL.path error:&error];
        if (error) {
            NSLog(@"delete sdk cache fail, error is: %@",error);
        }
        
    }
}

@end
