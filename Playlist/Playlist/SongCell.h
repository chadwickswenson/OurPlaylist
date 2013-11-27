//
//  SongCell.h
//  Playlist
//
//  Created by Chad Swenson on 6/20/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *songArtistLabel;
@property (weak, nonatomic) IBOutlet UILabel *songVotesLabel;
@property (strong, nonatomic) NSNumber *index;


@end
