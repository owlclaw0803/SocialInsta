//
//  ViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 01/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "STTwitter.h"
#import "UIImage+animatedGIF.h"

@interface ViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>
{
    IBOutlet UITextField *txtUserName;
    IBOutlet UIImageView *gifImageview;
    IBOutlet UITextField *txtPassWord;
    IBOutlet UITextField *txtFgtEmail;
    IBOutlet UITextField *txtFgtUsername;
    IBOutlet UIView *fgtView;
}

- (IBAction)login:(id)sender;
- (IBAction)forgetPassword:(id)sender;
- (IBAction)faceBook:(id)sender;
- (IBAction)signUp:(id)sender;
- (IBAction)twiter:(id)sender;
- (IBAction)fgtDone:(id)sender;
- (IBAction)fgtCancel:(id)sender;

@property (nonatomic, strong) STTwitterAPI *twitter;

-(void)LoginRequestAction:(NSString *)username password:(NSString *)password completionBlock:(void (^)(BOOL result)) return_block;
-(void)ForgetpsswordRequestAction:(NSString *)username email:(NSString *)email completionBlock:(void (^)(BOOL result)) return_block;

@end
