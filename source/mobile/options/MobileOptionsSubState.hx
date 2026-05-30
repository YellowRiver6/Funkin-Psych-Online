package mobile.options;

import flixel.input.keyboard.FlxKey;
import options.BaseOptionsMenu;
import options.Option;

class MobileOptionsSubState extends BaseOptionsMenu {
	#if android
	var storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL_OBB", "EXTERNAL_MEDIA", "EXTERNAL"];
	var externalPaths:Array<String> = StorageUtil.checkExternalPaths(true);
	var customPaths:Array<String> = StorageUtil.getCustomStorageDirectories(false);
	final lastStorageType:String = ClientPrefs.data.storageType;
	#end

	var option:Option;
	var HitboxTypes:Array<String>;
	public function new() {
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu'; // for Discord Rich Presence, fuck it
		#if android
		storageTypes = storageTypes.concat(customPaths); //Get Custom Paths From File
		storageTypes = storageTypes.concat(externalPaths); //Get SD Card Path
		#end

		HitboxTypes = Mods.mergeAllTextsNamed('mobile/Hitbox/HitboxModes/hitboxModeList.txt');

		option = new Option('MobilePad Opacity',
			'设置移动端按钮的不透明度（注意不要将数值设为 0，否则会完全看不到按钮）', 'mobilePadAlpha', 'percent');
		option.scrollSpeed = 1;
		option.minValue = 0.001;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = () -> {
			mobileManager.mobilePad.alpha = curOption.getValue();
			ClientPrefs.toggleVolumeKeys();
		};
		addOption(option);

		var option:Option = new Option('Extra Controls',
			'允许显示附加按钮（躲避）数量',
			'extraKeys',
			'int');
		option.scrollSpeed = 1;
		option.minValue = 0;
		option.maxValue = 4;
		option.changeValue = 1;
		option.decimals = 0;
		addOption(option);

		option = new Option('Extra Control Location',
			'选择附加按钮（躲避）位置',
			'hitboxLocation',
			'string',
			['Bottom', 'Top', 'Middle']
		);
		addOption(option);
		
		//HitboxTypes.insert(0, "Classic");
		option = new Option('Hitbox Mode',
			'选择你的碰撞框样式！',
			'hitboxMode',
			'string',
			HitboxTypes
		);
		addOption(option);
		
		option = new Option('Hitbox Design',
			'自定义点击按键区域的外观样式',
			'hitboxType',
			'string',
			['Gradient', 'No Gradient' , 'No Gradient (Old)']
		);
		addOption(option);

		option = new Option('Hitbox Hint',
			'Hitbox Hint',
			'点击按钮区域提示',
			'bool');
		addOption(option);

		option = new Option('V Slice Controls',
			'勾选此选项后，游戏操控逻辑将还原原版《周五夜放克》手机版的操作模式\n(警告：该选项可能会导致部分游戏机制失效，仅建议简易模组使用)',
			'ogGameControls',
			'bool');
		addOption(option);

		option = new Option('Hitbox Opacity',
			'调节点击按钮区域的不透明度',
			'hitboxAlpha',
			'percent'
		);
		option.scrollSpeed = 1;
		option.minValue = 0.001;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		#if mobile
		option = new Option('Wide Screen Mode',
			'勾选后，游戏画面将拉伸铺满整个屏幕\n(警告：该功能会造成画面显示效果变差，还可能使部分调整游戏画面、镜头尺寸的模组出现故障)',
			'wideScreen', 'bool');
		option.onChange = () -> ScreenUtil.wideScreen.enabled = ClientPrefs.data.wideScreen;
		addOption(option);
		#end

		#if android
		option = new Option('Storage Type',
			'选择 Psych Online 所保存数据的文件夹',
			'storageType',
			'string',
			storageTypes
		);
		addOption(option);
		#end
		super();
	}

	override public function destroy() {
		super.destroy();

		#if android
		if (ClientPrefs.data.storageType != lastStorageType) {
			File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.data.storageType);
			ClientPrefs.saveSettings();
			StorageUtil.initExternalStorageDirectory();
		}
		#end
	}
}
