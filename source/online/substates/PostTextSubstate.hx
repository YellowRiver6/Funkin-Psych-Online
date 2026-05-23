package online.substates;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxInput;

class PostTextSubstate extends MusicBeatSubstate
{
	var title:String;
	var onEnter:String->Void;
	var input:FlxInput;
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
		var titleTxt = new FlxText(0, 0, FlxG.width, title);
		titleTxt.setFormat(null, 32, 0xFFFFFF, "center");
		titleTxt.y = FlxG.height / 2 - 120;
		titleTxt.scrollFactor.set();
		add(titleTxt);

		// 标准输入框（最稳定、不报错）
		input = new FlxInput(FlxG.width * 0.1, FlxG.height / 2 - 20, FlxG.width * 0.8, 40);
		input.borderColor = 0xFFFFFF;
		input.borderSize = 2;
		add(input);
	}

	override function update(elapsed)
	{
		super.update(elapsed);

		if (input.justPressedEnter)
		{
			if (input.text.trim() != "")
				onEnter(input.text);
			close();
		}

		if (controls.BACK)
		{
			if (!confirmBack)
			{
				confirmBack = true;
				return;
			}
			close();
		}
	}

	function close()
	{
		FlxG.substates.remove(this);
	}
}
