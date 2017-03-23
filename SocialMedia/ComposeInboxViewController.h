//
//  ComposeInboxViewController.h
//  SocialMedia
//
//  Created by Khalid  on 30/09/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InboxCustomCell.h"
#import "chatViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ComposeInboxViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    IBOutlet UITableView    *followingTableView;
    IBOutlet UISearchBar    *serchbar;
    
    NSMutableArray          *followingArray;
    NSMutableArray          *filteredArray;
    
    BOOL                    isSearch;
}
@end
