//
//  SignupViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 01/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "MBProgressHUD.h"
#import "Base64.h"
#import "UIImage+animatedGIF.h"

@interface SignupViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{

    IBOutlet UITextField *txtUsername;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPhone;
    IBOutlet UITextField *txtOptions;
    IBOutlet UITextField *txtPassword;
    IBOutlet UITextField *txtRePassword;
    IBOutlet UIImageView *imageView;
    UIActionSheet *profilePicAction;
    UIImagePickerController *imagePickerController;
    IBOutlet UIImageView *gifImageview;
    
    IBOutlet UIView         *optionView;
    IBOutlet UITableView    *optionTableView;
    NSArray                 *optionsArray;
    BOOL                    isShowOptions;
    BOOL                    isDefaultImage;
}

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrolleView;
- (IBAction)signUp:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)optnClicked:(id)sender;

@end
