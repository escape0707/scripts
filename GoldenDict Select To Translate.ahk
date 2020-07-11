; Translate Selected text using GoldenDict

; Ignore attempts to launch when the script is already running
#SingleInstance Ignore


; Utility functions definitions: START
FindGoldenDictPath() {
  ; Find a installed GoldenDict
  PreviousRegView := A_RegView
  SetRegView, 32
  RegRead, FullFilePath, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GoldenDict, UninstallString
  SetRegView, %PreviousRegView%
  if (!ErrorLevel) {
      SplitPath, FullFilePath,, InstallPath
      Return, InstallPath . "\GoldenDict.exe"
  }

  ; If GoldenDict is not installed normally, check whether a scoop installed version exist
  ScoopFilePath := "C:\Users\" . A_UserName . "\scoop\apps\goldendict\current\GoldenDict.exe"
  if FileExist(ScoopFilePath) {
      Return, ScoopFilePath
  }

  Throw, "No GoldenDict installation could be found. You could still modify this .ahk file manually to provide a valid GoldenDictPath."
}


CloseGoldenDict() {
    Process, Close, GoldenDict.exe
}
; Utility functions definitions: END


; Main Thread: START
; Run GoldenDict if it's not running
Process, Exist, GoldenDict.exe
if (!ErrorLevel) {
    GoldenDictPath := FindGoldenDictPath()
    ; Unfortunately, run options like Max|Min|Hide won't work for GoldenDict
    Run, %GoldenDictPath%
}

; Register clean up function to be called on exit
OnExit("CloseGoldenDict")

; Use Window Spy shipped with AutoHotKey installation to find other windows you want this script to ignore, then add them below
GroupAdd, IgnoreWindowsGroup, ahk_class ConsoleWindowClass      ; Console
GroupAdd, IgnoreWindowsGroup, ahk_exe   Code - Insiders.exe     ; Visual Studio Code - Insiders
GroupAdd, IgnoreWindowsGroup, ahk_exe   Code.exe                ; Visual Studio Code
GroupAdd, IgnoreWindowsGroup, ahk_exe   Explorer.EXE            ; File Explorer
GroupAdd, IgnoreWindowsGroup, ahk_exe   ScreenClippingHost.exe  ; Snip & Sketch
GroupAdd, IgnoreWindowsGroup, ahk_exe   vlc.exe                 ; VLC media player
GroupAdd, IgnoreWindowsGroup, ahk_exe   WindowsTerminal.exe     ; Windows Terminal

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
; Main thread: END


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
    ; Don't lookup word in previously specified window classes
    if WinActive("ahk_group IgnoreWindowsGroup") {
      Return
    }
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
