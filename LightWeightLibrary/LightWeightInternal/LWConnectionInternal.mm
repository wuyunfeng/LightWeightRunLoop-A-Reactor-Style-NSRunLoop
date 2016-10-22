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

#import "LWConnectionInternal.h"
#import "LWConnHelper.hpp"

/**
 *  Automatic change `NSDictionary` presentation of HTTP HEADER to `NSString` presentation
 *
 *  @param headerFields `NSDictionary` presentation of HTTP HEADER
 *
 *  @return `NSString` presentation of HTTP HEADER
 */
NSString* LWHeaderStringFromHTTPHeaderFieldsDictironary(NSDictionary *headerFields)
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    NSArray *allKeys = [[headerFields allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSString* key in allKeys) {
        id value = [headerFields objectForKey:key];
        if (key && value) {
            [result appendFormat:@"%@: %@", key, value];
            [result appendString:@"\r\n"];
        }
    }
    [result appendString:@"\r\n"];
    return result;
}


@implementation LWConnectionInternal
{
    LWConnHelper *_helper;
    NSMutableURLRequest *request;
    NSMutableData *response;
}

- (instancetype)init
{
    if (self = [super init]) {
        _helper = new LWConnHelper();
    }
    return self;
}

- (instancetype)initWithRequest:(NSMutableURLRequest *)aRequest
{
    if (self = [super init]) {
        _helper = new LWConnHelper();
        request = aRequest;
    }
    return self;
}

- (void)dealloc
{
    delete _helper;
    self.delegate = nil;
}

- (NSMutableURLRequest *)request
{
    return request;
}

- (void)start
{
    [NSThread detachNewThreadSelector:@selector(startInternal) toTarget:self withObject:nil];
}

- (void)startInternal
{
    LWConnHelperContext context = {(__bridge void *)self,TimeOutCallBackRoutine, ReceiveCallBackRoutine, FinshCallBackRoutine, FailureCallBackRoutine};
    _helper->setLWConnHelperContext(&context);
    if ([self establishConnection]) {
        [self prepareHttpRequest];
        if ((strcasecmp("post", [request.HTTPMethod UTF8String]) == 0) && request.HTTPBody.length > 0) {
            [self prepareHTTPBody];
        }
        if (request.timeoutInterval <= 0) {
            request.timeoutInterval = 60;
        }
        _helper->createHttpRequest(request.timeoutInterval);
    } else {
        _helper->closeConn();
        [self failure];
    }
}

- (void)cancel
{
    _helper->closeConn();
    self.delegate = nil;
}

- (BOOL)establishConnection
{
    NSURL *targetURL = request.URL;
    NSString *host = targetURL.host;
    NSInteger port = [targetURL.port intValue];
    char *ip = _helper->resolveHostName([host UTF8String]);
    if (ip == NULL) {
        NSLog(@"resolve host name failure");
        return NO;
    }
    return _helper->establishSocket(ip, (int)port);
}

- (void)prepareHttpRequest
{
    NSURL *targetURL = request.URL;
    NSString *httpMethod = request.HTTPMethod;
    NSString *path = targetURL.path;
    NSString *host = targetURL.host;
    
    NSMutableString *httpRequestLineAndHeader = [[NSMutableString alloc] init];
    
    NSString *requestLine = [NSString stringWithFormat:@"%@ %@ HTTP/1.1 \r\n",httpMethod, path];
    NSString *hostHeader = [NSString stringWithFormat:@"HOST: %@ \r\n", host];
    [httpRequestLineAndHeader appendString:requestLine];
    [httpRequestLineAndHeader appendString:hostHeader];
    
    NSMutableDictionary *allHTTPHeaderFields = [[NSMutableDictionary alloc] init];
    [allHTTPHeaderFields setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [allHTTPHeaderFields setValue:@(request.HTTPBody.length) forKey:@"Content-Length"];
    [allHTTPHeaderFields setValue:@"wuyunfeng@LWURLConnection" forKey:@"Accept"];
    [allHTTPHeaderFields setValue:@"gzip, deflate" forKey:@"Accept-Encoding"];
    [allHTTPHeaderFields setValue:@"utf-8" forKey:@"Accept-Charset"];
    [allHTTPHeaderFields setValue:@"LWRunLoopAgent" forKey:@"User-Agent"];
    [allHTTPHeaderFields setValue:@"no-cache" forKey:@"Cache-Control"];
    [allHTTPHeaderFields setValue:@"close" forKey:@"Connection"];
    [allHTTPHeaderFields addEntriesFromDictionary:request.allHTTPHeaderFields];
    NSString *httpHeaderAndValues = LWHeaderStringFromHTTPHeaderFieldsDictironary(allHTTPHeaderFields);
    [httpRequestLineAndHeader appendString:httpHeaderAndValues];
    _helper->sendMsg([httpRequestLineAndHeader UTF8String], (int)httpRequestLineAndHeader.length);
}

- (void)prepareHTTPBody
{
    NSData *data = request.HTTPBody;
    _helper->sendMsg((const char *)([data bytes]), (int)[data length]);
}

#pragma mark - C-Style CallBack
void TimeOutCallBackRoutine(void *info)
{
    LWConnectionInternal *connection = (__bridge LWConnectionInternal *)info;
    [connection timeOut];
}

void ReceiveCallBackRoutine(void *info, void *data, int length)
{
    LWConnectionInternal *connection = (__bridge LWConnectionInternal *)info;
    NSData *receiveData = [[NSData alloc] initWithBytes:data length:length];
    [connection receiveData:receiveData];
}

void FinshCallBackRoutine(void *info)
{
    LWConnectionInternal *connection = (__bridge LWConnectionInternal *)info;
    [connection finish];
}

void FailureCallBackRoutine(void *info, int code)
{
    LWConnectionInternal *connection = (__bridge LWConnectionInternal *)info;
    [connection failure];
}

#pragma mark - CallBack Messaging
- (void)timeOut
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
    if ([self.delegate respondsToSelector:@selector(internal_connection:didFailWithError:)]) {
        NSError *error = [NSError errorWithDomain:@"TimeOut" code:-1 userInfo:nil];
        [self.delegate internal_connection:self didFailWithError:error];
    }
}

- (void)receiveData:(NSData *)data
{
    if (!response) {
        response = [[NSMutableData alloc] init];
    }
    [response appendData:data];
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
    if ([self.delegate respondsToSelector:@selector(internal_connection:didReceiveData:)]) {
        [self.delegate internal_connection:self didReceiveData:data];
    }
}

- (void)finish
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
    if ([self.delegate respondsToSelector:@selector(internal_connectionDidFinishLoading:)]) {
        [self.delegate internal_connectionDidFinishLoading:self];
    }
}

- (void)failure
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
    if ([self.delegate respondsToSelector:@selector(internal_connection:didFailWithError:)]) {
        [self.delegate internal_connection:self didFailWithError:nil];
    }
}
@end
