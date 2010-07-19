package cocoa.plaf.aqua.assetBuilder
{
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Icon;
import cocoa.Insets;
import cocoa.TextInsets;
import cocoa.border.AbstractBitmapBorder;
import cocoa.border.AbstractMultipleBitmapBorder;
import cocoa.border.OneBitmapBorder;
import cocoa.border.Scale1BitmapBorder;
import cocoa.border.Scale3EdgeHBitmapBorder;
import cocoa.border.Scale3HBitmapBorder;
import cocoa.border.Scale3VBitmapBorder;
import cocoa.border.Scale9BitmapBorder;
import cocoa.plaf.BitmapIcon;
import cocoa.plaf.ExternalizableResource;
import cocoa.plaf.aqua.AquaLookAndFeel;
import cocoa.plaf.aqua.BorderPosition;
import cocoa.util.FileUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

public class Builder
{
	[Embed(source="/assets.png")]
	private static var assetsClass:Class;

	[Embed(source="/popUpMenu.png")]
	private static var popUpMenuClass:Class;

	[Embed(source="/Window.bottomBar.application.png")]
	private static var bottomBarApplicationClass:Class;
	[Embed(source="/Window.bottomBar.chooseDialog.png")]
	private static var bottomBarChooseDialogClass:Class;

	[Embed(source="/Window.titleBarAndContent.png")]
	private static var titleBarAndContentClass:Class;
	[Embed(source="/Window.titleBarAndToolbarAndContent.png")]
	private static var titleBarAndToolbarAndContent:Class;

	[Embed(source="/Window.hud.titleBarAndContent.png")]
	private static var hudTitleBarAndContentClass:Class;

	[Embed(source="/segmentedControl.png")]
	private static var segmentedControlClass:Class;
	[Embed(source="/segmentedControl2.png")]
	private static var segmentedControl2Class:Class;
	[Embed(source="/segmentedControl3.png")]
	private static var segmentedControl3Class:Class;
	[Embed(source="/segmentedControl4.png")]
	private static var segmentedControl4Class:Class;

	[Embed(source="/segmentedControl.texturedRounded.png")]
	private static var segmentedControlTRClass:Class;
	[Embed(source="/segmentedControl2.texturedRounded.png")]
	private static var segmentedControl2TRClass:Class;
	[Embed(source="/segmentedControl3.texturedRounded.png")]
	private static var segmentedControl3TRClass:Class;
	[Embed(source="/segmentedControl4.texturedRounded.png")]
	private static var segmentedControl4TRClass:Class;

	[Embed(source="/hud/HUD-ButtonLeft-N.png")]
	private static var hudButtonOffLeft:Class;
	[Embed(source="/hud/HUD-ButtonFill-N.png")]
	private static var hudButtonOffCenter:Class;
	[Embed(source="/hud/HUD-ButtonRight-N.png")]
	private static var hudButtonOffRight:Class;

	[Embed(source="/hud/HUD-ButtonLeft-P.png")]
	private static var hudButtonOnLeft:Class;
	[Embed(source="/hud/HUD-ButtonFill-P.png")]
	private static var hudButtonOnCenter:Class;
	[Embed(source="/hud/HUD-ButtonRight-P.png")]
	private static var hudButtonOnRight:Class;

	[Embed(source="/hud/HUD-PopupLeft-N.png")]
	private static var hudPopUpButtonOffLeft:Class;
	[Embed(source="/hud/HUD-PopupFill-N.png")]
	private static var hudPopUpButtonOffCenter:Class;
	[Embed(source="/hud/HUD-PopupRight-N.png")]
	private static var hudPopUpButtonOffRight:Class;

	[Embed(source="/hud/HUD-PopupLeft-P.png")]
	private static var hudPopUpButtonOnLeft:Class;
	[Embed(source="/hud/HUD-PopupFill-P.png")]
	private static var hudPopUpButtonOnCenter:Class;
	[Embed(source="/hud/HUD-PopupRight-P.png")]
	private static var hudPopUpButtonOnRight:Class;

	[Embed(source="/hud/HUD-PopupLeft-D.png")]
	private static var hudPopUpButtonDisabledLeft:Class;
	[Embed(source="/hud/HUD-PopupFill-D.png")]
	private static var hudPopUpButtonDisabledCenter:Class;
	[Embed(source="/hud/HUD-PopupRight-D.png")]
	private static var hudPopUpButtonDisabledRight:Class;

	[Embed(source="/hud/HUD-SpinnerTop-N.png")]
	private static var hudSpinnerIncrementButtonOff:Class;
	[Embed(source="/hud/HUD-SpinnerTop-P.png")]
	private static var hudSpinnerIncrementButtonOn:Class;
	[Embed(source="/hud/HUD-SpinnerBottom-N.png")]
	private static var hudSpinnerDecrementButtonOff:Class;
	[Embed(source="/hud/HUD-SpinnerBottom-P.png")]
	private static var hudSpinnerDecrementButtonOn:Class;

	[Embed(source="/hud/HUD-SliderKnob_round-N.png")]
	private static var hudSliderThumbOff:Class;
	[Embed(source="/hud/HUD-SliderKnob_round-P.png")]
	private static var hudSliderThumbOn:Class;

	[Embed(source="/hud/HUD-SliderTrack-Fill.png")]
	private static var hudSliderTrackFill:Class;
	[Embed(source="/hud/HUD-SliderTrack-LeftCap.png")]
	private static var hudSliderTrackLeftCap:Class;
	[Embed(source="/hud/HUD-SliderTrack-RightCap.png")]
	private static var hudSliderTrackRightCap:Class;

	[Embed(source="/hud/HUD-Checkbox_Off-N.png")]
	private static var hudCheckBoxOff:Class;
	[Embed(source="/hud/HUD-Checkbox_Off-P.png")]
	private static var hudCheckBoxOffH:Class;
	[Embed(source="/hud/HUD-Checkbox_On-N.png")]
	private static var hudCheckBoxOn:Class;
	[Embed(source="/hud/HUD-Checkbox_On-P.png")]
	private static var hudCheckBoxOnH:Class;

	[Embed(source="/hud/HUDCloseButtonNormal.png")]
	private static var hudTitleBarCloseButtonOff:Class;
	[Embed(source="/hud/HUDCloseButtonPressed.png")]
	private static var hudTitleBarCloseButtonOn:Class;
	[Embed(source="/hud/HUDCloseButtonDisabled.png")]
	private static var hudTitleBarCloseButtonDisabled:Class;

	[Embed(source="/Tree.border.png")]
	private static var treeBorder:Class;

	[Embed(source="/Tree.sideBar.icons.png")]
	private static var treeSideBarIcons:Class;

	[Embed(source="/hud/menuItem.h.png")]
	private static var hudMenuItemH:Class;

	private static var buttonRowsInfo:Vector.<RowInfo> = new Vector.<RowInfo>(3, true);
	// rounded push button
	buttonRowsInfo[0] = new RowInfo(BorderPosition.pushButtonRounded, Scale3EdgeHBitmapBorder.create(new FrameInsets(-2, 0, -3, -2), new Insets(10, NaN, 10, 5)));
	// textured rounded push button
	buttonRowsInfo[1] = new RowInfo(BorderPosition.pushButtonTexturedRounded, Scale3EdgeHBitmapBorder.create(new FrameInsets(0, -1, 0, 0), new Insets(10, NaN, 10, 6)));
	// rounded pop up button
	buttonRowsInfo[2] = new RowInfo(BorderPosition.popUpButtonTexturedRounded, Scale3EdgeHBitmapBorder.create(new FrameInsets(-2, 0, -2, -3), new TextInsets(9, NaN, 9 + 21/* width of double-arrow area */, 5, 21)));

	private function finalizeRowsInfo(rowsInfo:Vector.<RowInfo>, top:Number = 0):void
	{
		for each (var rowInfo:RowInfo in rowsInfo)
		{
			rowInfo.top = top;
			top += rowInfo.height;
		}
	}

	/**
	 * 2 border — 1) top (2 bitmaps — off and highlighted) 2) bottom (2 bitmaps — off and highlighted)
	 */
	private function addSpinnerButtons():void
	{
		borders[BorderPosition.spinnerButton] = createFlexButtonBorder(hudSpinnerIncrementButtonOff, hudSpinnerIncrementButtonOn);
		borders[BorderPosition.spinnerButton + 1] = createFlexButtonBorder(hudSpinnerDecrementButtonOff, hudSpinnerDecrementButtonOn);
	}

	private function createFlexButtonBorder(off:Class, on:Class, frameInsets:FrameInsets = null):Scale1BitmapBorder
	{
		var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(2, true);
		bitmaps[0] = Bitmap(new off()).bitmapData;
		bitmaps[1] = Bitmap(new on()).bitmapData;
		return Scale1BitmapBorder.create(bitmaps, null, frameInsets == null ? new FrameInsets(-1, 0, -1, on == hudSpinnerIncrementButtonOn ? 0 : -2) : frameInsets);
	}

	private function bitmapClassesToBitmaps(bitmapClasses:Vector.<Class>):Vector.<BitmapData>
	{
		bitmapClasses.fixed = true;
		var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(bitmapClasses.length, true);
		for (var i:int = 0; i < bitmapClasses.length; i++)
		{
			bitmaps[i] = Bitmap(new bitmapClasses[i]).bitmapData;
		}

		return bitmaps;
	}

	private var borders:Vector.<Border>;

	public function build(testContainer:DisplayObjectContainer):void
	{
		borders = new Vector.<Border>(BorderPosition.totalLength, true);
		var compoundImageReader:CompoundImageReader = new CompoundImageReader(borders);

		finalizeRowsInfo(buttonRowsInfo, 22);
		compoundImageReader.read(assetsClass, buttonRowsInfo);
		// image view bezel border (imagewell border)
		borders[BorderPosition.imageView] = Scale9BitmapBorder.create(new FrameInsets(-3, -3, -3, -3), new Insets(4, 4, 4, 4)).configure(compoundImageReader.parseScale9Grid(new Rectangle(0, 352, 50, 50), new Insets(8, 8, 8, 8)));

		borders[BorderPosition.textArea] = Scale9BitmapBorder.create(null, new Insets(4, 3, 4, 2)).configure(compoundImageReader.parseScale9Grid(new Rectangle(120, 332, 100, 100)));

		var icons:Vector.<Icon> = new Vector.<Icon>(2, true);
		compoundImageReader.readMenu(icons, popUpMenuClass, Scale9BitmapBorder.create(new FrameInsets(-13, -3, -13, -23), new Insets(0, 4, 0, 4)), 18);
		borders[BorderPosition.hudMenuItem] = OneBitmapBorder.create(Bitmap(new hudMenuItemH()).bitmapData, new Insets(21, NaN, 21, 4));

		var windowBottomBarFrameInsets:FrameInsets = new FrameInsets(-33, 0, -33, -48);
		compoundImageReader.readScale3(bottomBarApplicationClass, Scale3EdgeHBitmapBorder.create(windowBottomBarFrameInsets), BorderPosition.windowApplicationBottomBar);
		compoundImageReader.readScale3(bottomBarChooseDialogClass, Scale3EdgeHBitmapBorder.create(windowBottomBarFrameInsets), BorderPosition.windowChooseDialogBottomBar);

		borders[BorderPosition.segmentItem] = new SegmentedControlBorderReader().read(segmentedControlClass, segmentedControl2Class, segmentedControl3Class, segmentedControl4Class);
		borders[BorderPosition.segmentItem + 1] = new SegmentedControlBorderReader().read(segmentedControlTRClass, segmentedControl2TRClass, segmentedControl3TRClass, segmentedControl4TRClass);

		compoundImageReader.readScrollbar();

		compoundImageReader.readTitleBarAndContent(titleBarAndContentClass, Scale3EdgeHBitmapBorder.create(new FrameInsets(-33, -18, -33)), BorderPosition.window);
		compoundImageReader.readTitleBarAndContent(titleBarAndToolbarAndContent, Scale3EdgeHBitmapBorder.create(new FrameInsets(-33, -18, -33)), BorderPosition.windowWithToolbar);
		compoundImageReader.readScale9(hudTitleBarAndContentClass, BorderPosition.hudWindow, Scale9BitmapBorder.create(new FrameInsets(-7, -2, -7, -10)), 25);

		// HUD PushButton
		compoundImageReader.readButtonAdditionalBitmaps(Scale3EdgeHBitmapBorder.create(new FrameInsets(-2, 0, -2, -2), new Insets(10, NaN, 10, 5)),
														new <Class>[hudButtonOffLeft, hudButtonOffCenter, hudButtonOffRight,
															hudButtonOnLeft, hudButtonOnCenter, hudButtonOnRight], BorderPosition.hudButton);
		// HUD PopUpButton
		compoundImageReader.readButtonAdditionalBitmaps(Scale3EdgeHBitmapBorder.create(new FrameInsets(-1, 0, -1, -2), new TextInsets(7, NaN, 7 + 18 /* width of double-arrow area */, 5, 18)),
														new <Class>[hudPopUpButtonOffLeft, hudPopUpButtonOffCenter, hudPopUpButtonOffRight,
															hudPopUpButtonOnLeft, hudPopUpButtonOnCenter, hudPopUpButtonOnRight, hudPopUpButtonDisabledLeft, hudPopUpButtonDisabledCenter, hudPopUpButtonDisabledRight], BorderPosition.hudPopUpButton);

		addSpinnerButtons();
		borders[BorderPosition.sliderThumb] = createFlexButtonBorder(hudSliderThumbOff, hudSliderThumbOn, new FrameInsets(-1, 0, -1, -2));

		// HUD Slider Track
		compoundImageReader.readButtonAdditionalBitmaps(Scale3EdgeHBitmapBorder.create(), new <Class>[hudSliderTrackLeftCap, hudSliderTrackFill, hudSliderTrackRightCap], BorderPosition.sliderTrack);

		// HUD CheckBox
		borders[BorderPosition.checkBox] = Scale1BitmapBorder.create(bitmapClassesToBitmaps(new <Class>[hudCheckBoxOff, hudCheckBoxOffH, hudCheckBoxOn, hudCheckBoxOnH]),
																		new Insets(12 + 6, 0, 0, 2), new FrameInsets(-1, 0, -1, -1));

		borders[BorderPosition.hudTitleBarCloseButton] = Scale1BitmapBorder.create(bitmapClassesToBitmaps(new <Class>[hudTitleBarCloseButtonOff, hudTitleBarCloseButtonOn, hudTitleBarCloseButtonDisabled]));

		// для tree content insets left это h gap между иконкой/текстом
		borders[BorderPosition.treeItem] = OneBitmapBorder.create(Bitmap(new treeBorder()).bitmapData, new Insets(4, 0, 7, 6));
		compoundImageReader.readTreeIcons(treeSideBarIcons, new FrameInsets(10, 5), new FrameInsets(8, 6));

		var data:ByteArray = new ByteArray();
		data.writeByte(borders.length);
		for each (var border:ExternalizableResource in borders)
		{
			assert(borders.indexOf(border) == borders.lastIndexOf(border));
			border.writeExternal(data);
		}

		data.writeByte(icons.length);
		for each (var icon:ExternalizableResource in icons)
		{
			icon.writeExternal(data);
		}

		FileUtil.writeBytes(File.applicationDirectory.nativePath + "/../../aquaLaF/src/main/resources/borders", data);
		data.position = 0;
		
		show(testContainer, data);

		AquaLookAndFeel._setBordersAndIcons(borders, icons);
	}

	private function show(displayObject:DisplayObjectContainer, data:ByteArray):void
	{
		var x:int = 100;
		var y:int = 100;

		var pendingBitmaps:Vector.<BitmapData> = new Vector.<BitmapData>();

		var n:int = data.readUnsignedByte();
		while (--n > -1 || (n == -1 && pendingBitmaps.length > 0))
		{
			var bitmaps:Vector.<BitmapData>;
			if (n != -1)
			{
				var border:AbstractBitmapBorder;
				switch (data.readUnsignedByte())
				{
					case 0: border = new Scale3EdgeHBitmapBorder(); break;
					case 1: border = new Scale1BitmapBorder(); break;
					case 2: border = new Scale9BitmapBorder(); break;
					case 3: border = new OneBitmapBorder(); break;
					case 4: border = new Scale3HBitmapBorder(); break;
					case 5: border = new Scale3VBitmapBorder(); break;
				}
				border.readExternal(data);

				if (border is AbstractMultipleBitmapBorder)
				{
					bitmaps = AbstractMultipleBitmapBorder(border).getBitmaps();
					if (pendingBitmaps.length > 0)
					{
						bitmaps = pendingBitmaps.concat(bitmaps);
						pendingBitmaps.length = 0;
					}
				}
				else
				{
					pendingBitmaps.push(OneBitmapBorder(border).getBitmap());
					continue;
				}
			}
			else
			{
				bitmaps = pendingBitmaps;
			}

			var lastHeight:Number;
			for each (var bitmapData:BitmapData in bitmaps)
			{
				if (bitmapData == null)
				{
					continue;
				}

				var bitmap:Bitmap = new Bitmap(bitmapData);
				bitmap.x = x;
				bitmap.y = y;
				displayObject.addChild(bitmap);
				x += bitmapData.width + 4;

				lastHeight = bitmapData.height;
			}

			x = 100;
			y += lastHeight < 30 ? 30 : 100;
		}

		y += 40;

		n = data.readUnsignedByte();
		var icon:BitmapIcon;
		for (var i:int = 0; i < n; i++)
		{
			var shape:Shape = new Shape();
			shape.x = x;
			shape.y = y;

			x += 20;

			icon = new BitmapIcon();
			icon.readExternal(data);
			icon.draw(null, shape.graphics, 5, 3);

			displayObject.addChild(shape);
		}
	}
}
}