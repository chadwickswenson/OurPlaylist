//
//  StepFinalViewController.m
//  Playlist
//
//  Created by Chad Swenson on 6/19/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import "StepFinalViewController.h"
#import "AdminPlayListViewController.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import <FacebookSDK/FBGraphUser.h>

@interface StepFinalViewController () <FBFriendPickerDelegate>

@end

@implementation StepFinalViewController{
    
    IBOutlet CLLocationManager *locationManager;
    NSMutableArray *localSongsArray2;
}
@synthesize friendPickerController = _friendPickerController;
@synthesize selectedFriends = _selectedFriends;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
    // Pre-fetch and cache friend data
    [cacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];	// Do any additional setup after loading the view.
    self.titleLabel.text = self.playListTitleString;
    self.localSongsArray = [[NSMutableArray alloc] init];
}
-(void)viewDidUnload
{
    self.searchBar = nil;
    self.friendPickerController = nil;}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
   
}
- (void)addSearchBarToFriendPickerView
{
    if (self.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        self.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
        self.searchBar.autoresizingMask = self.searchBar.autoresizingMask |
        UIViewAutoresizingFlexibleWidth;
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
        
        [self.friendPickerController.canvasView addSubview:self.searchBar];
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.friendPickerController.tableView.frame = newFrame;
    }
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
   
    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery playlistsQuery];
    NSArray *playlists = [myPlaylistsQuery collections];
    NSMutableArray *entryObjects = [[NSMutableArray alloc] init];
    
    NSLog(@"%i", [self.localPlayListsArray count]);
    
    for (MPMediaPlaylist *playlist in playlists) {
        
        BOOL shouldAddPlaylist = NO;
        for (NSString* item in self.localPlayListsArray)
        {
            if ([item isEqualToString:[playlist valueForProperty: MPMediaPlaylistPropertyName]])
                shouldAddPlaylist = YES;
        }
        if (shouldAddPlaylist)
        {
            NSArray *songs = [playlist items];
            for (MPMediaItem *song in songs) {
                NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
                [self.localSongsArray addObject: song];
                NSLog (@"\t\t%@", songTitle);
            }
            
        }
    }
    NSSet *tempSet;
    [tempSet setByAddingObjectsFromArray: self.localSongsArray];
   // self.localSongsArray = [NSMutableArray arrayWithArray:[tempSet allObjects]];

    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
    if (!error) {
        PFObject *playList = [PFObject objectWithClassName: @"PlayList"];
        [playList setObject:self.playListTitleString forKey:@"title"];
        [playList setObject:[PFUser currentUser] forKey:@"user"];
        [playList setObject:geoPoint forKey:@"location"];
        [playList setObject:[NSNumber numberWithInt:1] forKey:@"area"];
        
        for(MPMediaItem  *songInArray in self.localSongsArray){
            PFObject *songToInsert = [PFObject objectWithClassName: @"Song"];
            [songToInsert setObject:[songInArray valueForProperty: MPMediaItemPropertyTitle] forKey:@"name"];
            [songToInsert setObject:[songInArray valueForProperty: MPMediaItemPropertyArtist] forKey:@"artist"];
            [songToInsert setObject:[NSNumber numberWithInt:0] forKey:@"votes"];
            [songToInsert setObject:playList forKey:@"playListID"];
            [entryObjects addObject:songToInsert];
        }
       /* for(NSDictionary<FBGraphUser> *friend in self.selectedFriends){
            PFObject *FriendToInsert = [PFObject objectWithClassName: @"Invite"];
            [FriendToInsert setObject:friend.first_name forKey:@"first_name"];
            [FriendToInsert setObject:friend.last_name forKey:@"last_name"];
            [FriendToInsert setObject:friend.id forKey: @"id"];
            [FriendToInsert setObject:playList forKey:@"playListID"];
            PFUser* u = [PFUser currentUser];
            [FriendToInsert setObject:u.objectId forKey: @"hostId"];
            [entryObjects addObject:FriendToInsert];
        }*/
       
        [PFObject saveAllInBackground:entryObjects block:^(BOOL succeeded, NSError *error){
            
            if(succeeded){
                NSLog(@"playlist and songs uploaded");
            }
            else{
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                NSLog(@"Error: %@", errorString);
            }
        }];
        
    }
    else{
        
        
    }
    
    
    }];

    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
}
- (void)friendPickerViewControllerSelectionDidChange:
(FBFriendPickerViewController *)friendPicker
{
    NSLog(@"Current friend selections: %@", friendPicker.selection);
    self.selectedFriends = friendPicker.selection;
}

/*
 * Event: Done button clicked
 */
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    FBFriendPickerViewController *friendPickerController =
    (FBFriendPickerViewController*)sender;
    NSLog(@"Selected friends: %@", friendPickerController.selection);
    // Dismiss the friend picker
    
}
- (void)dealloc
{
    _friendPickerController.delegate = nil;
}/*
 * Event: Cancel button clicked
 */
- (void)facebookViewControllerCancelWasPressed:(id)sender {
    NSLog(@"Canceled");
    // Dismiss the friend picker
    [[sender presentingViewController] dismissModalViewControllerAnimated:YES];
    
    
}
- (IBAction)selectFriendsTouched:(id)sender {
    if (!self.friendPickerController) {
        self.friendPickerController = [[FBFriendPickerViewController alloc]
                                       initWithNibName:nil bundle:nil];
        self.friendPickerController.title = @"Select friends";
    }
    self.friendPickerController.delegate = self;
    [self.friendPickerController loadData];
    [self presentViewController:self.friendPickerController
                       animated:YES
                     completion:^(void){
                         [self addSearchBarToFriendPickerView];
                     }
     ];
    
}
- (void) handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.searchText = nil;
    [searchBar resignFirstResponder];
}
- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    if (self.searchText && ![self.searchText isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:self.searchText
                          options:NSCaseInsensitiveSearch];
        if (result.location != NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return YES;
}
- (IBAction)startPlayListTouched:(id)sender {
    
    
  
    //[sender setTitle:@"Hello" forState:UIControlStateNormal];
    
    /*[PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            PFObject *playList = [PFObject objectWithClassName: @"PlayList"];
            [playList setObject:self.playListTitleString forKey:@"title"];
            [playList setObject:@"userid" forKey:@"user"];
            [playList setObject:geoPoint forKey:@"location"];
            [playList setObject:[NSNumber numberWithInt:1] forKey:@"area"];
            [playList saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if(succeeded){
                    NSLog(@"playlist uploaded");
                }
                else{
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    NSLog(@"Error: %@", errorString);
                }
            }];
     
                   }
        else{
            
           
        }
     
     
    }];
     
     
     
     
     PFObject *song = [PFObject objectWithClassName: @"Song"];
     [song setObject:@"ABC" forKey:@"name"];
     [song setObject:@"led" forKey:@"artist"];
     [song setObject:[NSNumber numberWithInt:0] forKey:@"votes"];
     [song setObject:playList forKey:@"playListID"];
     [song saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
     if(succeeded){
     NSLog(@"objects Uploaded");
     }
     else{
     NSString *errorString = [[error userInfo] objectForKey:@"error"];
     NSLog(@"Error: %@", errorString);
     
     }
     }];
*/
    
    
}

- (NSString *)deviceLocation {
    NSString *theLocation = [NSString stringWithFormat:@"latitude: %f longitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
    return theLocation;
}
@end
