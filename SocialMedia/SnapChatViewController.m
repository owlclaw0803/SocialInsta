//
//  SnapChatViewController.m
//  SocialMedia
//
//  Created by kangZhe on 9/6/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "SnapChatViewController.h"
#import "SWTableViewCell.h"
#import "AsyncImageView.h"
#import "Base64.h"

@interface SnapChatViewController ()

@end

@implementation SnapChatViewController

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
    if(self.capturedimage)
        self.m_photoview.image = self.capturedimage;
    timercount = 1;
    pickerContent=[[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",nil];
    followings = [[NSMutableArray alloc] init];
    self.m_tblview.tableFooterView = [[UIView alloc] init];
    [self.m_btnSend setHidden:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)snapChatApiCall:(void (^)(BOOL result)) return_block{
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/post_snap.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    NSData *img = UIImageJPEGRepresentation(self.capturedimage, 0.3f);
    NSString *imagestring = [Base64 encode:img];
    NSString *myuserid = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
    NSArray *rows = [self.m_tblview indexPathsForSelectedRows];
    NSString *touser = @"";
    for(int i = 0 ; i < rows.count ; i++){
        NSIndexPath *index = (NSIndexPath*)[rows objectAtIndex:i];
        NSString* touserid = [[followings objectAtIndex:index.row] objectForKey:@"user_id"];
        touser = [NSString stringWithFormat:@"%@%@",touser,touserid];
        if(i != rows.count-1)
            touser = [NSString stringWithFormat:@"%@ ",touser];
    }
    //NSString *lat=locationManager.location.coordinate.latitude;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:myuserid forKey:@"user_id"];
    [request addPostValue:imagestring forKey:@"photo"];
    [request addPostValue:[NSString stringWithFormat:@"%d",timercount] forKey:@"countdown"];
    [request addPostValue:touser forKey:@"to_user_id"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error = nil;
        NSData *data = [request responseData];
        NSString *content = [[NSString alloc]  initWithBytes:[data bytes]
                                                      length:[data length] encoding: NSUTF8StringEncoding];
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
        //NSLog(@"News Root %@",root);
        if(root != NULL)
        {
            //go to first page
            [self.navigationController popToRootViewControllerAnimated:YES];
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

- (IBAction)onClickSend:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self snapChatApiCall:^(BOOL result) {
    }];
}

- (IBAction)onclickBtnTimer:(id)sender {
    [self openPickerView];
}

- (IBAction)onclickForwardBtn:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.m_view1.frame = CGRectMake(-320, self.m_view1.frame.origin.y, 320, self.m_view1.frame.size.height);
        self.m_view2.frame = CGRectMake(0, self.m_view2.frame.origin.y, 320, self.m_view2.frame.size.height);
    }completion:^(BOOL finished){
        status = 2;
        [self.m_btnSend setHidden:NO];
    }];
}

- (IBAction)onclickBackBtn:(id)sender {
    if(status == 2){
        [UIView animateWithDuration:0.5 animations:^{
            self.m_view1.frame = CGRectMake(0, self.m_view1.frame.origin.y, 320, self.m_view1.frame.size.height);
            self.m_view2.frame = CGRectMake(320, self.m_view2.frame.origin.y, 320, self.m_view2.frame.size.height);
        }completion:^(BOOL finished){
            status = 1;
            [self.m_btnSend setHidden:YES];
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)openPickerView
{
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:nil
                                     cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                     otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [actionSheet addSubview:pickerView];
    // [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Done"]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(actionSheetDoneButtonClicked:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];
    // [closeButton release];
    
    UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    cancelButton.momentary = YES;
    cancelButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
    cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
    cancelButton.tintColor = [UIColor blackColor];
    [cancelButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:cancelButton];
    
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

-(void)viewWillAppear:(BOOL)animated
{
    status = 1;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_following.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    request.shouldAttemptPersistentConnection   = NO;
    [request setValidatesSecureCertificate:NO];
    
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        //NSLog(@"News Root %@",root);
        if(root != NULL)
        {
            followings = Nil;
            followings = [[NSMutableArray alloc]init];
            for (int i=0 ; i < [root count] ; i++) {
                [followings addObject:[root objectAtIndex:i]];
            }
            [self.m_tblview reloadData];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

-(void)actionSheetDoneButtonClicked:(UIButton*)sender
{
    int selectIndex = [pickerView selectedRowInComponent:0];
    
    //sexTextField.text = [pickerContent objectAtIndex:selectIndex];
    timercount = [[pickerContent objectAtIndex:selectIndex] intValue];
    [self.m_btntimer setTitle:[NSString stringWithFormat:@"%d",selectIndex+1] forState:UIControlStateNormal];
    
    //[passwordTextField becomeFirstResponder];
    
    [ actionSheet dismissWithClickedButtonIndex:1 animated:YES];
}

-(void)dismissActionSheet:(UIButton*)sender
{
    [ actionSheet dismissWithClickedButtonIndex:1 animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [pickerContent count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [pickerContent objectAtIndex:row];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [followings count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    AsyncImageView *imageview = [[AsyncImageView alloc]initWithFrame:CGRectMake(10, 15,50,50)];
    //[imageview setTag:2];
    [cell.contentView addSubview:imageview];
    imageview.layer.cornerRadius = imageview.frame.size.width/2;
    imageview.layer.masksToBounds = YES;
    NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/thumb/%@-profile.jpg", [[followings objectAtIndex:indexPath.row] objectForKey:@"user_id"]];
    [imageview setImageURL:[NSURL URLWithString:aStrDisplyimage]];
    
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(80, 25, 240, 30)];
    //[lblCommntName setTag:3];
    [cell.contentView addSubview:lblTitle];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica-Light" size:17.0]];
    lblTitle.text = [[followings objectAtIndex:indexPath.row] objectForKey:@"display_name"];
    lblTitle.textColor = [UIColor whiteColor];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

@end
