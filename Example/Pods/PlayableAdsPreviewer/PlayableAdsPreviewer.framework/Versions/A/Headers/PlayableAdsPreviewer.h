//
//  PlayableAdsPreviewer.h
//  Pods
//
//  Created by d on 18/8/2017.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayableAdsPreviewer : NSObject

- (void)presentFromRootViewController:(UIViewController *)rootViewController
                             withAdID:(NSString *)adID
                              success:(void (^)(void))success
                              dismiss:(void (^)(void))dismiss
                              failure:(void (^)(NSError *error))failure;

- (void)presentFromRootViewController:(UIViewController *)rootViewController
                              withURL:(NSString *)url
                          isLandscape:(BOOL)isLandscape
                             itunesID:(NSNumber *)itunesID
                              success:(void (^)(void))success
                              dismiss:(void (^)(void))dismiss
                              failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
