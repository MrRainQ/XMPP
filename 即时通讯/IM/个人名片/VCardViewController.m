//
//  VCardViewController.m
//  即时通讯
//
//  Created by sen5labs on 14-9-19.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import "VCardViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "EditVCardViewController.h"
@interface VCardViewController ()<EditVCardViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jidLabel;
@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orgUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;


@end

@implementation VCardViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadvCard];
}


- (void)loadvCard
{
    // 取出当前用户的电子名片
    XMPPvCardTemp *myCard = [xmppDelegate xmppvCardTempModule].myvCardTemp;
    
    if (myCard == nil) {
        myCard = [[XMPPvCardTemp alloc]init];
        [xmppDelegate.xmppvCardTempModule updateMyvCardTemp:myCard];
    }
    
    if (myCard.photo) {
         _headerImageView.image = [UIImage imageWithData:myCard.photo];
    }else{
        NSData *photoData = [xmppDelegate.xmppvCardAvatarModule photoDataForJID:xmppDelegate.xmppStream.myJID];
        if (photoData) {
            _headerImageView.image = [UIImage imageWithData:photoData];
        }
    }
    _nickNameLabel.text = myCard.nickname;
    _jidLabel.text = xmppDelegate.xmppStream.myJID.bare;
    
    _orgNameLabel.text = myCard.orgName;
    _orgUnitLabel.text = myCard.orgUnits[0];
    _titleLabel.text = myCard.title;
    _telLabel.text = myCard.note;
    _emailLabel.text = myCard.mailer;
    
}

#pragma mark - 电子名片的方法

- (IBAction)logout:(id)sender {
    
    [xmppDelegate logout];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)cell
{
    EditVCardViewController *controller = segue.destinationViewController;
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)obj;
            
            // 标题
            if (label.tag == 1) {
                controller.contentTitle = label.text;
            }else {
                controller.contentLabel = label;
            }
        }
    }];
    
    controller.delegate = self;
}

#pragma mark 编辑视图控制器代理方法
- (void)editVCardViewControllerDidFinished
{
    [self savevCard];
    
}
- (void)savevCard
{
    XMPPvCardTemp *myCard = [xmppDelegate xmppvCardTempModule].myvCardTemp;
    myCard.photo = UIImagePNGRepresentation(_headerImageView.image);
    myCard.nickname = _nickNameLabel.text;
    myCard.orgName = _orgNameLabel.text;
    myCard.orgUnits = @[_orgUnitLabel.text];
    myCard.title = _titleLabel.text;
    myCard.note = _telLabel.text;
    myCard.mailer = _emailLabel.text;
    // 保存名片
    [[xmppDelegate xmppvCardTempModule] updateMyvCardTemp:myCard];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 0 ) {
        [self performSegueWithIdentifier:@"EditVCardSegue" sender:cell];
    }else if (cell.tag == 2){
        
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"选择照片", nil];
        [sheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==2) {
        return;
    }

    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    if (buttonIndex == 0) {
         picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
         picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    picker.delegate =self;
    picker.allowsEditing = YES;

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    _headerImageView.image = image;
    [self savevCard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
