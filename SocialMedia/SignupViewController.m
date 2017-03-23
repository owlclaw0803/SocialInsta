//
//  SignupViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 01/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "SignupViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

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
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Final" withExtension:@"gif"];
    gifImageview.image=[UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    
    [self.scrolleView contentSizeToFit];
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    optionsArray = [[NSMutableArray alloc] initWithObjects:@"Personal",@"Business", nil];
    [txtUsername setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [txtEmail setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [txtPassword setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [txtRePassword setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [txtPhone setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [txtOptions setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    profilePicAction = [[UIActionSheet alloc]initWithTitle:@"Change Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Current Photo" otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
    [self.view addSubview:profilePicAction];
    
    imagePickerController = [[UIImagePickerController alloc]init];
    [imagePickerController setDelegate:self];
    
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    imageView.layer.masksToBounds = YES;
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setImage:[UIImage imageNamed:@"addphoto.png"]];
    isDefaultImage = YES;
    UITapGestureRecognizer *changeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeProfilePicture:)];
    [imageView addGestureRecognizer:changeTap];
    imageView.userInteractionEnabled=YES;
    
    isShowOptions=NO;
    [optionView setHidden:YES];
    //NSURL *imageurl=[NSURL URLWithString:[[NSUserDefaults standardUserDefaults]objectForKey:@"image"]];
    //imageView.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:imageurl]];
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

- (IBAction)signUp:(id)sender {
    
    if ([txtPassword.text isEqualToString:txtRePassword.text]) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self signUpApiCall:^(BOOL result) {
            if (result) {
                [self performSegueWithIdentifier:@"SignupToTab" sender:NULL];
            }
        }];
    }
    else{
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:@"Password is Not Same"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:4.0];
       }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)changeProfilePicture:(id)sender {
    [profilePicAction showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0)
    {
    }
    if (buttonIndex == 1) {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.allowsEditing=YES;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
        else{
            UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"Camera" message:@"Camera is Not Available" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alt show];
        }
    }
    if (buttonIndex == 2){
        
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing=YES;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    imageView.image = image;
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    imageView.layer.masksToBounds = YES;
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    isDefaultImage = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController.viewControllers count] == 3)
    {
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        
        UIView *plCropOverlay = [[[viewController.view.subviews objectAtIndex:1]subviews] objectAtIndex:0];
        
        plCropOverlay.hidden = YES;
        
        int position = 0;
        
        if (screenHeight == [UIScreen mainScreen].bounds.size.height)
        {
            position = 124;
        }
        else
        {
            position = 80;
        }
        
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        
        UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:
                               CGRectMake(0.0f, position, 320.0f, 320.0f)];
        [path2 setUsesEvenOddFillRule:YES];
        
        [circleLayer setPath:[path2 CGPath]];
        
        [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 320, screenHeight-72) cornerRadius:0];
        
        [path appendPath:path2];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        fillLayer.opacity = 0.8;
        [viewController.view.layer addSublayer:fillLayer];
        
        UILabel *moveLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 50)];
        [moveLabel setText:@"Move and Scale"];
        [moveLabel setTextAlignment:NSTextAlignmentCenter];
        [moveLabel setTextColor:[UIColor whiteColor]];
        
        [viewController.view addSubview:moveLabel];
    }
}

-(void)signUpApiCall:(void (^)(BOOL result)) return_block{
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/user_signup.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    NSData *img,*cover;
    if (isDefaultImage==YES) {
        img=UIImageJPEGRepresentation([UIImage imageNamed:@"DefaultUser.png"], 0.3);
    } else {
        img=UIImageJPEGRepresentation(imageView.image, 0.3f);
    }
    //cover = UIImageJPEGRepresentation([UIImage imageNamed:@"backgroundimage@2x.png"], 0.3f);
    
    NSString *imagestring=[Base64 encode:img];
    //NSString *coverstring=[Base64 encode:cover];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    [request addPostValue:txtEmail.text forKey:@"email"];
    [request addPostValue:txtPassword.text forKey:@"password"];
    [request addPostValue:txtUsername.text forKey:@"username"];
    //[request addPostValue:fullNameTxt.text forKey:@"display_name"];
    [request addPostValue:txtPhone.text forKey:@"contact_number"];
    [request addPostValue:imagestring forKey:@"photo"];
    //[request addPostValue:coverstring forKey:@"cover_photo"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"fbid"] forKey:@"fb_id"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSString *str = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        NSLog(@"SignUp Root %@ and %@",root,str);
        if(root[@"id"]!=NULL ) {
            
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"id"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"username"];
            [[NSUserDefaults standardUserDefaults]setObject:root[@"id"] forKey:@"id"];
             [[NSUserDefaults standardUserDefaults]setObject:txtUsername.text forKey:@"username"];
            return_block(TRUE);
        }
        else if ([root[@"email"]isEqualToString:@"Email occupied"]){
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Ooops This Email is already occupied"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else if ([root[@"error"]isEqualToString:@"Invalid username"]){
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Ooops Username is not valid"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else if ([root[@"error"] isEqualToString:@"Invalid request"]){
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"somthing wrong"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else if ([root[@"error"]isEqualToString:@"invalid email id"]){
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Ooops Email is not valid"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else if ([root[@"error"]isEqualToString:@"invalid password"]){
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Ooops Password is not valid"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else if ([root[@"password"]isEqualToString:@"invalid password"]){
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Password should be atleast 6 character"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else if ([root[@"error"]isEqualToString:@"Failed"]){
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Hey Something is Wrong"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else if (root==NULL)
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


- (IBAction)optnClicked:(id)sender {
    if (isShowOptions==NO) {
        [optionView setHidden:NO];
        isShowOptions=YES;
    }
    else {
        [optionView setHidden:YES];
        isShowOptions=NO;
    }
}

#pragma mark - UITableView Delegates & Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [optionsArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [txtOptions setText:[optionsArray objectAtIndex:indexPath.row]];
    [optionView setHidden:YES];
    isShowOptions=NO;
}

@end
