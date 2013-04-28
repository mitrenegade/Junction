//
//  UIImage+GaussianBlur.m
//  Junction
//
//  Created by Bobby Ren on 12/25/12.
//
//

#import "UIImage+GaussianBlur.h"
#define REMOVE_BORDERS 0

@implementation UIImage (ImageBlur)

- (UIImage *)imageWithGaussianBlur {
    float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
    // Blur horizontally
    CGSize sizeWithBorders = self.size;
#if REMOVE_BORDERS
    int borderWidth = 50; //self.size.width * .25;
    int borderHeight = 50; //self.size.width * .25;
#else
    int borderWidth = 0; //self.size.width * .25;
    int borderHeight = 0; //self.size.width * .25;
#endif
    sizeWithBorders.width += 2*borderWidth;
    sizeWithBorders.height += 2*borderHeight;
    UIGraphicsBeginImageContext(sizeWithBorders);
    [self drawInRect:CGRectMake(borderWidth, borderHeight, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int x = 1; x < 5; ++x) {
        [self drawInRect:CGRectMake(borderWidth + x*10, borderHeight + 0, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
        [self drawInRect:CGRectMake(borderWidth - x*10, borderHeight + 0, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
    }
    UIImage *horizBlurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
#if REMOVE_BORDERS
    // remove added borders
    UIGraphicsBeginImageContext(self.size);
    [horizBlurredImage drawInRect:CGRectMake(-borderWidth, -borderHeight, sizeWithBorders.width, sizeWithBorders.height)];
    horizBlurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#endif
    
    // Blur vertically
    //UIGraphicsBeginImageContext(self.size);
    UIGraphicsBeginImageContext(sizeWithBorders);
    [horizBlurredImage drawInRect:CGRectMake(borderWidth, borderHeight, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int y = 1; y < 5; ++y) {
        [horizBlurredImage drawInRect:CGRectMake(borderWidth + 0, borderHeight + y, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
        [horizBlurredImage drawInRect:CGRectMake(borderWidth + 0, borderHeight - y, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
    }
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#if REMOVE_BORDERS
    // remove added borders
    UIGraphicsBeginImageContext(self.size);
    [finalImage drawInRect:CGRectMake(-borderWidth, -borderHeight, sizeWithBorders.width, sizeWithBorders.height)];
    finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#endif
    return finalImage;
}

@end