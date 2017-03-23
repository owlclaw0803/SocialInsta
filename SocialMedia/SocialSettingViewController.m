//
//  SocialSettingViewController.m
//  SocialMedia
//
//  Created by Khalid  on 02/10/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "SocialSettingViewController.h"

@interface SocialSettingViewController ()

@end

@implementation SocialSettingViewController

@synthesize userName;
@synthesize displayName;
@synthesize email;
@synthesize website;

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
    
    profileArray = [[NSMutableArray alloc] initWithObjects:@"Username",@"Display Name...",@"Bio",@"Website",@"Private Profile", nil];
    accountArray = [[NSMutableArray alloc] initWithObjects:@"user@email.com",@"Change password", nil];
    notificationArray = [[NSMutableArray alloc] initWithObjects:@"Chat",@"Likes",@"Photo Tagged",@"Comments",@"Quick Snap", nil];
    aboutArray = [[NSMutableArray alloc] initWithObjects:@"Privacy Policy",@"Report a Problem",@"About", nil];
    
    bioString = [[NSMutableString alloc] init];
    displayNameString = [[NSMutableString alloc] init];
    websiteString = [[NSMutableString alloc] init];
    isPrivate = [[NSMutableString alloc] init];
    isChatOn = [[NSMutableString alloc] init];
    isLikesOn = [[NSMutableString alloc] init];
    isPhotoTagsOn = [[NSMutableString alloc] init];
    isCommentsOn = [[NSMutableString alloc] init];
    isQuickSnapOn = [[NSMutableString alloc] init];
    
    settingTableView.tableFooterView = settingFooterView;
	// Do any additional setup after loading the view.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    [self getSettingDetails];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    int i;
    for (i=0; i<3; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1 inSection:0];
        SettingCustomCell *cell = (SettingCustomCell *)[settingTableView cellForRowAtIndexPath:indexPath];
        for (UIView *view in  cell.contentView.subviews) {
            if ([view isKindOfClass:[UITextField class]]) {
                UITextField* txtField = (UITextField *)view;
                if (txtField.tag==1) {
                    displayNameString = [NSMutableString stringWithString:[[cell.settingTextField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                }
                else if (txtField.tag==2) {
                    bioString = [NSMutableString stringWithString:[[cell.settingTextField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                }
                else {
                    websiteString = [NSMutableString stringWithString:[[cell.settingTextField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                }
            }
        }
    }
    NSLog(@"Bio is %@ Website is %@",bioString,websiteString);
    [self postSettingDetails];
}

//#pragma mark - UITextField Delegates
//
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if (textField.tag==0) {
//        bioString = [NSMutableString stringWithString:[[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
//    }
//    else {
//        websiteString = [NSMutableString stringWithString:[[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
//    }
//}

#pragma mark - UITableView Delegates/Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 5;
    }
    else if (section==1) {
        return 2;
    }
    else if (section==2) {
        return 5;
    }
    else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30; // you can have your own choice, of course
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentify = @"SettingCell";
    SettingCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell==nil) {
        cell = [[SettingCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    if (indexPath.section==0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.settingImageView setFrame:CGRectMake(10, 12, 20, 20)];
        [cell.settingLabel setFrame:CGRectMake(50, 11, 230, 21)];
        switch (indexPath.row) {
            case 0:
                [cell.settingLabel setHidden:NO];
                [cell.settingTextField setHidden:YES];
                cell.settingLabel.text = self.userName;
                [cell.settingImageView setImage:[UIImage imageNamed:@"SettingProfile.png"]];
                break;
            case 1:
                [cell.settingLabel setHidden:YES];
                [cell.settingTextField setHidden:NO];
                [cell.settingTextField setTag:indexPath.row];
                if (displayNameString.length>0) {
                    [cell.settingTextField setText:displayNameString];
                }
                else {
                    [cell.settingTextField setPlaceholder:@"Display name"];
                }
                [cell.settingImageView setImage:[UIImage imageNamed:@"SettingName.png"]];
                break;
            case 2:
                [cell.settingLabel setHidden:YES];
                [cell.settingTextField setHidden:NO];
                [cell.settingTextField setTag:indexPath.row];
                cell.settingLabel.text = [profileArray objectAtIndex:indexPath.row];
                if (bioString.length>0) {
                    [cell.settingTextField setText:bioString];
                }
                else {
                    [cell.settingTextField setPlaceholder:@"Bio..."];
                }
                [cell.settingImageView setImage:[UIImage imageNamed:@"SettingBio.png"]];
                break;
            case 3:
                [cell.settingLabel setHidden:YES];
                [cell.settingTextField setHidden:NO];
                [cell.settingTextField setTag:indexPath.row];
                cell.settingLabel.text = [profileArray objectAtIndex:indexPath.row];
                if (websiteString.length>0) {
                    [cell.settingTextField setText:websiteString];
                }
                else {
                    [cell.settingTextField setPlaceholder:@"Website"];
                }
                [cell.settingImageView setImage:[UIImage imageNamed:@"SettingWebsite.png"]];
                break;
            case 4:
                [cell.settingLabel setHidden:NO];
                [cell.settingTextField setHidden:YES];
                cell.settingLabel.text = [profileArray objectAtIndex:indexPath.row];
                [cell.settingImageView setImage:[UIImage imageNamed:@"SettingPrivate.png"]];
                break;
                
            default:
                break;
        }
    }
    else if (indexPath.section==1) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.settingLabel setHidden:NO];
        [cell.settingTextField setHidden:YES];
        [cell.settingLabel setFrame:CGRectMake(50, 11, 230, 21)];
        [cell.settingImageView setFrame:CGRectMake(10, 12, 20, 20)];
        switch (indexPath.row) {
            case 0:
                cell.settingLabel.text = self.email;
                [cell.settingImageView setImage:[UIImage imageNamed:@"SettingMain.png"]];
                break;
            case 1:
                cell.settingLabel.text = [accountArray objectAtIndex:indexPath.row];
                [cell.settingImageView setImage:[UIImage imageNamed:@"SettingPassword.png"]];
                break;
                
            default:
                break;
        }
    }
    else if (indexPath.section==2) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.settingLabel setHidden:NO];
        [cell.settingTextField setHidden:YES];
        [cell.settingLabel setFrame:CGRectMake(20, 11, 230, 21)];
        cell.settingLabel.text = [notificationArray objectAtIndex:indexPath.row];
        [cell.settingImageView setImage:nil];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.settingLabel setHidden:NO];
        [cell.settingTextField setHidden:YES];
        [cell.settingLabel setFrame:CGRectMake(20, 11, 230, 21)];
        cell.settingLabel.text = [aboutArray objectAtIndex:indexPath.row];
        [cell.settingImageView setImage:nil];
    }
    [cell.settingLabel setFont:[UIFont systemFontOfSize:14.0]];
    
    if (indexPath.section==0 && indexPath.row==4) {
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        [switchView setTag:1];
        if ([isPrivate isEqualToString:@"0"]) {
            [switchView setOn:NO animated:NO];
        }
        else {
            [switchView setOn:YES animated:NO];
        }
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    else if (indexPath.section==2 && indexPath.row==0) {
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        [switchView setTag:indexPath.row+indexPath.section];
        if ([isChatOn isEqualToString:@"0"]) {
            [switchView setOn:NO animated:NO];
        }
        else {
            [switchView setOn:YES animated:NO];
        }
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    else if (indexPath.section==2 && indexPath.row==1) {
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        [switchView setTag:indexPath.row];
        if ([isLikesOn isEqualToString:@"0"]) {
            [switchView setOn:NO animated:NO];
        }
        else {
            [switchView setOn:YES animated:NO];
        }
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    else if (indexPath.section==2 && indexPath.row==2) {
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        [switchView setTag:indexPath.row];
        if ([isPhotoTagsOn isEqualToString:@"0"]) {
            [switchView setOn:NO animated:NO];
        }
        else {
            [switchView setOn:YES animated:NO];
        }
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    else if (indexPath.section==2 && indexPath.row==3) {
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        [switchView setTag:indexPath.row];
        if ([isCommentsOn isEqualToString:@"0"]) {
            [switchView setOn:NO animated:NO];
        }
        else {
            [switchView setOn:YES animated:NO];
        }
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    else if (indexPath.section==2 && indexPath.row==4) {
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        [switchView setTag:indexPath.row];
        if ([isQuickSnapOn isEqualToString:@"0"]) {
            [switchView setOn:NO animated:NO];
        }
        else {
            [switchView setOn:YES animated:NO];
        }
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(0, 12, 320, 14);
    myLabel.textColor = [UIColor darkGrayColor];
    //myLabel.textAlignment = UITextAlignmentLeft;
    myLabel.font = [UIFont boldSystemFontOfSize:12];

    if (section==0) {
        myLabel.text = @"PROFILE";
    }
    else if (section==1) {
        myLabel.text = @"ACCOUNT";
    }
    else if (section==2) {
        myLabel.text = @"NOTIFICATIONS";
    }
    else {
        myLabel.text = @"ABOUT";
    }
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==1 && indexPath.row==1) {
        ChangePasswordViewController *chngPswrd = [self.storyboard instantiateViewControllerWithIdentifier:@"pswrd"];
        [self.navigationController pushViewController:chngPswrd animated:YES];
    }
    else if (indexPath.section==3 && indexPath.row==0) {
        PrivacyPolicyViewController *privacyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"privacy"];
        [self.navigationController pushViewController:privacyVC animated:YES];
    }
    else if (indexPath.section==3 && indexPath.row==1) {
        NSString *sharingEmailString = [NSString stringWithFormat:@"Social Media\n\nUserName:%@,\n\Email:%@\n\n Thanks!",self.userName,self.email];
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            NSArray *toRecipients = [NSArray arrayWithObjects:@"info@thesocial.life", nil];
            [controller setToRecipients:toRecipients];
            [controller setSubject:@"Social Media"];
            [controller setMessageBody:sharingEmailString isHTML:NO];
            [self presentViewController:controller animated:YES completion:nil];
        }
        else {
            [self showAlertViewWithMessage:@"You Phone has not Configured Mail"];
        }
    }
    else if (indexPath.section==3 && indexPath.row==2) {
        AboutViewController *aboutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"about"];
        [self.navigationController pushViewController:aboutVC animated:YES];
    }
}

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    switch (switchControl.tag) {
        case 1:
            if (switchControl.isOn==YES) {
                isPrivate = [NSMutableString stringWithFormat:@"1"];
            }
            else {
                isPrivate = [NSMutableString stringWithFormat:@"0"];
            }
            break;
        case 2:
            if (switchControl.isOn==YES) {
                isChatOn = [NSMutableString stringWithFormat:@"1"];
            }
            else {
                isChatOn = [NSMutableString stringWithFormat:@"0"];
            }
            break;
        case 3:
            if (switchControl.isOn==YES) {
                isLikesOn = [NSMutableString stringWithFormat:@"1"];
            }
            else {
                isLikesOn = [NSMutableString stringWithFormat:@"0"];
            }
            break;
        case 4:
            if (switchControl.isOn==YES) {
                isPhotoTagsOn = [NSMutableString stringWithFormat:@"1"];
            }
            else {
                isPhotoTagsOn = [NSMutableString stringWithFormat:@"0"];
            }
            break;
        case 5:
            if (switchControl.isOn==YES) {
                isCommentsOn = [NSMutableString stringWithFormat:@"1"];
            }
            else {
                isCommentsOn = [NSMutableString stringWithFormat:@"0"];
            }
            break;
        case 6:
            if (switchControl.isOn==YES) {
                isQuickSnapOn = [NSMutableString stringWithFormat:@"1"];
            }
            else {
                isQuickSnapOn = [NSMutableString stringWithFormat:@"0"];
            }
            break;
            
        default:
            break;
    }
    NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
}

#pragma mark Send Email

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed: {
            [self showAlertViewWithMessage:@"You Phone has not Configured Mail"];
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Show AlertView

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - API Handling

- (void)getSettingDetails {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self settingGetApiCall:^(BOOL result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        bioString = [settingMutableDictionaty valueForKey:@"bio"];
        displayNameString = [settingMutableDictionaty valueForKey:@"display_name"];
        websiteString = [settingMutableDictionaty valueForKey:@"setting_website"];
        isPrivate = [settingMutableDictionaty valueForKey:@"isPrivate"];
        isChatOn = [settingMutableDictionaty valueForKey:@"isChatOn"];
        isLikesOn = [settingMutableDictionaty valueForKey:@"isLikesOn"];
        isPhotoTagsOn = [settingMutableDictionaty valueForKey:@"isPhotoTagsOn"];
        isCommentsOn = [settingMutableDictionaty valueForKey:@"isCommentsOn"];
        isQuickSnapOn = [settingMutableDictionaty valueForKey:@"isQuickSnapOn"];
        [settingTableView reloadData];
    }];
}

- (void)postSettingDetails {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self settingPostApiCall:^(BOOL result) {
        if (result) {
        }
    }];
}

-(void)settingPostApiCall:(void (^)(BOOL result)) return_block {
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/change_setting.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];

    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request addPostValue:bioString forKey:@"bio"];
    [request addPostValue:websiteString forKey:@"setting_website"];
    [request addPostValue:displayNameString forKey:@"display_name"];
    [request addPostValue:isPrivate forKey:@"isPrivate"];
    [request addPostValue:isChatOn forKey:@"isChatOn"];
    [request addPostValue:isLikesOn forKey:@"isLikesOn"];
    [request addPostValue:isPhotoTagsOn forKey:@"isPhotoTagsOn"];
    [request addPostValue:isCommentsOn forKey:@"isCommentsOn"];
    [request addPostValue:isQuickSnapOn forKey:@"isQuickSnapOn"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        if([root[@"msg"] isEqualToString:@"success"]) {
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

-(void)settingGetApiCall:(void (^)(BOOL result)) return_block{
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_setting.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id" ] forKey:@"user_id"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"Login Root %@",root);
        if (root[@"user_id"]!=NULL) {
            settingMutableDictionaty=[root mutableCopy];
            NSArray *nulleys = [settingMutableDictionaty allKeysForObject:[NSNull null]];
            [settingMutableDictionaty removeObjectsForKeys:nulleys];
            return_block(TRUE);
        }
        else{
        }
    }];
}

-(void)displayNamePostApiCall:(void (^)(BOOL result)) return_block {
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/change_display_name.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request addPostValue:self.displayName forKey:@"display_name"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        if([root[@"msg"] isEqualToString:@"display name can not be blank"]) {
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Hey Something is Wrong"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else if([root[@"status"] isEqualToString:@"success"]) {
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


-(void)deactivateAccountGetApiCall:(NSString *)password completionBlock:(void (^)(BOOL result)) return_block {
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/deactivate_ac.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] forKey:@"username"];
    [request addPostValue:password forKey:@"password"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"Login Root %@",root);
        if([root[@"msg"] isEqualToString:@"Your Account Hass Been Deactivated!"]) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"id"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [ApplicationDelegate Initialize];
        }
        else if (root==NULL)
        {
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Hey Something is Wrong"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else if ([root[@"error"] isEqualToString:@"Invalid Username Or Password"]) {
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"InCorrect Password"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ((textField.text.length > 80 && range.length == 0) && (textField.tag==2 && ![string isEqualToString:@"\n"])) {
    	return NO; // return NO to not change text
    }
    else if ((textField.text.length > 15 && range.length == 0) && (textField.tag==1 && ![string isEqualToString:@"\n"])) {
    	return NO; // return NO to not change text
    }
    else if ((textField.text.length > 40 && range.length == 0) && (textField.tag==3 && ![string isEqualToString:@"\n"])) {
    	return NO; // return NO to not change text
    }
    else {
        return YES;
    }
}

#pragma mark - IBActions

-(IBAction)hideKeyboardOnReturnTap:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)btnDeleteAccountClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Are you sure you want to delete you account" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alert.tag = 1;
    [alert show];
}

- (IBAction)btnLogoutClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [ApplicationDelegate Initialize];
    //[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIAlert Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag==2 && buttonIndex==1) {
        NSLog(@"Delete");
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *text = [[alertView textFieldAtIndex:0] text];
        [self deactivateAccountGetApiCall:text completionBlock:^(BOOL result) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
    else if (alertView.tag==1 && buttonIndex==1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Password" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.tag = 2;
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert show];
    }
}

@end
