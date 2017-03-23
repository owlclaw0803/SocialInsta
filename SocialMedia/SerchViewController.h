//
//  SerchViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 08/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
@interface SerchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    IBOutlet UITableView *tblview;
    IBOutlet UISearchBar *serchbar;
    NSMutableArray *mutSerchArray;
    __weak IBOutlet UIButton *btnsearchpeople;
    __weak IBOutlet UIButton *btnsearchhash;
    BOOL bSearchPeople;
    
    NSMutableArray *hashdatas;
}

- (IBAction)back:(id)sender;
- (void)HidePhotoView;

- (IBAction)searchpeople:(id)sender;
- (IBAction)searchhashtag:(id)sender;
@end
