//
//  QRPhotoAlbumButton.m
//  Pods
//
//  Created by 王泽永 on 2017/9/29.
//

#import "QRPhotoAlbumButton.h"

@implementation QRPhotoAlbumButton

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _edgeColor            = [UIColor whiteColor];
        _fillColor            = [UIColor darkGrayColor];
        _edgeHighlightedColor = [UIColor whiteColor];
        _fillHighlightedColor = [UIColor blackColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{

}

// MARK: - UIResponder Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    [self setNeedsDisplay];
}

@end
