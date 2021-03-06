//
//  JournlerObject.m
//  Journler
//
//  Created by Philip Dow on 1/26/07.
//  Copyright 2007 Sprouted, Philip Dow. All rights reserved.
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

#import "JournlerObject.h"
#import "JournlerJournal.h"

#import "PDSingletons.h"

#import <SproutedUtilities/SproutedUtilities.h>


static NSString *JournlerObjectDefaultTagIDKey = @"tagID";
static NSString *JournlerObjectDefaultTitleKey = @"title";
static NSString *JournlerObjectDefaultIconKey = @"icon";

//
// bracketing property changes with key-value notifications
// is not necessary as long as key-value coding compliant
// methods are used when setting the property
//

@implementation JournlerObject

- (id) init
{
	return [self initWithProperties:nil];
}

- (id) initWithProperties:(NSDictionary*)aDictionary
{
	if ( self = [super init] )
	{
		// initialize with a default set of properties provided by the concrete subclass
		_properties = [[NSMutableDictionary alloc] initWithDictionary:[[self class] defaultProperties]];
		
		// add the objects from the other dictionary
		if ( aDictionary != nil )
			[_properties addEntriesFromDictionary:aDictionary];
		
		// inital state
		_dirty = [BooleanNumber(NO) retain];
		_deleted = [BooleanNumber(NO) retain];
	}
	return self;
}

#pragma mark -

- (void) dealloc
{
	[_properties release], _properties = nil;
	[_journal release], _journal = nil;
	
	[_dirty release], _dirty = nil;
	[_deleted release], _deleted = nil;
	
	[super dealloc];
}

#pragma mark -

- (id)copyWithZone:(NSZone *)zone 
{	
	// concrete subclasses should call super's implementation or make sure they address the same variables here
	JournlerObject *newObject = [[[self class] allocWithZone:zone] init];
	
	// properties and relationships
	[newObject setProperties:[self properties]];
	[newObject setJournal:[self journal]];
	
	// state data
	[newObject setDeleted:[self deleted]];
	[newObject setDirty:BooleanNumber(YES)];
	
	// applescript support
	[newObject setScriptContainer:[self scriptContainer]];
	
	return newObject;
}

#pragma mark -

- (id)initWithCoder:(NSCoder *)decoder 
{
	// ** concrete subclasses must override **
	NSLog(@"%s - ** concrete subclasses must override **", __PRETTY_FUNCTION__);
	
	// decode the archive
	NSDictionary *archivedProperties = [decoder decodeObjectForKey:@"properties"];
	if ( !archivedProperties ) 
		return nil;
	else
		return [self initWithProperties:archivedProperties];
}


- (void)encodeWithCoder:(NSCoder *)encoder 
{
	// ** concrete subclasses must override	**
	NSLog(@"%s - ** concrete subclasses must override **", __PRETTY_FUNCTION__);
	
	if ( ![encoder allowsKeyedCoding] ) 
	{
		NSLog(@"%s - keyed archiving required", __PRETTY_FUNCTION__);
		return;
	}
	
	NSDictionary *encodedProperties = [self valueForKey:@"properties"];
	[encoder encodeObject:encodedProperties forKey:@"properties"];
}


#pragma mark -

- (NSDictionary*) properties
{
	return _properties;
}

- (void) setProperties:(NSDictionary*)aDictionary
{
	if ( _properties != aDictionary )
	{
		[_properties release];
		_properties = [aDictionary mutableCopyWithZone:[self zone]];
	}
}

+ (NSDictionary*) defaultProperties
{
	// subclasses should override to provide a default set of properties
	return [NSDictionary dictionary];
}

#pragma mark -

- (JournlerJournal*) journal
{
	return _journal;
}

- (void) setJournal:(JournlerJournal*)aJournal
{
	if ( _journal != aJournal )
	{
		[_journal release];
		_journal = [aJournal retain];
		// to-one attribute retains the relationship
		
		[self setValue:BooleanNumber(YES) forKey:@"dirty"];
	}
}

- (NSNumber*) journalID 
{
	return [_properties objectForKey:PDJournalIdentifier]; 
} 

- (void) setJournalID:(NSNumber*)jID 
{
	[_properties setObject:(jID?jID:[NSNumber numberWithInteger:0]) forKey:PDJournalIdentifier];
	[self setDirty:BooleanNumber(YES)];
}

#pragma mark -

- (NSNumber*) dirty
{
	return _dirty;
}

- (void) setDirty:(NSNumber*)aNumber
{
	if ( ![_dirty isEqualToNumber:aNumber] )
	{
		[_dirty release];
		_dirty = [aNumber retain];
		// the number is retained to save memory
		
		// mark the journal dirty
		if ( [_dirty boolValue] )
			[[self valueForKey:@"journal"] setValue:_dirty forKey:@"dirty"];
	}
}

- (NSNumber*) deleted
{
	return _deleted;
}

- (void) setDeleted:(NSNumber*)aNumber
{
	if ( ![_deleted isEqualToNumber:aNumber] )
	{
		[_deleted release];
		_deleted = [aNumber retain];
		// the number is retained to save memory
	}
}

#pragma mark -

- (id) scriptContainer
{
	return _scriptContainer;
}

- (void) setScriptContainer:(id)anObject
{
	_scriptContainer = anObject;
}

- (NSScriptObjectSpecifier *)objectSpecifier
{
	// ** concrete subclasses must override	**
	NSLog(@"%s - ** concrete subclasses must override **", __PRETTY_FUNCTION__);

	return nil;
}

#pragma mark -

- (NSURL*) URIRepresentation
{
	// ** concrete subclasses must override	**
	NSLog(@"%s - ** concrete subclasses must override **", __PRETTY_FUNCTION__);
	return nil;
}

- (NSMenuItem*) menuItemRepresentation:(NSSize)imageSize
{
	NSString *myTitle = [self valueForKey:@"title"];
	if ( myTitle == nil ) myTitle = [NSString string];
		
	NSMenuItem *menuItem = [[[NSMenuItem alloc] 
			initWithTitle:myTitle
			action:nil 
			keyEquivalent:@""] autorelease];
	
	[menuItem setRepresentedObject:self];
	
	if ( imageSize.width != 0 )
	{
		NSImage *menuImage = [[self valueForKey:@"icon"] imageWithWidth:imageSize.width height:imageSize.height];
		[menuItem setImage:menuImage];
	}
	
	return menuItem;
}

#pragma mark -

- (NSUInteger)hash 
{
	// ** concrete subclasses must override	**
	NSLog(@"%s - ** concrete subclasses must override **", __PRETTY_FUNCTION__);
	return 0;
}

- (BOOL)isEqual:(id)anObject 
{
	// ** concrete subclasses must override	**
	NSLog(@"%s - ** concrete subclasses must override **", __PRETTY_FUNCTION__);
	return NO;
}

#pragma mark -

- (NSString *)description
{
	// subclasses might want to override
	return [_properties description];
}

#pragma mark -

+ (NSString*) tagIDKey
{
	// subclasses might want to override
	return JournlerObjectDefaultTagIDKey;
}

+ (NSString*) titleKey
{
	// subclasses might want to override
	return JournlerObjectDefaultTitleKey;
}

+ (NSString*) iconKey
{
	// subclasses might want to override
	return JournlerObjectDefaultIconKey;
}

#pragma mark -

- (NSNumber*) tagID
{
	return [_properties objectForKey:[[self class] tagIDKey]];
}

- (void) setTagID:(NSNumber*)aNumber
{
	[_properties setObject:( aNumber != nil ? aNumber : [NSNumber numberWithInteger:0] ) forKey:[[self class] tagIDKey]];
	[self setValue:BooleanNumber(YES) forKey:@"dirty"];
}

- (NSString*) title
{
	return [_properties objectForKey:[[self class] titleKey]];
}

- (void) setTitle:(NSString*)aString
{
	[_properties setObject:( aString != nil ? aString : [NSString string] ) forKey:[[self class] titleKey]];
	[self setValue:BooleanNumber(YES) forKey:@"dirty"];
}

- (NSImage*) icon
{
	return [_properties objectForKey:[[self class] iconKey]];
}

- (void) setIcon:(NSImage*)anImage
{
	[_properties setValue:( anImage ? anImage : [[[NSImage alloc] initWithSize:NSMakeSize(128,128)] autorelease] ) forKey:[[self class] iconKey]];
	[self setValue:BooleanNumber(YES) forKey:@"dirty"];
}

#pragma mark -
#pragma mark File Manager Delegation

- (BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo 
{
	NSLog(@"\n%s - file manager error working with path: %@\n", __PRETTY_FUNCTION__, [errorInfo description]);
	return NO;
}

- (void)fileManager:(NSFileManager *)manager willProcessPath:(NSString *)path 
{
	return;
}


@end
