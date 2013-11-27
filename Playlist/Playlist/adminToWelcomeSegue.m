//
//  adminToWelcomeSegue.m
//  Playlist
//
//  Created by Chad Swenson on 7/31/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import "adminToWelcomeSegue.h"
#import <QuartzCore/QuartzCore.h>
@implementation adminToWelcomeSegue

-(void)perform
{
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    
    [sourceViewController.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [sourceViewController.navigationController pushViewController:destinationController animated:NO];
}
@end
