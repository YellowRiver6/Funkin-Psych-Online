package online.substates;

import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import lime.system.System;

class PostTextSubstate extends MusicBeatSubstate {
	var title:String;
	var onEnter:String->Void;

	public function new(title:String, onEnter:String->Void) {
        super();
		this.title = title;
		this.onEnter = onEnter;
    }

	var input:TextField;
	var coolCam:FlxCamera;

    override function create() {
        super.create();
		// 开启系统IME中文输入核心开关
		if(System.window != null){
			System.window.imeEnabled = true;
			System.setHint("SDL_IME_INTERNAL_EDITING", "1");
		}

		coolCam = new FlxCamera();
		coolCam.bgColor.alpha = 0;
		FlxG.cameras.add(coolCam, false);
		cameras = [coolCam];

		var bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.7;
		bg.scrollFactor.set(0, 0);
		add(bg);

		// 标题文字
		var titleTxt = new FlxText(0, 0, FlxG.width, this.title + "\n\n(按回车键提交)");
		titleTxt.setFormat("Microsoft YaHei", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt.y = FlxG.height / 2 - titleTxt.height / 2 - 150;
		titleTxt.scrollFactor.set();
		add(titleTxt);

		// 原生支持中文输入框
		input = new TextField();
		input.type = TextFieldType.INPUT;
		input.editable = true;
		input.selectable = true;
		input.width = FlxG.width * 0.7;
		input.height = 40;
		input.x = (FlxG.width - input.width) / 2;
		input.y = FlxG.height / 2 - input.height / 2;
		// 中文字体，关闭字体嵌入保证输入法生效
		input.defaultTextFormat = new TextFormat("Microsoft YaHei", 26, 0xFFFFFF);
		input.embedFonts = false;
		stage.addChild(input);
		input.setFocus();

		// 字符录入监听
		FlxG.stage.addEventListener(TextEvent.TEXT_INPUT, e -> {
			input.text += e.text;
		});
	}

    var confirmBack = false;
    override function update(elapsed) {
        super.update(elapsed);

		// 回车提交
		if(controls.ACCEPT){
			var txt = input.text.trim();
			if(txt.length > 0){
				onEnter(txt);
				close();
			}
		}

        if (input.text.length <= 0 && controls.BACK) {
            if (!confirmBack) {
				confirmBack = true;
                return;
            }
            close();
        }
		else if (input.text.length > 0)
			confirmBack = false;
    }

	override function destroy() {
		super.destroy();
		if(input != null && input.parent != null){
			input.parent.removeChild(input);
		}
		FlxG.cameras.remove(coolCam);
		// 关闭输入焦点
		if(System.window != null) System.window.imeEnabled = false;
	}
}
