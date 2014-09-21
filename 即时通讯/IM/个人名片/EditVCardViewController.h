//
//  EditVCardViewController.h
//  即时通讯
//
//  Created by sen5labs on 14-9-19.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditVCardViewControllerDelegate <NSObject>

- (void)editVCardViewControllerDidFinished;

@end

@interface EditVCardViewController : UIViewController

@property (nonatomic, weak) id <EditVCardViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *contentTitle;
@property (nonatomic, weak) UILabel *contentLabel;

@end
