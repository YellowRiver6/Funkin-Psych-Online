package online.objects;

import online.gui.sidebar.SideUI;
import flixel.addons.ui.FlxInputText;
import lime.ui.Keyboard;
import lime.events.TextEvent;

class InputText extends FlxInputText {

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
                onEnter(text);
                this.text = "";
            }
        };
    }

    override function set_focus(value:Bool):Bool {
        if (value) {
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
        return super.set_focus(value);
    }

    function onTextInput(e:TextEvent):Void {
        if (e.text != null && e.text != "") {
            this.text += e.text;
        }
    }

    override function update(elapsed) {
        super.update(elapsed);

        if (focus && (FlxG.keys.justPressed.ESCAPE || (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(this)))) {
            focus = false;
        }
    }
}
