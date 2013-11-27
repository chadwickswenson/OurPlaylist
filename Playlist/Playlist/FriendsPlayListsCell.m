//
//  FriendsPlayListsCell.m
//  Playlist
//
//  Created by Chad Swenson on 6/20/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import "FriendsPlayListsCell.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@implementation FriendsPlayListsCell

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
/*
- (IBAction)mapButtonTouched:(id)sender {
    MKPlacemark* myPlaceMark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.playlistLocation.latitude, self.playlistLocation.longitude) addressDictionary:nil];
    
    MKMapItem* myLocation = [[MKMapItem alloc] initWithPlacemark:myPlaceMark];
    
    NSArray* itemArray = [[NSArray alloc] initWithObjects:(id) myLocation, nil];
    
    [MKMapItem openMapsWithItems:itemArray launchOptions:nil];
    
}
*/
@end
