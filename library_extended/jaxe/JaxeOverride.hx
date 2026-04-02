package jaxe;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class JaxeOverride {
	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var newFields:Array<Field> = [];

		for (field in fields) {
			switch (field.kind) {
				case FFun(f):
					var name = field.name;

					if (field.access.indexOf(AOverride) != -1) {
						var superName = "super_" + name;
						var scriptedName = "scripted_" + name;
						var args = f.args;
						var callArgs = [for (arg in args) macro $i{arg.name}];

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

						newFields.push({
							name: superName,
							access: [APublic],
							kind: FFun({
								args: args,
								ret: f.ret,
								expr: macro super.$name($a{callArgs})
							}),
							pos: field.pos
						});

						newFields.push({
							name: scriptedName,
							access: [APublic, ADynamic],
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
					else if (field.access.indexOf(AStatic) == -1 && name != "new") {
						if (field.access.indexOf(ADynamic) == -1) field.access.push(ADynamic);
						if (field.access.indexOf(APublic) == -1) field.access.push(APublic);
					}
				default:
			}
		}
		return fields.concat(newFields);
	}
}
