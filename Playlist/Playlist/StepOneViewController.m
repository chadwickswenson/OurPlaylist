//
//  StepOneViewController.m
//  Playlist
//
//  Created by Chad Swenson on 6/19/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import "StepOneViewController.h"
#import "AdminPlayListViewController.h"
#import "LocalPlayListCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>

@interface StepOneViewController ()

@end

@implementation StepOneViewController{
    NSArray *poop;
    NSMutableArray *playLists;
}

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
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery playlistsQuery];
    NSArray *temp = [myPlaylistsQuery collections];
    
    
    playLists = [[NSMutableArray alloc] init];

    
    
   
    
    for (MPMediaPlaylist *playlist in temp) {
        
       [playLists addObject:[playlist valueForProperty: MPMediaPlaylistPropertyName]];
        
      
    }
    
 
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.localSongsArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//VALIDATE USER INPUT
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
   
    
    
    return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GoToAdmin"]) {
               
        AdminPlayListViewController *destViewController = segue.destinationViewController;
        destViewController.playListID = self.playListID;
    }
}

- (void)updateViewConstraints {
   [super updateViewConstraints];
  //  self.activityIndicatorYConstraint.constant =
   // [UIScreen mainScreen].bounds.size.height > 480.0f ? 322 : 245;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    return [playLists count];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    // Return NO if you do not want the specified item to be editable.
    
    return NO;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocalPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"localPlayListCell"];
    cell.playListTitleLabel.text = [playLists objectAtIndex:indexPath.row];
    return cell;
}




- (IBAction)startButtonTouched:(id)sender {
    
    if(self.playListTitleTextField.text.length == 0){
        // Declare an instance of our Alert View dialog
        UIAlertView *dialog;
        
        // Initialise our Alert View Window with options
        dialog =[[UIAlertView alloc] initWithTitle:@"No Playlist Title"
                                           message:@"You must enter a name for your playlist to continue." delegate:self
                                 cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        
        // display our dialog and free the memory allocated by our
        [dialog show];
        
        return;
    }
    [self.loadingIndicator setAlpha:0.8];
    [self.navBar setHidesBackButton:YES];
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger j = 0; j < [self.localPlayListListView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.localPlayListListView numberOfRowsInSection:j]; ++i)
        {
            if ([self.localPlayListListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]] != nil)
            {
                [cells addObject:[self.localPlayListListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
                
            }
        }
        NSLog(@"getting cells");
    }
    
    NSMutableArray *selectedPlayLists = [[NSMutableArray alloc] init];
    BOOL selectedAPlaylist = NO;
    for (LocalPlayListCell *cell in cells)
    {
        if (cell.selected || self.allMusicToggle.isOn)
        {
            [selectedPlayLists addObject:cell.playListTitleLabel.text];
            selectedAPlaylist = YES;
            NSLog(@"%@%@%@", @"Cell: ", cell.playListTitleLabel.text, @"is selected");
        }
        NSLog(@"looping through cells");
    }
    if (!selectedAPlaylist)
    {
        UIAlertView *dialog;
        
        // Initialise our Alert View Window with options
        dialog =[[UIAlertView alloc] initWithTitle:@"No Playlists Selected"
                                           message:@"You must select atleast one playlist to continue." delegate:self
                                 cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        
        // display our dialog and free the memory allocated by our
        [dialog show];
        
        [self.loadingIndicator setAlpha:0.0];
        [self.navBar setHidesBackButton:NO];
        return;
    }
    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery playlistsQuery];
    NSArray *playlists = [myPlaylistsQuery collections];
    NSMutableArray *entryObjects = [[NSMutableArray alloc] init];
    
    for (MPMediaPlaylist *playlist in playlists) {
        
        BOOL shouldAddPlaylist = NO;
        for (NSString* item in selectedPlayLists)
        {
            if ([item isEqualToString:[playlist valueForProperty: MPMediaPlaylistPropertyName]])
                shouldAddPlaylist = YES;
        }
        if (shouldAddPlaylist)
        {
            NSArray *songs = [playlist items];
            if (![songs count] == 0)
            {
                for (MPMediaItem *song in songs) {
                    NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
                    [self.localSongsArray addObject: song];
                    NSLog (@"\t\t%@", songTitle);
                }
            }
            
        }
    }
    if([self.localSongsArray count] == 0)
    {
        UIAlertView *dialog;
        
        // Initialise our Alert View Window with options
        dialog =[[UIAlertView alloc] initWithTitle:@"No Songs in Playlist(s)"
                                           message:@"The playlist(s) you have selected do not contain any songs" delegate:self
                                 cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        
        // display our dialog and free the memory allocated by our
        [dialog show];
        [self.loadingIndicator setAlpha:0.0];
        [self.navBar setHidesBackButton:NO];
        return;
    }
    // self.localSongsArray = [[[NSSet setWithArray: self.localSongsArray] allObjects] mutableCopy];
    NSLog(@"COUNT LOCAL: %lu", (unsigned long)[self.localSongsArray count]);
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        if (!error) {
            PFObject *playList = [PFObject objectWithClassName: @"PlayList"];
            [playList setObject:self.playListTitleTextField.text forKey:@"title"];
            [playList setObject:[PFUser currentUser] forKey:@"user"];
            [playList setObject:geoPoint forKey:@"location"];
            [playList setObject:[NSNumber numberWithInt:1] forKey:@"area"];
            
            
            for(MPMediaItem  *songInArray in self.localSongsArray){
                PFObject *songToInsert = [PFObject objectWithClassName: @"Song"];
                [songToInsert setObject:[songInArray valueForProperty: MPMediaItemPropertyTitle] forKey:@"name"];
                if ([songInArray valueForProperty: MPMediaItemPropertyArtist] != nil) {
                    [songToInsert setObject:[songInArray valueForProperty: MPMediaItemPropertyArtist] forKey:@"artist"];

                }else {
                    [songToInsert setObject:@"Artist" forKey:@"artist"];
                }
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
                    NSLog(@"playlist and songs uploaded %@", [[entryObjects[0] valueForKey:@"playListID"] valueForKey:@"objectId"]);
                    self.playListID = [[entryObjects[0] valueForKey:@"playListID"] valueForKey:@"objectId"];
                    [self.invisButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                    [self.loadingIndicator setAlpha:0.0];
                    [self.navBar setHidesBackButton:NO];
                }
                else{
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    NSLog(@"Error: %@", errorString);
                    [self.navBar setHidesBackButton:NO];
                    
                }
            }];
            
        }
        else{
            NSLog(@"Error: %@", error);
            [self.navBar setHidesBackButton:NO];
            
        }
        
        
    }];
    //[self.loadingIndicator setAlpha:0.0];

}
@end
