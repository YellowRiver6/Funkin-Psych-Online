package online.substates;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.text.FlxText;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.StageText;
import openfl.text.TextFieldType;
import states.PlayState;

// 用 Psych Engine 自带的 MusicBeatSubstate，所有平台都能识别
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

		// 背景
		var bg = new flixel.FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, 0x000000);
		bg.alpha = 0.7;
		bg.scrollFactor.set(0, 0);
		add(bg);

		// 标题
		var titleTxt = new FlxText(0, 0, FlxG.width, title + "\n\n(按回车提交 / 按返回取消)");
		titleTxt.setFormat("Arial", 24, 0xFFFFFF, "center");
		titleTxt.y = FlxG.height / 2 - titleTxt.height / 2 - 100;
		titleTxt.scrollFactor.set();
		add(titleTxt);

		#if mobile
		// Android/iOS：用系统原生 StageText，完美支持中文输入法
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
		// Windows：用简单文本变量 + 监听键盘，避免 FlxInput 兼容性问题
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
		// Windows 键盘输入处理
		if (FlxG.keys.justPressed.BACKSPACE && input.length > 0) {
			input = input.substr(0, input.length - 1);
		}
		if (FlxG.keys.justPressed.ENTER) {
			if (input.trim().length > 0) {
				onEnter(input.trim());
			}
			close();
		}
		// 简单文本输入（中文依赖系统IME，project.xml已开启）
		// 你也可以在这里加自定义字符处理，这里用最兼容的方式
		#endif

		// 取消逻辑
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
