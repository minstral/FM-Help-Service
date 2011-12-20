/*
	FM_Help_ServiceAppDelegate.h
	FM Help Service

	Created by Mark Banks on 11/10/09.
	Copyright 2009~2011 Mark Banks. All rights reserved.
*/


#import <Cocoa/Cocoa.h>


@interface FM_Help_ServiceAppDelegate : NSObject <NSApplicationDelegate> {
}


- (void) searchFileMakerHelp: (NSPasteboard *)pasteboard userData: (NSString *)userData error: (NSString **)error;


// "private" methods

- (NSString *) searchTerm: (NSPasteboard *)pasteboard;
- (NSString *) helpBookID;


@end
