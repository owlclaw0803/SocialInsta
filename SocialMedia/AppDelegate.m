//
//  AppDelegate.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 01/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

-(void)Initialize
{
    if([UIScreen mainScreen].bounds.size.height>=568) {
        self.storyboardname = @"Main";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:self.storyboardname bundle:nil];
        ViewController *tab = [storyBoard instantiateViewControllerWithIdentifier:@"MainViewController"];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:tab];
        self.window.rootViewController = self.navigationController;
        [self.navigationController setNavigationBarHidden:YES];
    } else {
        self.storyboardname = @"Main4";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:self.storyboardname bundle:nil];
        ViewController *tab = [storyBoard instantiateViewControllerWithIdentifier:@"MainViewController"];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:tab];
        self.window.rootViewController = self.navigationController;
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [NSThread sleepForTimeInterval:2.5];
    strID=[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Post"];
    //strID=NULL;
    [self Initialize];
    
    if (strID!=NULL) {
        UIStoryboard *storyBoard= [UIStoryboard storyboardWithName:self.storyboardname bundle:nil];
        UITabBarController *tab = [storyBoard instantiateViewControllerWithIdentifier:@"TabBarViewControllerID"];
        
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        [navigationController pushViewController:tab animated:YES];
        
        //        UIStoryboard *storyBoard= [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        UITabBarController *tab = [storyBoard instantiateViewControllerWithIdentifier:@"TabBarViewControllerID"];
        
        self.window.rootViewController=navigationController;
    }
    // Override point for customization after application launch.
    return YES;
}

- (void)openSessionWithAllowLoginUI:(BOOL)allowLoginUI completionBlock:(void(^)(BOOL result))return_back {
    [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObjects:@"email",@"user_birthday",@"public_profile",@"user_friends",@"user_photos",nil]
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      NSLog(@"%@",error);
                                      if (state == FBSessionStateOpen && !error) {
                                          switch (state) {
                                              case FBSessionStateOpen: {
                                                  NSLog(@"FBSessionStateOpen");
                                                  if (FBSession.activeSession.isOpen) {
                                                      [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection,NSDictionary<FBGraphUser> *user,NSError *error) {
                                                          if (!error) {
                                                              [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"FBUserLogedInProfileData"];
                                                              NSURL *fb_url=[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=100&height=100",[user objectForKey:@"id"]]];
                                                              [[NSUserDefaults standardUserDefaults] synchronize];
                                                              NSLog(@"@@@@ %@",[user valueForKey:@"first_name"]);
                                                              NSLog(@"FBUser: ====>%@",user);
                                                              NSMutableDictionary *fbDict=[NSMutableDictionary dictionary];
                                                              [fbDict setObject:[fb_url absoluteString] forKey:@"image"];
                                                              [fbDict setObject:[user valueForKey:@"email"] forKey:@"email"];
                                                              [fbDict setObject:[user valueForKey:@"name"] forKey:@"displayname"];
                                                              [fbDict setObject:[user valueForKey:@"id"] forKey:@"facebookid"];
                                                              [[NSUserDefaults standardUserDefaults] synchronize];
                                                              NSLog(@"%@",fbDict);
                                                              [self FaceBookRequestAction:fbDict completionBlock:^(BOOL result) {
                                                                  if (result) {
                                                                      return_back(TRUE);
                                                                  }
                                                              }];
                                                          }
                                                          
                                                      }];
                                                  }
                                              }
                                                  break;
                                              case FBSessionStateClosed: {
                                                  NSLog(@"FBSessionStateClosed");
                                                  
                                                  //Change state of UserLogedInType if session is closed
                                                  // Once the user has logged out, we want them to be looking at the root view.
                                                  [FBSession.activeSession closeAndClearTokenInformation];
                                                  
                                                  if (error) {
                                                      [[[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                  message:@"Something is wrong!\nPlease relogin."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil] show];
                                                      
                                                      //Ask for Login
                                                      
                                                  }
                                              }
                                                  break;
                                              case FBSessionStateClosedLoginFailed: {
                                                  NSLog(@"FBSessionStateClosedLoginFailed");
                                                  if (error) {
                                                      [[[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                  message:@"Something is wrong!\nPlease relogin."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil] show];
                                                      
                                                      //Change state of UserLogedInType if session is closed
                                                      
                                                      
                                                      //Ask for Login
                                                      
                                                  }
                                              }
                                                  break;
                                              default:
                                                  break;
                                          }
                                      }
                                      // [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification object:session];
                                  }];
}
-(void)FaceBookRequestAction:(NSDictionary *)dict completionBlock:(void (^)(BOOL result)) return_block{
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/user_signup.php"]];
    
    __unsafe_unretained ASIFormDataRequest *request = _request;
    request.shouldAttemptPersistentConnection = NO;
    
    NSDictionary *loginDictionary = [[NSDictionary alloc]initWithDictionary:dict];
    //   NSString *username=[loginDictionary objectForKey:@"displayname"];
    NSString *email=[loginDictionary objectForKey:@"email"];
    NSString *facebookid=[loginDictionary objectForKey:@"facebookid"];
    NSString *displayname=[loginDictionary objectForKey:@"displayname"];
    NSLog(@"=====>%@",loginDictionary);
    // NSError *error;
    //    NSData *LoginData=[NSJSONSerialization dataWithJSONObject:loginDictionary options:NSJSONWritingPrettyPrinted error:&error];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:email forKey:@"email"];
    [request addPostValue:facebookid forKey:@"fb_id"];
    [request addPostValue:displayname forKey:@"display_name"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        
        
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"Login Root %@",root);
        if([[root[@"error"] description] isEqualToString:@"Signup required"])
        {
            [[NSUserDefaults standardUserDefaults ]setObject:email forKey:@"email"];
            [[NSUserDefaults standardUserDefaults]setObject:facebookid forKey:@"fbid"];
            [[NSUserDefaults standardUserDefaults] setObject:loginDictionary[@"image"] forKey:@"image"];
            [[NSUserDefaults standardUserDefaults]setObject:[loginDictionary objectForKey:@"displayname"] forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setValue:@"backgroundimage.png" forKey:@"CoverPage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //
            return_block(TRUE);
        }
        else if([[root[@"error"] description]isEqualToString:@"Failed"] ){
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:root[@"Something is Wrong!!!!!!"]
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:5.0];
        }
        else if (root[@"id"]!= NULL){
            
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"id"];
            
            [[NSUserDefaults standardUserDefaults]setObject:root[@"id"] forKey:@"id"];
            [[NSUserDefaults standardUserDefaults] setObject:loginDictionary[@"image"] forKey:@"image"];
             [[NSUserDefaults standardUserDefaults]setObject:[loginDictionary objectForKey:@"displayname"] forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            UIStoryboard *storyBoard= [UIStoryboard storyboardWithName:self.storyboardname bundle:nil];
            
            UITabBarController *tab = [storyBoard instantiateViewControllerWithIdentifier:@"TabBarViewControllerID"];
            UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
            [navigationController pushViewController:tab animated:YES];
            
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
    [request startAsynchronous];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:self.session];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [ self.session close];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
