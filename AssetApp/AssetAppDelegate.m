//
//  UntitledAppDelegate.m
//  Untitled
//
//  Created by Vladimir Krivosheev on 03.03.10.
//

#import "AssetAppDelegate.h"

@implementation AssetAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
		
	NSRect frame = NSMakeRect(500, 500, BUTTON_WIDTH * 5, CONTROL_FRAME_HEIGHT * 10);
	// должно NSTitledWindowMask, иначе окно не active
	NSWindow* testWindow  = [[NSWindow alloc] initWithContentRect:frame styleMask:NSBorderlessWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
	[testWindow setOpaque:NO];
	[testWindow setHasShadow:NO];
	[testWindow makeKeyAndOrderFront:NSApp];
	[testWindow setBackgroundColor:[NSColor clearColor]];
	
	contentView = [testWindow contentView];
	controlFrame = NSMakeRect(0, frame.size.height - CONTROL_FRAME_HEIGHT, BUTTON_WIDTH, CONTROL_FRAME_HEIGHT);
	
	// push button, regular
	[self createPushButton];
	[[self createPushButton] highlight:YES];	
	[[self createPushButton] setEnabled:NO];
	
	// round textured, regular
	controlFrame.origin.x = 0;
	controlFrame.origin.y -= CONTROL_FRAME_HEIGHT;
	controlFrame.size.width = BUTTON_WIDTH;
	
	[self createRoundTexturedButton];
	[[self createRoundTexturedButton] highlight:YES];	
	[[self createRoundTexturedButton] setEnabled:NO];
	
	// PopUpButton
	controlFrame.origin.x = 0;
	controlFrame.origin.y -= CONTROL_FRAME_HEIGHT;
	controlFrame.size.width = BUTTON_WIDTH;
	[self createPopUpButton];
	[[self createPopUpButton] highlight:YES];
	[[self createPopUpButton] setEnabled:NO];
	
	// related to PopUpButton — pop up menu
	controlFrame.origin.x = 0;
	controlFrame.origin.y -= CONTROL_FRAME_HEIGHT + 50;
	popUpMenuButton = [self createPopUpButton];
	
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];		
	[menu insertItem:[[NSMenuItem alloc] initWithTitle:@"Item 1" action:NULL keyEquivalent:@""] atIndex:0];
	
	// мы добавляем, чтобы получить checkmark на обычном фоне
	NSMenuItem *menuItemWithCheckmarkForOffState = [[NSMenuItem alloc] initWithTitle:@"Item 2" action:NULL keyEquivalent:@""];
	[menuItemWithCheckmarkForOffState setOffStateImage:[[menu itemAtIndex:0] onStateImage]];
	
	[menu insertItem:menuItemWithCheckmarkForOffState atIndex:1];
	[menu insertItem:[NSMenuItem separatorItem] atIndex:2];
	
	[popUpMenuButton setMenu:menu];
	[popUpMenuButton setBordered:NO];
	[popUpMenuButton performClick:popUpMenuButton];
	
	[NSTimer scheduledTimerWithTimeInterval:5 target:self selector: @selector(openMenu) userInfo:nil repeats: YES];
		
	// Scroll View (List)
	controlFrame.origin.x = 0;
	controlFrame.origin.y -= 3;
	controlFrame.size.width = 3;
	controlFrame.size.height = 3;
	
	NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:controlFrame];
	[contentView addSubview:scrollView];
	
	[scrollView setBorderType:NSBezelBorder];
}

- (void)openMenu {
	[popUpMenuButton performClick:popUpMenuButton];
}

- (id)createButton {
	NSButton *button = [[NSButton alloc] initWithFrame:controlFrame];
	[button setTitle:@""];
	
	[contentView addSubview:button];
	return button;
}

- (id)createRoundTexturedButton {
	NSButton *button = [self createButton];
	[button setBezelStyle:NSTexturedRoundedBezelStyle];
	controlFrame.origin.x += BUTTON_WIDTH;
	
	return button;
}

- (id)createPushButton {
	NSButton *button = [self createButton];
	[button setBezelStyle:NSRoundedBezelStyle];
	controlFrame.origin.x += BUTTON_WIDTH;
		
	return button;
}

- (id)createPopUpButton {
	NSPopUpButton *button = [[NSPopUpButton alloc] initWithFrame:controlFrame ];
	[contentView addSubview:button];
	
	controlFrame.origin.x += BUTTON_WIDTH;
	return button;
}

@end