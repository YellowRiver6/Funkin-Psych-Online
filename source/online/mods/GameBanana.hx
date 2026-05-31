package online.mods;

import haxe.Exception;
import online.substates.RequestSubstate;
import haxe.Http;
import haxe.Json;

class GameBanana {
	public static function searchMods(?search:String, page:Int, ?sortOrder:String = "default", response:(mods:Array<GBSub>, err:Dynamic) -> Void) {
		Thread.run(() -> {
			var http = new Http("https://psychcn.online/api/mods?page=" + page + (search != null ? "&keyword=" + Http.urlEncode(search) : ""));

			http.onData = function(data:String) {
				Waiter.put(() -> {
					var json:Dynamic;
					try {
						json = Json.parse(data);
					}
					catch (exc) {
						response(null, exc);
						return;
					}

					var list:Array<GBSub> = [];
					for (m in json.data) {
						var sub:GBSub = {
							_idRow: m.id,
							_sModelName: "Mod",
							_sName: m.name,
							_sProfileUrl: m.download,
							_aPreviewMedia: {
								_aImages: [{
									_sBaseUrl: "",
									_sFile: "",
									_sFile220: "",
									_wFile220: 220,
									_hFile220: 125,
									_sFile100: ""
								}]
							},
							_aRootCategory: {
								_sName: "本站Mod",
								_sIconUrl: ""
							},
							_sVersion: "1.0",
							_aGame: { _idRow: 8694 },
							_nLikeCount: 0
						};
						list.push(sub);
					}
					response(list, null);
				});
			};

			http.onError = function(error) {
				Waiter.put(() -> {
					response(null, error);
				});
			};

			http.request();
		});
	}

	public static function listCategory(id:String, page:Int, response:(mods:Array<GBSub>, err:Dynamic) -> Void) {
		searchMods(null, page, "", response);
	}

	public static function listCollection(id:String, page:Int, response:(mods:Array<GBSub>, err:Dynamic) -> Void) {
		searchMods(null, page, "", response);
	}

	public static function getMod(id:String, response:(mod:GBMod, err:Dynamic)->Void, ?threaded:Bool = true) {
		var fake:GBMod = {
			_id: id,
			name: "Mod",
			description: "",
			downloads: {},
			pageDownload: "",
			game: "FNF",
			trashed: false,
			withheld: false,
			rootCategory: "Mod",
			downloadCount: 0,
			likes: 0,
			screenshots: []
		};
		response(fake, null);
	}

	public static function getModDownloads(modID:Float, response:(downloads:DownloadPage, err:Dynamic) -> Void) {
		var fake:DownloadPage = {
			_bIsTrashed: false,
			_bIsWithheld: false,
			_aFiles: [],
			_aAlternateFileSources: []
		};
		response(fake, null);
	}

	public static function downloadMod(mod:GBMod, ?onSuccess:String->Void) {
		Alert.alert("提示", "请点击卡片直接下载！");
	}
}

typedef GBMod = {
	var _id:String;
	var name:String;
	var description:String;
	var downloads:Dynamic;
	var pageDownload:String;
	var game:String;
	var trashed:Bool;
	var withheld:Bool;
	var rootCategory:String;
	var downloadCount:Float;
	var likes:Float;
	var screenshots:Array<GBImage>;
}

typedef GBSub = {
	var _idRow:Float;
	var _sModelName:String;
	var _sName:String;
	var _sProfileUrl:String;
	var _aPreviewMedia:GBPrevMedia;
	var _aRootCategory:GBCategory;
	var _sVersion:String;
	var _aGame:GBGame;
	var _nLikeCount:Null<Float>;
}

typedef GBGame = {
	var _idRow:Float;
}

typedef GBPrevMedia = {
	var _aImages:Array<GBImage>;
}

typedef GBImage = {
	var _sBaseUrl:String;
	var _sFile:String;
	var _sFile220:String;
	var _wFile220:Int;
	var _hFile220:Int;
	var _sFile100:String;
}

typedef GBCategory = {
	var _sName:String;
	var _sIconUrl:String;
}

typedef DownloadProp = {
	var _sFile:String;
	var _nFilesize:Float;
	var _sDescription:String;
	var _sAnalysisState:String;
	var _sDownloadUrl:String;
	var _bContainsExe:Bool;
}

typedef AltDownload = {
	var url:String;
	var description:String;
}

typedef DownloadPage = {
	var _bIsTrashed:Bool;
	var _bIsWithheld:Bool;
	var _aFiles:Array<DownloadProp>;
	var _aAlternateFileSources:Array<AltDownload>;
}
