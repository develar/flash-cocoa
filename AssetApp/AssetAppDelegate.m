#import "AssetAppDelegate.h"
#import "CustomScroller.h"

@implementation AssetAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
		
	NSRect frame = NSMakeRect(500, 500, 800, CONTROL_FRAME_HEIGHT * 13);
	// должно NSTitledWindowMask, иначе окно не active
	NSWindow* testWindow  = [[NSWindow alloc] initWithContentRect:frame styleMask:NSBorderlessWindowMask | NSResizableWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:NO];
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
	//[popUpMenuButton performClick:popUpMenuButton];
	//[NSTimer scheduledTimerWithTimeInterval:5 target:self selector: @selector(openMenu) userInfo:nil repeats: YES];
		
	// Scroll View (List)
	controlFrame.origin.x = 0;
	controlFrame.origin.y -= 120;
	controlFrame.size.width = 120;
	controlFrame.size.height = 120;
	
	[self createScrollView];
		
	NSScrollView *scrollView = [self createScrollView];
	[[scrollView documentView] setFrame:NSMakeRect(0, 0, 4, 4)];
	
	scrollView = [self createScrollView];
	
	CustomScroller *scroller = [[CustomScroller alloc] initWithFrame:NSMakeRect(0, 0, 1, 0)];
	[scroller setEnabled:YES];
	[scroller setKnobProportion:0.1];
	[scroller setDoubleValue:0.5];
	[scrollView setHorizontalScroller:scroller];
	
	scroller = [[CustomScroller alloc] initWithFrame:NSMakeRect(0, 0, 0, 1)];
	[scroller setEnabled:YES];
	[scroller setKnobProportion:0.1];
	[scroller setDoubleValue:0.5];
	[scrollView setVerticalScroller:scroller];
	
	
	scrollView = [self createScrollView];
	
	scroller = [[CustomScroller alloc] initWithFrame:NSMakeRect(0, 0, 1, 0)];
	scroller.highlightArrowId = YES;
	[scroller setEnabled:YES];
	[scroller setKnobProportion:0.1];
	[scroller setDoubleValue:0.5];
	[scrollView setHorizontalScroller:scroller];
	
	scroller = [[CustomScroller alloc] initWithFrame:NSMakeRect(0, 0, 0, 1)];
	scroller.highlightArrowId = YES;
	[scroller setEnabled:YES];
	[scroller setKnobProportion:0.1];
	[scroller setDoubleValue:0.5];
	[scrollView setVerticalScroller:scroller];
	
	
	
	scrollView = [self createScrollView];
	[scrollView setFrame:NSMakeRect(controlFrame.origin.x - 130, controlFrame.origin.y, 250, 250)];
	
	[[scrollView documentView] setFrame:NSMakeRect(0, 0, 500, 500)];
	
	scroller = [[CustomScroller alloc] initWithFrame:NSMakeRect(0, 0, 1, 0)];
	scroller.highlightArrowId = YES;
	[scroller setEnabled:YES];
	[scroller setKnobProportion:0.8];
	[scroller setDoubleValue:0.5];
	[scrollView setHorizontalScroller:scroller];
	
	scroller = [[CustomScroller alloc] initWithFrame:NSMakeRect(0, 0, 0, 1)];
	scroller.highlightArrowId = YES;
	[scroller setEnabled:YES];
	[scroller setKnobProportion:0.6];
	[scroller setDoubleValue:0.5];
	[scrollView setVerticalScroller:scroller];

	// Image View (NSImageView or, IB Image Well)
	controlFrame.origin.x = 0;
	controlFrame.origin.y -= 50 + 10;
	controlFrame.size.width = 50;
	controlFrame.size.height = 50;
	
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:controlFrame];
	[imageView setImageFrameStyle:NSImageFrameGrayBezel];
	[imageView setEditable:YES];
	[contentView addSubview:imageView];
	
//	NSScroll
	
	return;
	
	// SegmentedControl
	frame.origin.x = 100;
	frame.size.height = CONTROL_FRAME_HEIGHT * 8;
	NSWindow* sWindow  = [[NSWindow alloc] initWithContentRect:frame styleMask:NSBorderlessWindowMask | NSResizableWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:NO];
	[sWindow setOpaque:NO];
	[sWindow setHasShadow:NO];
	[sWindow makeKeyAndOrderFront:NSApp];
	[sWindow setBackgroundColor:[NSColor clearColor]];
	
	controlFrame.origin.x = 0;
	controlFrame.origin.y = frame.size.height - CONTROL_FRAME_HEIGHT;
	controlFrame.size.width = 200;
	
	contentView = [sWindow contentView];
	
	[[self createSegmentedControl] setSelectedSegment:0];
	[[self createSegmentedControl] setSelectedSegment:1];
	[[self createSegmentedControl] setSelectedSegment:2];
	
	// highlight and off
	
	NSSegmentedControl *segmentedControl = [self createSegmentedControl];
	
	NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown
							location:NSMakePoint([segmentedControl frame].origin.x, [segmentedControl frame].origin.y + 1) 
							modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:0 pressure:0];
	
	[segmentedControl mouseDown:event];
	
	segmentedControl = [self createSegmentedControl];
	
	event = [NSEvent mouseEventWithType:NSLeftMouseDown
							   location:NSMakePoint([segmentedControl frame].origin.x + 30, [segmentedControl frame].origin.y + 1) 
						  modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:0 pressure:0];
	
	[segmentedControl mouseDown:event];
	
	segmentedControl = [self createSegmentedControl];
	event = [NSEvent mouseEventWithType:NSLeftMouseDown
							   location:NSMakePoint([segmentedControl frame].origin.x + 50, [segmentedControl frame].origin.y + 1) 
						  modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:0 pressure:0];
	
	[segmentedControl mouseDown:event];
	
	// highlight and on
	segmentedControl = [self createSegmentedControl];
	[segmentedControl setSelectedSegment:0];
	
	event = [NSEvent mouseEventWithType:NSLeftMouseDown
							   location:NSMakePoint([segmentedControl frame].origin.x, [segmentedControl frame].origin.y + 1) 
						  modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:0 pressure:0];
	
	[segmentedControl mouseDown:event];
	
	segmentedControl = [self createSegmentedControl];
	[segmentedControl setSelectedSegment:2];
	event = [NSEvent mouseEventWithType:NSLeftMouseDown
							   location:NSMakePoint([segmentedControl frame].origin.x + 50, [segmentedControl frame].origin.y + 1) 
						  modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:0 pressure:0];
	
	[segmentedControl mouseDown:event];
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

-(id)createScrollView {
	NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:controlFrame];
	
	[scrollView setDrawsBackground:NO];
	
	[scrollView setBorderType:NSNoBorder];
	[scrollView setHasVerticalScroller:YES];
	[scrollView setHasHorizontalScroller:YES];
	
	NSView *bigView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
	[scrollView setDocumentView:bigView];
	[[scrollView documentView] scrollPoint:NSMakePoint(100, 100)];
	
	[contentView addSubview:scrollView];
	
	controlFrame.origin.x += 130;
	return scrollView;
}

- (id)createSegmentedControl {
	NSSegmentedControl *segmentedControl = [[NSSegmentedControl alloc] initWithFrame:controlFrame];
	[contentView addSubview:segmentedControl];
	
	[segmentedControl setSegmentCount:3];
	
	controlFrame.origin.y -= CONTROL_FRAME_HEIGHT;
	return segmentedControl;
}

@end