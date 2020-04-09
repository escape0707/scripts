; Translate Selected text using GoldenDict

; Ignore attempts to launch when the script is already running
#SingleInstance Ignore

; Get install path and start GoldenDict (32bit)
SetRegView 32
RegRead, FullFileName, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GoldenDict, UninstallString
SplitPath, FullFileName,, InstallPath
GoldenDictPath := InstallPath . "\GoldenDict.exe"

; Run GoldenDict if it's not running
Process, Exist, GoldenDict.exe
if (!ErrorLevel) {
    ; Unfortunately, run options like Max|Min|Hide won't work for GoldenDict
    Run, %GoldenDictPath%
}

; Register clean up function to be called on exit
OnExit("CloseGoldenDict")
CloseGoldenDict() {
    Process, Close, GoldenDict.exe
}

; Use Window Spy shipped with AutoHotKey installation to find other windows you want this script to ignore, then add them below
GroupAdd, IgnoreWindowsGroup, ahk_class ConsoleWindowClass    ; Console
GroupAdd, IgnoreWindowsGroup, ahk_exe   Code - Insiders.exe   ; Visual Studio Code - Insiders
GroupAdd, IgnoreWindowsGroup, ahk_exe   Code.exe              ; Visual Studio Code
GroupAdd, IgnoreWindowsGroup, ahk_exe   Explorer.EXE          ; File Explorer
GroupAdd, IgnoreWindowsGroup, ahk_exe   WindowsTerminal.exe   ; Windows Terminal (preview)

; Avoid this script to be actived in above window classes
#IfWinNotActive ahk_group IgnoreWindowsGroup

; Set coordinate mode for mouse to be relative to the entire screen to correctly handle the position of clicks' which activate another window
CoordMode, Mouse, Screen

; Initialize global variables
MouseDownTime := 0
MouseDownPositionX := 0
MouseDownPositionY := 0
DoubleClickTime := DllCall("GetDoubleClickTime")
DoubleClicked := False


; Optional hotkey to toggle this script's suspending. Remove the semicolon in the next line if you need it
; F8::Suspend


~LButton::
    MouseGetPos MousePositionX, MousePositionY
    ; If Clicked within DoubleClickTime and mouse didn't moved
    if (A_TickCount - MouseDownTime < DoubleClickTime and Abs(MousePositionX - MouseDownPositionX) + Abs(MousePositionY - MouseDownPositionY) < 5) {
        DoubleClicked := True
    }
    ; Record this click
    MouseDownTime := A_TickCount
    MouseDownPositionX := MousePositionX
    MouseDownPositionY := MousePositionY
    return


~LButton Up::
    if (DoubleClicked) {
        DoubleClicked := False
        Gosub, TranslateRoutine
        return
    }

    MouseGetPos MouseUpPositionX, MouseUpPositionY
    ; If mouse moved
    if (Abs(MouseUpPositionX - MouseDownPositionX) + Abs(MouseUpPositionY - MouseDownPositionY) > 5) {
        GoSub, TranslateRoutine
    }
    return


; You can optionally comment out all following lines contains `ClipboardSave` to let the copied word remain in the clipboard
TranslateRoutine:
    ClipboardSave := ClipboardAll
    Clipboard :=
    SendInput, ^c

    ClipWait, 0
    if (!ErrorLevel) {
        Selected := Trim(Clipboard, " `t`r`n")
    }
    Clipboard := ClipboardSave
    ; Free the memory in case the Clipboard was very large
    ClipboardSave :=
    if (ErrorLevel) {
        return
    }

    SelectedLength := StrLen(Selected)
    if (SelectedLength <= 0 or SelectedLength > 50) {
        return
    }
    Selected := """" . Selected . """"
    Run, %GoldenDictPath% %Selected%
    return
