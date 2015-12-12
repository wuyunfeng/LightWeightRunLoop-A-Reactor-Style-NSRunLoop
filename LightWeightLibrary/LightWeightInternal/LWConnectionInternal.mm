//
//  LWConnectionInternal.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/12/12.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import "LWConnectionInternal.h"
#import "LWConnHelper.hpp"

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
    [self prepareHttpRequest];
    [self prepareHTTPBody];
    _helper->createHttpRequest(request.timeoutInterval, &context);
}

- (void)cancel
{
    _helper->closeConn();
    self.delegate = nil;
}

- (void)prepareHttpRequest
{
    NSURL *targetURL = request.URL;
    NSString *httpMethod = request.HTTPMethod;
    NSString *path = targetURL.path;
    NSString *host = targetURL.host;
    NSInteger port = [targetURL.port intValue];
    char *ip = _helper->resolveHostName([host UTF8String]);
    if (ip == NULL) {
        NSLog(@"resolve host name failure");
        return;
    }
    _helper->establishSocket(ip, port);
    
    NSMutableString *httpRequestLineAndHeader = [[NSMutableString alloc] init];
    
    NSString *requestLine = [NSString stringWithFormat:@"%@ %@ HTTP/1.1 \r\n",httpMethod, path];
    [httpRequestLineAndHeader appendString:requestLine];
    
    NSString *genernalHostHeader = [NSString stringWithFormat:@"HOST: %@ \r\n", host];
    [httpRequestLineAndHeader appendString:genernalHostHeader];

    NSString *contentType = @"Content-Type: application/x-www-form-urlencoded\r\n";
    [httpRequestLineAndHeader appendString:contentType];

    NSString *agentHeader = [NSString stringWithFormat:@"User-Agent: %@\r\n", @"iPhoneOS"];
    [httpRequestLineAndHeader appendString:agentHeader];

    NSString *httpAccept = [NSString stringWithFormat:@"Http_Accept: %@\r\n", @"*/*"];
    [httpRequestLineAndHeader appendString:httpAccept];
    
    NSString *contentLengthHeader = [NSString stringWithFormat:@"Content-Length: %u\r\n", request.HTTPBody.length];
    [httpRequestLineAndHeader appendString:contentLengthHeader];

    NSString *httpEncoding = [NSString stringWithFormat:@"HTTP-ACCPET-ENCODING: %@\r\n", @"gzip"];
    [httpRequestLineAndHeader appendString:httpEncoding];
    
    NSString *httpConn = [NSString stringWithFormat:@"Connection: close\r\n"];
    [httpRequestLineAndHeader appendString:httpConn];
    [httpRequestLineAndHeader appendString:@"\r\n"];
    _helper->sendHttpHeader([httpRequestLineAndHeader UTF8String], httpRequestLineAndHeader.length);
}

- (void)prepareHTTPBody
{
    NSData *data = request.HTTPBody;
    _helper->sendHttpBody((char *)([data bytes]), [data length]);
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
