//
//  InboxViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 08/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "customCell.h"
#import "InboxCustomCell.h"
#import "chatViewController.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "ComposeInboxViewController.h"
#import "UIImageView+AFNetworking.h"

@interface InboxViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,UITextFieldDelegate>
{
    IBOutlet UITableView *tblView;
   // IBOutlet UIView     *followingView;
    UIView              *headerView;
    NSMutableArray      *mutArray;
}

- (IBAction)writeNewMesssageClicked:(id)sender;

-(void)HidePhotoView;
-(void)LoadMore:(NSString *)postID completionBlock:(void (^)(BOOL result)) return_block;

@end
