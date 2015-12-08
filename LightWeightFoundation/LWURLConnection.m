//
//  LWURLConnection.m
//  LightWeightRunLoop
//
//  Created by 武云峰 on 15/12/7.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import "LWURLConnection.h"
#import "LWRunLoop.h"
#include<sys/socket.h>                         // for socket
#include<netinet/in.h>                         // for sockaddr_in
#include <arpa/inet.h>                         // for inet_aton
@implementation LWURLConnection
{
    int _fd;
}

- (void)configureClientSocket
{
    struct sockaddr_in client_addr;
    bzero(&client_addr, sizeof(client_addr));
    client_addr.sin_family = AF_INET; // internet协议族
    client_addr.sin_addr.s_addr = htons(INADDR_ANY); // INADDR_ANY表示自动获取本机地址
    client_addr.sin_port = htons(0); // auto allocated, 让系统自动分配一个空闲端口
    
    // 创建用于internet的流协议(TCP)类型socket，用client_socket代表客户端socket
    _fd = socket(PF_INET, SOCK_STREAM, 0);
    
    if (_fd < 0) {
        return;
    }
    //    fcntl(_fd, F_SETFL, O_NONBLOCK);
    
    // 设置一个socket地址结构server_addr,代表服务器的internet地址和端口
    struct sockaddr_in  server_addr;
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    // 服务器的IP地址来自程序的参数
    if (inet_aton("192.168.1.2", &server_addr.sin_addr) == 0) {
        return;
    }
    
    server_addr.sin_port = htons(8888);
    struct timeval timeout;
    timeout.tv_sec = 10;
    timeout.tv_usec = 0;
    
    //    if (setsockopt(_fd, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout)) < 0) {
    //        close(_fd);
    //        return;
    //    }
    //    if (setsockopt (_fd, SOL_SOCKET, SO_SNDTIMEO, (char *)&timeout, sizeof(timeout)) < 0) {
    //        close(_fd);
    //        return;
    //    }
    //
    
    if (connect(_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        NSLog(@"errno = %d", errno);
        //        close(_fd);
        return;
    }
}

- (void)sendHttpRequest
{
    NSString *postBody = [NSString stringWithFormat:@"name=%@&age=%d&mobile=%@", @"jack", 10, @"18600398904"];
    
    NSString *path = @"/post.php";
    
    NSString *host = @"www.wyf.com";
    
    NSString *requestLine = [NSString stringWithFormat:@"POST %@ HTTP/1.1 \r\n", path];
    const char *cRequestLine = [requestLine UTF8String];
    NSString *genernalHostHeader = [NSString stringWithFormat:@"HOST: %@ \r\n", host];
    
    ssize_t flag = write(_fd, cRequestLine, strlen(cRequestLine));
    flag = write(_fd, [genernalHostHeader UTF8String], genernalHostHeader.length);
    
    NSString *contentType = @"Content-Type: application/x-www-form-urlencoded\r\n";
    const char *cContentType = [contentType UTF8String];
    flag = write(_fd, cContentType, strlen(cContentType));
    
    NSString *agentHeader = [NSString stringWithFormat:@"User-Agent: %@\r\n", @"wuyunfeng@MAC"];
    const char *cAgentHeader = [agentHeader UTF8String];
    flag = write(_fd, cAgentHeader, strlen(cAgentHeader));
    
    NSString *httpAccept = [NSString stringWithFormat:@"Http_Accept: %@\r\n", @"text/html"];
    const char *cHttpAccept = [httpAccept UTF8String];
    flag = write(_fd, cHttpAccept, strlen(cHttpAccept));
    
    
    NSString *httpEncoding = [NSString stringWithFormat:@"HTTP-ACCPET-ENCODING: %@\r\n", @"gzip"];
    const char *cHttpEncoding = [httpEncoding UTF8String];
    flag = write(_fd, cHttpEncoding, strlen(cHttpEncoding));
    
    NSString *contentLengthHeader = [NSString stringWithFormat:@"Content-Length: %lu\r\n", (unsigned long)postBody.length];
    flag = write(_fd, [contentLengthHeader UTF8String], strlen([contentLengthHeader UTF8String]));
    flag = write(_fd, "Connection: close\r\n", strlen("Connection: close\r\n"));
    write(_fd, "\r\n", strlen("\r\n"));
    
    char post_content[128];
    memcpy(post_content,"name=wuyufeng&age=26",128);
    flag = write(_fd, [postBody UTF8String], postBody.length);/*(_fd, [postBody UTF8String], strlen([postBody UTF8String]));*/
    flag = write(_fd, "\r\n", sizeof("\r\n"));
    //    char buffer[4096 * 8];
    //    ssize_t nRead;
    //    do {
    //        nRead = read(_fd, buffer, 4096 * 8);
    //    } while ((nRead == -1 && errno == EINTR) || nRead == sizeof(buffer) );
    ////    read(_fd, buffer, 4096 * 8);
    //    NSString *response = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    //    NSLog(@"response = %@", response);
    ////    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    ////    [runloop run];
    //    close(_fd);
    //    [self processFd:_fd];
}



@end
