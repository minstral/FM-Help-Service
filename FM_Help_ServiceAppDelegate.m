/*
	FM_Help_ServiceAppDelegate.m
	FM Help Service

	Created by Mark Banks on 11/10/09.
	Copyright 2009~2012 Mark Banks. All rights reserved.
*/


#import "FM_Help_ServiceAppDelegate.h"


#define MAXIMUM_SEARCH_TERM_LENGTH 64
#define DEFAULT_FILEMAKER_HELP_BOOK @"FileMaker Pro 12 Help"


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


// find the "best" FileMaker

- (void) filemaker_url
{
	// first try whatever the OS thinks is the current FileMaker help
	
	// FM11 (and earlier)
	NSString * pro = @"com.filemaker.client";
	NSString * advanced = [pro stringByAppendingString: @".advanced"];
	// FM12
	NSString * pro12 = [pro stringByAppendingString: @".pro12"];
	NSString * advanced12 = [pro stringByAppendingString: @".advanced12"];
	
	
	// first try for "12 Advanced"	
	url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier: advanced12];
	if ( url == nil ) {		
		// then how about "Pro 12"	
		url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier: pro12];
		if ( url == nil ) {		
			// next try for "Advanced"	
			url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier: advanced];
			if ( url == nil ) {		
				// and failing that "Pro"
				url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier: pro];
			}
		}
	}
	
}


// find the FileMaker Pro [Advanced] help

- (NSString *) helpBookID
{

	[self filemaker_url];

	NSString * bookID;

	if ( url != nil ) {

		// extract the id for the help
		
		NSString *plistPath = [[url path ] stringByAppendingPathComponent:@"Contents/info.plist"];
		NSDictionary * contentArray = [NSDictionary dictionaryWithContentsOfFile: plistPath];
		bookID = [contentArray objectForKey: @"CFBundleHelpBookName"];
	
	} else {
		
		// still haven't found the help... make one last try
		
		bookID = DEFAULT_FILEMAKER_HELP_BOOK;
		NSString * notFoundError = NSLocalizedString ( @"Unable to determine the help bookID. Trying: ", @"" );
		NSLog ( @"%@%@", notFoundError, DEFAULT_FILEMAKER_HELP_BOOK );
	
	}
	
	return bookID;
}


@end

