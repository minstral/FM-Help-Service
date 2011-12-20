/*
	FM_Help_ServiceAppDelegate.m
	FM Help Service

	Created by Mark Banks on 11/10/09.
	Copyright 2009~2011 Mark Banks. All rights reserved.
*/


#import "FM_Help_ServiceAppDelegate.h"


#define MAXIMUM_SEARCH_TERM_LENGTH 64
#define DEFAULT_FILEMAKER_HELP_BOOK @"FileMaker Pro 11 Help"


@implementation FM_Help_ServiceAppDelegate



- (void)applicationDidFinishLaunching: (NSNotification *)aNotification
{
#pragma unused ( aNotification )
	
	[NSApp setServicesProvider: self];
}



- ( void ) searchFileMakerHelp: (NSPasteboard *)pasteboard userData: (NSString *)userData error: (NSString **)error
{
#pragma unused ( userData ) // the service does not send anything back

	NSString * bookID = [self helpBookID];
	if ( [bookID length] > 0 ) {
		
		NSString * searchTerm = [self searchTerm: pasteboard];
		NSString * searchFor = [NSString stringWithFormat: @"help:search=%@&bookID=%@", searchTerm, bookID];
		NSString* escapedURL = [searchFor stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		NSURL * helpURL = [NSURL URLWithString: escapedURL];
		[[NSWorkspace sharedWorkspace] openURL: helpURL]; // = bool

	} else {
		*error = NSLocalizedString ( @"Error: no suitable data on the clipboard", @"" );
	}
	
	// don't hang around...
	[[NSRunningApplication currentApplication ] terminate];
}


#pragma mark -
#pragma mark "private" methods
#pragma mark -

// extract the search term from the pasteboard, truncating it to if necessary

- (NSString *) searchTerm: (NSPasteboard *) pasteboard
{
	NSString * searchFor = @"";
	
	// Test for strings on the pasteboard.
	NSArray *classes = [NSArray arrayWithObject: [NSString class]];
	NSDictionary *options = [NSDictionary dictionary];
	
	if ( [pasteboard canReadObjectForClasses: classes options: options] ) {
		
		// get the search term from the clipboard
		NSString *searchTerm = [pasteboard stringForType: NSStringPboardType];
		
		if ( searchTerm != nil ) {

			// the help app doesn't like long search terms...
			// truncate the string in case a large amount of text was (accidentally) selected
			
			NSUInteger length = [searchTerm length];
			if ( length > MAXIMUM_SEARCH_TERM_LENGTH ) {
				length = MAXIMUM_SEARCH_TERM_LENGTH;
			}
			
			searchFor = [searchTerm substringToIndex: length];

		}
	}
	
	return searchFor;
	
}


// find the FileMaker Pro [Advanced] help

- (NSString *) helpBookID
{
	// first try whatever the OS thinks is the current FileMaker help
	
	NSString * pro = @"com.filemaker.client";
	NSString * advanced = [pro stringByAppendingString: @".advanced"];

	// first try for "Advanced"
	
	NSURL * url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier: advanced];
	if ( url == nil ) {
		
		// and failing that "Pro"
		url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier: pro];
	}


	NSString * bookID;
	if ( url == nil ) {

		// still haven't found the help... make one last try
		
		bookID = DEFAULT_FILEMAKER_HELP_BOOK;
		NSString * notFoundError = NSLocalizedString ( @"Unable to determine the help bookID. Trying: ", @"" );
		NSLog ( @"%@%@", notFoundError, DEFAULT_FILEMAKER_HELP_BOOK );
	
	} else {
		
		// extract the id for the help
		
		NSString *plistPath = [[url path ] stringByAppendingPathComponent:@"Contents/info.plist"];
		NSDictionary * contentArray = [NSDictionary dictionaryWithContentsOfFile: plistPath];
		bookID = [contentArray objectForKey: @"CFBundleHelpBookName"];
	
	}
	
	return bookID;
}


@end

