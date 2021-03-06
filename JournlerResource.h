//
//  JournlerResource.h
//  Journler
//
//  Created by Philip Dow on 10/26/06.
//  Copyright 2006 Sprouted, Philip Dow. All rights reserved.
//

/*
 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions
 and the following disclaimer in the documentation and/or other materials provided with the
 distribution.
 
 * Neither the name of the author nor the names of its contributors may be used to endorse or
 promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// Basically, you can use the code in your free, commercial, private and public projects
// as long as you include the above notice and attribute the code to Philip Dow / Sprouted
// If you use this code in an app send me a note. I'd love to know how the code is used.

// Please also note that this copyright does not supersede any other copyrights applicable to
// open source code used herein. While explicit credit has been given in the Journler about box,
// it may be lacking in some instances in the source code. I will remedy this in future commits,
// and if you notice any please point them out.

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>

typedef NSUInteger JournlerResourceType;

enum {
	kResourceTypeFile = 1,
	kResourceTypeURL = 2,
	kResourceTypeABRecord = 3,
	kResourceTypeJournlerObject = 4
};

enum {
	kResourceTypeRecording = 101,
};

typedef NSUInteger NewResourceCommand;

enum {
	kNewResourceUseDefaults = NSDragOperationGeneric,
	kNewResourceForceLink = NSDragOperationLink,
	kNewResourceForceCopy = NSDragOperationCopy,
	kNewResourceForceMove = NSDragOperationMove
};

enum {
	kJournlerResourceAliasBadge = 0,
	kJournlerResourceQuestionMarkBadge,
	kJournlerResourceBlankDocumentIcon,
	kJournlerResourceAlertBadge
};

#define ResourceUnknownUTI				@"com.journler.unknown"
#define ResourceURLUTI					@"com.journler.url"
#define ResourceABPersonUTI				@"com.journler.abperson"
#define ResourceJournlerObjectURIUTI	@"com.jourlner.uri"

#define ResourceSnapshotUTI				@"com.journler.snapshot"
#define ResourceAudioRecordingUTI		@"com.journler.audio-recording"
#define ResourceVideoRecordingUTI		@"com.journler.video-recording"

#define ResourceMailUTI					@"com.apple.mail.emlx"
#define ResourceMailStandardEmailUTI	@"com.apple.mail.email"
#define ResourceChatUTI					@"com.apple.ichat.ichat"

@class JournlerJournal;
@class JournlerEntry;

#import "JournlerObject.h"

@interface JournlerResource : JournlerObject <NSCopying, NSCoding>
{
	// relationships
	JournlerEntry *entry;
	NSArray *entries;
	
	// used when re-establishing the entry-resource relationships during load
	NSArray *entryIDs;
	NSNumber *owningEntryID;
	
	// applescript
	NSNumber *scriptAliased;
	
	// searching
	float relevance;
	
	// icon memory management
	NSInteger _previewRetainCount;
	NSTimeInterval _lastPreviewAccess;
}

+ (NSArray*) definedUTIs;

- (JournlerEntry*) entry;
- (void) setEntry:(JournlerEntry*)anEntry;

- (NSArray*) entries;
- (void) setEntries:(NSArray*)anArray;

#pragma mark -

- (NSArray *) entryIDs;
- (void) setEntryIDs:(NSArray*)anArray;

- (NSNumber *) owningEntryID;
- (void) setOwningEntryID:(NSNumber*)aNumber;

#pragma mark -

- (JournlerResourceType) type;
- (void) setType:(JournlerResourceType)aResourceType;

- (NSNumber*) searches;
- (void) setSearches:(NSNumber*)search;

- (NSNumber*) label;
- (void) setLabel:(NSNumber*)aNumber;

- (NSString*) uti;
- (void) setUti:(NSString*)aString;

- (NSArray*) utisConforming;
- (void) setUtisConforming:(NSArray*)anArray;

- (NSString*) allUTIs;
- (NSArray*) allUTIsArray;

- (NSNumber*) globalResource;
- (void) setGlobalResource:(NSNumber*)global;

// plain text representation of the receiver, used when performing searches

- (NSString*) textRepresentation;
- (void) setTextRepresentation:(NSString*)aString;

// the last modification date of the underlying data, 
// ie a file's mod date rather than when the resource was last changed in Journler

- (NSDate*) underlyingModificationDate;
- (void) setUnderlyingModificationDate:(NSDate*)aDate;

- (float) relevance;
- (void) setRelevance:(float)aValue;

#pragma mark -

- (BOOL) representsFile;
- (BOOL) representsURL;
- (BOOL) representsABRecord;
- (BOOL) representsJournlerObject;

- (BOOL) isEqualToResource:(JournlerResource*)aResource;

#pragma mark -

//- (NSURL*) URIRepresentation;
- (void) loadIcon;
- (void) cacheIconToDisk;
- (void) reloadIcon;
- (void) addMissingFileBadge;
- (NSString*) createFileAtDestination:(NSString*)path;
- (NSString*) htmlRepresentationWithCache:(NSString*)cachePath;

#pragma mark -

- (void) revealInFinder;
- (void) openWithFinder;

#pragma mark -

- (NSString*) _pathForFileThumbnail;
- (NSImage*) _iconForFileResource;
- (void) _deriveTextRepresentation:(NSString*)filename;

#pragma mark -

- (void) retainPreview;
- (void) releasePreview;
- (NSInteger) previewRetainCount;
- (NSTimeInterval) lastPreviewAccess;
- (void) unloadPreview;
- (NSImage*) previewIfLoaded;

#pragma mark -

- (void) perform253Maintenance;

@end

@interface JournlerResource (FileResource)

- (id) initFileResource:(NSString*)path;

- (NSString*) filename;
- (void) setFilename:(NSString*)aString;

- (NSString*) relativePath;
- (void) setRelativePath:(NSString*)aString;

- (NSString*) path;
- (NSString*) originalPath;

- (BOOL) isAlias;

- (BOOL) isDirectory;
- (BOOL) isFilePackage;

- (BOOL) isAppleScript;
- (BOOL) isApplication;

+ (NSImage*) iconBadgeForType:(NSInteger)type;

@end

@interface JournlerResource (URLResource)

- (id) initURLResource:(NSURL*)aURL;

- (NSString*) urlString;
- (void) setUrlString:(NSString*)aString;

- (NSString*) searchContentForURL;
- (NSString*) htmlRepresentationForURLWithCache:(NSString*)cachePath;

@end

@interface JournlerResource (ABPersonResource)

- (id) initABPersonResource:(ABPerson*)aPerson;

- (NSString*) uniqueId;
- (void) setUniqueId:(NSString*)aString;

- (ABPerson*) person;
- (NSString*) searchContentForABRecord;

@end

@interface JournlerResource (JournlerObjectResource)

- (id) initJournalObjectResource:(NSURL*)aURI;

- (NSString*) uriString;
- (void) setUriString:(NSString*)aString;

- (id) journlerObject;

@end

/*
@interface JournlerResource (AudioVideoSnapshotSupport)

- (id) initSnapshotResource;
- (id) initAudioRecordingResource;
- (id) initVideoRecordingResource;

- (BOOL) representsRecording;

@end
*/

@interface JournlerResource (PasteboardSupport)

- (id) initWithPasteboard:(NSPasteboard*)pboard operation:(NewResourceCommand)command 
		entry:(JournlerEntry*)anEntry journal:(JournlerJournal*)aJournal;

@end

@interface JournlerResource (JournlerScriptability)

- (OSType) scriptType;
- (void) setScriptType:(OSType)osType;

- (OSType) scriptLabel;
- (void) setScriptLabel:(OSType)osType;

- (NSNumber*) scriptAliased;
- (void) setScriptAliased:(NSNumber*)aNumber;

- (NSString*) URIRepresentationAsString;

#pragma mark -

- (NSInteger) indexOfObjectInJSEntries:(JournlerEntry*)anEntry;
- (NSUInteger) countOfJSEntries;
- (JournlerEntry*) objectInJSEntriesAtIndex:(NSUInteger)i;
- (JournlerEntry*) valueInJSEntriesWithUniqueID:(NSNumber*)idNum;

//- (NSScriptObjectSpecifier *)objectSpecifier;

#pragma mark -

- (void) jsExport:(NSScriptCommand *)command;

@end
