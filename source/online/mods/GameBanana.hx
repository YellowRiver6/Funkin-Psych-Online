package online.mods;

import haxe.Exception;
import online.substates.RequestSubstate;
import haxe.Http;
import haxe.Json;

class GameBanana {
	// 搜索模组 对接自建API
	public static function searchMods(?search:String, page:Int, ?sortOrder:String = "default", response:(mods:Array<GBSub>, err:Dynamic) -> Void) {
		Thread.run(() -> {
			var baseUrl = "https://psychcn.online/api/mods";
			var queryList = ["page=" + page];
			if (search != null && search != "") {
				queryList.push("keyword=" + Http.urlEncode(search));
			}
			if (sortOrder != null && sortOrder != "default") {
				queryList.push("sort=" + Http.urlEncode(sortOrder));
			}
			var fullUrl = baseUrl + "?" + queryList.join("&");

			var http = new Http(fullUrl);
			http.onData = function(rawText:String) {
				Waiter.put(() -> {
					try {
						var jsonRoot = Json.parse(rawText);
						if (jsonRoot.error != null) {
							response(null, jsonRoot.error);
							return;
						}
						var rawModArray = jsonRoot.data;
						var outputGBSub:Array<GBSub> = [];
						for (var rawItem in rawModArray) {
							var fakeItem:GBSub = {
								_idRow: rawItem.id,
								_sModelName: "Mod",
								_sName: rawItem.name,
								_sProfileUrl: rawItem.download,
								_aPreviewMedia: {
									_aImages: [
										{
											_sBaseUrl: "",
											_sFile: "",
											_sFile220: "",
											_wFile220: 220,
											_hFile220: 125,
											_sFile100: ""
										}
									]
								},
								_aRootCategory: {
									_sName: "本站Mod",
									_sIconUrl: ""
								},
								_sVersion: "1.0",
								_aGame: { _idRow: 8694 },
								_nLikeCount: 0
							};
							outputGBSub.push(fakeItem);
						}
						response(outputGBSub, null);
					} catch (parseErr) {
						response(null, "JSON解析异常：" + Std.string(parseErr));
					}
				});
			};
			http.onError = function(errMsg) {
				Waiter.put(() -> {
					response(null, "网络请求失败：" + errMsg);
				});
			};
			http.request();
		});
	}

	// 分类列表 兼容调用，复用搜索接口
	public static function listCategory(id:String, page:Int, response:(mods:Array<GBSub>, err:Dynamic) -> Void) {
		searchMods(null, page, null, response);
	}

	// 合集列表 兼容调用，复用搜索接口
	public static function listCollection(id:String, page:Int, response:(mods:Array<GBSub>, err:Dynamic) -> Void) {
		searchMods(null, page, null, response);
	}

	// 假详情接口，不请求网络，返回空数据
	public static function getMod(id:String, response:(mod:GBMod, err:Dynamic)->Void, ?threaded:Bool = true) {
		var fakeMod:GBMod = {
			_id: id,
			name: "",
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
		response(fakeMod, null);
	}

	// 假下载页面接口，直接返回空
	public static function getModDownloads(modID:Float, response:(downloads:DownloadPage, err:Dynamic) -> Void) {
		var emptyPage:DownloadPage = {
			_bIsTrashed: false,
			_bIsWithheld: false,
			_aFiles: [],
			_aAlternateFileSources: []
		};
		response(emptyPage, null);
	}

	// 拦截旧下载函数，弹窗提示点击卡片直接下载
	public static function downloadMod(mod:GBMod, ?onSuccess:String->Void) {
		Alert.alert("提示", "请返回模组列表，点击模组卡片下载按钮进行下载！");
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
