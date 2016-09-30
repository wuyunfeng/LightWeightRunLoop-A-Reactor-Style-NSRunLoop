//
//  WorkerClass.h
//  LightWeightRunLoop
//
//  Created by 武云峰 on 16/9/24.
//  Copyright © 2016年 com.wuyunfeng.open. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWPort.h"

@interface WorkerClass : NSObject

- (void)launchThreadWithPort:(LWPort *)port;

- (LWPort *)localPort;


@end
