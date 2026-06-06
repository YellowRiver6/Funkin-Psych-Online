package externs;

// class from another fnf mod that i made, bringing this here because my eyes burn
// anyway some code from
// https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/apply-windows-themes

#if (windows && cpp)
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows" />
	<lib name="user32.lib" if="windows" />
</target>
')

@:cppFileCode('
#include "dwmapi.h"
#include "winuser.h"
#include <windows.h>
#include <tchar.h>
#include <stdlib.h>
#include <string.h>

#define WM_SETICON 0x0080

HICON hWindowIcon = NULL;
HICON hWindowIconBig = NULL;

// 对话框过程
static INT_PTR CALLBACK PromptDlgProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
	switch (msg) {
		case WM_INITDIALOG: {
			// 设置默认文本
			if (lParam) {
				SetDlgItemTextW(hwnd, 1001, (LPCWSTR)lParam);
				SetFocus(GetDlgItem(hwnd, 1001));
				SendMessage(GetDlgItem(hwnd, 1001), EM_SETSEL, 0, -1);
			}
			return TRUE;
		}
		case WM_COMMAND: {
			if (LOWORD(wParam) == IDOK) {
				wchar_t buf[512];
				GetDlgItemTextW(hwnd, 1001, buf, 512);
				// 保存文本到用户数据
				SetWindowLongPtr(hwnd, DWLP_USER, (LONG_PTR)_wcsdup(buf));
				EndDialog(hwnd, IDOK);
				return TRUE;
			} else if (LOWORD(wParam) == IDCANCEL) {
				EndDialog(hwnd, IDCANCEL);
				return TRUE;
			}
			break;
		}
		case WM_CLOSE: {
			EndDialog(hwnd, IDCANCEL);
			return TRUE;
		}
	}
	return FALSE;
}

// 显示输入框的函数
static const char* PromptBox(const char* title, const char* defaultText) {
	// 将标题和默认文本转换为宽字符
	wchar_t wTitle[256];
	wchar_t wDefaultText[512];
	
	// 转换标题
	int len = MultiByteToWideChar(CP_UTF8, 0, title, -1, wTitle, 256);
	if (len == 0) {
		wcscpy_s(wTitle, L"输入");
	}
	
	// 转换默认文本
	len = MultiByteToWideChar(CP_UTF8, 0, defaultText, -1, wDefaultText, 512);
	if (len == 0) {
		wDefaultText[0] = L"";
	}

	// 创建对话框模板
	DLGTEMPLATE* dlgTemplate = (DLGTEMPLATE*)malloc(sizeof(DLGTEMPLATE) + sizeof(DLGITEMTEMPLATE) * 3 + 512);
	if (!dlgTemplate) return NULL;
	
	memset(dlgTemplate, 0, sizeof(DLGTEMPLATE));
	dlgTemplate->style = DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_CENTER;
	dlgTemplate->cdit = 3; // 3个控件
	dlgTemplate->x = 0;
	dlgTemplate->y = 0;
	dlgTemplate->cx = 350;
	dlgTemplate->cy = 140;

	BYTE* p = (BYTE*)dlgTemplate + sizeof(DLGTEMPLATE);

	// 对话框标题
	memcpy(p, wTitle, wcslen(wTitle) * sizeof(wchar_t) + sizeof(wchar_t));
	p += wcslen(wTitle) * sizeof(wchar_t) + sizeof(wchar_t);

	// 编辑框
	DLGITEMTEMPLATE* item = (DLGITEMTEMPLATE*)p;
	item->style = WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL | ES_LEFT;
	item->x = 20;
	item->y = 30;
	item->cx = 310;
	item->cy = 24;
	item->id = 1001;
	item->dwExtendedStyle = 0;
	p += sizeof(DLGITEMTEMPLATE);

	// 确定按钮
	item = (DLGITEMTEMPLATE*)p;
	item->style = WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON;
	item->x = 100;
	item->y = 80;
	item->cx = 60;
	item->cy = 24;
	item->id = IDOK;
	p += sizeof(DLGITEMTEMPLATE);

	// 取消按钮
	item = (DLGITEMTEMPLATE*)p;
	item->style = WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON;
	item->x = 190;
	item->y = 80;
	item->cx = 60;
	item->cy = 24;
	item->id = IDCANCEL;

	// 显示对话框
	HWND parent = GetActiveWindow();
	INT_PTR ret = DialogBoxIndirectParamW(
		GetModuleHandle(NULL),
		dlgTemplate,
		parent,
		(DLGPROC)PromptDlgProc,
		(LPARAM)wDefaultText
	);

	const char* result = NULL;
	if (ret == IDOK) {
		wchar_t* text = (wchar_t*)GetWindowLongPtr(parent, DWLP_USER);
		if (text) {
			int len = WideCharToMultiByte(CP_UTF8, 0, text, -1, NULL, 0, NULL, NULL);
			char* utf8 = (char*)malloc(len);
			if (utf8) {
				WideCharToMultiByte(CP_UTF8, 0, text, -1, utf8, len, NULL, NULL);
				result = utf8;
			}
			free(text);
		}
	}

	free(dlgTemplate);
	return result;
}
')
#end
class WinAPI {
	#if (windows && cpp)
    @:functionCode('
    HWND window = FindWindowA(NULL, title.c_str());
	if (window == NULL) 
        window = FindWindowExA(GetActiveWindow(), NULL, NULL, title.c_str());

    int value = enabled ? 1 : 0;

    if (window != NULL) {
        DwmSetWindowAttribute(window, 20, &value, sizeof(value));

        ShowWindow(window, 0);
        ShowWindow(window, 1);
        SetFocus(window);
    }
    ')
    #end
    public static function setDarkMode(title:String, enabled:Bool):Void {}

	#if (windows && cpp)
    @:functionCode('
    HWND window = FindWindowA(NULL, title.c_str());
	if (window == NULL) 
        window = FindWindowExA(GetActiveWindow(), NULL, NULL, title.c_str());

    if (window != NULL) {
        if(hWindowIcon!=NULL)
           DestroyIcon(hWindowIcon);
        if(hWindowIconBig!=NULL)
           DestroyIcon(hWindowIconBig);

        if (stricon.c_str() == "")
        {
            SendMessage( window, WM_SETICON, ICON_SMALL, (LPARAM)NULL );
            SendMessage( window, WM_SETICON, ICON_BIG, (LPARAM)NULL );
        }
        else
        {
            hWindowIcon = (HICON)LoadImage(NULL, stricon.c_str(), IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
            hWindowIconBig =(HICON)LoadImage(NULL, stricon.c_str(), IMAGE_ICON, 32, 32, LR_LOADFROMFILE);
            SendMessage( window, WM_SETICON, ICON_SMALL, (LPARAM)hWindowIcon );
            SendMessage( window, WM_SETICON, ICON_BIG, (LPARAM)hWindowIconBig );
        }
    }
    ')
    #end
	public static function setIcon(title:String, stricon:String):Void {}

    // TaskDialog doesn't work on haxe for some reason
	#if (windows && cpp)
	@:functionCode('
    int msgboxID = MessageBox(NULL, content.c_str(), title.c_str(), MB_ICONERROR | MB_OKCANCEL | MB_DEFBUTTON2);
    switch (msgboxID) {
    	case IDOK:
            yesCallback();
    		break;
    	case IDCANCEL:
    		break;
    }
    ')
	#end
	public static function alert(title:String, content:String, yesCallback:Void->Void):Void {}

    #if (windows && cpp)
	@:functionCode('
    int msgboxID = MessageBox(NULL, content.c_str(), title.c_str(), MB_ICONERROR | MB_YESNOCANCEL | MB_DEFBUTTON3);
    switch (msgboxID) {
    	case IDYES:
            yesCallback();
    		break;
        case IDNO:
            noCallback();
    		break;
    	case IDCANCEL:
    		break;
    }
    ')
	#end
	public static function ask(title:String, content:String, yesCallback:Void->Void, noCallback:Void->Void):Void {}

	#if (windows && cpp)
	@:functionCode('
    const char* c_result = PromptBox(title.c_str(), defaultText.c_str());
    if (c_result) {
        result = String(c_result);
        free((void*)c_result);
    }
    ')
	#end
	public static function prompt(title:String, defaultText:String):String {
		var result:String = "";
		#if (windows && cpp)
		untyped __cpp__('
			const char* c_result = PromptBox(title.c_str(), defaultText.c_str());
			if (c_result) {
				result = String(c_result);
				free((void*)c_result);
			}
		');
		#end
		return result;
	}
}
