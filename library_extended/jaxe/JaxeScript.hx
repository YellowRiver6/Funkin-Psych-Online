package jaxe;

import haxe.CallStack;

class JaxeScript {
	public var interp:JaxeInterp;
	public var parser:JaxeParser;
	public var scriptName:String;

	var sourceCode:String;
	var ast:Array<JaxeExpr>;

	private static inline var COLOR_RED = "\x1b[31m";
	private static inline var COLOR_YELLOW = "\x1b[33m";
	private static inline var COLOR_RESET = "\x1b[0m";

	public function new(sourceCode:String, scriptName:String = "Script.java") {
		this.sourceCode = sourceCode;
		this.scriptName = scriptName;
		
		this.interp = new JaxeInterp();
		this.parser = new JaxeParser();
		this.interp.scriptName = this.scriptName;
	}

	public function call(functionName:String, args:Array<Dynamic> = null):Dynamic {
		if (args == null) args = [];
		return interp.call(functionName, args);
	}

	public function set(name:String, value:Dynamic):Void {
		interp.variables.set(name, value);
	}

	public function setParent(parent:Dynamic) {
		if (Std.isOfType(parent, JaxeScript)) {
			handleError("Runtime Error: A JaxeScript instance cannot be set as a parent.", 0, 0, null, scriptName);
			return;
		}
		interp.scriptObject = parent;
	}

	/**
	 * Runs the script. If the script contains a class matching the filename, 
	 * it creates an instance of it and returns the native Haxe object.
	 */
	public function run():Dynamic {
		try {
			ast = parser.parseString(sourceCode, scriptName);
			interp.execute(ast);

			var targetClassName = scriptName;
			if (targetClassName.indexOf(".") != -1) {
				targetClassName = targetClassName.split(".")[0];
			}

			if (interp.scriptClasses.exists(targetClassName)) {
				// Instantiate the class and return the native object
				var mainInstance = interp.expr(ENew(targetClassName, [], []));
				interp.extendedObject = mainInstance; 
				return mainInstance; 
			} else {
				if (interp.locals.exists(targetClassName)) interp.call(targetClassName, []);
				else if (interp.locals.exists("new")) interp.call("new", []);
				else if (interp.locals.exists("main")) interp.call("main", []);
				return this;
			}
		} catch (e:Dynamic) {
			handleError(Std.string(e), parser.lastLine, parser.lastCol, e, scriptName);
			return null;
		}
	}

	#if sys
	/**
	 * Reads a file, parses the script, instantiates its main class, and returns it.
	 * Allows seamless switching to scripted classes directly from Haxe.
	 */
	public static function loadClass(filePath:String):Dynamic {
		if (!sys.FileSystem.exists(filePath)) {
			handleError('Script file not found: $filePath', 0, 0, null, filePath);
			return null;
		}
		
		var content = sys.io.File.getContent(filePath);
		var fileName = filePath;
		
		// Extract just the filename (e.g. "MyGameMenu.java" from "assets/scripts/MyGameMenu.java")
		if (fileName.indexOf("/") != -1) fileName = fileName.split("/").pop();
		if (fileName.indexOf("\\") != -1) fileName = fileName.split("\\").pop();
		
		var script = new JaxeScript(content, fileName);
		return script.run();
	}
	#end

	public static function handleError(msg:String, line:Int = 0, col:Int = 0, e:Dynamic = null, scriptName:String = "Unknown", isWarning:Bool = false) {
		var color = isWarning ? COLOR_YELLOW : COLOR_RED;
		var prefix = isWarning ? "[Jaxe Warning]" : "[Jaxe Error]";
		var output = '$color$prefix $scriptName:$line:$col - $msg$COLOR_RESET';
		
		#if sys
		Sys.println(output);
		#else
		trace(output);
		#end
	}
}
