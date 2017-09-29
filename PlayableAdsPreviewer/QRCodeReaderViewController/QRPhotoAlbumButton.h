//
//  QRPhotoAlbumButton.h
//  Pods
//
//  Created by 王泽永 on 2017/9/29.
//

#import <UIKit/UIKit.h>

@interface QRPhotoAlbumButton : UIButton

/** @name Managing Properties */

/**
 * @abstract The edge color of the drawing.
 * @discussion The default color is the white.
 * @since 2.0.0
 */
@property (nonatomic, strong) UIColor *edgeColor;

/**
 * @abstract The fill color of the drawing.
 * @discussion The default color is the darkgray.
 * @since 2.0.0
 */
@property (nonatomic, strong) UIColor *fillColor;

/**
 * @abstract The edge color of the drawing when the button is touched.
 * @discussion The default color is the white.
 * @since 2.0.0
 */
@property (nonatomic, strong) UIColor *edgeHighlightedColor;

/**
 * @abstract The fill color of the drawing when the button is touched.
 * @discussion The default color is the black.
 * @since 2.0.0
 */
@property (nonatomic, strong) UIColor *fillHighlightedColor;

@end
