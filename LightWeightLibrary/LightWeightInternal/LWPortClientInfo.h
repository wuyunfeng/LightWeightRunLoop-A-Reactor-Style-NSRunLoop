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

@interface LWPortClientInfo : NSObject

@property (assign) ushort port;
//unuse, for future
@property (nonatomic, nullable) NSString *ip;
@property (assign) int fd;

@property (nullable) NSData *cacheSend;

@end
