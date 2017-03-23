//
//  InboxCustomCell.m
//  SocialMedia
//
//  Created by Khalid  on 27/09/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "InboxCustomCell.h"

@implementation InboxCustomCell

@synthesize profileImageView;
@synthesize nameLabel;
@synthesize mesgLabel;
@synthesize timeLabel;

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
