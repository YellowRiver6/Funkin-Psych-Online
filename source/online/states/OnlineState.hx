package online.states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import haxe.io.Path;
import shaders.WarpShader;
import online.network.FunkinNetwork;
import states.FreeplayState;
import lime.system.Clipboard;
import haxe.Json;
import states.MainMenuState;
import openfl.events.KeyboardEvent;
import flixel.addons.text.FlxTextField;

#if lumod
@:build(lumod.LuaScriptClass.build())
#end
class OnlineState extends MusicBeatState {
	var items:FlxTypedSpriteGroup<FlxText>;

	var itms:Array<String> = [
		"加入房间",
		"创建房间",
		"查找房间",
		"在线设置",
		"排行榜",
		"模组下载器"
	];

	var itemDesc:FlxText;
	var playersOnline:FlxText;

	public static var twitterIsDead:Bool = false;
	static var curSelected = 0;

	var inputWait = false;
	var inputString(get, set):String;
	function get_inputString():String {
		switch (curSelected) {
			case 0:
				return daCoomCode;
		}
		return null;
	}
	function set_inputString(v) {
		switch (curSelected) {
			case 0:
				return daCoomCode = v;
		}
		return null;
	}

	public static var inviteRoomID:String;

	var daCoomCode:String = "";
	var disableInput = false;

	var selectLine:FlxSprite;
	var descBox:FlxSprite;
	
	var discord:FlxSprite;
	var github:FlxSprite;
	var bsky:FlxSprite;
	var twitter:FlxSprite;

	function onRoomJoin(err:Dynamic) {
		trace(err);
		if (err != null) {
			disableInput = false;
			return;
		}

		Waiter.putPersist(() -> {
			FlxG.switchState(() -> new RoomState());
		});
	}

	function getItemName(item:String) {
		if (curSelected == 0 && item == "加入房间" && inputWait)
		{
			return "房间代码: " + inputString;
		}
		return item;
	}

	override function create() {
		super.create();

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			states.TitleState.playFreakyMusic();

		if (online.GameClient.isConnected()) {
			disableInput = true;
			FlxG.switchState(() -> new online.states.RoomState());
			return;
		}

		if (inviteRoomID != null) {
			disableInput = true;
			function onJoin(err:Dynamic) {
				Waiter.putPersist(() -> {
					FlxG.switchState(() -> new OnlineState());
				});
			}
			GameClient.joinRoom(inviteRoomID, onJoin);
			inviteRoomID = null;
			return;
		}

		OnlineMods.checkMods();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("菜单中", "在线菜单");
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xff2b2b2b;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		
		var warp:FlxSprite = new FlxSprite();
		warp.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		warp.updateHitbox();
		warp.screenCenter();
		if (!ClientPrefs.data.lowQuality && !ClientPrefs.data.disableOnlineShaders)
			add(new WarpEffect(warp));
		warp.antialiasing = ClientPrefs.data.antialiasing;
		add(warp);

		var lines:FlxSprite = new FlxSprite().loadGraphic(Paths.image('coolLines'));
		lines.updateHitbox();
		lines.screenCenter();
		lines.antialiasing = ClientPrefs.data.antialiasing;
		add(lines);

		selectLine = new FlxSprite();
		selectLine.makeGraphic(1, 1, FlxColor.BLACK);
		selectLine.alpha = 0.3;
		add(selectLine);

		descBox = new FlxSprite(0, FlxG.height - 125);
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.4;
		add(descBox);

		items = new FlxTypedSpriteGroup<FlxText>();
		var prevText:FlxText = null;
		var i = 0;
		for (itm in itms) {
			var text = new FlxText(0, 0, 0, getItemName(itm));
			if (prevText != null) {
				text.y += prevText.height * i;
			}
			text.ID = i;
			// ==============================================
			// 这里把字体大小从 40 改成 30（适配中文）
			// ==============================================
			text.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.alpha = inputWait ? 0.5 : 0.8;
			if (text.ID == curSelected) {
				text.text = "> " + text.text + " <";
				text.alpha = 1;
			}
			items.add(prevText = text);
			i++;
		}
		items.screenCenter(Y);
		add(items);

		discord = new FlxSprite();
		discord.antialiasing = ClientPrefs.data.antialiasing;
		discord.frames = Paths.getSparrowAtlas('online_discord');
		discord.animation.addByPrefix('idle', "idle", 24);
		discord.animation.addByPrefix('active', "active", 24);
		discord.animation.play('idle');
		discord.updateHitbox();
		discord.x = 30;
		discord.y = FlxG.height - discord.height - 30;
		discord.alpha = 0.8;
		add(discord);

		github = new FlxSprite();
		github.antialiasing = ClientPrefs.data.antialiasing;
		github.frames = Paths.getSparrowAtlas('online_github');
		github.animation.addByPrefix('idle', "idle", 24);
		github.animation.addByPrefix('active', "active", 24);
		github.animation.play('idle');
		github.updateHitbox();
		github.x = discord.x + discord.width + 20;
		github.y = FlxG.height - github.height - 28;
		github.alpha = 0.8;
		add(github);

		if (twitterIsDead) {
			bsky = new FlxSprite();
			bsky.antialiasing = ClientPrefs.data.antialiasing;
			bsky.frames = Paths.getSparrowAtlas('online_bsky');
			bsky.animation.addByPrefix('idle', "idle", 24);
			bsky.animation.addByPrefix('active', "active", 24);
			bsky.animation.play('idle');
			bsky.updateHitbox();
			bsky.x = github.x + github.width + 20;
			bsky.y = FlxG.height - bsky.height - 28;
			bsky.alpha = 0.8;
			add(bsky);
		}
		else {
			twitter = new FlxSprite();
			twitter.antialiasing = ClientPrefs.data.antialiasing;
			twitter.frames = Paths.getSparrowAtlas('online_twitter');
			twitter.animation.addByPrefix('idle', "idle", 24);
			twitter.animation.addByPrefix('active', "active", 24);
			twitter.animation.play('idle');
			twitter.updateHitbox();
			twitter.x = github.x + github.width + 20;
			twitter.y = FlxG.height - twitter.height - 28;
			twitter.alpha = 0.8;
			add(twitter);
		}

		var microblog = (twitterIsDead ? bsky : twitter);

		itemDesc = new FlxText(0, FlxG.height - 170);
		itemDesc.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		itemDesc.screenCenter(X);
		add(itemDesc);

		playersOnline = new FlxText(0, 100);
		playersOnline.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		playersOnline.alpha = 0.7;
		playersOnline.text = "获取中...";
		playersOnline.screenCenter(X);
		add(playersOnline);

		var availableRooms = new FlxText(0, 130);
		availableRooms.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		availableRooms.alpha = 0.6;
		availableRooms.screenCenter(X);
		add(availableRooms);

		var credit = new FlxText(0, 0, 0, 'Psych Online 作者：Snirozu');
		credit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		credit.alpha = 0.3;
		credit.screenCenter(X);
		credit.x = (microblog.x + microblog.width - discord.x) / 2 + discord.x - credit.width / 2;
		credit.y = FlxG.height - credit.height - 5;
		add(credit);

		var frontMessage = new FlxText(0, 0, 500);
		frontMessage.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		frontMessage.alpha = 0.5;
		frontMessage.x = FlxG.width - frontMessage.fieldWidth - 50;
		add(frontMessage);

		final theus = this;
		Thread.run(() -> {
			FunkinNetwork.ping();

			if (FunkinNetwork.loggedIn)
				Waiter.put(() -> {
					var profileBox = new ProfileBox(FunkinNetwork.nickname, true);
					profileBox.setPosition(FlxG.width - profileBox.width - 20, 20);
					if (FlxG.state == theus)
						add(profileBox);
				});
		});

		Thread.run(() -> {
			var data = FunkinNetwork.fetchFront();
			Waiter.put(() -> {
				if (data == null) {
					playersOnline.text = "网络离线";
				}
				else {
					playersOnline.text = "在线玩家: " + data.online;
					availableRooms.text = '可用房间: ' + data.rooms;
					frontMessage.text = data.sez;
					frontMessage.y = FlxG.height - frontMessage.height - 20;
				}

				playersOnline.screenCenter(X);
				availableRooms.screenCenter(X);
			});
		});
		changeSelection(0);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

		FlxG.mouse.visible = true;
		
		mobileManager.addMobilePad('NONE', 'B');
		mobileManager.addMobilePadCamera();
	}

	override function destroy() {
		super.destroy();

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	override function update(elapsed) {
		super.update(elapsed);

		if (disableInput) return;

		for (item in items) {
			item.text = getItemName(itms[item.ID]);
			item.alpha = inputWait ? 0.5 : 0.8;
			if (item.ID == curSelected) {
				item.text = "> " + item.text + " <";
				item.alpha = 1;
			}
			item.screenCenter(X);
		}

		var mouseInItems = FlxG.mouse.y > items.y && FlxG.mouse.y < items.y + items.members.length * 40;

		if (FlxG.mouse.justPressed && inputWait) {
			if (!FlxG.mouse.overlaps(items.members[curSelected])) {
				inputWait = false;
				return;
			}
			enterInput();
			return;
		}

		if (FlxG.mouse.justPressedRight && inputWait && Clipboard.text != null) {
			inputString += Clipboard.text;
		}

		if (FlxG.mouse.justMoved && !inputWait && mouseInItems) {
			curSelected = Std.int((FlxG.mouse.y - (items.y)) / 40);
			changeSelection(0);
		}

		if (!inputWait) {
			if (controls.UI_UP_P)
				changeSelection(-1);
			else if (controls.UI_DOWN_P)
				changeSelection(1);

			if (controls.ACCEPT || (FlxG.mouse.justPressed && mouseInItems)) {
				switch (itms[curSelected]) {
					case "加入房间":
						FlxG.stage.window.textInputEnabled = true;
						inputWait = true;
					case "查找房间":
						disableInput = true;
						FlxG.switchState(() -> new FindRoomState());
					case "创建房间":
						disableInput = true;
						GameClient.createRoom(GameClient.serverAddress, onRoomJoin);
					case "在线设置":
						disableInput = true;
						FlxG.switchState(() -> new OnlineOptionsState());
					case "排行榜":
						openSubState(new TopPlayerSubstate());
					case "模组下载器":
						disableInput = true;
						FlxG.switchState(() -> new DownloaderState());
				}
			}

			if (controls.BACK) {
				disableInput = true;

				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				FlxG.mouse.visible = false;

				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new MainMenuState());
			}
			
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V) {
				disableInput = true;
				GameClient.joinRoom(Clipboard.text, onRoomJoin);
			}

			if (FlxG.mouse.justPressed || FlxG.mouse.justMoved) {
				if (FlxG.mouse.overlaps(discord)) {
					discord.alpha = 1;
					discord.animation.play("active");
					discord.offset.set(2, 2);

					itemDesc.text = "加入官方中文交流群";
					itemDesc.screenCenter(X);

					if (FlxG.mouse.justPressed) {
						RequestSubstate.requestURL("https://discord.gg/juHypjWuNc", true);
					}
				}
				else {
					discord.alpha = 0.8;
					discord.animation.play("idle");
					discord.offset.set(0, 0);
				}

				if (FlxG.mouse.overlaps(github)) {
					github.alpha = 1;
					github.animation.play("active");

					itemDesc.text = "查看文档、常见问题与源代码";
					itemDesc.screenCenter(X);

					if (FlxG.mouse.justPressed) {
						switch (Main.repoHost) {
							case 'github':
								RequestSubstate.requestURL("https://github.com/Snirozu/Funkin-Psych-Online/wiki", true);
							case 'codeberg':
								RequestSubstate.requestURL("https://codeberg.org/Snirozu/Funkin-Psych-Online/wiki", true);
							default:
								Alert.alert("离线状态");
						}
					}
				}
				else {
					github.alpha = 0.8;
					github.animation.play("idle");
				}

				if (twitterIsDead) {
					if (FlxG.mouse.overlaps(bsky)) {
						bsky.alpha = 1;
						bsky.animation.play("active");

						itemDesc.text = "关注官方账号";
						itemDesc.screenCenter(X);

						if (FlxG.mouse.justPressed) {
							RequestSubstate.requestURL("https://bsky.app/profile/funkin.sniro.boo", true);
						}
					}
					else {
						bsky.alpha = 0.8;
						bsky.animation.play("idle");
					}
				}
				else {
					if (FlxG.mouse.overlaps(twitter)) {
						twitter.alpha = 1;
						twitter.animation.play("active");
						twitter.offset.set(5, 5);

						itemDesc.text = "关注官方账号";
						itemDesc.screenCenter(X);

						if (FlxG.mouse.justPressed) {
							RequestSubstate.requestURL("https://twitter.com/PsychOnlineFNF", true);
						}
					}
					else {
						twitter.alpha = 0.8;
						twitter.animation.play("idle");
						twitter.offset.set(0, 0);
					}
				}
			}
		}
	}
	
	function changeSelection(diffe:Int) {
		curSelected += diffe;

		if (curSelected >= items.length) {
			curSelected = 0;
		}
		else if (curSelected < 0) {
			curSelected = items.length - 1;
		}

		switch (curSelected) {
			case 0:
				itemDesc.text = "输入房间代码加入房间";
			case 1:
				itemDesc.text = "创建一个新的游戏房间";
			case 2:
				itemDesc.text = "查看所有公开房间列表";
			case 3:
				itemDesc.text = "在线功能设置与账号管理";
			case 4:
				itemDesc.text = "查看全服玩家分数排行榜";
			case 5:
				itemDesc.text = "从 Gamebanana 下载模组";
		}
		itemDesc.screenCenter(X);

		descBox.scale.set(FlxG.width - 500, (itemDesc.text.split("\n").length + 2) * (itemDesc.size));
		descBox.y = itemDesc.y + descBox.scale.y * 0.5 - itemDesc.size;
		descBox.screenCenter(X);
		
		selectLine.y = (items.y + 20) + (curSelected) * 40;
		selectLine.scale.set(FlxG.width, 40);
		selectLine.screenCenter(X);

		for (item in items) {
			item.text = getItemName(itms[item.ID]);
			item.alpha = inputWait ? 0.5 : 0.8;
			if (item.ID == curSelected) {
				item.text = "> " + item.text + " <";
				item.alpha = 1;
			}
			item.screenCenter(X);
		}
	}

	function onKeyDown(e:KeyboardEvent) {
		if (!inputWait) return;

		var key = e.keyCode;

		if (e.charCode == 0) {
			return;
		}

		if (key == 46) {
			return;
		}

		if (key == 8) {
			inputString = inputString.substring(0, inputString.length - 1);
			return;
		}
		else if (key == 13) {
			enterInput();
			return;
		}
		else if (key == 27) {
			inputWait = false;
			tempDisableInput();
			return;
		}

		var newText:String = String.fromCharCode(e.charCode);
		if ((curSelected == 0 && !e.shiftKey) || (curSelected != 0 && e.shiftKey)) {
			newText = newText.toUpperCase();
		}
		else {
			newText = newText.toLowerCase();
		}

		if (key == 86 && e.ctrlKey) {
			newText = Clipboard.text;
		}

		if (newText.length > 0) {
			inputString += newText;
		}
	}

	function enterInput() {
		inputWait = false;

		if (inputString.length >= 0) {
			switch (itms[curSelected].toLowerCase()) {
				case "加入房间":
					disableInput = true;
					FlxG.stage.window.textInputEnabled = false;
					
					// 彩蛋代码保留
					if (daCoomCode.toLowerCase() == "adachi") {
						FlxG.sound.playMusic(Paths.sound('cabbage'));
						var image = new FlxSprite().loadGraphic(Paths.image('unnamed_file_from_google'));
						image.setGraphicSize(FlxG.width, FlxG.height);
						image.updateHitbox();
						FreeplayState.destroyFreeplayVocals();
						add(image);
						return;
					}
					else if (daCoomCode.toLowerCase() == "tomar") {
						FlxG.sound.playMusic(Paths.sound('tomar'));
						var image = new FlxSprite().loadGraphic(Paths.image('tomar'));
						image.setGraphicSize(FlxG.width, FlxG.height);
						image.updateHitbox();
						FreeplayState.destroyFreeplayVocals();
						add(image);
						FlxG.sound.music.onComplete = () -> {
							remove(image);
							image.destroy();
							disableInput = false;
							states.TitleState.playFreakyMusic();
						};
						return;
					}
					else if (daCoomCode.toLowerCase() == "3d") {
						FlxG.switchState(() -> new online.s3d.ScriptedState3D());
						return;
					}
					GameClient.joinRoom(daCoomCode, onRoomJoin);
			}
		}

		tempDisableInput();
	}

	function tempDisableInput() {
		disableInput = true;
		new FlxTimer().start(0.1, (t) -> disableInput = false);
	}
}
