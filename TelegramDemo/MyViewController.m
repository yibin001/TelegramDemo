//
//  ViewController.m
//  TelegramDemo
//
//  Created by qmk on 2024/8/14.
//

#import "MyViewController.h"
#import "TelegramDemo-Swift.h"
//#import <ObjCRuntimeUtils/RuntimeUtils.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface MyViewController ()

//create a button
@property (nonatomic, strong) UIButton *button;

//create another button
@property (nonatomic, strong) UIButton *button2;

//create another button
@property (nonatomic, strong) UIButton *button3;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor yellowColor];

    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(50, 100, 200, 100);
    [self.button setTitle:@"Show ListView" forState:UIControlStateNormal];
    self.button.backgroundColor = [UIColor redColor];
    [self.button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.button];

    self.button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button2.frame = CGRectMake(50, 200, 200, 100);
    [self.button2 setTitle:@"Show RAC Test" forState:UIControlStateNormal];
    self.button2.backgroundColor = [UIColor blueColor];
    [self.button2 addTarget:self action:@selector(buttonClick2) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.button2];

    self.button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button3.frame = CGRectMake(50, 300, 200, 100);
    [self.button3 setTitle:@"Show ChatList" forState:UIControlStateNormal];
    self.button3.backgroundColor = [UIColor greenColor];
    [self.button3 addTarget:self action:@selector(buttonClick3) forControlEvents:UIControlEventTouchUpInside];

//    [self.view addSubview:self.button3];
}

- (void)buttonClick {
    NSLog(@"button click");

    ChatListViewController *vc = [ChatListViewController new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)buttonClick2 {
    TestSignalViewController *vc = [TestSignalViewController new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)buttonClick3 {
}

@end
