//
//  NotificationCustomCell.m
//  SocialMedia
//
//  Created by Khalid  on 25/09/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "NotificationCustomCell.h"

@implementation NotificationCustomCell

@synthesize profileImageView;
@synthesize contentImageView;
@synthesize profileButton;
@synthesize contentButton;
@synthesize commentTextView;
@synthesize timeLabel;
@synthesize notificationView;
@synthesize acceptButton;
@synthesize rejectButton;
@synthesize notificationImage;
@synthesize dotLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
