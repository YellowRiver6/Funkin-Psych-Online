package online.mods;

import haxe.Exception;
import sys.FileSystem;
import online.mods.GameBanana;
import online.http.HTTPClient;
import sys.io.File;

class ModDownloader {
	public static var downloaders:Array<ModDownloader> = [];
	public static var failed:Array<String> = [];

	public var client:HTTPClient;
	public var alert:DownloadAlert;

	public var status(default, set):Null<DownloaderStatus>;
	function set_status(v) {
		if (onStatus != null)
			onStatus(v);
		return status = v;
	}
	public var onStatus:DownloaderStatus->Void;

	static var downloadDir(get, never):String;
	var downloadPath:String;
	var id:String;
	public var url:String;

	public function new(fileName:String, modURL:String, ?gbMod:GBMod, ?onSuccess:String->Void, ?headers:Map<String, String>, ?ogURL:String) {
		url = ogURL ?? modURL;
		id = FileUtils.formatFile(url);
		downloadPath = downloadDir + id + ".dwl";
		fileName = FileUtils.formatFile(fileName);

		for (down in downloaders) {
			if (down.id == id)
				return;
		}

		if (downloaders.length >= 6) {
			Waiter.putPersist(() -> {
				Alert.alert('下载失败！', '当前正在下载的文件过多！(最多 6 个)');
			});
			return;
		}

		if (!FunkinFileSystem.exists(downloadDir)) {
			FileSystem.createDirectory(downloadDir);
		}

		client = new HTTPClient(modURL);
		alert = new DownloadAlert(url);

		client.onStatus = v -> {
			switch (v) {
				case CONNECTING:
					status = CONNECTING;
				case READING_HEADERS:
					status = READING_HEADERS;
				case READING_BODY:
					status = READING_BODY;
					if (!isMediaTypeAllowed(client.response.headers.get("content-type"))) {
						client.cancel();
						Waiter.putPersist(() -> {
							Alert.alert('下载失败！', client.response.headers.get("content-type") + " 可能是无效或不支持的文件类型！");
							RequestSubstate.requestURL(url, "该模组需要从此来源手动安装", true);
						});
					}
				case COMPLETED:
					status = DOWNLOADED;
				case FAILED(exc):
					status = FAILED(exc);
					failed.push(modURL);
			}
		};

		downloaders.push(this);
		
		Thread.run(() -> {
			try {
				client.request({
					output: File.append(downloadPath, true),
					headers: headers
				});
			} 
			catch (exc) {
				if (!client.cancelRequested) {
					Waiter.putPersist(() -> {
						Alert.alert('错误！', id + ': ' + ShitUtil.prettyError(exc));
					});
				}
			}

			client.close();

			if (client.response?.isFailed()) {
				if (client.cancelRequested) {
					Waiter.putPersist(() -> {
						Alert.alert('下载已取消！');
					});
				}
				else {
					Waiter.putPersist(() -> {
						Alert.alert('下载失败！', 
							ShitUtil.prettyStatus(client.response.status) + "\n" +
							(client?.response?.exception != null ? ShitUtil.prettyError(client.response.exception) : '')
						);
					});
				}
			}
			else {
				status = INSTALLING;
				OnlineMods.installMod(downloadPath, url, gbMod, onSuccess);
				status = FINISHED;
			}

			delete();
		});
    }

	function delete() {
		downloaders.remove(this);
		if (alert != null)
			alert.destroy();
		alert = null;
		deleteTempFile();
	}

	function deleteTempFile() {
		try {
			if (FunkinFileSystem.exists(downloadPath)) {
				FileSystem.deleteFile(downloadPath);
			}
		} catch (_) {}
	}

	static function get_downloadDir():String
	{
		return haxe.io.Path.addTrailingSlash(haxe.io.Path.join([Sys.getCwd(), "downloads"]));
	}

    static var allowedMediaTypes:Array<String> = [
		"application/zip",
		"application/zip-compressed",
		"application/x-zip-compressed",
		"application/x-zip",
		"application/x-tar",
		"application/gzip",
		"application/x-gtar",
		"application/octet-stream",
		#if RAR_SUPPORTED
		"application/vnd.rar",
		"application/x-rar-compressed",
		"application/x-rar",
		#end
	];

	public static function isMediaTypeAllowed(file:String) {
		file = file.trim();
		for (item in allowedMediaTypes) {
			if (file == item)
				return true;
		}
		return false;
	}

	public static function cancelAll() {
		Sys.println("正在取消 " + downloaders.length + " 个下载...");
		for (downloader in downloaders) {
			if (downloader != null)
				downloader.client.cancel();
		}
	}

	public static function checkDeleteDlDir() {
		#if !mobile
		if (FileSystem.exists(downloadDir)) {
			FileUtils.removeFiles(downloadDir);
		}
		#end
	}
}

enum DownloaderStatus {
	CONNECTING;     // 正在连接
	READING_HEADERS;// 读取头部
	READING_BODY;   // 读取内容
	FAILED(exc:Exception); // 下载失败
	DOWNLOADED;     // 下载完成
	INSTALLING;     // 正在安装
	FINISHED;       // 全部完成
}
