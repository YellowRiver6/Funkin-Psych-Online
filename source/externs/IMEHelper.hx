package externs;

#if (windows && cpp)
@:buildXml('
<target id="haxe">
    <lib name="imm32.lib" if="windows" />
</target>
')

@:cppFileCode('
#include <windows.h>
#include <imm.h>
')
#end
class IMEHelper
{
    /**
     * Sets BOTH the IME composition window AND candidate window positions
     * directly via Windows IMM32 API. This bypasses SDL2's incomplete IME
     * implementation which only calls ImmSetCompositionWindow but NOT
     * ImmSetCandidateWindow (so the Chinese character candidate list
     * never appears).
     *
     * @param x       X position of caret in window client-area pixels
     * @param y       Y position of caret (top of text line) in window client-area pixels
     * @param width   Width of caret (1-2 px)
     * @param height  Height of the text line (font size + padding)
     */
    #if (windows && cpp)
    @:functionCode('
    // Cache the game window HWND
    static HWND s_imeHwnd = NULL;

    if (s_imeHwnd == NULL || !IsWindow(s_imeHwnd))
    {
        s_imeHwnd = GetActiveWindow();
        if (s_imeHwnd == NULL)
            s_imeHwnd = GetForegroundWindow();
    }

    if (s_imeHwnd == NULL) return;

    HIMC hImc = ImmGetContext(s_imeHwnd);
    if (hImc == NULL) return;

    // Position the composition window at the caret
    COMPOSITIONFORM compForm;
    compForm.dwStyle = CFS_POINT;
    compForm.ptCurrentPos.x = x;
    compForm.ptCurrentPos.y = y;
    ImmSetCompositionWindow(hImc, &compForm);

    // Position the candidate window BELOW the text line
    CANDIDATEFORM candForm;
    candForm.dwIndex = 0;
    candForm.dwStyle = CFS_CANDIDATEPOS;
    candForm.ptCurrentPos.x = x;
    candForm.ptCurrentPos.y = y + height + 2;
    ImmSetCandidateWindow(hImc, &candForm);

    ImmReleaseContext(s_imeHwnd, hImc);
    ')
    #end
    public static function setIMEPosition(x:Int, y:Int, width:Int, height:Int):Void {}
}
