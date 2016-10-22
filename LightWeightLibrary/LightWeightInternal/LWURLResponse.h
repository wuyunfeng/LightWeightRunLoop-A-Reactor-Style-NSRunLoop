/********************************************************************
 * (C) wuyunfeng 2015-2016
 *
 * The project is available from https://github.com/wuyunfeng/LightWeightRunLoop-A-Reactor-Style-NSRunLoop
 *
 * The code is intended as a illustration of the NSRunLoopp Foundation at work and
 * is not suitable for use in production code (some error handling has been strongly
 * simplified).
 *
 ********************************************************************/

#import <Foundation/Foundation.h>

@interface LWURLResponse : NSObject


@property (readonly, strong, nullable) NSData *responseData;

@property (readonly ,strong, nullable) NSString *responseBody;

@property (readonly) NSInteger statusCode;

@property (readonly, nullable) NSString *statusMsg;

@property (readonly, strong, nullable) NSDictionary *allHeaderFields;

//may have bug
- (instancetype _Nullable)initWithData:(NSData * _Nullable)data;


@end
