package options;

import states.FreeplayState;
import backend.NoteSkinData;
import online.GameClient;
import objects.Note;
import objects.StrumNote;
import objects.Alphabet;

class VisualsUISubState extends BaseOptionsMenu
{
	public static var isOpened:Bool = false;

	var noteOptionID:Int = -1;
	var notes:FlxTypedGroup<StrumNote>;
	var notesTween:Array<FlxTween> = [];
	var noteY:Float = 90;

	function openNotes() {
		// for note skins
		notes = new FlxTypedGroup<StrumNote>();
		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = new StrumNote(370 + (560 / Note.colArray.length) * i, -200, i, 0);
			note.centerOffsets();
			note.centerOrigin();
			note.playAnim('static');
			notes.add(note);
		}

		// options

		var option:Option = new Option('Note Colors',
			'设置音符的颜色！',
			null,
			'button');
		option.onChange = () -> {
			openSubState(new options.NotesSubState());
		};
		addOption(option);

		if(NoteSkinData.noteSkins.length > 0)
		{
			if(!NoteSkinData.noteSkinArray.contains(ClientPrefs.data.noteSkin))
				ClientPrefs.data.noteSkin = ClientPrefs.defaultData.noteSkin; //Reset to default if saved noteskin couldnt be found

			var option:Option = new Option('Note Skins:',
				"选择你喜欢的音符皮肤。",
				'noteSkin',
				'string',
				NoteSkinData.noteSkinArray);
			addOption(option);
			option.onChange = onChangeNoteSkin;
			noteOptionID = optionsArray.length - 1;
		}
		
		var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared');
		if(noteSplashes.length > 0)
		{
			if(!noteSplashes.contains(ClientPrefs.data.splashSkin))
				ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; //Reset to default if saved splashskin couldnt be found

			noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin); //Default skin always comes first
			var option:Option = new Option('Note Splashes:',
				"选择你喜欢的音符击中特效，或关闭该功能。",
				'splashSkin',
				'string',
				noteSplashes);
			addOption(option);
		}

		var option:Option = new Option('Note Splash Opacity',
			'设置音符击中特效的透明度。\n0% 表示关闭该特效。',
			'splashAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Note Hold Splash Opacity',
			'设置长按音符特效的透明度。\n0% 表示关闭该特效。',
			'holdSplashAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Trail Note Opacity',
			'设置长按音符拖尾的透明度。',
			'holdAlpha',
			'percent');
		option.scrollSpeed = 1.3;
		option.minValue = 0.5;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Note Underlay Opacity', '如果数值大于0%，玩家音符下方会显示底色。', 'noteUnderlayOpacity', 'percent');
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.05;
		option.decimals = 2;

		var option:Option = new Option('Note Underlay Type:',
			"设置游戏渲染音符底色的方式。",
			'noteUnderlayType',
			'string',
			['All-In-One', 'By Note']);
		addOption(option);
	}

	function openAccessibility() {
		var option:Option = new Option('Flashing Lights',
			"如果你对闪光敏感，请取消勾选！",
			'flashing',
			'bool');
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"如果取消勾选，击中节拍时相机不会缩放。",
			'camZooms',
			'bool');
		addOption(option);

		var option:Option = new Option('Camera Shakes',
			"如果取消勾选，相机将不会震动。",
			'camShakes',
			'bool');
		addOption(option);

		var option:Option = new Option('Camera Tilt',
			"如果取消勾选，相机将不会倾斜。",
			'camAngles',
			'bool');
		addOption(option);

		var option:Option = new Option('Camera Movement',
			"如果取消勾选，相机会固定不动，不会跟随角色移动。",
			'camMovement',
			'bool');
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"如果取消勾选，每次击中音符时分数文本不会放大。",
			'scoreZoom',
			'bool');
		addOption(option);
	}

	function openComboAndRating() {
		var option:Option = new Option('Adjust Positions',
			'在这里自定义连击和判定文本的偏移位置！',
			null,
			'button');
		option.onChange = () -> {
			FlxG.switchState(() -> new options.NoteOffsetState());
		};
		addOption(option);

		var option:Option = new Option('Rating Color',
			'如果勾选，判定文本和连击会根据当前评级显示对应颜色。',
			'colorRating',
			'bool');
		addOption(option);

		var option:Option = new Option('Disable Combo Rating',
			'如果勾选，将不再显示连击评级。',
			'disableComboRating',
			'bool');
		addOption(option);

		var option:Option = new Option('Disable Combo Counter',
			'如果勾选，将不再显示连击计数器。',
			'disableComboCounter',
			'bool');
		addOption(option);

		var option:Option = new Option('Show Note Timing',
			'如果勾选，屏幕上会显示击中音符的时间（毫秒）。',
			'showNoteTiming',
			'bool');
		addOption(option);
	}

	function openUI() {
		var option:Option = new Option('Hide HUD',
			'如果勾选，隐藏大部分游戏界面元素。',
			'hideHud',
			'bool');
		addOption(option);

		var option:Option = new Option('Time Bar:',
			"设置时间条显示的内容。",
			'timeBarType',
			'string',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Health Bar Opacity',
			'设置生命值条和图标的透明度。',
			'healthBarAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Nameplate Fade Time',
			'玩家名称牌会在几秒后隐藏？\n设置为0立即隐藏，设置为-1永久显示。',
			'nameplateFadeTime',
			'int');
		option.displayFormat = '%vs';
		option.scrollSpeed = 20;
		option.minValue = -1;
		option.maxValue = 60;
		option.changeValue = 1;
		option.decimals = 0;
		addOption(option);

		var option:Option = new Option('Show Funkin Points Counter',
			'如果勾选，分数文本中会显示当前FP值，游戏内可按F7切换。',
			'showFP',
			'bool');
		addOption(option);

		var option:Option = new Option('FP V5 Preview',
			'如果启用，计数器会显示新版FP算法。',
			'newFPPreview',
			'bool');
		addOption(option);

		var option:Option = new Option('Disable Song Comments',
			'在回放查看器和游戏中禁用歌曲评论。',
			'disableSongComments',
			'bool');
		addOption(option);
		
		var option:Option = new Option('Song Comments Opacity',
			'设置游戏中歌曲评论的可见度。',
			'midSongCommentsOpacity',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		#if !mobile
		var option:Option = new Option('FPS Counter',
			'如果取消勾选，隐藏FPS计数器。',
			'showFPS',
			'bool');
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
	}

	public function new(category:String)
	{
		title = category;
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		NoteSkinData.reloadNoteSkins();

		isOpened = true;

		switch (category) {
			case 'Notes':
				openNotes();
			case 'Combo & Rating':
				openComboAndRating();
			case 'User Interface':
				openUI();
			case 'Accessibility':
				openAccessibility();
		}

		super();
		add(notes);
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		
		if(noteOptionID < 0) return;

		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = notes.members[i];
			if (note == null) continue;
			if(notesTween[i] != null) notesTween[i].cancel();
			if(curSelected == noteOptionID)
				notesTween[i] = FlxTween.tween(note, {y: noteY}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
			else
				notesTween[i] = FlxTween.tween(note, {y: -200}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
		}
	}

	function onChangeNoteSkin()
	{
		notes.forEachAlive(function(note:StrumNote) {
			changeNoteSkin(note);
			note.centerOffsets();
			note.centerOrigin();
		});
	}

	function changeNoteSkin(note:StrumNote)
	{
		var data:NoteSkinStructure = NoteSkinData.getCurrent();
		Mods.currentModDirectory = data.folder;

		var skin:String = Note.defaultNoteSkin;
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

		note.texture = skin; //Load texture and anims
		note.reloadNote();
		note.playAnim('static');
	}

	override function destroy()
	{
		isOpened = false;
		if (GameClient.isConnected()) {
			var data:NoteSkinStructure = NoteSkinData.getCurrent(-1);
			GameClient.send('updateNoteSkinData', [data.skin, data.folder, data.url]);
		}
		Mods.currentModDirectory = '';
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}
	#end
}
