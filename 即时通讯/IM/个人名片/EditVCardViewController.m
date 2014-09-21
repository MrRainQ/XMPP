//
//  EditVCardViewController.m
//  即时通讯
//
//  Created by sen5labs on 14-9-19.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import "EditVCardViewController.h"


@interface EditVCardViewController ()<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *contextText;

@end

@implementation EditVCardViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.contentTitle;
    _contextText.placeholder = [NSString stringWithFormat:@"请输入%@", _contentTitle];

    _contextText.text = _contentLabel.text;
    
    [_contextText becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self save:nil];
    return YES;
}

- (IBAction)save:(id)sender {

    _contentLabel.text = [_contextText.text trimString];
    [_delegate editVCardViewControllerDidFinished];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
