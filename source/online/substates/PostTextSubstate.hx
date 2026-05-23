package online.substates;

import openfl.events.TextEvent;

class PostTextSubstate extends MusicBeatSubstate {
	var title:String;
	var onEnter:String->Void;

	public function new(title:String, onEnter:String->Void) {
        super();
		this.title = title;
		this.onEnter = onEnter;
    }

	var input:InputText;
	var coolCam:FlxCamera;

    override function create() {
        super.create();

		coolCam = new FlxCamera();
		coolCam.bgColor.alpha = 0;
		FlxG.cameras.add(coolCam, false);
		cameras = [coolCam];

		var bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.7;
		bg.scrollFactor.set(0, 0);
		add(bg);

		// 汉化提示（完全不影响功能）
		var title = new FlxText(0, 0, FlxG.width, this.title + "\n\n(按回车键提交)");
		title.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		title.y = FlxG.height / 2 - title.height / 2 - 150;
		title.scrollFactor.set();
		add(title);

		// 输入框本体
		input = new InputText(0, 0, FlxG.width, text -> {
            if (text.trim().length <= 0) return;
			onEnter(text);
            close();
		});
		input.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		input.y = FlxG.height / 2 - input.height / 2;
		input.scrollFactor.set();
		add(input);

		// ==============================================
		// 【关键修复】在 Psych 里安全地获取 stage 并添加中文输入支持
		// ==============================================
		var canvas = FlxG.canvas;
		if (canvas != null && canvas.stage != null) {
			canvas.stage.addEventListener(TextEvent.TEXT_INPUT, function(e:TextEvent):Void {
				if (e.text != null && e.text != "") {
					input.text += e.text;
				}
			});
		}
	}

    var confirmBack = false;
    override function update(elapsed) {
        super.update(elapsed);
		input.hasFocus = true;

        if (input.text.length <= 0 && controls.BACK) {
            if (!confirmBack) {
				confirmBack = true;
                return;
            }
            close();
        }
		else if (input.text.length > 0) {
			confirmBack = false;
        }
    }

	override function destroy() {
		super.destroy();
		FlxG.cameras.remove(coolCam);
	}
}
