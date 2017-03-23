//
//  InboxCustomCell.h
//  SocialMedia
//
//  Created by Khalid  on 27/09/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxCustomCell : UITableViewCell

@property(nonatomic, retain) IBOutlet UIImageView    *profileImageView;
@property(nonatomic, retain) IBOutlet UILabel        *nameLabel;
@property(nonatomic, retain) IBOutlet UILabel        *mesgLabel;
@property(nonatomic, retain) IBOutlet UILabel        *timeLabel;

@end
