//
//  LoginViewController.m
//  即时通讯
//
//  Created by sen5labs on 14-9-18.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *hostnameText;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1. 屏幕适配
    if ([UIScreen mainScreen].bounds.size.height >= 568.0) {
        _topConstraint.constant = 80.0;
    }
   
    UIImage *loginImage = [UIImage imageNamed:@"LoginGreenBigBtn"];
    loginImage = [loginImage stretchableImageWithLeftCapWidth:loginImage.size.width * .5 topCapHeight:loginImage.size.height * 0.5];
    [_loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
    
    UIImage *registerImage = [UIImage imageNamed:@"LoginwhiteBtn"];
    registerImage = [registerImage stretchableImageWithLeftCapWidth:registerImage.size.width * .5 topCapHeight:registerImage.size.height * 0.5];
    [_registerButton setBackgroundImage:registerImage forState:UIControlStateNormal];
}


- (IBAction)userLogin:(UIButton *)sender {
    
    // 1. 获取用户输入内容
    NSString *userName = _usernameText.text;
    NSString *password = _passwordText.text;
    NSString *hostName = _hostnameText.text;
   
    // 2. 系统偏好，用来存储常用的个人信息
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:userName forKey:kXMPPLoginUserNameKey];
    [defaults setObject:password forKey:kXMPPLoginPasswordKey];
    [defaults setObject:hostName forKey:KXMPPLoginHostNameKey];
    
    [defaults synchronize];
    
    //    // 2. 获取AppDelegate
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate connectToHost];
}

@end
