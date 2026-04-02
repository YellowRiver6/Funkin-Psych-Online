package funkin.backend.scripting;

#if sys
import sys.io.File;
import sys.FileSystem;
#end
import haxe.io.Path;
import jaxe.JaxeScript;

using StringTools;

/**
 * A lightweight, simple wrapper for loading and running individual Jaxe scripts.
 */
class JScript {
	public var backend:JaxeScript;
	public var active:Bool = true;
	public var scriptPath:String;
	public var fileName:String;

	public function new(path:String, ?parentObj:Dynamic) {
		this.scriptPath = path;
		this.fileName = Path.withoutDirectory(path);

		#if sys
		if (FunkinFileSystem.exists(path)) {
			var code = FunkinFileSystem.getText(path);
			backend = new JaxeScript(code);
			backend.scriptName = fileName;

			if (parentObj != null) {
				backend.setParent(parentObj);
			}

			for (k => v in getDefaultVariables()) {
				backend.set(k, v);
			}

			backend.run();
		} else {
			trace('Jaxe Error: Script not found at normal path -> $path');
		}
		#else
		trace("Jaxe Error: File system access requires a sys target (Windows/Mac/Linux/Android).");
		#end
	}

	/**
	 * Calls a specific function inside the script.
	 */
	public function call(funcName:String, args:Array<Dynamic> = null):Dynamic {
		if (!active || backend == null) return null;
		return backend.call(funcName, args != null ? args : []);
	}

	/**
	 * Injects a custom variable or object into this script.
	 */
	public function set(varName:String, value:Dynamic):Void {
		if (backend != null) {
			backend.set(varName, value);
		}
	}

	/**
	 * A much cleaner, simpler list of essential default FNF classes.
	 */
	public static function getDefaultVariables():Map<String, Dynamic> {
		return [
			"Mods"		  => backend.Mods,
			"AttachedSprite"		  => objects.AttachedSprite,
			"ClientPrefs"		  => backend.ClientPrefs,
			"FunkinFileSystem"		  => backend.FunkinFileSystem,
			"Converters"		  => backend.Converters,

			/* Sys related stuff */
			"File"		  => File,
			"Process"		  => sys.io.Process,
			"FileSystem"		  => FileSystem,
			"Thread"		  => CoolUtil.getMacroAbstractClass("sys.thread.Thread"),
			"Mutex"		  => CoolUtil.getMacroAbstractClass("sys.thread.Mutex"),

			/* Haxe related stuff */
			"Std"			   => Std,
			"Math"			  => Math,
			"Type"			  => Type,
			"Date"			  => Date,
			"Array"			  => Array,
			"Reflect"			  => Reflect,
			"StringTools"	   => StringTools,
			"Json"			  => haxe.Json,
			"Access"			  => CoolUtil.getMacroAbstractClass("haxe.xml.Access"),

			/* OpenFL & Lime related stuff */
			"Assets"			=> openfl.utils.Assets,
			"TextField"		  => openfl.text.TextField,
			"Application"	   => lime.app.Application,
			"Main"				=> Main,
			"window"			=> lime.app.Application.current.window,

			/* Flixel related stuff */
			"FlxG"			  => flixel.FlxG,
			"FlxSprite"		 => flixel.FlxSprite,
			"FlxBasic"		  => flixel.FlxBasic,
			"FlxCamera"		 => flixel.FlxCamera,
			"state"			 => flixel.FlxG.state,
			"FlxEase"		   => flixel.tweens.FlxEase,
			"FlxTween"		  => flixel.tweens.FlxTween,
			"FlxSound"		  => flixel.sound.FlxSound,
			"FlxAssets"		 => flixel.system.FlxAssets,
			"FlxMath"		   => flixel.math.FlxMath,
			"FlxGroup"		  => flixel.group.FlxGroup,
			"FlxTypedGroup"	 => flixel.group.FlxGroup.FlxTypedGroup,
			"FlxSpriteGroup"	=> flixel.group.FlxSpriteGroup,
			"FlxTypeText"	   => flixel.addons.text.FlxTypeText,
			"FlxText"		   => flixel.text.FlxText,
			"FlxTimer"		  => flixel.util.FlxTimer,
			"FlxFlicker"		  => flixel.effects.FlxFlicker,
			"FlxBackdrop"		  => flixel.addons.display.FlxBackdrop,
			"FlxOgmo3Loader"		  => flixel.addons.editors.ogmo.FlxOgmo3Loader,
			"FlxTilemap"		  => flixel.tile.FlxTilemap,
			"FlxTextBorderStyle"		  => flixel.text.FlxTextBorderStyle,
			"FlxTextAlign"	  => CoolUtil.getMacroAbstractClass("flixel.text.FlxText.FlxTextAlign"),
			"FlxPoint"		  => CoolUtil.getMacroAbstractClass("flixel.math.FlxPoint"),
			"FlxAxes"		   => CoolUtil.getMacroAbstractClass("flixel.util.FlxAxes"),
			"FlxColor"		  => CoolUtil.getMacroAbstractClass("flixel.util.FlxColor"),
			"BlendMode"		  => CoolUtil.getMacroAbstractClass("openfl.display.BlendMode"),

			/* Objects */
			"FlxAnimate"		=> flxanimate.FlxAnimate, //PsychFlxAnimate is removed for CNE compatibility
			"HealthIcon"		=> objects.HealthIcon,
			"Note"				=> objects.Note,
			"Character"		=> objects.Character,
			"Boyfriend"			=> objects.Character, // for compatibility

			/* Backend */
			"Alphabet"			=> objects.Alphabet,
			"Paths"			=> backend.Paths,
			"Conductor"		=> backend.Conductor,
			"CoolUtil"			=> backend.CoolUtil,

			/* Codename Engine related stuff */
			"FunkinShader"	=> funkin.backend.shaders.FunkinShader,
			"CustomShader"	=> funkin.backend.shaders.CustomShader,
			"FunkinText"		=> funkin.backend.FunkinText,
			"FunkinSprite"		=> funkin.backend.FunkinSprite,

			/* States */
			"PlayState"		 => states.PlayState,
			"FreeplayState"	 => states.FreeplayState,
			"MainMenuState"	 => states.MainMenuState,
			"PauseSubState"	 => substates.PauseSubState,
			"StoryMenuState"	 => states.StoryMenuState,
			"TitleState"		 => states.TitleState,
			"OptionsState"		 => options.OptionsState,
			"LoadingState"		 => states.LoadingState,
			"MusicBeatState"	 => backend.MusicBeatState,

			/* Substates */
			"GameOverSubstate"  => substates.GameOverSubstate,
			"MusicBeatSubstate"  => backend.MusicBeatSubstate,
			"PauseSubstate"	 => substates.PauseSubState,

			/* Custom Menus */
			#if SCRIPTING_ALLOWED
			"ModState"		  => funkin.backend.scripting.ModState,
			"ModSubState"		  => funkin.backend.scripting.ModSubState,
			#end

			/* hxVLC */
			"FlxVideo"		  => hxvlc.flixel.FlxVideo,
			"FlxVideoSprite"		  => hxvlc.flixel.FlxVideoSprite,

			/* hxCodec 2.6.0 things */
			/*
			"VideoHandler"		  => VideoHandler,
			"VideoSprite"		  => VideoSprite,
			*/

			/* hxCodec 2.5.1 */
			"MP4Handler"		  => vlc.MP4Handler,
			//"MP4Sprite"		  => vlc.MP4Sprite,
			
			//Online Stuffs
			"GameClient"	=> online.GameClient,
		];
	}
}


/**
 * Manages multiple Jaxe scripts and broadcasts function calls to all of them.
 */
class JScriptManager {
	public var scripts:Array<JScript> = [];

	public function new() {}

	/**
	 * Loads a single script by its normal file path.
	 */
	public function loadScript(path:String, ?parentObj:Dynamic):JScript {
		var script = new JScript(path, parentObj);

		scripts.push(script);
		return script;
	}

	/**
	 * Loads all .java and .jaxe files inside a normal directory path.
	 */
	public function loadFolder(folderPath:String, ?parentObj:Dynamic):Void {
		#if sys
		if (FunkinFileSystem.exists(folderPath) && FileSystem.isDirectory(folderPath)) {
			for (file in FileSystem.readDirectory(folderPath)) {
				if (file.endsWith(".java") || file.endsWith(".jaxe")) {
					loadScript(folderPath + "/" + file, parentObj);
				}
			}
		} else {
			trace('JaxeManager: Folder not found -> $folderPath');
		}
		#end
	}

	/**
	 * Broadcasts a function call to EVERY active script.
	 * Example: callAll("update", [elapsed]);
	 */
	public function callAll(funcName:String, args:Array<Dynamic> = null):Void {
		for (script in scripts) {
			//if (script.active) {
				script.call(funcName, args);
			//}
		}
	}

	/**
	 * Sets a variable in EVERY active script.
	 * Example: setAll("boyfriend", PlayState.instance.boyfriend);
	 */
	public function setAll(varName:String, value:Dynamic):Void {
		for (script in scripts) {
			script.set(varName, value);
		}
	}

	/**
	 * Clears all scripts from memory.
	 */
	public function destroy():Void {
		scripts = [];
	}
}
