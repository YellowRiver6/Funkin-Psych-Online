package mobile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxDestroyUtil;
import mobile.MobilePad;
import mobile.Hitbox;
import mobile.JoyStick;
import flixel.FlxBasic;
import flixel.group.FlxGroup; //fuck you FlxGroup.

/**
 * A simple mobile manager for who doesn't want to create these manually
 * if you're making big projects or have a experience to how controls work, create the controls yourself
 */
class MobileControlManager extends FlxGroup {
	#if TOUCH_CONTROLS
	public var mobilePadCam:FlxCamera;
	public var mobilePad:MobilePad;
	public var joyStickCam:FlxCamera;
	public var joyStick:JoyStick;
	public var hitboxCam:FlxCamera;
	public var hitbox:Hitbox;
	#end

	public function new():Void
	{
		super();
		#if TOUCH_CONTROLS
		trace("MobileControlManager initialized.");
		#else
		trace("MobileControls disabled for this build");
		#end
	}

	public function addMobilePad(DPad:String, Action:String):Void
	{
		#if TOUCH_CONTROLS
		if (mobilePad != null) removeMobilePad();
		mobilePad = new MobilePad(DPad, Action);
		add(mobilePad);
		#end
	}

	public function removeMobilePad():Void
	{
		#if TOUCH_CONTROLS
		if (mobilePad != null)
		{
			remove(mobilePad);
			mobilePad = FlxDestroyUtil.destroy(mobilePad);
		}

		if(mobilePadCam != null)
		{
			FlxG.cameras.remove(mobilePadCam);
			mobilePadCam = FlxDestroyUtil.destroy(mobilePadCam);
		}
		#end
	}

	public function addMobilePadCamera():Void
	{
		#if TOUCH_CONTROLS
		mobilePadCam = new FlxCamera();
		mobilePadCam.bgColor.alpha = 0;
		FlxG.cameras.add(mobilePadCam, false);
		mobilePad.cameras = [mobilePadCam];
		#end
	}

	public function addHitbox(Mode:String):Void
	{
		#if TOUCH_CONTROLS
		if (hitbox != null) removeHitbox();
		hitbox = new Hitbox(Mode);
		add(hitbox);
		#end
	}

	public function removeHitbox():Void
	{
		#if TOUCH_CONTROLS
		if (hitbox != null)
		{
			remove(hitbox);
			hitbox = FlxDestroyUtil.destroy(hitbox);
		}

		if(hitboxCam != null)
		{
			FlxG.cameras.remove(hitboxCam);
			hitboxCam = FlxDestroyUtil.destroy(hitboxCam);
		}
		#end
	}

	public function addHitboxCamera():Void
	{
		#if TOUCH_CONTROLS
		hitboxCam = new FlxCamera();
		hitboxCam.bgColor.alpha = 0;
		FlxG.cameras.add(hitboxCam, false);
		hitbox.cameras = [hitboxCam];
		#end
	}

	public function addJoyStick(x:Float = 0, y:Float = 0, ?graphic:String, ?onMove:Float->Float->Float->String->Void):Void
	{
		#if TOUCH_CONTROLS
		if (joyStick != null) removeJoyStick();
		joyStick = new JoyStick(x, y, graphic, onMove);
		add(joyStick);
		#end
	}

	public function removeJoyStick():Void
	{
		#if TOUCH_CONTROLS
		if (joyStick != null)
		{
			remove(joyStick);
			joyStick = FlxDestroyUtil.destroy(joyStick);
		}

		if(joyStickCam != null)
		{
			FlxG.cameras.remove(joyStickCam);
			joyStickCam = FlxDestroyUtil.destroy(joyStickCam);
		}
		#end
	}

	public function addJoyStickCamera():Void {
		#if TOUCH_CONTROLS
		joyStickCam = new FlxCamera();
		joyStickCam.bgColor.alpha = 0;
		FlxG.cameras.add(joyStickCam, false);
		joyStick.cameras = [joyStickCam];
		#end
	}

	#if TOUCH_CONTROLS
	override public function destroy():Void {
		super.destroy();
		removeMobilePad();
		removeHitbox();
		removeJoyStick();
	}
	#end
}
