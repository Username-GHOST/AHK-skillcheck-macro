#Persistent
Toggle := false  ; Start with the script turned off
SetTimer, DetectOverlap, Off  ; Initially disable the detection loop
SetTimer, DetectFishing, Off  ; Initially disable fishing detection

; Default values
ToggleKey := "Numpad9"
Color1 := 0xFF0000  ; Moving red color
Color2 := 0x1971C2  ; Nonmoving red color
Delay := 30  ; Delay before pressing key (ms)
KeyToPress := "e"  ; Default key to press
FishingKey := "o"
FishingInterval := 1000  ; Default interval for fishing detection (ms)
FishingColor := 0x000000  ; Default fishing detection color
FishingX := 136
FishingY := 752

; Preformat values for the GUI
Color1Formatted := Format("0x{:06X}", Color1)
Color2Formatted := Format("0x{:06X}", Color2)
FishingColorFormatted := Format("0x{:06X}", FishingColor)

; Load settings from a file (if available)
SettingsFile := A_ScriptDir "\settings.ini"
IfExist, %SettingsFile%
{
    IniRead, ToggleKey, %SettingsFile%, Settings, ToggleKey, %ToggleKey%
    IniRead, Color1, %SettingsFile%, Settings, Color1, %Color1%
    IniRead, Color2, %SettingsFile%, Settings, Color2, %Color2%
    IniRead, Delay, %SettingsFile%, Settings, Delay, %Delay%
    IniRead, KeyToPress, %SettingsFile%, Settings, KeyToPress, %KeyToPress%
    IniRead, FishingKey, %SettingsFile%, Settings, FishingKey, %FishingKey%
    IniRead, FishingInterval, %SettingsFile%, Settings, FishingInterval, %FishingInterval%
    IniRead, FishingColor, %SettingsFile%, Settings, FishingColor, %FishingColor%
    IniRead, FishingX, %SettingsFile%, Settings, FishingX, %FishingX%
    IniRead, FishingY, %SettingsFile%, Settings, FishingY, %FishingY%
}

; Create the GUI
Gui, Font, s12 Bold, Verdana
Gui, Color, Black
Gui, Add, Text, x10 y10 w350 Center cPurple, Color & Fishing Detection
Gui, Add, Text, x10 y50 w350 Center vScriptStatus Hidden  ; Status starts hidden

Gui, Font, s10 Bold, Verdana
Gui, Add, GroupBox, x10 y80 w350 h480 cPurple, Settings
Gui, Font, s10, Verdana

; Settings
Gui, Add, Text, x20 y110 w150 cWhite, Toggle Keybind:
Gui, Add, Edit, x180 y110 w150 vToggleKeyEdit, %ToggleKey%

Gui, Add, Text, x20 y150 w150 cWhite, Moving Color HEX:
Gui, Add, Edit, x180 y150 w150 vColor1Edit, %Color1Formatted%

Gui, Add, Text, x20 y190 w150 cWhite, Nonmoving Color HEX:
Gui, Add, Edit, x180 y190 w150 vColor2Edit, %Color2Formatted%

Gui, Add, Text, x20 y230 w150 cWhite, Delay before pressing key (ms):
Gui, Add, Edit, x180 y230 w150 vDelayEdit, %Delay%

Gui, Add, Text, x20 y270 w150 cWhite, Key to Press:
Gui, Add, Edit, x180 y270 w150 vKeyToPressEdit, %KeyToPress%

Gui, Add, Text, x20 y310 w150 cWhite, Fishing Key:
Gui, Add, Edit, x180 y310 w150 vFishingKeyEdit, %FishingKey%

Gui, Add, Text, x20 y350 w150 cWhite, Fishing Interval (ms):
Gui, Add, Edit, x180 y350 w150 vFishingIntervalEdit, %FishingInterval%

Gui, Add, Text, x20 y390 w150 cWhite, Fishing Success Letter Color HEX:
Gui, Add, Edit, x180 y390 w150 vFishingColorEdit, %FishingColorFormatted%

Gui, Add, Text, x20 y430 w150 cWhite, Fishing Success Letter Location X:
Gui, Add, Edit, x180 y430 w150 vFishingXEdit ReadOnly cWhite, %FishingX%

Gui, Add, Text, x20 y470 w150 cWhite, Fishing Success Letter Location Y:
Gui, Add, Edit, x180 y470 w150 vFishingYEdit ReadOnly cWhite, %FishingY%

; Add button to capture coordinates
Gui, Add, Button, x180 y510 w150 h30 gCaptureCoordinates, Set Fishing Coordinates

; Controls
Gui, Font, s10 Bold, Verdana
Gui, Add, GroupBox, x10 y570 w350 h100 cPurple, Controls
Gui, Font, s10, Verdana
Gui, Add, Button, x50 y600 w120 h30 gToggleScript, Toggle
Gui, Add, Button, x200 y600 w120 h30 gSaveSettings, Save Settings

Gui, Show, w380 h700, Color & Fishing Detection

; Ensure the hotkey is set initially
Hotkey, %ToggleKey%, DynamicToggle, On
return

; Toggle button handler
ToggleScript:
    Toggle := !Toggle
    if (Toggle) {
        SetTimer, DetectOverlap, 10
        SetTimer, DetectFishing, %FishingInterval%
        GuiControl, -Hidden, ScriptStatus  ; Show the status text
        GuiControl,, ScriptStatus, WORKING
        GuiControl, +cGreen, ScriptStatus  ; Green color for WORKING
    } else {
        SetTimer, DetectOverlap, Off
        SetTimer, DetectFishing, Off
        GuiControl, +Hidden, ScriptStatus  ; Hide the status text when off
    }
return

; Save settings
SaveSettings:
    Gui, Submit, NoHide
    ToggleKey := ToggleKeyEdit
    ; Ensure valid HEX format before saving (i.e., 0xRRGGBB)
    Color1 := "0x" . SubStr(Color1Edit, 3)
    Color2 := "0x" . SubStr(Color2Edit, 3)
    Delay := DelayEdit
    KeyToPress := KeyToPressEdit
    FishingKey := FishingKeyEdit
    FishingInterval := FishingIntervalEdit
    FishingColor := "0x" . SubStr(FishingColorEdit, 3)
    FishingX := FishingXEdit
    FishingY := FishingYEdit

    ; Ensure HEX values are valid
    if !RegExMatch(Color1, "^0x[0-9A-Fa-f]{6}$")
        Color1 := "0xFF0000"  ; Default if invalid
    if !RegExMatch(Color2, "^0x[0-9A-Fa-f]{6}$")
        Color2 := "0x1971C2"  ; Default if invalid
    if !RegExMatch(FishingColor, "^0x[0-9A-Fa-f]{6}$")
        FishingColor := "0xFFFFFF"  ; Default if invalid

    ; Save to settings.ini (Ensure valid HEX values)
    IniWrite, %ToggleKey%, %SettingsFile%, Settings, ToggleKey
    IniWrite, %Color1%, %SettingsFile%, Settings, Color1
    IniWrite, %Color2%, %SettingsFile%, Settings, Color2
    IniWrite, %Delay%, %SettingsFile%, Settings, Delay
    IniWrite, %KeyToPress%, %SettingsFile%, Settings, KeyToPress
    IniWrite, %FishingKey%, %SettingsFile%, Settings, FishingKey
    IniWrite, %FishingInterval%, %SettingsFile%, Settings, FishingInterval
    IniWrite, %FishingColor%, %SettingsFile%, Settings, FishingColor
    IniWrite, %FishingX%, %SettingsFile%, Settings, FishingX
    IniWrite, %FishingY%, %SettingsFile%, Settings, FishingY
return

; Capture fishing coordinates
CaptureCoordinates:
    ToolTip, Click on the screen to capture coordinates...
    KeyWait, LButton, D  ; Wait for left mouse click
    MouseGetPos, FishingX, FishingY
    GuiControl,, FishingXEdit, %FishingX%
    GuiControl,, FishingYEdit, %FishingY%
    ToolTip  ; Clear tooltip
return

; Variable to prevent key conflict
KeyLock := false

; Fishing detection
DetectFishing:
    if (KeyLock)
        return  ; Skip if key is already being pressed

    PixelGetColor, color, %FishingX%, %FishingY%, RGB
    if (color = FishingColor) {
        KeyLock := true  ; Lock the key
        SendInput {%FishingKey% down}
        Sleep, 50
        SendInput {%FishingKey% up}
        KeyLock := false  ; Unlock the key after press
    }
return

; Detect overlap
DetectOverlap:
    if (KeyLock)
        return  ; Skip if key is already being pressed

    ; Center of the screen
    CenterX := A_ScreenWidth // 2
    CenterY := A_ScreenHeight // 2

    ; Define the 500x500 search area
    StartX := CenterX - 250
    StartY := CenterY - 250
    EndX := CenterX + 250
    EndY := CenterY + 250

    ; Search for Color1 in the area
    PixelSearch, Px1, Py1, StartX, StartY, EndX, EndY, %Color1%, 10, Fast RGB
    if (ErrorLevel)
        return  ; Color1 not found

    ; Search for Color2 near Color1
    PixelSearch, Px2, Py2, Px1 - 10, Py1 - 10, Px1 + 10, Py1 + 10, %Color2%, 10, Fast RGB
    if (ErrorLevel)
        return  ; Color2 not found

    ; Both colors found, apply delay and simulate key press
    KeyLock := true  ; Lock the key

    ; Apply delay before pressing key
    Sleep, %Delay%  ; This will wait for the defined delay

    ; Send key press after delay
    SendInput {%KeyToPress% down}
    Sleep, 50
    SendInput {%KeyToPress% up}
    
    KeyLock := false  ; Unlock the key after press
return

; Dynamic toggle hotkey
DynamicToggle:
    Gosub, ToggleScript
return

GuiClose:
ExitApp
