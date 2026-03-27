package objects;

import flixel.addons.ui.StrNameLabel;
import flixel.addons.ui.FlxUIButton;
import flixel.FlxG;
import flixel.addons.ui.FlxUIDropDownMenu;

/**
 * A FlxUIDropDownMenu that is extended to have scrolling capabilities.
 * @author Vortex, larsiusprime (original  scroll code)
 * @see https://github.com/Vortex2Oblivion/LeatherEngine-LTS/blob/main/source/ui/FlxScrollableDropDownMenu.hx
 */
class FlxScrollableDropDownMenu extends FlxUIDropDownMenu  {

    private var currentScroll:Int = 0; //Handles the scrolling
    public var canScroll:Bool = true;
	
	// Handles mobile swipe / drag detection
	private var touchStartY:Float = 0; 
	private var minSwipeDistance:Float = 15;

	public function new(X:Float = 0, Y:Float = 0, DataList:Array<flixel.addons.ui.StrNameLabel>, ?Callback:String -> Void, ?Header:FlxUIDropDownHeader, ?DropPanel:flixel.addons.ui.FlxUI9SliceSprite, ?ButtonList:Array<FlxUIButton>, ?UIControlCallback:(Bool, FlxUIDropDownMenu) -> Void) {
		super(X, Y, DataList, Callback, Header, DropPanel, ButtonList, UIControlCallback);
		dropDirection = Down;
	}
    
    override private function set_dropDirection(dropDirection):FlxUIDropDownMenuDropDirection
    {
        this.dropDirection = Down;
        updateButtonPositions();
        return dropDirection;
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        
		if (dropPanel.visible && list.length > 1 && canScroll)
		{
			var scrollUp:Bool = false;
			var scrollDown:Bool = false;

			if (FlxG.mouse.wheel > 0 || FlxG.keys.justPressed.UP) scrollUp = true;
			if (FlxG.mouse.wheel < 0 || FlxG.keys.justPressed.DOWN) scrollDown = true;

			var pointerJustPressed = false;
			var pointerPressed = false;
			var pointerY:Float = 0;

			if (FlxG.mouse.justPressed) {
				pointerJustPressed = true;
				pointerY = FlxG.mouse.screenY;
			} else if (FlxG.mouse.pressed) {
				pointerPressed = true;
				pointerY = FlxG.mouse.screenY;
			}

			#if FLX_TOUCH
			for (touch in FlxG.touches.list) {
				if (touch.justPressed) {
					pointerJustPressed = true;
					pointerY = touch.screenY;
				} else if (touch.pressed) {
					pointerPressed = true;
					pointerY = touch.screenY;
				}
			}
			#end

			if (pointerJustPressed) {
				touchStartY = pointerY;
				isScrolling = false;
			} 
			else if (pointerPressed) {
				var dragDist = pointerY - touchStartY;
				
				if (Math.abs(dragDist) > minSwipeDistance) {
					isScrolling = true;
					
					if (dragDist > 0) {
						scrollUp = true;
					} else {
						scrollDown = true;
					}

					touchStartY = pointerY; 
				}
			}

			if (scrollUp) {
				currentScroll--;
				if (currentScroll < 0) currentScroll = 0;
				updateButtonPositions();
			} else if (scrollDown) {
				currentScroll++;
				if (currentScroll >= list.length) currentScroll = list.length - 1;
				updateButtonPositions();
			}
		}
    }

    override function updateButtonPositions():Void{
        super.updateButtonPositions();
        var buttonHeight = header.background.height;
		dropPanel.y = header.background.y;
		if (dropsUp())
			dropPanel.y -= getPanelHeight();
		else
			dropPanel.y += buttonHeight;

		var offset = dropPanel.y;
        for (i in 0...currentScroll) {
			var button:FlxUIButton = list[i];
			if(button != null) {
				button.y = -99999;
			}
		}
		for (i in currentScroll...list.length)
		{
			var button:FlxUIButton = list[i];
			if(button != null) {
				button.y = offset;
				offset += buttonHeight;
			}
		}
    }

	 public static function makeStrIdLabelArray(StringArray:Array<String>, UseIndexID:Bool = false):Array<StrNameLabel>
	{
		var strIdArray:Array<StrNameLabel> = [];
		for (i in 0...StringArray.length)
		{
			var ID:String = StringArray[i];
			if (UseIndexID)
			{
				ID = Std.string(i);
			}
			strIdArray[i] = new StrNameLabel(ID, StringArray[i]);
		}
		return strIdArray;
	}
}