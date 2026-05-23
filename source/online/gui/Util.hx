package online.gui;

import online.gui.sidebar.SideUI;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.DisplayObject;

@:publicFields
class Util {
	// 检查按键是否被按下
	static function checkKey(key:Int, keyID:String):Bool {
		for (k in ClientPrefs.keyBinds.get(keyID)) {
			if (key == k)
				return true;
		}
		return false;
	}

	// 检测鼠标是否重叠在对象上
	static function overlapsMouse(obj:DisplayObject) {
		return obj != null && obj.visible && obj.alpha > 0 && obj.mouseX > 0 && obj.mouseX < obj.width && obj.mouseY > 0 && obj.mouseY < obj.height;
	}

	// 创建文本
	static function createText(?parent:DisplayObject, x:Float, y:Float, size:Int = 18, ?color:Int = 0xFFFFFFFF) {
		var obj = new TextField();
		obj.x = x;
		obj.y = y;
		obj.selectable = false;
		obj.multiline = true;
		obj.defaultTextFormat = new TextFormat(Assets.getFont('assets/fonts/vcr.ttf').fontName, size, color, false);
		obj.embedFonts = true;
		return obj;
	}

	// 设置文本内容
	static function setText(obj:TextField, text:String, ?maxWidth:Null<Float>, ?color:Null<Int>) {
		obj.scaleX = 1;
		obj.scaleY = 1;
		if (color != null) {
			var format = obj.defaultTextFormat;
			format.color = color;
			obj.defaultTextFormat = format;
		}
		obj.autoSize = LEFT;
		obj.text = text;
		obj.scaleX = Math.min(1, (maxWidth ?? ((SideUI.instance.curTab?.tabWidth ?? SideUI.DEFAULT_TAB_WIDTH) - obj.x - 20)) / obj.width);
		obj.scaleY = obj.scaleX;
	}

	// 获取文本宽度
	static function getTextWidth(obj:TextField) {
		return obj.textWidth;
	}
	// 获取文本高度
	static function getTextHeight(obj:TextField):Float {
		return obj.textHeight;
	}

	// 邀请玩家一起游戏
	static function inviteToPlay(daUsername:String) {
		if (GameClient.isConnected()) {
			if (NetworkClient.room == null)
				NetworkClient.connect();

			while (NetworkClient.connecting) {}

			if (NetworkClient.room != null) {
				NetworkClient.room.send('inviteplayertoroom', daUsername);
			}
			else
				Alert.alert('网络连接失败！');
		}
		else {
			Alert.alert('你不在房间内！');
		}
	}

	// 获取真实高度
	static function getRealHeight(?parent:DisplayObject) {
		var maxHeight:Float = 0;
		for (child in @:privateAccess parent.__children) {
			if (child.visible)
				maxHeight = Math.max(maxHeight, child.y + child.height - parent.y);
		}
		return maxHeight;
	}

	// 自动换行文本
	static function wrapText(text:String, ?everyCharacters:Int = 45, ?stopAtLine:Int = 10, ?trimLines:Bool = true) {
		var output = '';
		var i = -1;
		var score = 0;
		var lineScore = 0;
		var char = '';

		while (++i < text.length) {
			if (char == '\n' && char == text.charAt(i)) {
				continue;
			}
			char = text.charAt(i);
			score++;

			if (score >= everyCharacters) {
				score = 0;
				lineScore++;

				if (lineScore >= stopAtLine) {
					break;
				}

				if (trimLines) {
					output += '[...]\n';
					while (++i < text.length) {
						if (text.charAt(i) == ' ' || text.charAt(i) == '\n') {
							break;
						}
					}
					continue;
				}
				else {
					output += '\n';
				}
			}
			else if (score >= everyCharacters - 10 && char == ' ') {
				score = 0;
				output += '\n';
				lineScore++;
				if (lineScore >= stopAtLine) {
					break;
				}
				continue;
			}

			if (char == '\n') {
				score = 0;
				lineScore++;
				if (lineScore >= stopAtLine) {
					break;
				}
			}

			output += char;
		}

		if (lineScore >= stopAtLine) {
			output += '\n...';
		}

		return output;
	}
}
