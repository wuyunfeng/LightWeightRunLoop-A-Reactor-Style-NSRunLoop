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

#import "TestTarget2.h"

@implementation TestTarget2

- (void)performTest
{
    NSLog(@"* [ Object: %@ performSelector: ( %@ ) on Thread : %@ ] *", [self class], NSStringFromSelector(_cmd), [NSThread currentThread].name);
}


- (void)dealloc
{
//    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

@end
