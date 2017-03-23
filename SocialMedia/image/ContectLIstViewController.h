//
//  ContectLIstViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 16/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ProfileViewController.h"


@interface ContectLIstViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    ABAddressBookRef addressBookRef;
    ABRecordRef record;
    NSMutableString *ContectNumberString;
    NSMutableString *emailString;
}
@property (strong, nonatomic) IBOutlet UITableView *tbleViewObj;
@property(strong,nonatomic)NSMutableArray *resulatArray;
-(void)GetContectlistFriends:(NSMutableString *)phonenumber email:(NSMutableString *)email completionBlock:(void (^)(BOOL result)) return_block;
-(void)getCOntectlist;
- (IBAction)backVc:(id)sender;

@end
