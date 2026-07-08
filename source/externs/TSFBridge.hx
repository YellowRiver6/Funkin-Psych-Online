package externs;

#if (windows && cpp)
@:buildXml('<target id="haxe"><lib name="imm32.lib" if="windows"/></target>')

@:cppFileCode('
#define _WIN32_WINNT 0x0601
#include <windows.h>
#include <imm.h>

static HWND g_hw = NULL;
static WNDPROC g_oldWndProc = NULL;

// IME polled state (converted to UTF-8 for Haxe)
static char g_comp[256] = {0};   // composition string
static int  g_compLen = 0;
static int  g_compCursor = 0;
static int  g_candCount = 0;
static int  g_candTotal = 0;
static int  g_candSel = 0;
static char g_cands[9][64] = {{0}}; // up to 9 candidates
static int  g_pageStart = 0;
static int  g_pageSize = 9;

static void _wide_to_utf8(const wchar_t* ws, char* out, int maxOut) {
    WideCharToMultiByte(65001/*CP_UTF8*/, 0, ws, -1, out, maxOut, NULL, NULL);
}

static void _pollIME() {
    g_compLen = 0; g_compCursor = 0; g_candCount = 0; g_candSel = 0;
    memset(g_comp, 0, sizeof(g_comp));
    memset(g_cands, 0, sizeof(g_cands));

    HWND hw = g_hw;
    if (!hw) { hw = GetActiveWindow(); if (!hw) hw = GetForegroundWindow(); g_hw = hw; }
    if (!hw) return;

    HIMC hi = ImmGetContext(hw);
    if (!hi) return;

    // Composition string (GCS_COMPSTR)
    LONG len = ImmGetCompositionStringW(hi, 8/*GCS_COMPSTR*/, NULL, 0);
    if (len > 0) {
        wchar_t* buf = (wchar_t*)malloc(len + 2);
        ImmGetCompositionStringW(hi, 8, buf, len);
        buf[len/2] = 0;
        _wide_to_utf8(buf, g_comp, 250);
        g_compLen = (int)(len/2);
        free(buf);

        // Cursor position
        g_compCursor = ImmGetCompositionStringW(hi, 0x8000/*GCS_CURSORPOS*/, NULL, 0);

        // Attribute (to determine selection range)
        LONG attrLen = ImmGetCompositionStringW(hi, 0x10/*GCS_COMPATTR*/, NULL, 0);
        if (attrLen > 0) {
            BYTE* attrs = (BYTE*)malloc(attrLen);
            ImmGetCompositionStringW(hi, 0x10, attrs, attrLen);
            // Find the clause (selection) range
            int selStart = -1, selEnd = -1;
            for (int i = 0; i < attrLen; i++) {
                if (attrs[i] == 1/*ATTR_TARGET_CONVERTED*/) {
                    if (selStart < 0) selStart = i;
                    selEnd = i + 1;
                }
            }
            if (selStart >= 0 && selEnd > selStart) {
                g_compCursor = selStart; // use as selection info
            }
            free(attrs);
        }
    }

    // Candidate list
    DWORD sz = ImmGetCandidateListW(hi, 0, NULL, 0);
    if (sz > 0) {
        LPCANDIDATELIST cl = (LPCANDIDATELIST)malloc(sz);
        ImmGetCandidateListW(hi, 0, cl, sz);
        g_candTotal = (int)cl->dwCount;
        g_pageStart = (int)cl->dwPageStart;
        g_pageSize = (int)cl->dwPageSize;
        if (g_pageSize < 1) g_pageSize = (int)cl->dwCount;
        if (g_pageSize > 9) g_pageSize = 9;
        g_candCount = g_pageSize;
        g_candSel = (int)cl->dwSelection - g_pageStart; // page-relative selection
        // Read only CURRENT PAGE candidates
        for (DWORD i = 0; i < (DWORD)g_pageSize; i++) {
            DWORD idx = (DWORD)g_pageStart + i;
            if (idx >= cl->dwCount) break;
            wchar_t* ws = (wchar_t*)((BYTE*)cl + cl->dwOffset[idx]);
            _wide_to_utf8(ws, g_cands[i], 60);
        }
        free(cl);
    }

    ImmReleaseContext(hw, hi);
}

// Subclassed window: fix WM_IME_SETCONTEXT
static LRESULT CALLBACK _imeWndProc(HWND h, UINT m, WPARAM w, LPARAM l) {
    if (m == 0x0281 && (l & 0xC0000000)) {
        LRESULT allow = DefWindowProcA(h, m, w, l);
        if (g_oldWndProc) CallWindowProcA(g_oldWndProc, h, m, w, l);
        return allow;
    }
    if (g_oldWndProc) return CallWindowProcA(g_oldWndProc, h, m, w, l);
    return DefWindowProcA(h, m, w, l);
}
')
#end
class TSFBridge
{
    #if (windows && cpp)
    @:functionCode('
    if (!g_hw) { g_hw = GetActiveWindow(); if(!g_hw) g_hw = GetForegroundWindow();
        if (g_hw) g_oldWndProc = (WNDPROC)(LONG_PTR)SetWindowLongPtrA(g_hw, -4, (LONG_PTR)_imeWndProc); }
    _pollIME();
    static int cc = 0;
    if (++cc <= 30 || cc % 60 == 0) {
        OutputDebugStringA(\"IME poll: comp=\"); OutputDebugStringA(g_comp);
        char tmp[128]; wsprintfA(tmp, \" cands=%d sel=%d start=%d size=%d\", g_candCount, g_candSel, g_pageStart, g_pageSize);
        OutputDebugStringA(tmp);
        OutputDebugStringA(\"\\n\");
    }
    ')
    #end
    public static function updatePosition(x:Int, y:Int, w:Int, h:Int):Void {}

    #if (windows && cpp) @:functionCode('') #end public static function init():Void {}
    #if (windows && cpp) @:functionCode('if (g_hw&&g_oldWndProc)SetWindowLongPtrA(g_hw,-4,(LONG_PTR)g_oldWndProc);') #end public static function shutdown():Void {}

    // --- IME state queries called from Haxe ---
    #if (windows && cpp) @:functionCode('return g_compLen > 0 ? true : false;') #end
    public static function hasComposition():Bool { return false; }

    #if (windows && cpp) @:functionCode('{ return (const char*)g_comp; }') #end
    public static function getCompositionString():String { return ""; }

    #if (windows && cpp) @:functionCode('return g_candCount;') #end
    public static function getCandidateCount():Int { return 0; }

    #if (windows && cpp) @:functionCode('{ if (idx >= 0 && idx < 9 && idx < g_candCount) return (const char*)g_cands[idx]; return ""; }') #end
    public static function getCandidate(idx:Int):String { return ""; }

    #if (windows && cpp) @:functionCode('return g_candSel;') #end
    public static function getSelectedIndex():Int { return 0; }

    #if (windows && cpp) @:functionCode('return g_pageStart;') #end
    public static function getPageStart():Int { return 0; }

    #if (windows && cpp) @:functionCode('return g_pageSize;') #end
    public static function getPageSize():Int { return 0; }

    #if (windows && cpp) @:functionCode('return g_candTotal;') #end
    public static function getTotalCandidates():Int { return 0; }
}
