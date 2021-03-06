/*
	FM_Help_ServiceAppDelegate.h
	FM Help Service

	Created by Mark Banks on 11/10/09.
	Copyright 2009~2012 Mark Banks. All rights reserved.
*/


#import <Cocoa/Cocoa.h>


@interface FM_Help_ServiceAppDelegate : NSObject <NSApplicationDelegate> {
	
	NSURL * url;
	
}


- (void) searchFileMakerHelp: (NSPasteboard *)pasteboard userData: (NSString *)userData error: (NSString **)error;


// "private" methods

- (NSString *) searchTerm: (NSPasteboard *)pasteboard;
- (void) filemaker_url;
- (NSString *) helpBookID;


@end
