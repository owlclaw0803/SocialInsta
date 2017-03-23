//
//  SocialSettingViewController.h
//  SocialMedia
//
//  Created by Khalid  on 02/10/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SettingCustomCell.h"
#import "AboutViewController.h"
#import "ChangePasswordViewController.h"
#import "PrivacyPolicyViewController.h"
#import "CustomIOS7AlertView.h"

@interface SocialSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UITextFieldDelegate,UIAlertViewDelegate>
{
    IBOutlet UITableView    *settingTableView;
    IBOutlet UIView         *settingFooterView;
    
    UITextField             *pswrdTextField;
    
    NSMutableArray          *profileArray;
    NSMutableArray          *accountArray;
    NSMutableArray          *notificationArray;
    NSMutableArray          *aboutArray;
    
    NSMutableDictionary     *settingMutableDictionaty;
    
    NSMutableString         *bioString;
    NSMutableString         *displayNameString;
    NSMutableString         *websiteString;
    NSMutableString         *isPrivate;
    NSMutableString         *isChatOn;
    NSMutableString         *isLikesOn;
    NSMutableString         *isPhotoTagsOn;
    NSMutableString         *isCommentsOn;
    NSMutableString         *isQuickSnapOn;
}

@property (nonatomic,retain) NSString *userName;
@property (nonatomic,retain) NSString *displayName;
@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *website;

- (IBAction)btnDeleteAccountClicked:(id)sender;
- (IBAction)btnLogoutClicked:(id)sender;

@end
