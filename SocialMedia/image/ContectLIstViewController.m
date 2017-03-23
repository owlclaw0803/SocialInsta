//
//  ContectLIstViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 16/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "ContectLIstViewController.h"

@interface ContectLIstViewController ()

@end

@implementation ContectLIstViewController
@synthesize resulatArray;

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
    
    resulatArray = [[NSMutableArray alloc] init];
    emailString = [[NSMutableString alloc] init];
    ContectNumberString=[[NSMutableString alloc]init];
    addressBookRef=ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self getCOntectlist];
            }
        });
    }else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        [self getCOntectlist];
    }else{
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:@"change privacy setting in settings app!!!"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:4.0];
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
    
    NSLog(@"%@",emailString);
    NSLog(@"%@",ContectNumberString);
    [self GetContectlistFriends:ContectNumberString email:emailString completionBlock:^(BOOL result) {
    }];
	
    _tbleViewObj.tableFooterView = [[UIView alloc] init];
	// Do any additional setup after loading the view.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    [self GetContectlistFriends:ContectNumberString email:emailString completionBlock:^(BOOL result) {
        
    }];
}

-(void)getCOntectlist
{
    CFArrayRef allpeople=ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    CFIndex index=ABAddressBookGetPersonCount(addressBookRef);
    
    NSLog(@"%ld",index);
    for (CFIndex i=0;i<index ; i++) {
        
        record=CFArrayGetValueAtIndex(allpeople, i);
        
        ABMultiValueRef Email=ABRecordCopyValue(record, kABPersonEmailProperty);
        NSString *strEmail=(__bridge NSString *)(ABMultiValueCopyValueAtIndex(Email, 0));
        NSString *strWork=(__bridge NSString *)(ABMultiValueCopyValueAtIndex(Email, 1));
        
        ABMultiValueRef phone=ABRecordCopyValue(record, kABPersonPhoneProperty);
        NSString *strMobile=(__bridge NSString *)(ABMultiValueCopyValueAtIndex(phone, 0));
        NSString *newstrMobile = [[strMobile componentsSeparatedByCharactersInSet:
                                   [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                  componentsJoinedByString:@""];
        newstrMobile = [newstrMobile stringByTrimmingCharactersInSet:[NSCharacterSet nonBaseCharacterSet]];
        
        NSString *strIphone=(__bridge NSString *)(ABMultiValueCopyValueAtIndex(phone, 1));
        NSString *newstrIphone = [[strIphone componentsSeparatedByCharactersInSet:
                                   [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                  componentsJoinedByString:@""];
        newstrIphone = [newstrIphone stringByTrimmingCharactersInSet:[NSCharacterSet nonBaseCharacterSet]];
        
        NSString *strHome=(__bridge NSString *)(ABMultiValueCopyValueAtIndex(phone, 2));
        NSString *newstrHome = [[strHome componentsSeparatedByCharactersInSet:
                                 [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                componentsJoinedByString:@""];
        newstrHome = [newstrHome stringByTrimmingCharactersInSet:[NSCharacterSet nonBaseCharacterSet]];
        
        
        NSString *str=[NSString stringWithFormat:@"%@,%@,%@",newstrMobile,newstrIphone,newstrHome];
        NSString *email=[NSString stringWithFormat:@"%@;%@",strEmail,strWork];
        
        [emailString appendString:[NSString stringWithFormat:@";%@",email]];
        emailString = [[emailString stringByReplacingOccurrencesOfString:@";(null)"
                                                              withString:@""]
                       mutableCopy];
        
        
        [ContectNumberString appendString:[NSString stringWithFormat:@",%@",str]];
        
        ContectNumberString = [[ContectNumberString stringByReplacingOccurrencesOfString:@",(null)"                                                                       withString:@""] mutableCopy];
    }
    
    NSLog(@"%@",emailString);
    NSLog(@"%@",ContectNumberString);
    [self GetContectlistFriends:ContectNumberString email:emailString completionBlock:^(BOOL result) {
    }];
}

- (IBAction)backVc:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)GetContectlistFriends:(NSMutableString *)phonenumber email:(NSMutableString *)email completionBlock:(void (^)(BOOL result)) return_block{
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/check_phone_contacts.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    request.shouldAttemptPersistentConnection   = NO;
    [request setValidatesSecureCertificate:NO];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:phonenumber forKey:@"phone_nums"];
    [request addPostValue:email forKey:@"emails"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"Login Root %@",root);
        
        if (root==NULL) {
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Contect friends are not use This App"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else{
            [self populateCollection:root completionBlock:^(BOOL result) {
                [self.tbleViewObj reloadData];
            }];
        }
    }];
    
    [request setFailedBlock:^{
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:4.0];
    }];
}

-(void)populateCollection:(NSMutableArray *)collectionArray completionBlock:(void (^)(BOOL result)) return_block{
    
    resulatArray = NULL;
    resulatArray = [[NSMutableArray alloc]init];
    resulatArray = [collectionArray mutableCopy];
    NSLog(@"MUT%@",resulatArray);
    
    return_block(true);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [resulatArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *aCell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UIImageView *aImageView = (UIImageView*)[aCell viewWithTag:1];
    aImageView.layer.cornerRadius = aImageView.frame.size.width/2;
    aImageView.layer.masksToBounds = YES;
    NSString *astr = [[resulatArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/thumb/%@-profile.jpg", astr ];
    NSURL *aimageurl = [NSURL URLWithString:aStrDisplyimage];
    [aImageView setImageWithURL:aimageurl];
    
    UILabel *aDisplayName = (UILabel*)[aCell viewWithTag:2];
    aDisplayName.text=[[resulatArray objectAtIndex:indexPath.row]objectForKey:@"display_name"];
    
    UILabel *aUserName = (UILabel*)[aCell viewWithTag:3];
    aUserName.text = [[resulatArray objectAtIndex:indexPath.row]objectForKey:@"username"];
    
    UIButton *btnFollow = (UIButton*)[aCell viewWithTag:4];
    [btnFollow addTarget:self action:@selector(Followbtn:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[[[resulatArray objectAtIndex:indexPath.row] objectForKey:@"follow01"] description]isEqualToString:@"1"]) {
        [btnFollow setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        [btnFollow setSelected:NO];
    }else{
        [btnFollow setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
        [btnFollow setSelected:YES];
    }
    return aCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"user"]isEqualToString:@"n"]) {
    //
    //
    //    UIStoryboard *storyboard = self.navigationController.storyboard;
    //
    //    FollowersProfileVC *followerProfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    //    followerProfile.userid=[[resulatArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    //    [self.navigationController  pushViewController:followerProfile animated:YES];
    //    }
    //
    //    else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"user"]isEqualToString:@"v"]){
    //
    //        if ([[[resulatArray objectAtIndex:indexPath.row] objectForKey:@"user_type"]isEqualToString:@"c"]) {
    //            NSString *str=[[resulatArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    //            UIStoryboard *storyboard = self.navigationController.storyboard;
    //            VIPProfileVC  *vipPrfile = [storyboard instantiateViewControllerWithIdentifier:@"vip"];
    //            vipPrfile.userId=str;
    //            [self.navigationController pushViewController:vipPrfile animated:YES];
    //        }
    //        else{
    //            UIStoryboard *storyboard = self.navigationController.storyboard;
    //
    //            FollowersProfileVC *followerProfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    //            followerProfile.userid=[[resulatArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    //            [self.navigationController  pushViewController:followerProfile animated:YES];
    //        }
    //    }
    //    else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"user"]isEqualToString:@"c"]){
    //
    //
    //        if ([[[resulatArray objectAtIndex:indexPath.row] objectForKey:@"user_type"]isEqualToString:@"c"]) {
    NSString *str = [[resulatArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    UIStoryboard *storyboard = self.navigationController.storyboard;
    ProfileViewController  *vipPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    vipPrfile.userId = str;
    [self.navigationController pushViewController:vipPrfile animated:YES];
    //        }
    //        else{
    //            UIStoryboard *storyboard = self.navigationController.storyboard;
    //
    //            FollowersProfileVC *followerProfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    //            followerProfile.userid=[[resulatArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    //            [self.navigationController  pushViewController:followerProfile animated:YES];
    //
    //
    //
    //        }
    //
    //
    //    }
}

- (IBAction)Followbtn:(id)sender{
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tbleViewObj];
    NSIndexPath *hitIndex = [self.tbleViewObj indexPathForRowAtPoint:hitPoint];
    NSLog(@"%ld",(long)hitIndex.row);
    
    NSString *aStrFolloeID=[[resulatArray objectAtIndex:hitIndex.row] objectForKey:@"id"];
    
    [self FollowUnfollowApiCall:(NSString *)aStrFolloeID completionBlock:^(BOOL result) {
        [self GetContectlistFriends:ContectNumberString email:emailString completionBlock:^(BOOL result) {
        }];
    }];
}

-(void)FollowUnfollowApiCall:(NSString *)imageID completionBlock:(void (^)(BOOL result)) return_block{
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/follow.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request setPostValue:imageID forKey:@"user_id2"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        if([root[@"status"]isEqualToString:@"success"])
        {
            return_block(TRUE);
        }
    }];
    
    [request setFailedBlock:^{
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

@end
