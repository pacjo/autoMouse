#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance Force
#MaxThreadsPerHotkey 2
SendMode Event

; This script saves it's settings in directory, where it was executed

version_number := "1.1-ALPHA2"

; Default values (get changed if setting.ini exists):
run_startup := 0
clicking_delay := 30
moving_speed := 10

; **************************Menu settings**************************************

Menu, Tray, Tip, autoMouse
Menu, Tray, NoStandard
Menu, Tray, Add, &Auto clicker, AUTOCLICKER_HANDLER
Menu, Tray, Add, &Mouse jiggler, MOUSEJIGGLER_HANDLER
Menu, Tray, Add
Menu, Tray, Add, &Settings, SETTINGS_HANDLER
Menu, Tray, Add
Menu, Tray, Add, &Exit, EXIT_HANDLER

; **************************Get stored settings / create settings file*********

if !FileExist("%A_MyDocuments%\settings.ini")
	FileCreateDir, %A_MyDocuments%\autoMouse
	FileAppend, [Settings] `nRunOnSystemBoot=%run_startup% `nClickingDelay=%clicking_delay% `nMovingSpeed=%moving_speed%, %A_MyDocuments%\autoMouse\settings.ini

if FileExist("%A_MyDocuments%\settings.ini")
	IniRead, run_startup, %A_MyDocuments%\autoMouse\settings.ini, Settings, RunOnSystemBoot
	IniRead, clicking_delay, %A_MyDocuments%\autoMouse\settings.ini, Settings, ClickingDelay
	IniRead, moving_speed, %A_MyDocuments%\autoMouse\settings.ini, Settings, MovingSpeed


; MsgBox, Run on startup: %run_startup% `nClicking delay: %clicking_delay% `nMoving speed: %moving_speed%

; **************************Gui************************************************

; Gui Add, CheckBox, vrun_startup x8 y8 w283 h23 +Checked, Run on system start (places shortcut in shell:startup)
If (run_startup = 1)
	Gui Add, CheckBox, vrun_startup x8 y8 w283 h23 +Checked, Run on system start (places shortcut in shell:startup)
else
	Gui Add, CheckBox, vrun_startup x8 y8 w283 h23, Run on system start (places shortcut in shell:startup)
Gui Add, Edit, vclicking_delay x8 y40 w67 h21 +Number, %clicking_delay%
Gui Add, Text, x88 y40 w201 h23 +0x200, Clicking speed (delay between clicks)
Gui Add, Edit, vmoving_speed x8 y72 w67 h21 +Number, %moving_speed%
Gui Add, Text, x88 y72 w201 h23 +0x200, Mouse moving speed [mm/s]
Gui Add, Button, gSAVE_BUTTON x8 y152 w283 h23, Save
Gui Add, Text, x8 y180 w201 h13 +0x200, %version_number%

;**************************end of autorun section*****************************

return

;**************************Handlers*******************************************

SETTINGS_HANDLER:
	Gui Show, w300 h200, autoMouse settings
return

AUTOCLICKER_HANDLER:
	; Menu, Tray, ToggleCheck, &Auto clicker
	clickerToggle := !clickerToggle
	Goto, click_mouse
return

MOUSEJIGGLER_HANDLER:
	; Menu, Tray, ToggleCheck, &Mouse jiggler
	movingToggle := !movingToggle
	Goto, move_mouse
return

RUN_ON_BOOT:
	If (run_startup = 1) {
		FileCreateShortcut, %A_ScriptDir%\%A_ScriptName%, %A_Startup%\%A_ScriptName%.lnk
		; MsgBox, creation complete
	}
	If (run_startup = 0) {
		FileDelete, %A_Startup%\%A_ScriptName%.lnk
		; MsgBox, file deleted
	}
return

SAVE_BUTTON:
	Gui, Submit

	FileDelete, %A_MyDocuments%\autoMouse\settings.ini
	FileAppend, , %A_MyDocuments%\autoMouse\settings.ini

	IniWrite, %run_startup%, %A_MyDocuments%\autoMouse\settings.ini, Settings, RunOnSystemBoot
	IniWrite, %clicking_delay%, %A_MyDocuments%\autoMouse\settings.ini, Settings, ClickingDelay
	IniWrite, %moving_speed%, %A_MyDocuments%\autoMouse\settings.ini, Settings, MovingSpeed

	gosub RUN_ON_BOOT
return

EXIT_HANDLER:
	ExitApp
return

GuiEscape:
GuiClose:
	Gui, Cancel

;**************************Functions******************************************

move_mouse:
	global movingToggle
	global moving_speed

	; MsgBox, %movingToggle%

	if (movingToggle = 1)
	{
		Menu, Tray, Check, &Mouse jiggler
		MouseMove, 30, 0, %moving_speed%, R
		MouseMove, 0, 30, %moving_speed%, R
		MouseMove, -30, 0, %moving_speed%, R
		MouseMove, 0, -30, %moving_speed%, R
		Goto, move_mouse
		return
	} else
		Menu, Tray, Uncheck, &Mouse jiggler
		return

click_mouse:
	global clickerToggle
	global clicking_delay

	; MsgBox, %clickerToggle%

	if (clickerToggle = 1)
	{
		Menu, Tray, Check, &Auto clicker
		MouseClick
		Sleep, %clicking_delay%
		Goto, click_mouse
	}
	else
		Menu, Tray, Uncheck, &Auto clicker
		return

;**************************Hotkeys********************************************

^+r::Reload
return

^t::MsgBox, Run on startup: %run_startup% `nClicking delay: %clicking_delay% `nMoving speed: %moving_speed% `nScript name: "%A_ScriptDir%\%A_ScriptName%" `nShortcut: "%A_Startup%\%A_ScriptName%.lnk `nDocuments folder:%A_MyDocuments%
return

F6::
movingToggle := !movingToggle
Goto, move_mouse
return

F7::
clickerToggle := !clickerToggle
Goto, click_mouse
return
