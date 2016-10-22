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

#import "LWURLResponse.h"

@implementation LWURLResponse
{
    NSString *responseBody;
    NSInteger statusCode;
    NSDictionary *allHeaderFields;
    NSString *statusMsg;
    NSData *responseData;
}

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        NSLog(@"raw http response = \n%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        allHeaderFields = [[NSMutableDictionary alloc] init];
        [self parseResponse:data];
    }
    return self;
}

- (void)parseResponse:(NSData *)data
{
    NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (responseStr == nil || [responseStr length] == 0) {
        return;
    }
    NSArray *responseArray = [responseStr componentsSeparatedByString:@"\r\n\r\n"];
    [self getHttpResponseHeaders:[responseArray firstObject]];
    responseBody = [responseArray lastObject];
    responseData = [[responseArray lastObject] dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)getHttpResponseHeaders:(NSString *)content
{
    NSArray *headerArray = [content componentsSeparatedByString:@"\r\n"];
    NSString *statusLine = [headerArray firstObject];
    
    const char *ptrStatusLine = [statusLine UTF8String];
    char httpVersion[10];
    char httpStatusMsg[20];
    sscanf(ptrStatusLine, "%s %ld %s", httpVersion, &statusCode, httpStatusMsg);
    statusMsg = [NSString stringWithUTF8String:httpStatusMsg];
    [headerArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            return;
        }
        NSArray *headerItem = [obj componentsSeparatedByString:@": "];
        NSString *headerKey = [[headerItem firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *headerValue = [[headerItem lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [allHeaderFields setValue:headerValue forKey:headerKey];
    }];
}

- (NSData *)responseData
{
    return responseData;
}

- (NSString *)responseBody
{
    return responseBody;
}

- (NSInteger)statusCode
{
    return statusCode;
}

- (NSDictionary *)allHeaderFields
{
    return allHeaderFields;
}

- (NSString *)statusMsg
{
    return statusMsg;
}
@end
