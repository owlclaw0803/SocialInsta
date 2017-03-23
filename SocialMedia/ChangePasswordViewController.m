//
//  ChangePasswordViewController.m
//  SocialMedia
//
//  Created by Khalid  on 18/10/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost == YES) {
        [self.tabBarController setSelectedIndex:0];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegates/Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else {
        return 2;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.; // you can have your own choice, of course
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentify = @"PswrdCell";
    ChangePasswordCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell==nil) {
        cell = [[ChangePasswordCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    [cell.leftImage setImage:[UIImage imageNamed:@"SettingPassword.png"]];
    [cell.pswrdField setTag:indexPath.section+indexPath.row];
    if (indexPath.section==0) {
        [cell.pswrdField setPlaceholder:@"Current Password"];
    }
    else if (indexPath.section==1) {
        switch (indexPath.row) {
            case 0:
                [cell.pswrdField setPlaceholder:@"New Password"];
                break;
            case 1:
                [cell.pswrdField setPlaceholder:@"New Password, again"];
                break;
                
            default:
                break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    [self postSettingDetails];
}

#pragma mark - API's 

- (void)postSettingDetails {
    [self settingPostApiCall:^(BOOL result) {
        if (result) {
        }
    }];
}

- (void)settingPostApiCall:(void (^)(BOOL result)) return_block {
    
    NSString *oldPassword, *newPassword, *newPasswordAgain;
    int i;
    for (i = 0 ; i < 2 ; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        ChangePasswordCustomCell *cell = (ChangePasswordCustomCell *)[changePswrdTableView cellForRowAtIndexPath:indexPath];
        for (UIView *view in  cell.contentView.subviews) {
            if ([view isKindOfClass:[UITextField class]]) {
                UITextField* txtField = (UITextField *)view;
                if (indexPath.row == 0) {
                    newPassword = [[cell.pswrdField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else {
                    newPasswordAgain = [[cell.pswrdField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
            }
        }
    }
    if ([newPassword isEqualToString:newPasswordAgain]) {
        if(newPassword.length < 6){
            for (i = 0 ; i < 2 ; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
                ChangePasswordCustomCell *cell = (ChangePasswordCustomCell *)[changePswrdTableView cellForRowAtIndexPath:indexPath];
                for (UIView *view in  cell.contentView.subviews) {
                    if ([view isKindOfClass:[UITextField class]]) {
                        UITextField* txtField = (UITextField *)view;
                        if (indexPath.row == 0) {
                            cell.pswrdField.text = @"";
                        }
                        else {
                            cell.pswrdField.text = @"";
                        }
                    }
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Password must be more than 6 characters."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        ChangePasswordCustomCell *cell = (ChangePasswordCustomCell *)[changePswrdTableView cellForRowAtIndexPath:indexPath];
        for (UIView *view in  cell.contentView.subviews) {
            if ([view isKindOfClass:[UITextField class]]) {
                UITextField* getTextView = (UITextField *)view;
                if (indexPath.row == 0) {
                    oldPassword = [[cell.pswrdField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
            }
        }
//        UITextField *getTextView = (UITextField*)[cell.contentView viewWithTag:0];
//        oldPassword = [[getTextView text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/change_password.php"]];
        _request.shouldAttemptPersistentConnection   = NO;
        __unsafe_unretained ASIFormDataRequest *request = _request;
        
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
        [request addPostValue:oldPassword forKey:@"old_pass"];
        [request addPostValue:newPassword forKey:@"new_pass"];
        [request startAsynchronous];
        [request setCompletionBlock:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
            if([root[@"status"] isEqualToString:@"success"]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else //if (root==NULL)
            {
                [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                                type:AJNotificationTypeRed
                                               title:@"Hey Something is Wrong"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:4.0];
            }
        }];
        [request setFailedBlock:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSError *error=[request error];
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:error.localizedDescription
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }];
    }
    else {
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:@"New Passwords does not Match"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:4.0];
    }
}

-(IBAction)hideKeyboardOnReturnTap:(id)sender
{
    [sender resignFirstResponder];
}

@end
