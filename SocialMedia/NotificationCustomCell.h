//
//  NotificationCustomCell.h
//  SocialMedia
//
//  Created by Khalid  on 25/09/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationCustomCell : UITableViewCell

@property(nonatomic,retain) IBOutlet UIImageView    *profileImageView;
@property(nonatomic,retain) IBOutlet UIImageView    *contentImageView;
@property(nonatomic,retain) IBOutlet UIImageView    *notificationImage;
@property(nonatomic,retain) IBOutlet UIButton       *profileButton;
@property(nonatomic,retain) IBOutlet UIButton       *contentButton;
@property(nonatomic,retain) IBOutlet UIButton       *acceptButton;
@property(nonatomic,retain) IBOutlet UIButton       *rejectButton;
@property(nonatomic,retain) IBOutlet UIView         *notificationView;
@property(nonatomic,retain) IBOutlet UITextView     *commentTextView;
@property(nonatomic,retain) IBOutlet UILabel        *timeLabel;
@property(nonatomic,retain) IBOutlet UILabel        *dotLabel;

@end
