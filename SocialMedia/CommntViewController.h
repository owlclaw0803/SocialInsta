//
//  CommntViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 07/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "NotificationCustomCell.h"
#import "UIImageView+AFNetworking.h"

@interface CommntViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *tblView;
    NSMutableArray *mutCommentArry;
    IBOutlet UITextField *txtfield;
    IBOutlet UIView *viewTextField;
}

@property(strong,nonatomic)NSString *strimageid;
@property(strong,nonatomic)NSString *strUserid;

- (IBAction)CommentSend:(id)sender;
- (IBAction)back:(id)sender;
-(void)CommentApicall:(NSString *)comment completionBlock:(void (^)(BOOL result)) return_block;

@end
