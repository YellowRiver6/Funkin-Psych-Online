package online.objects;

import online.gui.sidebar.SideUI;
import flixel.addons.ui.FlxInputText;
// 必须加这两个！
import lime.ui.Keyboard;
import lime.events.TextEvent;

/**
 * 聊天输入框组件 - 已支持中文IME输入
 */
class InputText extends FlxInputText {
    public var hasFocus:Bool = false;

    public function new(x:Float, y:Float, width:Float, onEnter:(text:String)->Void) {
        super(x, y, Std.int(width));

		backgroundColor = FlxColor.TRANSPARENT;
		fieldBorderColor = FlxColor.TRANSPARENT;
		caretColor = FlxColor.WHITE;

        var prevText:String = '';
		callback = (text, action) -> {
            if (SideUI.instance != null && SideUI.instance.active) {
                this.text = prevText;
                return;
            }
            prevText = text;

            if (action == FlxInputText.ENTER_ACTION) {
				hasFocus = false;
				onEnter(text);
            }
        };
    }

    // 焦点开启时 → 启动中文输入法
    override function set_hasFocus(value:Bool):Bool {
        if (value == true) {
            Keyboard.startTextInput();
            Keyboard.setTextInputRect(new lime.geom.Rectangle(x, y, width, height));
            
            // 监听中文输入（核心！）
            addEventListener(TextEvent.TEXT_INPUT, onTextInput);
        } else {
            Keyboard.stopTextInput();
            removeEventListener(TextEvent.TEXT_INPUT, onTextInput);
        }
        return super.set_hasFocus(value);
    }

    // 接收中文输入
    function onTextInput(e:TextEvent):Void {
        if (e.text != null && e.text != "") {
            this.text += e.text;
        }
    }

    override function update(elapsed) {
        super.update(elapsed);

		if (hasFocus && (FlxG.keys.justPressed.ESCAPE || (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(this)))) {
            hasFocus = false;
        }
    }
}
