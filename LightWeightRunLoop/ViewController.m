//
//  ViewController.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/10/30.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import "ViewController.h"
#import "LightWeightRunLoop.h"
#import "UIViewAdditions.h"
#import "TestTarget1.h"
#import "TestTarget2.h"
#import "LWTimer.h"
@interface ViewController ()
{
    UIButton *_button;
    UIButton *_button2;
    NSThread *_thread;
    NSThread *_thread2;
    
    TestTarget1 *_target1;
    TestTarget2 *_target2;
    
    NSInteger _count;
    LWTimer *gTimer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContentView];

    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(lightWeightRunloopThreadEntryPoint:) object:nil];
    _thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(lightWeightRunloopThreadEntryPoint2:) object:nil];
    _thread.name = @"Thead 1";
    _thread2.name = @"Thread 2";

    [_thread start];
    [_thread2 start];
}

#pragma mark - layout all subviews
- (void)setContentView
{
    [self.view setBackgroundColor:[UIColor grayColor]];
    self.title = @"Realize RunLoop";
    
    _target1 = [[TestTarget1 alloc] init];
    _target2 = [[TestTarget2 alloc] init];
    
    _button = [UIButton new];
    _button.width = self.view.width / 4;
    _button.height = 50;
    _button.top = 100;
    _button.centerX = self.view.centerX;
    [_button setTitle:@"Perform" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [_button addTarget:self action:@selector(executePost:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    _button2 = [UIButton new];
    _button2.width = self.view.width / 4;
    _button2.height = 50;
    _button2.top = 200;
    _button2.centerX = self.view.centerX;
    [_button2 setTitle:@"Perform Test" forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [_button2 addTarget:self action:@selector(performTest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button2];
}


- (void)performTest:(UIButton *)button
{
  [_target2 postSelector:@selector(performTest) onThread:_thread2 withObject:nil afterDelay:3000];
}
#pragma mark - test LWRunLoop
- (void)executePost:(UIButton *)button
{
//    [self postSelector:@selector(execute) onThread:_thread2 withObject:nil];
//    [_target1 postSelector:@selector(performTest) onThread:_thread2 withObject:nil];
//    [_target2 postSelector:@selector(performTest) onThread:_thread2 withObject:nil];
    [NSThread detachNewThreadSelector:@selector(asyncExecuteMethodOnThread:) toTarget:self withObject:nil];
//    [NSThread detachNewThreadSelector:@selector(asyncExecuteMethodOnThread:) toTarget:self withObject:nil];
}

#pragma mark - post method from new-thread to _thread
- (void)asyncExecuteMethodOnThread:(id)args
{
//    sleep(2);
//    [_target1 postSelector:@selector(performTest) onThread:_thread2 withObject:nil];
//    sleep(1);
//    [_target2 postSelector:@selector(performTest) onThread:_thread2 withObject:nil afterDelay:3000];
//    sleep(2);
    [self postSelector:@selector(execute) onThread:_thread2 withObject:nil afterDelay:0];
}

#pragma mark - Thread EntryPoint
- (void)lightWeightRunloopThreadEntryPoint:(id)data
{
    @autoreleasepool {
        [[LWRunLoop currentLWRunLoop] run];
    }
}


- (void)lightWeightRunloopThreadEntryPoint2:(id)data
{
    @autoreleasepool {
        LWRunLoop *looper = [LWRunLoop currentLWRunLoop];
        [looper run];
    }
}
#pragma mark - post method from main-thread to _thread
- (void)execute
{
//    NSLog(@"* [ Object: %@ performSelector: ( %@ ) on Thread : %@ ] *", [self class], NSStringFromSelector(_cmd), [NSThread currentThread].name);
//    LWTimer *timer = [LWTimer timerWithTimeInterval:1000 target:self selector:@selector(performTimer:) userInfo:nil repeats:YES];
//    _count = 0;
//
    gTimer = [LWTimer scheduledLWTimerWithTimeInterval:2000 target:self selector:@selector(performTimer:) userInfo:nil repeats:YES];

}

- (void)performTimer:(LWTimer *)timer
{
    NSLog(@"timer = %p", timer);
    NSLog(@"gTimer = %p", gTimer);

    _count++;
    NSLog(@"* [ Object: %@ performSelector: ( %@ ) on Thread : %@ ] *", [self class], NSStringFromSelector(_cmd), [NSThread currentThread].name);
    if (_count == 4) {
        [timer invalidate];
    }
}

#pragma mark - MemoryWaring
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
