

#import "LWImageUtil.h"

@implementation LWImageUtil


+ (UIImage *)imageWithColor:(UIColor *)color andBounds:(CGRect)bounds{
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, bounds);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (NSData *)imageFromView:(UIView *)view{
    UIGraphicsBeginImageContext(view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *screenshotData = UIImagePNGRepresentation(theImage);
    return screenshotData;
}

@end
