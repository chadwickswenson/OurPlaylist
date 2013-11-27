//
//  AdminPlayListViewController.m
//  Playlist
//
//  Created by Chad Swenson on 6/19/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import "AdminPlayListViewController.h"
#import <Parse/Parse.h>
#import <Parse/PFObject.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import "SongCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PLAppDelegate.h"
#import "MCSwipeTableViewCell.h"
#import "KxMenu.h"
#import "UISlider+FlatUI.h"
#import "MainViewController.h"
#import "REMenu.h"

@interface AdminPlayListViewController ()



@end

@implementation AdminPlayListViewController{
    NSArray *objectsMatchSearch;
    NSMutableArray *voteArray;
    NSNumber *voteState;
    BOOL clearTable;
    BOOL refreshing;
    BOOL isFiltered;
    BOOL isPopulated;
    BOOL skipThisSong;
    NSTimer* chooseSongTimer;
    BOOL menuDown;
    BOOL noInteract;
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
    [super viewDidLoad];
    //[self.volumeSlider setValue:[self.audioPlayer v]];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handle_VolumeChanged:)
     name:@"AVSystemController_SystemVolumeDidChangeNotification"
     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(songFinishedNotification:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.audioPlayer  currentItem]];
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    self.volumeSlider.value = musicPlayer.volume;
    
    UIAlertView *dialog;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    // Initialise our Alert View Window with options
    dialog =[[UIAlertView alloc] initWithTitle:@"Don't Lock Your Phone"
                                       message:@"Locking your phone will prevent the playlist from continuing to play" delegate:self
                             cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    
    // display our dialog and free the memory allocated by our
    [dialog show];
	// Do any additional setup after loading the view.
   /* [self.volumeSlider configureFlatSliderWithTrackColor:[UIColor colorWithRed:205 / 255.0 green:205 / 255.0 blue:205 / 255.0 alpha:1.0]
                                  progressColor:[UIColor colorWithRed:84 / 255.0 green:166 / 255.0 blue:188 / 255.0 alpha:1.0]
                                     thumbColor:[UIColor colorWithRed:72 / 255.0 green:140 / 255.0 blue:158 / 255.0 alpha:1.0]];*/
    
    
    
}
-(void) chooseSong: (NSTimer *)timer {
    NSUInteger dTotalSeconds = CMTimeGetSeconds(CMTimeSubtract([[self.audioPlayer currentItem] duration], [self.audioPlayer currentTime]));
    
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    
    
    self.timeLabel.text = [NSString stringWithFormat:@"%i:%02i:%02i",dHours, dMinutes, dSeconds];
     if (CMTimeGetSeconds(CMTimeSubtract([[self.audioPlayer currentItem]duration], [self.audioPlayer currentTime])) > 20 && CMTimeGetSeconds(CMTimeSubtract([[self.audioPlayer currentItem]duration], [self.audioPlayer currentTime])) < 21.5 && isPopulated)
    {
        [self refresh];
    }
    /*
    if (isPopulated)
    {
    if(!self.audioPlayer || (CMTimeGetSeconds(CMTimeSubtract([[self.audioPlayer currentItem]duration], [self.audioPlayer currentTime])) < 3 || (CMTimeGetSeconds(CMTimeSubtract([[self.audioPlayer currentItem]duration], [self.audioPlayer currentTime])) < 20 && CMTimeGetSeconds(CMTimeSubtract([[self.audioPlayer currentItem]duration], [self.audioPlayer currentTime])) > 18)) )
    {
        
        PLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];        
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSEntityDescription *entityDesc =[NSEntityDescription entityForName:@"Song" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(localID = %i)", 0];
        [request setPredicate:pred];
        NSManagedObject *matches = nil;
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        matches = objects[0];
        MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
        NSArray *artists = [artistsQuery collections];
        for (MPMediaItemCollection *artist in artists) {
            if ([[[artist representativeItem] valueForProperty:MPMediaItemPropertyArtist] isEqualToString: [matches valueForKey:@"artist"]])
            {
                for (MPMediaItem *song in artist.items)
                {
                    if ([[song valueForProperty:MPMediaItemPropertyTitle] isEqualToString: [matches valueForKey:@"title"]])
                    {
                        self.nextSong = song;
                        break;
                    }
                }
                break;
            }
        }
    }
    }
     */
}
-(void) chooseSongNotTimer
{
    if(isPopulated)
    {
        PLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSEntityDescription *entityDesc =[NSEntityDescription entityForName:@"Song" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(localID = %i)", 0];
        [request setPredicate:pred];
        NSManagedObject *matches = nil;
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        matches = objects[0];
        MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
        NSArray *artists = [artistsQuery collections];
        for (MPMediaItemCollection *artist in artists) {
            if ([[[artist representativeItem] valueForProperty:MPMediaItemPropertyArtist] isEqualToString: [matches valueForKey:@"artist"]])
            {
                for (MPMediaItem *song in artist.items)
                {
                    if ([[song valueForProperty:MPMediaItemPropertyTitle] isEqualToString: [matches valueForKey:@"title"]])
                    {
                        self.nextSong = song;
                        if (skipThisSong)
                        {
                            skipThisSong = NO;
                            [self songFinished];
                        }
                        break;
                    }
                }
                break;
            }
        }
    }
}
-(void) songFinishedNotification: (id) sender
{
    [self songFinished];
}

-(void) songFinished
{
    //set next song
    [self.audioPlayer pause];
    if(!self.audioPlayer){
        self.audioPlayer = [[AVPlayer alloc] initWithURL:[self.nextSong valueForProperty:MPMediaItemPropertyAssetURL]];
    } else {
        [self.audioPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[self.nextSong valueForProperty:MPMediaItemPropertyAssetURL]]];
    }
    [self.audioPlayer play];
    [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    [self.playPauseButton setImage:([UIImage imageNamed:(@"pause1.png")]) forState:UIControlStateNormal];
    //set current song's votes to zero and get SongId
    PLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc =[NSEntityDescription entityForName:@"Song" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(localID = %i)", 0];
    [request setPredicate:pred];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    [objects[0] setValue: 0 forKey:@"voteID"];
    self.songNameLabel.text = [objects[0] valueForKey:@"title"];
    self.artistLabel.text = [objects[0] valueForKey:@"artist"];
    [context save:&error];
    PFQuery *query = [PFQuery queryWithClassName:@"Song"];
    [query getObjectInBackgroundWithId:[objects[0] valueForKey:@"songID"] block:^(PFObject *song, NSError *error) {
        NSLog(@"%@", song);
        [song setObject:[NSNumber numberWithInt:0] forKey:@"votes"];
        [song incrementKey:@"plays"];
        [song saveInBackground];
    }];
    
    query = [PFQuery queryWithClassName:@"Vote"];
    [query whereKey:@"songID" equalTo:[objects[0] valueForKey:@"songID"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        for(PFObject *obj in results)
        {
            [obj deleteInBackground];
        }
    }];
}
-(void) viewDidUnload
{

}
-(void) viewWillDisappear:(BOOL)animated
{
    if(self.audioPlayer != NULL)
    {
        [self.audioPlayer pause];
        self.audioPlayer = NULL;
    }
}
-(void) dealloc
{
}
-(void) handle_NowPlayingItemChanged: (id) notification
{
   
}
/*- (void) handle_PlaybackStateChanged: (id) notification
{
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    if (playbackState == MPMusicPlaybackStatePaused) {
        [self.playPauseButton setTitle:(@"Pause") forState:UIControlStateNormal];
    } else if (playbackState == MPMusicPlaybackStatePlaying) {
        [self.playPauseButton setTitle:(@"Play") forState:UIControlStateNormal];
    } else if (playbackState == MPMusicPlaybackStateStopped){
        [self.playPauseButton setTitle:(@"Play") forState:UIControlStateNormal];
    }
}
*/
- (IBAction)volumeChanged:(id)sender
{
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    musicPlayer.volume = self.volumeSlider.value;
}

- (void) handle_VolumeChanged: (id) notification
{
    self.volumeSlider.value = [[[notification userInfo]
                                objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]
                               floatValue];
}

- (void)viewWillAppear:(BOOL)animated {
    

    clearTable = NO;
    
    voteState  = [NSNumber numberWithInt:0];
   
    
    self.songTableView.backgroundView = nil;
    self.titleNavBar.title = self.playListTitle;
    NSLog(@"Playlist Title in ViewWillAppear is: %@", self.playListTitle);
    
    [self getPlayListSongsAndPopulate];
    
    clearTable = NO;
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
-(BOOL)getPlayListSongsAndPopulate{
    
    isPopulated = NO;
    [self.listViewLoader startAnimating];
    BOOL ret = YES;
    self.songsArray = [[NSArray alloc] init];
    refreshing = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Song"];
    
    [query whereKey:@"playListID" equalTo:[PFObject objectWithoutDataWithClassName:@"PlayList" objectId:self.playListID]];
     
    [query addDescendingOrder:@"votes"];
    [query addAscendingOrder:@"plays"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            // NSLog(@"Successfully retrieved %d songs.", objects.count);
            self.songsArray = objects;
            
            //[self togglePlayListViewLoading: 2];
            PFUser* u = [PFUser currentUser];
            PFQuery *voteQuery = [PFQuery queryWithClassName:@"Vote"];
            
            [voteQuery whereKey:@"playListID" equalTo:self.playListID];
            [voteQuery whereKey:@"voterID" equalTo:u];
            
            [voteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects2, NSError *error) {
                
                if (!error) {
                    
                    
                    NSNumber *count = [NSNumber numberWithInt:0];
                    
                    for(PFObject *song in self.songsArray){
                        
                        NSString *tempSongID;
                        NSString *tempVoteID;
                        NSNumber *vote = [NSNumber numberWithInt:0];
                        
                        
                        
                        for(PFObject *aVote in objects2){
                            
                            if([song.objectId isEqualToString:[aVote objectForKey:@"songID"]]){
                                
                                tempVoteID = aVote.objectId;
                                
                                if([[[aVote objectForKey:@"vote"] stringValue] isEqualToString: @"1"]){
                                    vote = [NSNumber numberWithInt:1];
                                }
                                else if([[[aVote objectForKey:@"vote"] stringValue] isEqualToString: @"-1"]){
                                    vote = [NSNumber numberWithInt:-1];
                                }
                                else{
                                    vote = [NSNumber numberWithInt:0];
                                }
                                break;
                                
                            }
                            
                            
                        }
                        tempSongID = song.objectId;
                        
                        PLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                        
                        NSManagedObjectContext *context = [appDelegate managedObjectContext];
                        NSManagedObject *newSong;
                        
                        newSong = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:context];
                        
                        
                        
                        
                        [newSong setValue: [song objectForKey:@"artist"] forKey:@"artist"];
                        [newSong setValue: [song objectForKey:@"name"] forKey:@"title"];
                        [newSong setValue: song.objectId forKey:@"songID"];
                        [newSong setValue: vote forKey:@"vote"];
                        [newSong setValue: [song objectForKey:@"votes"] forKey:@"votes"];
                        [newSong setValue: tempVoteID forKey:@"voteID"];
                        [newSong setValue: count forKey:@"localID"];
                        NSError *error;
                        [context save:&error];
                        
                        
                        int value = [count intValue];
                        count = [NSNumber numberWithInt:value+1];
                        [self.songTableView reloadData];
                        
                        
                        
                    }
                    
                    //FINALLY RELOAD THE TABLE VIEW LOL
                    [self.listViewLoader stopAnimating];
                    refreshing = NO;
                    
                    chooseSongTimer = [NSTimer scheduledTimerWithTimeInterval: .9
                                                            target: self
                                                          selector: @selector(chooseSong:)
                                                          userInfo: nil
                                                           repeats: YES];
                                        isPopulated = YES;
                    [self chooseSongNotTimer];
                    [self.playPauseButton setUserInteractionEnabled:YES];
                    [self.nextSongButton setUserInteractionEnabled: YES];
                    noInteract = NO;
                }
                else {
                    
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    
                }
                
            }];
            
        }
        else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }
        
    }];
    
    
    return ret;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    return [self.songsArray count];//[playLists count];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    // Return NO if you do not want the specified item to be editable.
    
    return NO;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(clearTable == YES){
        NSLog(@"returning 0");
        //return 0;
    }
    
    int index = indexPath.row;
    
   /* if(isFiltered){
        index = [objectsMatchSearch[indexPath.row] intValue];
    }*/
    
    PLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =[NSEntityDescription entityForName:@"Song" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(localID = %i)", index];
    
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    
    /* NSLog(@"updating available playlists");
     
     SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"guestSongCell"];
     
     cell.songNameLabel.text = [[self.songsArray objectAtIndex: indexPath.row] objectForKey:@"name"];
     cell.songArtistLabel.text = [[self.songsArray objectAtIndex: indexPath.row] objectForKey:@"artist"];
     cell.songVotesLabel.text = [NSString stringWithFormat:@"votes: %@",[[self.songsArray objectAtIndex: indexPath.row] objectForKey:@"votes"]];
     
     return cell;
     
     static NSString *CellIdentifier = @"Cell";*/
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"guestSongCell"];
    
    if (!cell) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"guestSongCell"];
    }
    
    [cell setDelegate:self];
    
    cell.index =[NSNumber numberWithInt:index];
    
    [cell setFirstStateIconName:@"up.png"
                     firstColor:[UIColor colorWithRed:38.0 / 255.0 green:169.0 / 255.0 blue:237.0 / 255.0 alpha:1.0]
            secondStateIconName:nil
                    secondColor:nil
                  thirdIconName:@"down.png"
                     thirdColor:[UIColor colorWithRed:237.0 / 255.0 green:38.0 / 255.0 blue:57.0 / 255.0 alpha:1.0]
                 fourthIconName:nil
                    fourthColor:nil];
    //cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, 20, 10);
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    
    if(nameLabel == nil){
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-40, 7.0, 300.0, 20.0)];
        [nameLabel setTag:1];
        //nameLabel.text = @"0";
        [nameLabel setBackgroundColor:[UIColor clearColor]]; // transparent label background
        [nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        
        [cell.contentView addSubview:nameLabel];
    }
    
    // custom views should be added as subviews of the cell's contentView:
    
    cell.accessoryView = [[ UIImageView alloc ] initWithImage:nil];
    cell.accessoryView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    
    //Add image view
    CGRect z =  cell.accessoryView.frame;
    z.origin.x =-8;
    z.size.width = 1;
    cell.accessoryView.frame = z;
    
    //set contentMode to scale aspect to fit
    
    CGRect frame = CGRectMake(0, 0, 1, 45);
    cell.accessoryView.frame = frame;
    
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    
    [cell setMode:MCSwipeTableViewCellModeSwitch];
    // [cell.songID = [[self.songsArray objectAtIndex: indexPath.row] objectForKey:@"name"];
    //  [cell.textLabel setText:[[self.songsArray objectAtIndex: indexPath.row] objectForKey:@"name"]];
    //[cell.detailTextLabel setText:[[self.songsArray objectAtIndex: indexPath.row] objectForKey:@"artist"]];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    
    // cell.accessoryView.backgroundColor = [UIColor clearColor];
    // cell.accessoryView. = [UIColor blackColor];
    //cell.accessoryView setBackgroundColor:[UIColor blackColor]
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    if ([objects count] == 0) {
        NSLog(@"no votes found in core data");
    } else {
        matches = objects[0];
        [cell.textLabel setText:[matches valueForKey:@"title"]];
        [cell.detailTextLabel setText:[matches valueForKey:@"artist"]];
        
        
        nameLabel.text = [[objects[0] valueForKey:@"votes"] stringValue];
        
        
        
        if([[[matches valueForKey:@"vote"] stringValue] isEqualToString:@"1"]){
            [UIView animateWithDuration:0.5 animations:^() {
                cell.accessoryView.backgroundColor = [UIColor colorWithRed:85.0 / 255.0 green:165.0 / 255.0 blue:190.0 / 255.0 alpha:1.0];
            }];
        }
        else if([[[matches valueForKey:@"vote"] stringValue] isEqualToString:@"-1"]){
            [UIView animateWithDuration:0.5 animations:^() {
                cell.accessoryView.backgroundColor = [UIColor colorWithRed:237.0 / 255.0 green:38.0 / 255.0 blue:57.0 / 255.0 alpha:1.0];
            }];
        }
    }
    
    
    
    if (indexPath.row % 2) {
        
    }
    else {
        
    }
    /*if(self.searchBar.text.length > 0){
     if ([cell.textLabel.text rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location == NSNotFound &&
     [cell.detailTextLabel.text rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location == NSNotFound) {
     cell.hidden = YES;
     cell.frame = CGRectMake(0,0,0,0);
     return cell;
     }
     
     }*/
    return cell;
    
}
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    NSLog(@"IndexPath : %@ - MCSwipeTableViewCellState : %d - MCSwipeTableViewCellMode : %d", [self.songTableView indexPathForCell:cell], state, mode);
    [self.playPauseButton setUserInteractionEnabled:NO];
    [self.nextSongButton setUserInteractionEnabled: NO];
    if(voteState == [NSNumber numberWithInt:1]){
        NSLog(@"bad state");
        return;
    }
    else{
        voteState = [NSNumber numberWithInt:0];
    }
    
    
    if(state == 1 || state == 3){
        //cell.contentView.backgroundColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
        int voteType = 0;
        int voteChangeTotal = 0;
        
        
        if(state == 1){
            voteType = 1;
            [UIView animateWithDuration:0.5 animations:^() {
                cell.accessoryView.backgroundColor = [UIColor colorWithRed:85.0 / 255.0 green:165.0 / 255.0 blue:190.0 / 255.0 alpha:1.0];
            }];
        }
        else if(state == 3){
            voteType = -1;
            [UIView animateWithDuration:1 animations:^() {
                cell.accessoryView.backgroundColor = [UIColor colorWithRed:237.0 / 255.0 green:38.0 / 255.0 blue:57.0 / 255.0 alpha:1.0];
            }];
        }
        
        
        
        PLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        NSEntityDescription *entityDesc =[NSEntityDescription entityForName:@"Song" inManagedObjectContext:context];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        
        // NSLog(@"cell ID: %@", [self.songTableView indexPathForCell:cell].row);
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(localID = %@)", cell.index];
        
        
        [request setPredicate:pred];
        
        
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        
        
        if ([objects count] > 0){
            
            UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
            
            
            if([[[objects[0] valueForKey:@"vote"] stringValue] isEqualToString:@"-1"]){
                if(voteType == -1){
                    voteChangeTotal = 0;
                }
                else if(voteType == 0){
                    voteChangeTotal = 1;
                }
                else if(voteType == 1){
                    voteChangeTotal = 2;
                }
                
            }
            else if([[[objects[0] valueForKey:@"vote"] stringValue] isEqualToString:@"0"]){
                voteChangeTotal = voteType;
            }
            else if([[[objects[0] valueForKey:@"vote"] stringValue] isEqualToString:@"1"]){
                if(voteType == -1){
                    voteChangeTotal = -2;
                }
                else if(voteType == 0){
                    voteChangeTotal = -1;
                }
                else if(voteType == 1){
                    voteChangeTotal = 0;
                }
                
            }
            
            if(voteChangeTotal == 0){
                NSLog(@"vote is same returning");
                [self.playPauseButton setUserInteractionEnabled:YES];
                [self.nextSongButton setUserInteractionEnabled: YES];
                return;
            }
            
            NSNumber *votes1 = [objects[0] valueForKey:@"votes"];
            int tempy = [votes1 intValue];
            votes1 = [NSNumber numberWithInt:(tempy + voteChangeTotal)];
            
            
            
            [objects[0] setValue: [NSNumber numberWithInt:voteType] forKey:@"vote"];
            [objects[0] setValue: votes1 forKey:@"votes"];
            
            
            //if vote alreadu exists it will have an id > than length 3
            NSString *test = [objects[0] valueForKey:@"voteID"];
            if(test.length < 3){//[[objects[0] valueForKey:@"voteID"] stringValue]){
                
                
                //NSLog(@"songID::%@",[objects[0] valueForKey:@"songID"]);
                
                PFObject *voteToInsert = [PFObject objectWithClassName: @"Vote"];
                [voteToInsert setObject:[PFUser currentUser] forKey:@"voterID"];
                [voteToInsert setObject:[objects[0] valueForKey:@"songID"] forKey:@"songID"];
                [voteToInsert setObject:[NSNumber numberWithInt:voteType] forKey:@"vote"];
                [voteToInsert setObject:self.playListID forKey:@"playListID"];
                
                [voteToInsert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if(succeeded){
                        
                        [objects[0] setValue: voteToInsert.objectId forKey:@"voteID"];
                        
                        
                    }
                    
                }];
                
                
                
            }
            else{
                ;
                PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
                [query whereKey:@"objectId" equalTo:[objects[0] valueForKey:@"voteID"]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        // The find succeeded.
                        
                        // Do something with the found objects
                        for (PFObject *object in objects) {
                            [object setObject:[NSNumber numberWithInt:voteType] forKey:@"vote"];
                            [object saveInBackground];
                            
                        }
                        
                        
                    } else {
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
            
            PFQuery *query = [PFQuery queryWithClassName:@"Song"];
            [query whereKey:@"objectId" equalTo:[objects[0] valueForKey:@"songID"]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    
                    // Do something with the found objects
                    for (PFObject *object in objects) {
                        
                        NSNumber *totalOldVotes = [object objectForKey:@"votes"];
                        int tempInt = [totalOldVotes intValue];
                        totalOldVotes = [NSNumber numberWithInt:(tempInt + voteChangeTotal)];
                        
                        [object setObject:totalOldVotes forKey:@"votes"];
                        
                        [object saveInBackground];
                        
                        [object setValue: totalOldVotes  forKey:@"votes"];
                        
                        label.text = [totalOldVotes stringValue];
                        
                        [context save:&error];
                        
                        voteState = [NSNumber numberWithInt:0];
                        
                    }
                    
                    
                } else {
                    // Log details of the failure
                    
                    [context save:&error];
                    voteState = [NSNumber numberWithInt:0];
                }
                [self.playPauseButton setUserInteractionEnabled:YES];
                [self.nextSongButton setUserInteractionEnabled: YES];
                noInteract = NO;
            }];
            
            
            
        }
        else{
            //already voted
            NSLog(@"already voted %@", [[objects[0] valueForKey:@"vote"] stringValue]);
        }
        
    }
    else{
        NSLog(@"WTF: THAT SONG IS NOT IN CORE DATA");
        voteState = [NSNumber numberWithInt:0];
    }
    
    
    
    
}
-(void) resetCoreData{
    NSError *error;
    
    PLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    // retrieve the store URL
    NSURL * storeURL = [[context persistentStoreCoordinator] URLForPersistentStore:[[[context persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [context lock];
    [context reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[context persistentStoreCoordinator] removePersistentStore:[[[context persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [[context persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [context unlock];
    ///////
    //Make new persistent store for future saves   (Taken From Above Answer)
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // do something with the error
    }
    
    NSLog(@"Data Reset");
}


- (void)refresh {
    [self.playPauseButton setUserInteractionEnabled:NO];
    [self.nextSongButton setUserInteractionEnabled: NO];
    [self.navBarMenuButton setUserInteractionEnabled:NO];
    noInteract = YES;
    [self resetCoreData];
    [self getPlayListSongsAndPopulate];
    clearTable = YES;
    [self.songTableView reloadData];
    clearTable = NO;
    
}
- (IBAction)refreshButtonTouched: (id)sender {
    /*[self resetCoreData];
    [self getPlayListSongsAndPopulate];
    clearTable = YES;
    [self.songTableView reloadData];
    clearTable = NO;
     */
    [self refresh];
}
- (IBAction)playPause:(id)sender
{
    
    if ([self.playPauseButton.currentTitle isEqualToString: @"Play"])
    {
        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [self.playPauseButton setImage:([UIImage imageNamed:(@"pause1.png")]) forState:UIControlStateNormal];
        NSLog(@"CurrentItem: %@", [self.audioPlayer currentItem]);
        if ([self.audioPlayer currentItem] == nil)
        {
            //self.audioPlayer = [[AVPlayer alloc] initWithURL:[self.nextSong valueForProperty:MPMediaItemPropertyAssetURL]];
            [self refresh];
            //[self chooseSongNotTimer];
            skipThisSong = YES;
        }

        [self.audioPlayer play];
        
        
    }else if ([self.playPauseButton.currentTitle isEqualToString: @"Pause"])
    {
        NSLog(@"%@", @"Pause button pressed");
        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.playPauseButton setImage:[UIImage imageNamed:@"play1.png"] forState:UIControlStateNormal];
        [self.audioPlayer pause];
    }
}
- (IBAction)nextSong:(id)sender
{
    
    [self refresh];
    [self chooseSongNotTimer];
    skipThisSong = YES;
}
- (IBAction)inviteFriendsTouched:(id)sender {
    
    NSString *actionSheetTitle = @"Invite Friends Via"; //Action Sheet Title
    
    NSString *destructiveTitle = nil; //Action Sheet Button Titles
    
    NSString *sms = @"Text";
    
    NSString *facebook = @"Facebook";
    
    NSString *copyLink = @"Copy Link";
    
    NSString *twitter = @"Twitter";
    
    NSString *cancelTitle = @"Cancel";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  
                                  initWithTitle:actionSheetTitle
                                  
                                  delegate:self
                                  
                                  cancelButtonTitle:cancelTitle
                                  
                                  destructiveButtonTitle:destructiveTitle
                                  
                                  otherButtonTitles:sms, facebook, twitter, copyLink, nil];
    
    [actionSheet showInView:self.view];
    
}
- (void)inviteFriends {
    
    NSString *actionSheetTitle = @"Invite Friends Via"; //Action Sheet Title
    
    NSString *destructiveTitle = nil; //Action Sheet Button Titles
    
    NSString *sms = @"Text";
    
    NSString *facebook = @"Facebook";
    
    NSString *copyLink = @"Copy Link";
    
    NSString *twitter = @"Twitter";
    
    NSString *cancelTitle = @"Cancel";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  
                                  initWithTitle:actionSheetTitle
                                  
                                  delegate:self
                                  
                                  cancelButtonTitle:cancelTitle
                                  
                                  destructiveButtonTitle:destructiveTitle
                                  
                                  otherButtonTitles:sms, facebook, twitter, copyLink, nil];
    
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"Text"]) {
        
        NSLog(@"SMS Pressed");
        
        [self sendSMS:[NSString stringWithFormat: @"%@%@",@"Join this playlist and vote on the songs to play. ourplaylistapp.com/webapp/playlist.html?playListID=", self.playListID] recipientList:nil];
        
    }
    
    if ([buttonTitle isEqualToString:@"Copy Link"]) {
        
        NSLog(@"Copy Link pressed");
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        
        pasteboard.string = [NSString stringWithFormat: @"%@%@",@"Join this playlist and vote on the songs to play. ourplaylistapp.com/webapp/playlist.html?playListID=", self.playListID];
        
    }
    
    if ([buttonTitle isEqualToString:@"Facebook"]) {
        
        NSLog(@"Facebook Presed");
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
            
        {
            
            self.mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
            
            self.mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter
            
            [self.mySLComposerSheet setInitialText:[NSString stringWithFormat:@"%@%@",@"Join this playlist. ourplaylistapp.com/webapp/playlist.html?playListID=", self.playListID]]; //the message you want to post
            
            //[self.mySLComposerSheet addImage:yourimage]; //an image you could post
            
            //for more instance methodes, go here:https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Reference/SLComposeViewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012205
            
            [self presentViewController:self.mySLComposerSheet animated:YES completion:nil];
            
        }
        
        [self.mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            NSString *output;
            
            switch (result) {
                    
                case SLComposeViewControllerResultCancelled:
                    
                    output = @"Action Cancelled";
                    
                    break;
                    
                case SLComposeViewControllerResultDone:
                    
                    output = @"Post Successfull";
                    
                    break;
                    
                default:
                    
                    break;
                    
            } //check if everythink worked properly. Give out a message on the state.
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
            
        }];    }
    
    if ([buttonTitle isEqualToString:@"Twitter"]) {
        
        NSLog(@"Twitter Presed");
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
            
        {
            
            self.mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
            
            self.mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter]; //Tell him with what social plattform to use it, e.g. facebook or twitter
            
            [self.mySLComposerSheet setInitialText:[NSString stringWithFormat:@"%@%@",@"Join this playlist! ourplaylistapp.com/webapp/playlist.html?playListID=", self.playListID]]; //the message you want to post
            
            //[self.mySLComposerSheet addImage:yourimage]; //an image you could post
            
            //for more instance methodes, go here:https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Reference/SLComposeViewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012205
            
            [self presentViewController:self.mySLComposerSheet animated:YES completion:nil];
            
        }
        
        [self.mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            NSString *output;
            
            switch (result) {
                    
                case SLComposeViewControllerResultCancelled:
                    
                    output = @"Action Cancelled";
                    
                    break;
                    
                case SLComposeViewControllerResultDone:
                    
                    output = @"Post Successfull";
                    
                    break;
                    
                default:
                    
                    break;
                    
            } //check if everythink worked properly. Give out a message on the state.
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
            
        }];    }
    
    if ([buttonTitle isEqualToString:@"Cancel Button"]) {
        
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
        
    }
    
}

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients

{
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    if([MFMessageComposeViewController canSendText])
        
    {
        
        controller.body = bodyOfMessage;
        
        controller.recipients = recipients;
        
        controller.messageComposeDelegate = self;
        
        [self presentModalViewController:controller animated:YES];
        
    }
    
}



- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result

{
    
    [self dismissModalViewControllerAnimated:YES];
    
    
    
    if (result == MessageComposeResultCancelled)
        
        NSLog(@"Message cancelled");
    
    else if (result == MessageComposeResultSent)
        
        NSLog(@"Message sent");
    
    else 
        
        NSLog(@"Message failed");
    
}




- (IBAction)menuTouched:(id)sender {
    if (noInteract)
    {
        return;
    }
    if (_menu.isOpen){
        return [_menu close];
        
    }
    else{
        REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"invite"
                                                        subtitle:@"invite friends to playlist"
                                                           image:[UIImage imageNamed:@"Icon_Home"]
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              NSLog(@"Item: %@", item);
                                                              [self inviteFriends];
                                                          }];
        
        REMenuItem *exploreItem = [[REMenuItem alloc] initWithTitle:@"home"
                                                           subtitle:@"go to the home screen"
                                                              image:[UIImage imageNamed:@"Icon_Explore"]
                                                   highlightedImage:nil
                                                             action:^(REMenuItem *item) {
                                                                 [chooseSongTimer invalidate];
                                                                 chooseSongTimer = nil;
                                                                 [self performSegueWithIdentifier:@"home" sender:self];

                                                             }];
        
        REMenuItem *activityItem = [[REMenuItem alloc] initWithTitle:@"delete"
                                                            subtitle:@"delete playlist forever"
                                                               image:[UIImage imageNamed:@"Icon_Activity"]
                                                    highlightedImage:nil
                                                              action:^(REMenuItem *item) {
                                                                  NSLog(@"Item: %@", item);
                                                                  [self deletePlaylist];
                                                              }];
        
        
        _menu = [[REMenu alloc] initWithItems:@[homeItem, exploreItem, activityItem]];
        [_menu showFromNavigationController:self.navigationController];
    }
    
    
    /*
    NSLog(@"here");
    NSArray *menuItems =
    @[
      
      
      [KxMenuItem menuItem:@"Invite"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(inviteFriendsTouched:)],
      

      
      [KxMenuItem menuItem:@"Go home"
                     image:[UIImage imageNamed:@"home_icon"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Destroy Playlist"
                     image:[UIImage imageNamed:@"down"]
                    target:self
                    action:@selector(deletePlaylist:)]
      
      
      ];
    
    KxMenuItem *first = menuItems[2];
    first.foreColor = [UIColor colorWithRed:238 / 255.0 green:38 / 255.0 blue:57 / 255.0 alpha:1.0];
    
    [KxMenu showMenuInView:self.view
                  fromRect:self.menuStart.frame
                 menuItems:menuItems];*/

}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"home"])
    {
        MainViewController *mainViewController = [segue destinationViewController];
    }
}
-(void) deletePlaylist
{
    [chooseSongTimer invalidate];
    chooseSongTimer = nil;
    [self.deletingPlaylistIndicator setAlpha:0.8];
    UIBarButtonItem *leftButtonHolder = [self.titleNavBar leftBarButtonItem];
    [self.titleNavBar setLeftBarButtonItem:(nil)];
    [self.titleNavBar setHidesBackButton:YES];
    [self.titleNavBar setRightBarButtonItem:(nil)];
    [self.loader startAnimating];
    if(self.audioPlayer != NULL)
    {
        [self.audioPlayer pause];
        self.audioPlayer = NULL;
    }
    NSLog(@"Removing votes");
    //remove playlist votes
    PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
    [query whereKey:@"playListID" equalTo:self.playListID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        [PFObject deleteAllInBackground: results block:^(BOOL succeeded, NSError *error){
                NSLog(@"Removing song");
                // remove playlist songs
                PFQuery *query = [PFQuery queryWithClassName:@"Song"];
                [query whereKey:@"playListID" equalTo:[PFObject objectWithoutDataWithClassName:@"PlayList" objectId:self.playListID]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                    [PFObject deleteAllInBackground:results block:^(BOOL succeeded, NSError *error) {
                            NSLog(@"Removing playlist");
                            //remove playList
                            PFQuery *query = [PFQuery queryWithClassName:@"PlayList"];
                            [query getObjectInBackgroundWithId:self.playListID block:^(PFObject *playList, NSError *error) {
                                [playList deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    [self.deletingPlaylistIndicator setAlpha:0];
                                    [self.loader stopAnimating];
                                    [self.titleNavBar setLeftBarButtonItem:(leftButtonHolder)];
                                    [self performSegueWithIdentifier:@"home" sender:self];
                                }];
                            }];
                        }];
                }];
                
            }];
    }];
}
- (void) pushMenuItem:(id)sender
{
    [chooseSongTimer invalidate];
    chooseSongTimer = nil;
    [self performSegueWithIdentifier:@"home" sender:self];
}

@end
