package funkin.backend.scripting;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.events.Event;
import openfl.Lib;

typedef DebugMessage = {
	var tf:TextField;
	var timeLeft:Float;
}

class DebugText {
	public static var container:Sprite;
	public static var messages:Array<DebugMessage> = [];
	private static var lastTime:Int = 0;

	public static function addTextToDebug(text:String, color:Int) {
		try {
			if (!ClientPrefs.isDebug()) {
				return;
			}
		} catch(e:Dynamic) {}

		#if LUA_ALLOWED
		if (container == null) {
			container = new Sprite();
			Lib.current.stage.addChild(container); 
			lastTime = Lib.getTimer();
			container.addEventListener(Event.ENTER_FRAME, onUpdate);
		}

		var newText = new TextField();
		newText.defaultTextFormat = new TextFormat("_sans", 16, color, true); 
		newText.text = text;
		newText.selectable = false;
		newText.mouseEnabled = false;
		newText.autoSize = LEFT;

		newText.x = 10;
		newText.y = 10;

		for (msg in messages) {
			msg.tf.y += newText.height + 2;
		}

		container.addChild(newText);
		messages.push({ tf: newText, timeLeft: 6.0 });
		#end
	}

	private static function onUpdate(e:Event) {
		var currentTime = Lib.getTimer();
		var elapsed = (currentTime - lastTime) / 1000;
		lastTime = currentTime;

		var i:Int = messages.length - 1;
		while (i >= 0) {
			var msg = messages[i];

			msg.timeLeft -= elapsed;
			if(msg.timeLeft < 0) msg.timeLeft = 0;

			if(msg.timeLeft < 1) {
				msg.tf.alpha = msg.timeLeft;
			}

			if(msg.tf.alpha == 0 || msg.tf.y >= Lib.current.stage.stageHeight) {
				container.removeChild(msg.tf);
				messages.splice(i, 1);
			}
			i--;
		}
	}
}
