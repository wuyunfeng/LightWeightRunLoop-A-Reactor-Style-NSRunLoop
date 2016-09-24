//
//  LWClientInfo.h
//  LightWeightRunLoop
//
//  Created by 武云峰 on 16/9/24.
//  Copyright © 2016年 com.wuyunfeng.open. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWPortClientInfo : NSObject

@property (assign) ushort port;
//unuse, for future
@property (nonatomic, nullable) NSString *ip;
@property (assign) int fd;

@property (nullable) NSData *cacheSend;

@end
