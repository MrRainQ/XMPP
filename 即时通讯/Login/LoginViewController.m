//
//  LoginViewController.m
//  即时通讯
//
//  Created by sen5labs on 14-9-18.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "NSString+Helper.h"
@interface LoginViewController ()<UITextFieldDelegate>

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
    
    // 3. 从系统偏好读取用户已经保存的信息设置UI
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _usernameText.text = [defaults stringForKey:kXMPPLoginUserNameKey];
    _passwordText.text = [defaults stringForKey:kXMPPLoginPasswordKey];
    _hostnameText.text = [defaults stringForKey:KXMPPLoginHostNameKey];

    if (_usernameText.text.length == 0) {
        [_usernameText becomeFirstResponder];
    } else {
        [_passwordText becomeFirstResponder];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 1. 获取用户输入内容
    NSString *userName = [_usernameText.text trimString];
    NSString *password = _passwordText.text ;
    NSString *hostName = [_hostnameText.text trimString];
    
    if (userName.length > 0 && password.length > 0 && hostName.length > 0) {
        [self userLogin:nil];
    }else{
        
        if (userName.length == 0) {
            [_usernameText becomeFirstResponder];
        }else if (password.length == 0){
            [_passwordText becomeFirstResponder];
        }else{
            [_hostnameText becomeFirstResponder];
        }
    }
    return YES;
}

- (IBAction)userLogin:(UIButton *)sender {
    
    // 1. 获取用户输入内容
    NSString *userName = [_usernameText.text trimString];
    NSString *password = _passwordText.text;
    NSString *hostName = [_hostnameText.text trimString];
   
    // 2. 系统偏好，用来存储常用的个人信息
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:userName forKey:kXMPPLoginUserNameKey];
    [defaults setObject:password forKey:kXMPPLoginPasswordKey];
    [defaults setObject:hostName forKey:KXMPPLoginHostNameKey];
    
    [defaults synchronize];
    
    // 3. 获取AppDelegate
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.isRegisterUser = sender.tag;
    [delegate connectOnFailed:^(kLoginErrorType type) {
        NSString *msg = nil;
        if (type == kLoginLogonError) {
            msg = @"用户名或密码错误";
        }else if(type == kLoginNotConnection){
            msg = @"无法连接到服务器";
        }else if(type == kLoginRegisterError){
            msg = @"用户名重复，无法注册";
        }
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
        if (type == kLoginLogonError) {
            [_passwordText becomeFirstResponder];
        } else if (type == kLoginNotConnection) {
            [_hostnameText becomeFirstResponder];
        } else {
            [_usernameText becomeFirstResponder];
        }
    }];
}


@end
