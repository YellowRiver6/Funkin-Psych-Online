package online.objects;

import online.gui.sidebar.SideUI;
import flixel.addons.ui.FlxInputText;

/**
 * 聊天输入框组件
 * 用于游戏内聊天输入
 */
class InputText extends FlxInputText {
    public function new(x:Float, y:Float, width:Float, onEnter:(text:String)->Void) {
        super(x, y, Std.int(width));

		backgroundColor = FlxColor.TRANSPARENT;
		fieldBorderColor = FlxColor.TRANSPARENT;
		caretColor = FlxColor.WHITE;

        var prevText:String = '';
		callback = (text, action) -> {
            // 禁止在UI打开时输入
			if (SideUI.instance != null && SideUI.instance.active) {
                this.text = prevText;
                return;
            }

            prevText = text;

            // 按下回车时提交消息
            if (action == FlxInputText.ENTER_ACTION) {
				hasFocus = false;
				onEnter(text);
            }
        };
    }

    override function update(elapsed) {
        super.update(elapsed);

		// 按ESC或点击外部失去焦点
		if (hasFocus && (FlxG.keys.justPressed.ESCAPE || (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(this)))) {
            hasFocus = false;
        }
    }
}
