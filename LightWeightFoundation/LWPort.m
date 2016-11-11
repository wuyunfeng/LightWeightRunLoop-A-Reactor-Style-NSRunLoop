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

#import "LWPort.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "NSThread+Looper.h"


@interface LWPort()


@end


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

- (void)setValid:(BOOL)valid
{
    _isValid = valid;
}

@end

@implementation LWPortMessage
{
    NSData *_components;
    LWPort *_receivePort;
    LWPort *_sendPort;
}

- (NSData *)components
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
    [self internalSendBeforDate:delay];
    return YES;
}

- (void)internalSendBeforDate:(NSInteger)delay
{
    LWSocketPort *_sendSocketPort = (LWSocketPort *)_sendPort;
    LWSocketPort *_receiveSocketPort = (LWSocketPort *)_receivePort;
    LWRunLoop *runloop = [LWRunLoop currentLWRunLoop];
    //send `data` from `leader` to `follower`
    if (_sendSocketPort.roleType == LWSocketPortRoleTypeLeader) {
        short port = _receiveSocketPort.port;
        [runloop send:_components toPort:port];
    } else {//send `data` from `follower` to `leader`
        int fd = _sendSocketPort.socket;
        [runloop send:_components toFd:fd];
    }
}

//only support LWSocketPort, nil returned for other LWPort
- (instancetype)initWithSendPort:(LWPort *)sendPort receivePort:(LWPort *)replyPort components:(NSData *)components
{
    if ([sendPort isMemberOfClass:[LWSocketPort class]]
        && [replyPort isMemberOfClass:[LWSocketPort class]]) {
        _sendPort = sendPort;
        _receivePort = replyPort;
        _components = components;
    }
    return self;
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
    LWRunLoop *_runloop;
    NSString *_currentMode;
}

- (nullable instancetype)initWithTCPPort:(unsigned short)port
{
    if (self = [super init]) {
        if (![self initInternalWithTCPPort:port]) {
            return nil;
        }
    }
    return self;
}

- (ushort)port
{
    return _port;
}


- (BOOL)initInternalWithTCPPort:(unsigned short)port
{
    if ((_sockFd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        return NO;
    }
    _context.info = (__bridge void *)(self);
    _context.LWPortReceiveDataCallBack = PortBasedReceiveDataRoutine;
    struct sockaddr_in sockAddr;
    memset(&sockAddr, 0, sizeof(sockAddr));
    sockAddr.sin_family = AF_INET;
    sockAddr.sin_addr.s_addr = htonl(INADDR_ANY);
    sockAddr.sin_port = htons(port);
    _roleType = LWSocketPortRoleTypeLeader;//leader
    int option = 1;
    setsockopt(_sockFd, SOL_SOCKET, SO_REUSEADDR, &option, sizeof(option));
    
    //if bind failure, the _sockFd become follower, othrewise leader
    if (-1 == bind(_sockFd, (struct sockaddr *)&sockAddr, sizeof(sockAddr))) {
        _roleType = LWSocketPortRoleTypeFollower;//follower
    }
    
    if (_roleType == LWSocketPortRoleTypeLeader) {
        if (listen(_sockFd, 5) == -1) {
            return NO;
        }
        [self setValid:YES];
        _port = port;
    } else {
        //we can ignore the `connect` delay for the local TCP connect
        int flag = connect(_sockFd, (struct sockaddr *)&sockAddr, sizeof(sockAddr));
        if (-1 == flag) {
            return NO;
        }
        struct sockaddr_in name;
        socklen_t namelen = sizeof(name);
        getsockname(_sockFd, (struct sockaddr *)&name, &namelen);
        _port = name.sin_port;
        [self setValid:YES];
    }
    return YES;
}

- (void)notify:(NSData *)data
{
    if ([self.delegate respondsToSelector:@selector(handlePortMessage:)]) {
        [self.delegate handlePortMessage:data];
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

- (void)setType:(LWSocketPortRoleType)type
{
    _roleType = type;
}

- (void)dealloc
{
    close(_sockFd);
    [self setValid:NO];
}

- (NSString *)host
{
    return @"127.0.0.1";
}

// not implented at present
- (void)scheduleInRunLoop:(LWRunLoop * _Nonnull)runLoop forMode:(NSString * _Nonnull)mode
{
    _runloop = runLoop;
    _currentMode = mode;
}

// not implented at present
- (void)removeFromRunLoop:(LWRunLoop * _Nonnull)runLoop forMode:(NSString * _Nonnull)mode
{
    _runloop = nil;
    _currentMode = nil;
}

// ignore `fd` at present, but .... ^o^
void PortBasedReceiveDataRoutine(int fd, void * _Nullable info, void * _Nullable data, int length)
{
    LWSocketPort *port = (__bridge LWSocketPort *)(info);
    NSData *receiveData = [[NSData alloc] initWithBytes:data length:length];
    [port notify:receiveData];
}

@end


