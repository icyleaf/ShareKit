//
//  SHKiOS6SinaWeibo.m
//  ShareKit
//
//  Created by icyleaf on 12-10-23.
//  Copyright (c) 2012 icyleaf. All rights reserved.
//

#import "SHKiOS6SinaWeibo.h"
#import <Social/Social.h>


@interface SHKiOS6SinaWeibo ()

@property (retain) UIViewController *currentTopViewController;

- (void)callUI:(NSNotification *)notif;
- (void)presentUI;

@end

@implementation SHKiOS6SinaWeibo

@synthesize currentTopViewController;

- (void)dealloc {
    
    [currentTopViewController release];
    [super dealloc];
}

+ (NSString *)sharerTitle
{
	return @"新浪微博";
}

+ (NSString *)sharerId
{
	return @"SHKSinaWeibo";
}

- (void)share {
    
    if ([[SHK currentHelper] currentView]) { //user is sharing from SHKShareMenu
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(callUI:)
                                                     name:SHKHideCurrentViewFinishedNotification
                                                   object:nil];
        [self retain];  //must retain, so that it is still around for SHKShareMenu hide callback. Menu hides asynchronously when sharer is chosen.
        
    } else {
        
        [self presentUI];
    }
}

#pragma mark -

- (void)callUI:(NSNotification *)notif {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHKHideCurrentViewFinishedNotification object:nil];
    [self presentUI];
    [self release]; //see share
}

- (void)presentUI {
    
    if ([self.item shareType] == SHKShareTypeUserInfo) {
        SHKLog(@"User info not possible to download on iOS5+. You can get Twitter enabled user info from Accounts framework");
        return;
    }
    
    SLComposeViewController *socialController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];

    NSString *statusBody = [NSString stringWithString:(self.item.shareType == SHKShareTypeText ? item.text : item.title)];
    
    NSString *tagString = [self tagStringJoinedBy:@" " allowedCharacters:[NSCharacterSet alphanumericCharacterSet] tagPrefix:@"#" forChina:YES];
    if ([tagString length] > 0) statusBody = [statusBody stringByAppendingFormat:@" %@", tagString];
    
    // Trim string to fit 140 character max.
    NSUInteger textLength = [statusBody length] > 140 ? 140 : [statusBody length];
    
    while ([socialController setInitialText:[statusBody substringToIndex:textLength]] == NO && textLength > 0) {
        textLength--;
    }
    [socialController addURL:self.item.URL];
    [socialController addImage:self.item.image];
    
    socialController.completionHandler = ^(SLComposeViewControllerResult result){
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                [self sendDidCancel];
                break;
            case SLComposeViewControllerResultDone:
            default:
                [self sendDidFinish];
                break;
        }
        
        [socialController dismissViewControllerAnimated:YES completion:Nil];
    };
    
    self.currentTopViewController = [[SHK currentHelper] rootViewForCustomUIDisplay];
    [self.currentTopViewController presentViewController:socialController animated:YES completion:nil];
}


@end
