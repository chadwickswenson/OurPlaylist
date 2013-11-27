//
//  GuestPlayListViewController.m
//  Playlist
//
//  Created by Chad Swenson on 6/19/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import "GuestPlayListViewController.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import "SongCell.h"
#import "MCSwipeTableViewCell.h"
#import <CoreData/CoreData.h>
#import "PLAppDelegate.h"

@interface GuestPlayListViewController (){
@private
    NSArray *objectsMatchSearch;
    BOOL isFiltered;
}

@end

@implementation GuestPlayListViewController{
    NSMutableArray *voteArray;
    NSNumber *voteState;
    BOOL clearTable;
    BOOL refreshing;
    int height;
    int width;
    
    BOOL first;
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
    
	// Do any additional setup after loading the view.
    
    
   
}

- (void)viewWillAppear:(BOOL)animated {
    voteState  = [NSNumber numberWithInt:0];
    NSLog(@"%@", self.playListTitle);
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.titleNavItem.title = self.playListTitle;
    self.songTableView.backgroundView = nil;
    
    clearTable = NO;
    first = YES;
    
    [self getPlayListSongsAndPopulate];
   
    height = 505;
    width = 320;
   
    if(! [self checkWhetherRunBefore:NSStringFromClass([self class])])
    {
        self.swipeLeftTut.alpha = 1;
       // self.swipeRightTut.alpha = 1;
        
        [self hasRunForMyClass:NSStringFromClass([self class])];
        
        [UIView animateWithDuration:1 animations:^() {
           [self.view viewWithTag:101].alpha = 1.0;
        }];
        [UIView animateWithDuration:1 animations:^() {
            [self.view viewWithTag:100].alpha = 1.0;
        }];
        CGRect leftFrame = self.swipeLeftTut.frame;
        leftFrame.origin.x = 500;
        leftFrame.origin.y = 105;
        self.swipeLeftTut.frame = leftFrame;
        
        leftFrame.origin.x = 0;
        
        [UIView animateWithDuration:0.5
                              delay:2.0
                            options: UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             self.swipeLeftTut.frame = leftFrame;
                         }
                         completion:nil];
        
        CGRect rightFrame = self.swipeRightTut.frame;
        rightFrame.origin.x = -500;
        rightFrame.origin.y = 56;
        self.swipeRightTut.frame = rightFrame;
        
        rightFrame.origin.x = 0;
        
        [UIView animateWithDuration:0.5
                              delay:1.0
                            options: UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             self.swipeRightTut.frame = rightFrame;
                         }
                         completion:nil];

    }
    else{
        first = NO;
        NSLog(@"already here");
    }
}
- (BOOL)checkWhetherRunBefore:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

- (void)hasRunForMyClass:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
-(BOOL)getPlayListSongsAndPopulate{
    
    [self.listViewLoader startAnimating];
    BOOL ret = YES;
    self.songsArray = [[NSArray alloc] init];
    refreshing = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Song"];
    
    [query whereKey:@"playListID" equalTo:[PFObject objectWithoutDataWithClassName:@"PlayList" objectId:self.playListID]];
     [query orderByDescending:@"votes"];
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
    return isFiltered ? objectsMatchSearch.count : [self.songsArray count]  ;
    //return [self.songsArray count];//[playLists count];
    
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
    
    if(isFiltered){
        index = [objectsMatchSearch[indexPath.row] intValue];
    }
    
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
    //cell.accessoryView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    
    //Add image view

    
    //set contentMode to scale aspect to fit
    
    CGRect frame = CGRectMake(0, 4, 10, 45);
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
    CGRect z =  cell.accessoryView.frame;
    z.origin.x =-8;
    z.size.width = 1;
    cell.accessoryView.frame = z;
    
    
        
    if ([objects count] == 0) {
        NSLog(@"no votes found in core data");
    } else {
        matches = objects[0];
        [cell.textLabel setText:[matches valueForKey:@"title"]];
        [cell.detailTextLabel setText:[matches valueForKey:@"artist"]];
        
       
        nameLabel.text = [[objects[0] valueForKey:@"votes"] stringValue];
         
        
        
        if([[[matches valueForKey:@"vote"] stringValue] isEqualToString:@"1"]){
            [UIView animateWithDuration:0.5 animations:^() {
                cell.accessoryView.backgroundColor = [UIColor colorWithRed:38.0 / 255.0 green:169.0 / 255.0 blue:237.0 / 255.0 alpha:1.0];
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
    
    if(voteState == [NSNumber numberWithInt:1]){
        NSLog(@"bad state");
        return;
    }
    else{
        voteState = [NSNumber numberWithInt:0];
    }
    if(first){
        CGRect leftFrame = self.swipeLeftTut.frame;
        
        
        leftFrame.origin.x = -700;
        NSLog(@"move frame");
        [UIView animateWithDuration:0.5
                              delay:0.2
                            options: UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             self.swipeLeftTut.frame = leftFrame;
                         }
                         completion:nil];
        
        CGRect rightFrame = self.swipeRightTut.frame;
        
        
        rightFrame.origin.x = 500;
        
        [UIView animateWithDuration:0.5
                              delay:0.2
                            options: UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             self.swipeRightTut.frame = rightFrame;
                         }
                         completion:nil];
        
        /*[UIView animateWithDuration:0.5
                              delay:1.0
                            options: UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             //self.pinchTutView.alpha = 0.8;
                         }
                         completion:nil];*/
       
    }
    
    if(state == 1 || state == 3){
        //cell.contentView.backgroundColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
        int voteType = 0;
        int voteChangeTotal = 0;
        
         
        if(state == 1){
            voteType = 1;
            [UIView animateWithDuration:0.5 animations:^() {
                cell.accessoryView.backgroundColor = [UIColor colorWithRed:38.0 / 255.0 green:169.0 / 255.0 blue:237.0 / 255.0 alpha:1.0];
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

- (IBAction)refreshButtonTouched:(id)sender {
    [self resetCoreData];
    [self getPlayListSongsAndPopulate];
    clearTable = YES;
    [self.songTableView reloadData];
    clearTable = NO;
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)inviteFriendsTouched:(id)sender {
    NSLog(@"%@",@"Invite Friends Touched");
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
- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    NSLog(@"searchBarTextDidBeginEditing");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"The search text is: %@", searchText);
    
    if (searchText.length == 0)
        isFiltered = NO;
    else
        isFiltered = YES;
    
    NSMutableArray *tmpSearched = [[NSMutableArray alloc] init];
    
    NSNumber *count = [NSNumber numberWithInt:0];
    
    for (PFObject *obj in self.songsArray) {
        
        if ([[obj valueForKey:@"name"] rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [[obj valueForKey:@"artist"] rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound) {
      
            [tmpSearched addObject:count];
           
        }
        
        int value = [count intValue];
        count = [NSNumber numberWithInt:value + 1];
        
    }
    
    objectsMatchSearch = tmpSearched.copy;
    
    //self.searchText = searchText;
    [self.songTableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
    NSLog(@"searchBarTextDidEndEditing");
    [theSearchBar resignFirstResponder];
    [self.view endEditing:YES];
}

- (IBAction)tablePinched:(id)sender {
  /*  CGRect frame = self.songTableView.frame;
    
    
    if(!refreshing && frame.size.height < 250 ){
        refreshing = YES;
        frame.size.height = height;
        frame.size.width = width;
        frame.origin.x = 0;
        frame.origin.y =0;
        
        self.songTableView.frame = frame;
        
        
        [self resetCoreData];
        [self getPlayListSongsAndPopulate];
        clearTable = YES;
        [self.songTableView reloadData];
        clearTable = NO;
    
        NSLog(@"pinched");
    }
    else if(!refreshing){
        
        frame.size.height = frame.size.height - 3;
        frame.size.width = frame.size.width - 2;
        frame.origin.x = (height - frame.size.height)/2;
        frame.origin.y = (width - frame.size.width)/2;

        self.songTableView.frame = frame;
    }*/
    
    if(!refreshing){
        
        refreshing = YES;
        [self resetCoreData];
        [self getPlayListSongsAndPopulate];
        clearTable = YES;
        [self.songTableView reloadData];
        clearTable = NO;
            }
    if(first){
        [UIView animateWithDuration:1 animations:^() {
            self.pinchTutView.alpha = 0;
        }];
        first=NO;
    }
}
- (IBAction)refreshTouched:(id)sender {
    if(!refreshing){
        
        refreshing = YES;
        [self resetCoreData];
        [self getPlayListSongsAndPopulate];
        clearTable = YES;
        [self.songTableView reloadData];
        clearTable = NO;
    }
}
@end
