//
//  LWURLResponse.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/12/12.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import "LWURLResponse.h"

@implementation LWURLResponse
{
    NSString *responseBody;
    NSInteger statusCode;
    NSDictionary *allHeaderFields;
    NSString *statusMsg;
}

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        NSLog(@"raw response = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
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
    [self getAllHttpHeaders:[responseArray firstObject]];
    responseBody = [responseArray lastObject];
}

- (void)getAllHttpHeaders:(NSString *)content
{
    NSArray *headerArray = [content componentsSeparatedByString:@"\r\n"];
    NSString *httpRequestLine = [headerArray firstObject];
    if (httpRequestLine) {
        NSArray *requstLineArray = [httpRequestLine componentsSeparatedByString:@" "];
        statusCode = [[requstLineArray objectAtIndex:1] integerValue];
        statusMsg = [requstLineArray objectAtIndex:2];
    }
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
