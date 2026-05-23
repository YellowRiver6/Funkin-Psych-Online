package online.substates;

import flixel.FlxG;
import flixel.text.FlxText;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.StageText;
import openfl.text.TextFieldType;

class PostTextSubstate extends MusicBeatSubstate
{
	var title:String;
	var onEnter:String->Void;

	#if mobile
	var nativeInput:StageText;
	#else
	var input:String = "";
	#end

	var confirmBack:Bool = false;

	public function new(title:String, onEnter:String->Void)
	{
		super();
		this.title = title;
		this.onEnter = onEnter;
	}

	override function create()
	{
		super.create();

		// 半透明背景
		var bg = new flixel.FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, 0x000000);
		bg.alpha = 0.7;
		bg.scrollFactor.set(0, 0);
		add(bg);

		// 标题文字
		var titleTxt = new FlxText(0, 0, FlxG.width, title + "\n\n(按回车提交 / 按返回取消)");
		titleTxt.setFormat("Arial", 24, 0xFFFFFF, "center");
		titleTxt.y = FlxG.height / 2 - titleTxt.height / 2 - 100;
		titleTxt.scrollFactor.set();
		add(titleTxt);

		#if mobile
		nativeInput = new StageText();
		nativeInput.type = TextFieldType.INPUT;
		nativeInput.width = FlxG.width * 0.8;
		nativeInput.height = 50;
		nativeInput.x = (FlxG.width - nativeInput.width) / 2;
		nativeInput.y = FlxG.height / 2 - nativeInput.height / 2;
		nativeInput.stage = FlxG.stage;

		nativeInput.addEventListener(Event.SUBMIT, onSubmit);
		nativeInput.addEventListener(FocusEvent.FOCUS_OUT, onBlur);
		nativeInput.needsSoftKeyboard = true;
		#else
		input = "";
		#end
	}

	#if mobile
	function onSubmit(e:Event):Void
	{
		var txt = nativeInput.text.trim();
		if (txt.length > 0) {
			onEnter(txt);
		}
		close();
	}
	function onBlur(e:FocusEvent):Void {}
	#end

	override function update(elapsed)
	{
		super.update(elapsed);

		#if !mobile
		if (FlxG.keys.justPressed.BACKSPACE && input.length > 0) {
			input = input.substr(0, input.length - 1);
		}
		if (FlxG.keys.justPressed.ENTER) {
			if (input.trim().length > 0) {
				onEnter(input.trim());
			}
			close();
		}
		#endif

		if (controls.BACK) {
			if (!confirmBack) {
				confirmBack = true;
				return;
			}
			close();
		} else {
			confirmBack = false;
		}
	}

	function close():Void
	{
		#if mobile
		if (nativeInput != null) {
			nativeInput.stage = null;
			nativeInput.removeEventListener(Event.SUBMIT, onSubmit);
			nativeInput.removeEventListener(FocusEvent.FOCUS_OUT, onBlur);
		}
		#end
		FlxG.substates.remove(this);
	}

	override function destroy()
	{
		#if mobile
		nativeInput = null;
		#end
		super.destroy();
	}
}
