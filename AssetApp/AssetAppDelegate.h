//
//  UntitledAppDelegate.h
//  Untitled
//
//  Created by Vladimir Krivosheev on 03.03.10.
//  Copyright 2010 TWP. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AssetAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	@private NSRect controlFrame;
	@private NSView *contentView;
	@private NSPopUpButton *popUpMenuButton;
}

enum
{
	CONTROL_FRAME_HEIGHT = 30,
	BUTTON_WIDTH = 50
};

@property (assign) IBOutlet NSWindow *window;

- (id)createRoundTexturedButton;
- (id)createPushButton;
- (id)createButton;
- (id)createPopUpButton;
- (id)createRoundTexturedPopUpButton;

- (id)createScrollView;
- (id)createSegmentedControl;

@end
