package online.objects;

import online.gui.sidebar.SideUI;
import flixel.addons.ui.FlxInputTextIme;

class InputTextIme extends FlxInputTextIme {
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

            if (action == FlxInputTextIme.ENTER_ACTION) {
                hasFocus = false; //allow event to overwrite it
                onEnter(text);
            }
        };
    }

    override function update(elapsed) {
        super.update(elapsed);

        if (hasFocus && (FlxG.keys.justPressed.ESCAPE || (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(this)))) {
            hasFocus = false;
        }
    }
}