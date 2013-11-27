//
//  SongCell.m
//  Playlist
//
//  Created by Chad Swenson on 6/20/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import "SongCell.h"

@implementation SongCell

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
