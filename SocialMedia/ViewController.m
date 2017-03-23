//
//  ViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 01/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "ViewController.h"
#define MyAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Final" withExtension:@"gif"];
    gifImageview.image=[UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    txtUserName.delegate=self;
    txtPassWord.delegate=self;
    [txtPassWord setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [txtUserName setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [txtFgtUsername setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [txtFgtEmail setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
	// Do any additional setup after loading the view, typically from a nib.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self LoginRequestAction:txtUserName.text password:txtPassWord.text completionBlock:^(BOOL result) {
        if (result) {
            [self performSegueWithIdentifier:@"tabSegue" sender:nil];
        }
    }];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
 //   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [self LoginRequestAction:txtUserName.text password:txtPassWord.text completionBlock:^(BOOL result) {
//        if (result) {
//            [self performSegueWithIdentifier:@"tabSegue" sender:nil];
//        }
//    }];
    
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtPassWord resignFirstResponder];
    [txtUserName resignFirstResponder];
    [txtFgtUsername resignFirstResponder];
    [txtFgtEmail resignFirstResponder];
}

- (IBAction)forgetPassword:(id)sender {
    [fgtView setHidden:NO];
    fgtView.alpha=0.0;
    [txtFgtUsername becomeFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^() {
        fgtView.alpha = 1.0;
    }];
}

- (IBAction)faceBook:(id)sender {
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyAppDelegate openSessionWithAllowLoginUI:YES completionBlock:^(BOOL result) {
        if(result){
           // [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //[self performSegueWithIdentifier:@"signup" sender:NULL];
        }
    }];
}

-(IBAction)unwindSegue:(UIStoryboardSegue *)segue{
    //    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"id"];
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (IBAction)signUp:(id)sender {
    [self performSegueWithIdentifier:@"signup" sender:NULL];
}

- (IBAction)twiter:(id)sender {
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@"upzIVEvSg5uqoSezkA"
                                                 consumerSecret:@"kEpkOKiRwRHDgp5xgeNdCh5oqxutyKnWcgDlUuw"];

    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        
        [_twitter getUserInformationFor:@"twitterapi" successBlock:^(NSDictionary *user) {
            NSLog(@"%@", user);
        } errorBlock:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
    } errorBlock:^(NSError *error) {
         NSLog(@"%@",error);
    }];
}

- (IBAction)fgtDone:(id)sender {
    
    [fgtView setHidden:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self ForgetpsswordRequestAction:txtFgtUsername.text email:txtFgtEmail.text completionBlock:^(BOOL result) {
        if (result) {
            
            UIAlertView *aAlertView=[[UIAlertView alloc]initWithTitle:@"Password reset email sent" message:@"Please check your inbox" delegate:NO cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [aAlertView show];
            
        }
    }];
    [txtFgtEmail resignFirstResponder];
    [txtFgtUsername resignFirstResponder];
}

- (IBAction)fgtCancel:(id)sender {
    
    [fgtView setHidden:YES];
    [txtFgtUsername resignFirstResponder];
    [txtFgtEmail resignFirstResponder];
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        /*
         At this point, the user can use the API and you can read his access tokens with:
         
         _twitter.oauthAccessToken;
         _twitter.oauthAccessTokenSecret;
         
         You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
         
         Next time, just instanciate STTwitter with the class method:
         
         +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
         
         Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
         */
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

-(void)LoginRequestAction:(NSString *)username password:(NSString *)password completionBlock:(void (^)(BOOL result)) return_block {
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/user_login.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    request.shouldAttemptPersistentConnection = NO;
    [request setValidatesSecureCertificate : NO];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:password forKey:@"password"];
    [request addPostValue:username forKey:@"username"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"Login Root %@",root);
        if(root[@"id"] != NULL && [[root valueForKey:@"active"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"id"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"username"];
            [[NSUserDefaults standardUserDefaults]setObject:root[@"id"] forKey:@"id"];
            [[NSUserDefaults standardUserDefaults]setObject:username forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return_block(TRUE);
        }
        else if (root[@"id"]!=NULL && [[root valueForKey:@"active"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"id"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"username"];
            [[NSUserDefaults standardUserDefaults]setObject:root[@"id"] forKey:@"id"];
            [[NSUserDefaults standardUserDefaults]setObject:username forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Do you want to activate your account" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert setTag:10];
            [alert show];
        }
        else if ([root[@"error"]isEqualToString:@"Invalid request"]){
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Please Enter Proper Username or Password"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else if ([root[@"error"]isEqualToString:@"Your account has been blocked. Please contact blocked@blocked.com for more information"]){
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Your account has been blocked. Please contact blocked@blocked.com for more information"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else if ([root[@"error"] isEqualToString:@"Not found"]){
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Username or Password is wrong!!!"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:4.0];
        }
        else{
            UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"Opps!!!!" message:@"Username or Password is wrong" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alt show];
        }
        
    }];
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error = [request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:4.0];
    }];
}

-(void)ForgetpsswordRequestAction:(NSString *)username email:(NSString *)email completionBlock:(void (^)(BOOL result)) return_block {
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/reset_password.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:username forKey:@"username"];
    [request addPostValue:email forKey:@"email"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"Login Root %@",root);
        if([root[@"status"]isEqualToString:@"success"])
        {
            return_block(TRUE);
        }
        else if ([root[@"error"]isEqualToString:@"Not found"])
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:@"Not found" delegate:NULL cancelButtonTitle:@"Cancel" otherButtonTitles:NULL, nil];
            [alert show];
            
        }
        else if ([root[@"error"]isEqualToString:@"Improper username"])
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:@"Improper username" delegate:NULL cancelButtonTitle:@"Cancel" otherButtonTitles:NULL, nil];
            [alert show];
            
        }
        else if ([root[@"error"]isEqualToString:@"Email error"])
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:@"Email error" delegate:NULL cancelButtonTitle:@"Cancel" otherButtonTitles:NULL, nil];
            [alert show];
            
        }
        else if ([root[@"error"]isEqualToString:@"Unable to process request"])
        {
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:@"Unable to process request" delegate:NULL cancelButtonTitle:@"Cancel" otherButtonTitles:NULL, nil];
            [alert show];
        }
    }];
}

-(void)reactivateRequestcompletionBlock:(void (^)(BOOL result)) return_block {
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/reactivate_ac.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    request.shouldAttemptPersistentConnection   = NO;
    [request setValidatesSecureCertificate:NO];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    NSLog(@"Id is %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]);
    [request setPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"] forKey:@"user_id"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"Login Root %@",root);
        if ([root[@"msg"] isEqualToString:@"Your Account Hass Been Reactivated!"]) {
            return_block(TRUE);
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"id"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [ApplicationDelegate Initialize];
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:@"Hey there is something wrong"
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10 && buttonIndex == 1) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self reactivateRequestcompletionBlock:^(BOOL result) {
            if (result) {
                NSLog(@"");
                [self performSegueWithIdentifier:@"tabSegue" sender:nil];
            }
        }];
    }
    else if (alertView.tag == 10 && buttonIndex == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"id"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [ApplicationDelegate Initialize];
    }
}

@end
