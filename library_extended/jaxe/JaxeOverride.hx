package jaxe;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.ComplexTypeTools;
import jaxe.JaxeConfig;

class JaxeOverride {
	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var localClass = Context.getLocalClass().get();
		var fullClassName = localClass.pack.join(".") + "." + localClass.name;

		for (ignored in JaxeConfig.DISALLOW_OVERRIDE_CLASSES) {
			if (fullClassName == ignored || localClass.name == ignored) return fields;
		}

		var newFields:Array<Field> = [];

		function parentHasJaxeField(fieldName:String):Bool {
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
			if (field.name.indexOf("__") == 0 || field.name == "hget" || field.name == "hset") continue;

			switch (field.kind) {
				case FFun(f):
					var name = field.name;
					var isStatic = field.access.indexOf(AStatic) != -1;
					var isInline = field.access.indexOf(AInline) != -1;
					var isPrivate = field.access.indexOf(APrivate) != -1;
					var isOverride = field.access.indexOf(AOverride) != -1;

					if (!isStatic && !isInline && !isPrivate && name != "new") {
						var superName = "super_" + name;
						var scriptedName = "scripted_" + name;

						var hasParentSuper = parentHasJaxeField(superName);
						var hasParentScripted = parentHasJaxeField(scriptedName);

						var args = f.args;
						var callArgs = [for (arg in args) macro $i{arg.name}];

						var defaultReturn = macro {};
						if (f.ret != null) {
							var retStr = ComplexTypeTools.toString(f.ret);
							if (retStr != "Void") defaultReturn = macro return cast null;
						}

						function patchBody(e:Expr):Expr {
							if (e == null) return null;
							switch (e.expr) {
								case ECall(eField, params):
									var eStr = ExprTools.toString(eField);
									if (eStr == "super." + name) {
										var patchedParams = [for (p in params) patchBody(p)];
										return if (hasParentSuper) {
											macro super.$superName($a{patchedParams});
										} else {
											macro super.$name($a{patchedParams});
										}
									}
								default:
							}
							return ExprTools.map(e, patchBody);
						}

						var originalCode = (f.expr != null) ? patchBody(f.expr) : defaultReturn;

						var superAccess:Array<Access> = [APublic];
						if (hasParentSuper) superAccess.push(AOverride);

						newFields.push({
							name: superName,
							access: superAccess,
							kind: FFun({
								args: args,
								ret: f.ret,
								expr: originalCode
							}),
							pos: field.pos
						});

						var scriptedAccess:Array<Access> = [APublic, ADynamic];
						if (hasParentScripted) scriptedAccess.push(AOverride);

						newFields.push({
							name: scriptedName,
							access: scriptedAccess,
							kind: FFun({
								args: args,
								ret: f.ret,
								expr: macro return $i{superName}($a{callArgs})
							}),
							pos: field.pos
						});

						f.expr = macro {
							return $i{scriptedName}($a{callArgs});
						};
					}
				default:
			}
		}
		return fields.concat(newFields);
	}
}
