//
//  ChangePasswordViewController.h
//  SocialMedia
//
//  Created by Khalid  on 18/10/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChangePasswordCustomCell.h"

@interface ChangePasswordViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView    *changePswrdTableView;
}
@end
