//
//  ViewController.m
//  CustomAlbum
//
//  Created by 天狼 on 2019/7/13.
//  Copyright © 2019 com.XlX.www. All rights reserved.
//

#import "ViewController.h"
#import "PhotoSlectController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"选择照片" forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 100, 100, 100);
    button.center = self.view.center;
    [button addTarget:self action:@selector(clickPhpotoButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)clickPhpotoButton {
   [self.navigationController pushViewController:[PhotoSlectController new] animated:true];
}

@end
