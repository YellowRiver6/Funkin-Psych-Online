package options;

import objects.Character;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	var antialiasingOption:Int;
	var boyfriend:Character = null;
	public function new()
	{
		title = 'Performance';
		rpcTitle = 'Performance Settings Menu'; //for Discord Rich Presence

		boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
		boyfriend.visible = false;

		var option:Option = new Option('Low Quality',
			"如果勾选，会禁用部分背景细节，减少加载时间并提升性能。",
			'lowQuality',
			'bool');
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			"如果取消勾选，会关闭抗锯齿，提升性能但画面会更锐利。",
			'antialiasing',
			'bool');
		option.onChange = onChangeAntiAliasing;
		addOption(option);
		antialiasingOption = optionsArray.length-1;

		var option:Option = new Option('Shaders',
			"如果取消勾选，会关闭着色器。用于部分视觉效果，低配设备会占用大量性能。",
			'shaders',
			'bool');
		addOption(option);

		#if !html5
		var option:Option = new Option('Framerate',
			"很容易理解，不是吗？",
			'framerate',
			'int');
		addOption(option);

		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;

		var option:Option = new Option('Max FPS',
			"如果勾选，帧率限制会设为1000。此设置会让输入 timing 更精准，但可能出现轻微画面问题。",
			'unlockFramerate',
			'bool');
		option.onChange = onChangeFramerate;
		addOption(option);
		#end

		var option:Option = new Option('Disable Text Item Icons',
			"如果勾选，菜单文本图标将不会加载，大幅减少加载时间。",
			'disableFreeplayIcons',
			'bool');
		addOption(option);

		var option:Option = new Option('Disable Text Item Alphabet',
			"如果勾选，各类菜单元素将使用像素字体渲染。",
			'disableFreeplayAlphabet',
			'bool');
		addOption(option);

		var option:Option = new Option('Combo Stacking',
			"如果取消勾选，判定与连击不会叠加显示，节省少量内存并更易阅读。",
			'comboStacking',
			'bool');
		addOption(option);

		super();
		insert(1, boyfriend);
	}

	function onChangeAntiAliasing()
	{
		FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;
		
		for (sprite in members)
		{
			var sprite:FlxSprite = cast sprite;
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if (ClientPrefs.data.unlockFramerate) {
			FlxG.updateFramerate = 1000;
			FlxG.drawFramerate = 1000;
			return;
		}


		if(ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		boyfriend.visible = (antialiasingOption == curSelected);
	}
}
