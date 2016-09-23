//
//  LWPort.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 16/8/28.
//  Copyright © 2016年 com.wuyunfeng.open. All rights reserved.
//

#import "LWPort.h"
#import <sys/socket.h>
#import <netinet/in.h>

@implementation LWPort
{
    BOOL _isValid;
}

+ (LWPort * _Nullable)port
{
    LWPort *instance = [[LWPort alloc] init];
    return instance;
}

- (void)invalidate
{
    _isValid = NO;
}

- (BOOL)isValid
{
    return _isValid;
}

- (void)scheduleInRunLoop:(LWRunLoop * _Nonnull)runLoop forMode:(LWRunLoop * _Nonnull)mode
{
    NSAssert(false, @"Must be implemented in subclass");
}

- (void)removeFromRunLoop:(LWRunLoop * _Nonnull)runLoop forMode:(LWRunLoop * _Nonnull)mode
{
    NSAssert(false, @"Must be implemented in subclass");
}

@end

@implementation LWPortMessage
{
    NSArray *_components;
    NSPort *_receivePort;
    NSPort *_sendPort;
}

- (NSArray *)components
{
    return _components;
}

- (NSPort *)receivePort
{
    return _receivePort;
}

- (NSPort *)sendPort
{
    return _sendPort;
}

- (BOOL)sendBeforeDate:(NSInteger)delay
{
    return YES;
}

- (_Nullable instancetype)initWithSendPort:(nullable NSPort *)sendPort receivePort:(nullable NSPort *)replyPort components:(nullable NSArray *)components
{
    
    return nil;
}

@end


@implementation LWSocketPort
{
    int _potocolFamily;
    int _socketType;
    int _protocol;
    
    NSString *_ipStr;
    unsigned short _port;
    
    int _sockFd;
    
    NSData *_address;
    
    //Leader-Follower Flag
    int _flag;
}

- (nullable instancetype)initWithTCPPort:(unsigned short)port
{
    if (self = [super init]) {
        _port = port;
        if (![self initInternal]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)initInternal
{
    if ((_sockFd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        return NO;
    }
    
    struct sockaddr_in sockAddr;
    memset(&sockAddr, 0, sizeof(sockAddr));
    sockAddr.sin_family = AF_INET;
    sockAddr.sin_addr.s_addr = htonl(INADDR_ANY);
    sockAddr.sin_port = htons(_port);
    if (-1 == bind(_sockFd, (struct sockaddr *)&sockAddr, sizeof(sockAddr))) {
        //socket is already bound to an address and the protocol does not support binding to a new address
        if (EINVAL == errno) {
            _flag = 1;//follower
        } else {
            return NO;
        }
    }
    _flag = 0;//leader
    
    if (_flag == 0) {
        if (listen(_sockFd, 5) == -1) {
            return NO;
        }
    } else {
        //we can ignore the `connect` delay for the local TCP connect
        if (-1 == connect(_sockFd, (struct sockaddr *)&sockAddr, sizeof(sockAddr))) {
            return NO;
        }
    }
    
    [self makeSocketNonBlocking:_sockFd];
    return YES;
}


- (BOOL)makeSocketNonBlocking:(int)fd
{
    int flags;
    if ((flags = fcntl(fd, F_GETFL, NULL)) < 0) {
        return NO;
    }
    if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) == -1) {
        return NO;
    }
    return YES;
}

- (int)socket
{
    return _sockFd;
}

- (int)protocolFamily
{
    return _protocol;
}

- (int)protocol
{
    return _protocol;
}

- (int)socketType
{
    return _socketType;
}


@end


