package options;

import states.FreeplayState;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	function openGameOptions() {
		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'如果勾选，音符会向下移动而不是向上。', //Description
			'downScroll', //Save data variable name
			'bool'); //Variable type
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'如果勾选，你的音符会居中显示。',
			'middleScroll',
			'bool');
		addOption(option);

		var option:Option = new Option('Opponent Notes',
			'如果取消勾选，对手的音符会被隐藏。',
			'opponentStrums',
			'bool');
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"如果勾选，在没有可击中音符时按键，不会判定失误。",
			'ghostTapping',
			'bool');
		addOption(option);
		
		var option:Option = new Option('Auto Pause',
			"如果勾选，当游戏窗口失去焦点时会自动暂停。",
			'autoPause',
			'bool');
		addOption(option);
		option.onChange = onChangeAutoPause;

		var option:Option = new Option('Disable Reset Button',
			"如果勾选，按下 R 将不会生效。",
			'noReset',
			'bool');
		addOption(option);

		var option:Option = new Option('Hitsound Volume',
			'击中音符时会发出“嘀”的音效。"',
			'hitsoundVolume',
			'percent');
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Rating Offset',
			'调整判定“Sick!”的早晚偏移值。\n数值越高，需要越晚击中。',
			'ratingOffset',
			'int');
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		// phantom ass options

		// var option:Option = new Option('Sick! Hit Window',
		// 	'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
		// 	'sickWindow',
		// 	'int');
		// option.displayFormat = '%vms';
		// option.scrollSpeed = 15;
		// option.minValue = 15;
		// option.maxValue = 45;
		// addOption(option);

		// var option:Option = new Option('Good Hit Window',
		// 	'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
		// 	'goodWindow',
		// 	'int');
		// option.displayFormat = '%vms';
		// option.scrollSpeed = 30;
		// option.minValue = 15;
		// option.maxValue = 90;
		// addOption(option);

		// var option:Option = new Option('Bad Hit Window',
		// 	'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
		// 	'badWindow',
		// 	'int');
		// option.displayFormat = '%vms';
		// option.scrollSpeed = 60;
		// option.minValue = 15;
		// option.maxValue = 135;
		// addOption(option);

		var option:Option = new Option('Safe Frames',
			'调整提前或晚点击中音符的容错帧数。',
			'safeFrames',
			'float');
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Disable Note Modchart',
			'如果勾选，音符将不会移动或改变透明度。',
			'disableStrumMovement',
			'bool');
		addOption(option);

		var option:Option = new Option('Modchart Skin Changes',
			'如果启用，谱面事件会改变你当前皮肤的角色。',
			'modchartSkinChanges',
			'bool');
		addOption(option);

		var option:Option = new Option('Disable Lag Detection',
			'如果勾选，游戏检测到卡顿后不会回退3秒。',
			'disableLagDetection',
			'bool');
		addOption(option);
	}

	function openPreferences() {
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'正式版中，启用此项会在游戏启动时检查更新。',
			'checkForUpdates',
			'bool');
		addOption(option);
		#end

		#if DISCORD_ALLOWED
		var option:Option = new Option('Discord Rich Presence',
			"取消勾选可在Discord中隐藏游戏状态。",
			'discordRPC',
			'bool');
		addOption(option);
		#end
		
		var option:Option = new Option('Disable Recording Replays',
			'如果勾选，游戏将不再记录游戏录像，分数也不会上传到排行榜。',
			'disableReplays',
			'bool');
		addOption(option);

		var option:Option = new Option('Disable Leaderboard Submiting',
			'如果勾选，游戏将不再上传录像到排行榜。\n可在游戏内按F2切换。',
			'disableSubmiting',
			'bool');
		addOption(option);

		var option:Option = new Option('Disable Automatic Downloads',
			'禁用自动下载对手的模组和皮肤。',
			'disableAutoDownloads',
			'bool');
		addOption(option);

		var option:Option = new Option('Pause Screen Song:',
			"你希望暂停界面播放什么音乐？",
			'pauseMusic',
			'string',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		var option:Option = new Option('Group Songs:',
			"自由模式中的歌曲应如何分组？",
			'groupSongsBy',
			'string',
			FreeplayState.GROUPS);
		addOption(option);

		var option:Option = new Option('Favorite Tracks Menu Theme',
			'如果勾选，游戏会随机播放你收藏的歌曲作为主菜单音乐。',
			'favsAsMenuTheme',
			'bool');
		option.onChange = () -> {
			states.TitleState.playFreakyMusic();
		};
		addOption(option);

		var option:Option = new Option('Debug Mode',
			"如果勾选，启用调试警告等功能。",
			'debugMode',
			'bool');
		addOption(option);
	}

	public function new(category:String)
	{
		title = category;
		rpcTitle = 'Game Settings Menu'; //for Discord Rich Presence

		switch (category) {
			case 'Gameplay':
				openGameOptions();
			case 'Preferences':
				openPreferences();
		}

		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.data.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

		changedMusic = true;
	}

	override function destroy() {
		if(changedMusic && !OptionsState.onPlayState) states.TitleState.playFreakyMusic();
		super.destroy();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);
	}

	function onChangeAutoPause()
	{
		FlxG.autoPause = ClientPrefs.data.autoPause;
	}
}
