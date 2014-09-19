//
//  VCardViewController.m
//  即时通讯
//
//  Created by sen5labs on 14-9-19.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import "VCardViewController.h"
#import "AppDelegate.h"

@interface VCardViewController ()

@end

@implementation VCardViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)logout:(id)sender {
    
    [xmppDelegate logout];
}



@end
