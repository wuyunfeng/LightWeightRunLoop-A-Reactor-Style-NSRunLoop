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
@interface ViewController ()
{
    UIButton *_button;
    NSThread *_thread;
    
    TestTarget1 *_target1;
    TestTarget2 *_target2;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContentView];
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(lightWeightRunloopThreadEntryPoint:) object:nil];
    _thread.name = @"com.wyf.opensource.thread";
    [_thread start];
}

#pragma mark - layout all subviews
- (void)setContentView
{
    [self.view setBackgroundColor:[UIColor grayColor]];
    self.title = @"Realize RunLoop";
    
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
}

#pragma mark - test LWRunLoop
- (void)executePost:(UIButton *)button
{
    
    _target1 = [[TestTarget1 alloc] init];
    _target2 = [[TestTarget2 alloc] init];
    [self postSelector:@selector(execute) onThread:_thread withObject:nil];
    [_target1 postSelector:@selector(performTest) onThread:_thread withObject:nil];
    [_target2 postSelector:@selector(performTest) onThread:_thread withObject:nil];
    [NSThread detachNewThreadSelector:@selector(asyncExecuteMethodOnThread:) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(asyncExecuteMethodOnThread:) toTarget:self withObject:nil];
}

#pragma mark - post method from new-thread to _thread
- (void)asyncExecuteMethodOnThread:(id)args
{
    sleep(2);
    [_target1 postSelector:@selector(performTest) onThread:_thread withObject:nil];
    sleep(1);
    [_target2 postSelector:@selector(performTest) onThread:_thread withObject:nil];
    sleep(1);
    [self postSelector:@selector(execute) onThread:_thread withObject:nil];
}

#pragma mark - Thread EntryPoint
- (void)lightWeightRunloopThreadEntryPoint:(id)data
{
    [[LWRunLoop currentLWRunLoop] run];
}

#pragma mark - post method from main-thread to _thread
- (void)execute
{
    
    NSLog(@"* [ Object: %@ performSelector: ( %@ ) on Thread : %@ ] *", [self class], NSStringFromSelector(_cmd), [NSThread currentThread].name);
    
}

#pragma mark - MemoryWaring
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
