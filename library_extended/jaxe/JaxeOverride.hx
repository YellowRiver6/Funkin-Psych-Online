package jaxe;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class JaxeOverride {
	//ignore classes for preventing issues.
	public static var ignoredClasses:Array<String> = [
		"options.BaseOptionsMenu",
		"states.PlayState",
		"states.FreeplayState"
	];

	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var localClass = Context.getLocalClass().get();
		var fullClassName = localClass.pack.join(".") + "." + localClass.name;

		for (ignored in ignoredClasses) {
			if (fullClassName == ignored || localClass.name == ignored) {
				return fields;
			}
		}
		var newFields:Array<Field> = [];

		// Check if any parent function in the class.
		function hasFieldInParents(fieldName:String):Bool {
			var cl = localClass.superClass;
			while (cl != null) {
				var t = cl.t.get();
				for (f in t.fields.get()) {
					if (f.name == fieldName) return true;
				}
				cl = t.superClass;
			}
			return false;
		}

		for (field in fields) {
			if (field.name.indexOf("__") == 0 || field.name == "hget" || field.name == "hset") continue; // Skip certain fields to get HScript Improved and Jaxe at the same time.

			switch (field.kind) {
				case FFun(f):
					var name = field.name;
					//makes if() much easier.
					var isInline = field.access.indexOf(AInline) != -1;
					var isStatic = field.access.indexOf(AStatic) != -1;
					var isPrivate = field.access.indexOf(APrivate) != -1;
					var isOverride = field.access.indexOf(AOverride) != -1;
					var isDynamic = field.access.indexOf(ADynamic) != -1;

					if (isOverride && !isInline && !isPrivate) {
						var superName = "super_" + name;
						var scriptedName = "scripted_" + name;
						var args = f.args;
						var callArgs = [for (arg in args) macro $i{arg.name}];

						var superAccess:Array<Access> = [APublic];
						if (hasFieldInParents(superName)) superAccess.push(AOverride);

						var scriptedAccess:Array<Access> = [APublic, ADynamic];
						if (hasFieldInParents(scriptedName)) scriptedAccess.push(AOverride);

						function patchSuperCalls(e:Expr):Expr {
							if (e == null) return null;

							var eStr = ExprTools.toString(e);

							if (eStr.indexOf("super.") == 0) {
								switch (e.expr) {
									case ECall(eField, params):
										var fieldStr = ExprTools.toString(eField);
										if (fieldStr.indexOf("super.") == 0) {
											var parts = fieldStr.split(".");
											var calledFunc = parts[1];
											var newSuperCall = "super_" + calledFunc;

											return {
												expr: ECall(macro $i{newSuperCall}, [for (p in params) patchSuperCalls(p)]),
												pos: e.pos
											};
										}
									default:
								}
							}
							return ExprTools.map(e, patchSuperCalls);
						}

						var patchedBody = (f.expr != null) ? patchSuperCalls(f.expr) : macro {};
						var parentHasSuperAnchor = hasFieldInParents(superName);

						newFields.push({
							name: superName,
							access: superAccess,
							kind: FFun({
								args: args,
								ret: f.ret,
								expr: if (parentHasSuperAnchor) {
									macro $i{superName}($a{callArgs});
								} else {
									macro super.$name($a{callArgs});
								}
							}),
							pos: field.pos
						});

						newFields.push({
							name: scriptedName,
							access: scriptedAccess,
							kind: FFun({
								args: args,
								ret: f.ret,
								expr: patchedBody
							}),
							pos: field.pos
						});

						f.expr = macro {
							$i{scriptedName}($a{callArgs});
						};
					}
					else if (!isStatic && !isInline && name != "new") {
						if (!isDynamic) field.access.push(ADynamic);
						//if (field.access.indexOf(APublic) == -1) field.access.push(APublic);
					}
				default:
			}
		}
		return fields.concat(newFields);
	}
}
