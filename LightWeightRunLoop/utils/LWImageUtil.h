


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LWImageUtil : NSObject

+ (UIImage *)imageWithColor:(UIColor *)color andBounds:(CGRect)bounds;

+ (NSData *)imageFromView:(UIView *)view;

@end
