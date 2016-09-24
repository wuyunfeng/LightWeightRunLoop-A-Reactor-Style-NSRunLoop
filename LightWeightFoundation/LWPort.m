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
    LWPort *_receivePort;
    LWPort *_sendPort;
}

- (NSArray *)components
{
    return _components;
}

- (LWPort *)receivePort
{
    return _receivePort;
}

- (LWPort *)sendPort
{
    return _sendPort;
}

- (BOOL)sendBeforeDate:(NSInteger)delay
{
    return YES;
}

- (void)internalSendBeforDate:(NSInteger)delay
{
    
}

//only support LWSocketPort, nil returned for other LWPort
- (_Nullable instancetype)initWithSendPort:(nullable LWPort *)sendPort receivePort:(nullable LWPort *)replyPort components:(nullable NSArray *)components
{
    if ([sendPort isMemberOfClass:[LWSocketPort class]]
        && [replyPort isMemberOfClass:[LWSocketPort class]]) {
        _sendPort = sendPort;
        _receivePort = replyPort;
        _components = components;
    }
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
    LWSocketPortRoleType _roleType;
    
    LWPortContext _context;
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
            _roleType = LWSocketPortRoleTypeFollower;//follower
        } else {
            return NO;
        }
    }
    _roleType = LWSocketPortRoleTypeLeader;//leader
    
    if (_roleType == LWSocketPortRoleTypeLeader) {
        int option = 1;
        setsockopt(_sockFd, SOL_SOCKET, SO_REUSEADDR, &option, sizeof(option));
        if (listen(_sockFd, 5) == -1) {
            return NO;
        }
    } else {
        //we can ignore the `connect` delay for the local TCP connect
        if (-1 == connect(_sockFd, (struct sockaddr *)&sockAddr, sizeof(sockAddr))) {
            return NO;
        }
    }    
    _context.info = (__bridge void * _Nullable)(self);
    _context.LWPortReceiveDataCallBack = PortBasedReceiveDataRoutine;
    return YES;
}

- (void)notify:(NSData *)data
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
    if ([self.delegate respondsToSelector:@selector(handleMachMessage:)]) {
        [self.delegate handlePortMessage:nil];
    }
}

- (LWPortContext)context
{
    return _context;
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

void PortBasedReceiveDataRoutine(int fd, void * _Nullable info, void * _Nullable data, int length)
{
    LWSocketPort *port = (__bridge LWSocketPort *)(info);
    NSData *receiveData = [[NSData alloc] initWithBytes:data length:length];
    [port notify:receiveData];
}

@end


