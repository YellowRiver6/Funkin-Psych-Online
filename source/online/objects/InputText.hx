package online.objects;

import online.gui.sidebar.SideUI;
import flixel.addons.ui.FlxInputText;
import lime.ui.Keyboard;
import lime.events.TextEvent;
import openfl.events.KeyboardEvent;

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

    override function set_hasFocus(value:Bool):Bool {
        if (value == true) {
            // 安卓 + Windows 通用 IME
            Keyboard.startTextInput();
            Keyboard.setTextInputRect(new lime.geom.Rectangle(x, y, width, height));
            
            addEventListener(TextEvent.TEXT_INPUT, onTextInput);
            #if android
            FlxG.stage.window.textInputEnabled = true;
            #end
        } else {
            Keyboard.stopTextInput();
            removeEventListener(TextEvent.TEXT_INPUT, onTextInput);
            
            #if android
            FlxG.stage.window.textInputEnabled = false;
            #end
        }
        return super.set_hasFocus(value);
    }

    // 核心：接收中文、日文、韩文等所有输入法
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
