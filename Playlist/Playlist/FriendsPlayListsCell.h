//
//  FriendsPlayListsCell.h
//  Playlist
//
//  Created by Chad Swenson on 6/20/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface FriendsPlayListsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *playListTitle;
@property (weak, nonatomic) IBOutlet UILabel *playListHost;
@property (weak, nonatomic) IBOutlet UILabel *playListInfo;
@property (strong, nonatomic) IBOutlet UILabel *title;

@property (strong, nonatomic) NSString *playListID;
//- (IBAction)mapButtonTouched:(id)sender;
//@property (strong, nonatomic) PFGeoPoint *playlistLocation;
//@property (strong, nonatomic) PFGeoPoint *myPoint;
@end
