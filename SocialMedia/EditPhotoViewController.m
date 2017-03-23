//
//  EditPhotoViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 07/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "EditPhotoViewController.h"

@interface EditPhotoViewController ()

@end

@implementation EditPhotoViewController
@synthesize imageObj;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    //[self.scrollView contentSizeToFit];
    self.tabbar = [[UITabBarController alloc] init];
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
	// Do any additional setup after loading the view.
    if (self.videoURL == NULL) {
        if (self.aBoolpano) {
            if([UIScreen mainScreen].bounds.size.height == 480) {
                scroll.frame = CGRectMake(0, 66, 320,350);
            }
            else if([UIScreen mainScreen].bounds.size.height == 568){
                scroll.frame = CGRectMake(0, 66, 320,442);
            }
            //[self.view insertSubview:scroll atIndex:0];
            [scroll setBounces:NO];
            pano = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageObj.size.width*scroll.frame.size.height/imageObj.size.height, scroll.frame.size.height)];
            [pano setBackgroundColor:[UIColor clearColor]];
            pano.contentMode = UIViewContentModeScaleAspectFill;
            pano.image = imageObj;
            [scroll addSubview:pano];
            [scroll setContentSize:CGSizeMake(imageObj.size.width*scroll.frame.size.height/imageObj.size.height,0)];
        } else {
            imageview.image = imageObj;
            CGRect rt = CGRectMake(0, 66, imageObj.size.width*imageview.frame.size.height/imageObj.size.height, imageview.frame.size.height);
            if(rt.size.width > 320)
                rt.size.width = 320;
            rt.origin.x = (320-rt.size.width)/2;
            imageview.frame = rt;
        }
    } else {
        videoController = [[MPMoviePlayerController alloc] init];
        [videoController setContentURL:self.videoURL];
        if([UIScreen mainScreen].bounds.size.height == 480){
            [videoController.view setFrame:CGRectMake (0, 66, 320, 400)];
        }
        else if([UIScreen mainScreen].bounds.size.height == 568){
            [videoController.view setFrame:CGRectMake (0, 66, 320, 442)];
        }
        //[self.view insertSubview:videoController.view belowSubview:sharingView];
        [self.view insertSubview:videoController.view atIndex:0];
        [videoController play];
    }
    sharingView.layer.zPosition = 40;
    btnfacebook.layer.zPosition = 50;
    btntwitter.layer.zPosition = 50;
    btnEditPhoto.layer.zPosition = 50;
    btnSaveCameraroll.layer.zPosition = 50;
    txtfield.layer.zPosition = 50;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    if (self.videoURL == NULL) {
        [editLabel setText:@"EDIT PHOTO"];
    }
    else {
        [editLabel setText:@"EDIT VIDEO"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editPhoto:(id)sender {
    NSArray * toolOrder = @[kAFEnhance, kAFEffects, kAFAdjustments, kAFFocus,  kAFStickers,  kAFOrientation, kAFCrop,  kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme , kAFFrames];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    AFPhotoEditorController *editorController;
    if (self.videoURL == NULL) {
        if(self.aBoolpano)
            editorController = [[AFPhotoEditorController alloc] initWithImage:pano.image];
        else
            editorController = [[AFPhotoEditorController alloc] initWithImage:imageview.image];
    }else{
        editorController = [[AFPhotoEditorController alloc] initWithImage:self.videoImage];
    }
    
    [editorController setDelegate:self];
    [self presentViewController:editorController animated:YES completion:nil];
}

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)imagez
{
    if(self.aBoolpano)
        [pano setImage:imagez];
    else
        [imageview setImage:imagez];
    // editImagePub = imagez;

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)AddLocation:(id)sender {
    [mapView GetCurrentLoc];
    
    userLoc = [[Place alloc]init];
    userLoc.name = @"Current UserName";
    userLoc.description = @"Current Location";
    userLoc.latitude = mapView.userlatitude;
    userLoc.longitude = mapView.userlongitude;
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.distanceFilter = 100.0;
    if([self checkForLocationPrivacy]){
        [locationManager startUpdatingLocation];
        locationManager.headingFilter = 0.1;
        [locationManager startUpdatingHeading];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTime:) name:@"updateTime" object:nil];
    }
    else{
        //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ProjectName message:alertLocationLibAcess delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        //    [alert show];
    }
}

-(void)updateTime:(NSDictionary*)infoDictionary{
    NSString *strDistTime =[infoDictionary valueForKey:@"object"];
    strDistTime = [strDistTime stringByReplacingOccurrencesOfString:@" (" withString:@""];
    strDistTime = [strDistTime stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSArray *arrDistTime = [strDistTime componentsSeparatedByString:@" / "];
    //    _lblTime.text=[NSString stringWithFormat:@"%@",[arrDistTime objectAtIndex:0]];
    //    _lbldistance.text=[NSString stringWithFormat:@"%@",[arrDistTime objectAtIndex:1]];
    NSLog(@"%@",arrDistTime);
}

-(BOOL)checkForLocationPrivacy
{
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        return TRUE;
    }
    return FALSE;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    ApplicationDelegate.boolCenterMap=FALSE;
    CLLocation *location=[locations lastObject];
    userLoc.longitude=location.coordinate.longitude;
    userLoc.latitude=location.coordinate.latitude;
    _latitude=[NSString stringWithFormat:@"%f", userLoc.latitude];
    _longitude=[NSString stringWithFormat:@"%f", userLoc.longitude];
}

-(BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return YES;
}

-(void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
}

- (IBAction)Post:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.videoURL == NULL) {
        if (self.aBoolpano) {
            [self panoUplodApiCall:^(BOOL result) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Post"];
                //[self showAlertWithMessage:@"Panorama is Successfully Shared"];
                [self.navigationController popViewControllerAnimated:YES];
                //[self.navigationController pushViewController:self.tabbar animated:YES];
                //[self.tabBarController setSelectedIndex:0];
            }];
        }
        else{
            [self photoUplodApiCall:^(BOOL result) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Post"];
                //[self showAlertWithMessage:@"Photo is Successfully Shared"];
                [self.navigationController popViewControllerAnimated:YES];
                //[self.navigationController pushViewController:self.tabbar animated:YES];
                //[self performSegueWithIdentifier:@"done" sender:NULL];
                //[self.tabBarController setSelectedIndex:0];
            }];
        }
    }
    else{
        [self videoUplodApiCall:^(BOOL result) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Post"];
            //[self showAlertWithMessage:@"Video is Successfully Shared"];
            [self.navigationController popViewControllerAnimated:YES];
            //[self.navigationController pushViewController:self.tabbar animated:YES];
            //[self performSegueWithIdentifier:@"done" sender:NULL];
            //[self.tabBarController setSelectedIndex:0];
        }];
    }
}

- (void)photoUplodApiCall:(void (^)(BOOL result)) return_block{
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/post.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    NSData *img = UIImageJPEGRepresentation(imageview.image, 0.3f);
    NSString *imagestring = [Base64 encode:img];
    NSData *video = [NSData dataWithContentsOfURL:self.videoURL];
    NSString *videostring = [Base64 encode:video];
    //NSString *lat=locationManager.location.coordinate.latitude;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:imagestring forKey:@"photo"];
    [request addPostValue:videostring forKey:@"video"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id" ] forKey:@"user_id"];
    if ([[txtfield text] length]>0 && [[txtfield text] isEqualToString:@"Caption..."]) {
        [request addPostValue:@"" forKey:@"caption"];
    }
    else {
        [request addPostValue:txtfield.text forKey:@"caption"];
    }
    [request addPostValue:_longitude forKey:@"long"];
    [request addPostValue:_latitude forKey:@"lat"];
    request.timeOutSeconds = 60;
    [request startAsynchronous];
    [locationManager stopUpdatingLocation];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"update Root %@",root);
        
        if (root[@"id"]!=NULL) {
            return_block(TRUE);
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

-(void)videoUplodApiCall:(void (^)(BOOL result)) return_block{
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/post_video.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    //NSData *video=[NSData dataWithContentsOfURL:self.videoURL];
    // NSString *videostring=[Base64 encode:video];
    NSData *img=UIImageJPEGRepresentation(self.videoImage, 0.3f);
    NSString *imagestring = [Base64 encode:img];
    
    [imageview setImage:self.videoImage];
    
    [request addRequestHeader:@"Content-Type" value:@"multipart/form-data"];
    [request addFile:self.videoStr forKey:@"video"];
    [request addPostValue:imagestring forKey:@"image"];
    [request addPostValue:@"v" forKey:@"post_type"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id" ] forKey:@"user_id"];
    [request addData:img forKey:@"image"];
    if ([[txtfield text] length]>0 && [[txtfield text] isEqualToString:@"Caption..."]) {
        [request addPostValue:@"" forKey:@"caption"];
    }
    else {
        [request addPostValue:txtfield.text forKey:@"caption"];
    }
    // [request addPostValue:_longitude forKey:@"long"];
    //[request addPostValue:_latitude forKey:@"lat"];
    request.timeOutSeconds = 200;
    [request startAsynchronous];
    [locationManager stopUpdatingLocation];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSString *myString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        NSLog(@"ResponseData is %@",myString);
        NSLog(@"update Root %@",root);
        return_block(TRUE);
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

-(void)panoUplodApiCall:(void (^)(BOOL result)) return_block{
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/post.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    NSData *img=UIImageJPEGRepresentation(pano.image, 0.3f);
    NSString *imagestring=[Base64 encode:img];

    //NSString *lat=locationManager.location.coordinate.latitude;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:imagestring forKey:@"photo"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id" ] forKey:@"user_id"];
    if ([[txtfield text] length]>0 && [[txtfield text] isEqualToString:@"Caption..."]) {
        [request addPostValue:@"" forKey:@"caption"];
    }
    else {
        [request addPostValue:txtfield.text forKey:@"caption"];
    }
    [request addPostValue:_longitude forKey:@"long"];
    [request addPostValue:_latitude forKey:@"lat"];
    [request addPostValue:@"p" forKey:@"post_type"];
    request.timeOutSeconds = 60;
    [request startAsynchronous];
    [locationManager stopUpdatingLocation];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"update Root %@",root);
        
        if (root[@"id"]!=NULL) {
            return_block(TRUE);
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

- (IBAction)back:(id)sender {
    [videoController stop];
    videoController = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)SavePhotoOnClick:(id)sender {
    
    if (self.videoURL == NULL) {
        if (self.aBoolpano) {
            UIImageWriteToSavedPhotosAlbum(pano.image, nil, nil, nil);
            [self showSharingAlert:@"Camera Roll" WithMessage:@"Your panorama has been saved."];
        }
        else {
            UIImageWriteToSavedPhotosAlbum(imageview.image, nil, nil, nil);
            [self showSharingAlert:@"Camera Roll" WithMessage:@"Your photo has been saved."];
        }
    } else {
        UISaveVideoAtPathToSavedPhotosAlbum(self.videoStr,nil,nil,nil);
        [self showSharingAlert:@"Camera Roll" WithMessage:@"Your video has been saved."];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView setText:@""];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(0, -170, 320, self.view.frame.size.height);
    }completion:^(BOOL finished){
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (![textView text].length>0) {
        [textView setText:@"Caption..."];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"])
    {
        //[self Post:nil];
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        }completion:^(BOOL finished){
        }];
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)btnshareFacebook:(id)sender {
    NSString *title = @"Social Media";
    NSString *sharingEvent;
    if ([[txtfield text] length]>0 && [[txtfield text] isEqualToString:@"Caption..."]) {
        sharingEvent = @"";
    } else {
        sharingEvent = [txtfield text];
    };
    Class composeViewControllerClass = [SLComposeViewController class];
    
    if(composeViewControllerClass == nil || ![composeViewControllerClass isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Please make sure you are logged into Facebook before you can share" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        
        SLComposeViewController *composeViewController = [composeViewControllerClass composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeViewController setInitialText:sharingEvent];
        if (self.videoURL == NULL) {
            if (self.aBoolpano) {
                [composeViewController addImage:pano.image];
            }
            else {
                [composeViewController addImage:imageview.image];
            }
        } else {
            [composeViewController addURL:self.videoURL];
        }
        [composeViewController setInitialText:sharingEvent];
        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    //[self showSharingAlert:@"Congratulations" WithMessage:@"Successfully Shared on Facebook"];
                    break;
                    
                default:
                    break;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}

- (IBAction)btnshareTwitter:(id)sender {
    
    NSString *sharingEvent;
    if ([[txtfield text] length]>0 && [[txtfield text] isEqualToString:@"Caption..."]) {
        sharingEvent = @"";
    } else {
        sharingEvent = [txtfield text];
    };
    Class composeViewControllerClass = [SLComposeViewController class];
    
    if(composeViewControllerClass == nil || ![composeViewControllerClass isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"Please make sure you are logged into Twitter before you can share" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        
        SLComposeViewController *composeViewController = [composeViewControllerClass composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:sharingEvent];
        if (self.videoURL == NULL) {
            if (self.aBoolpano) {
                [composeViewController addImage:pano.image];
            }
            else {
                [composeViewController addImage:imageview.image];
            }
        } else {
            [composeViewController addURL:self.videoURL];
        }
        [composeViewController setInitialText:sharingEvent];
        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    //[self showSharingAlert:@"Congratulations" WithMessage:@"Successfully Shared on Twitter"];
                    break;
                    
                default:
                    break;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}

#pragma mark - UIAlertView

- (void)showSharingAlert:(NSString *)title WithMessage:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showAlertWithMessage:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    alert.tag = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag==1 && buttonIndex==0) {
        [self.navigationController popViewControllerAnimated:YES];
        //[self.tabBarController setSelectedIndex:0];
    }
}

@end
