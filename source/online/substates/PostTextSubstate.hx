package online.substates;

import flixel.FlxSubstate;
import flixel.text.FlxText;
import flixel.ui.FlxInput;
import openfl.text.StageText;
import openfl.text.TextFieldType;
import openfl.events.Event;
import openfl.events.FocusEvent;
import flixel.FlxG;
import online.ChatBox;

class PostTextSubstate extends FlxSubstate
{
	var label:FlxText;
	#if mobile
	var nativeInput:StageText;
	#else
	var input:FlxInput;
	#end

	var submitCallback:String->Void;
	var hint:String;

	public function new(hint:String, callback:String->Void)
	{
		super();
		this.hint = hint;
		submitCallback = callback;
	}

	override function create()
	{
		super.create();
		label = new FlxText(10, 10, 0, hint, 20);
		add(label);

		#if mobile
		// Android/iOS：用StageText原生输入框，完美支持中文输入法候选
		nativeInput = new StageText();
		nativeInput.type = TextFieldType.INPUT;
		nativeInput.width = FlxG.width - 20;
		nativeInput.height = 40;
		nativeInput.x = 10;
		nativeInput.y = 40;
		nativeInput.stage = FlxG.stage;

		nativeInput.addEventListener(Event.CHANGE, onTextChange);
		nativeInput.addEventListener(Event.SUBMIT, onSubmit);
		nativeInput.addEventListener(FocusEvent.FOCUS_OUT, onBlur);

		nativeInput.needsSoftKeyboard = true;
		#else
		// Windows：FlxInput + LIME_ENABLE_IME，中文IME正常
		input = new FlxInput(10, 40, FlxG.width - 20, 32, "", 20);
		input.maxWidth = FlxG.width - 20;
		add(input);
		#end
	}

	#if mobile
	function onTextChange(e:Event):Void {}
	function onSubmit(e:Event):Void
	{
		var txt = nativeInput.text.trim();
		if (txt != "") submitCallback(txt);
		close();
	}
	function onBlur(e:FocusEvent):Void {}
	#end

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		#if !mobile
		if (input.justPressedEnter)
		{
			var txt = input.text.trim();
			if (txt != "") submitCallback(txt);
			close();
		}
		#end
	}

	function close()
	{
		#if mobile
		nativeInput.stage = null;
		nativeInput.removeEventListener(Event.CHANGE, onTextChange);
		nativeInput.removeEventListener(Event.SUBMIT, onSubmit);
		nativeInput.removeEventListener(FocusEvent.FOCUS_OUT, onBlur);
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
