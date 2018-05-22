;*****************************************
;firefoxCopyToLocal.au3 by Timo Schrader
;Erstellt mit ISN AutoIt Studio v. 1.06
;*****************************************
#include <Array.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiComboBox.au3>
#include "Forms\ProfileSelection.isf"

func __dbgOut($data)
	ConsoleWrite("[" & @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & "] ")
	ConsoleWrite($data)
	ConsoleWrite(@CRLF)
EndFunc

__dbgOut("Retrieving Appdata Value...")
local $appdata = EnvGet("appdata")
__dbgOut("Got Appdata value! Appdata = " & $appdata)

__dbgOut("Retrieving userprofile Value...")
local $userprofile = EnvGet("userprofile")
__dbgOut("Got userprofile value! Userprofile = " & $userprofile)

__dbgOut("Retrieving Location of the Firefox ini")
local $firefoxINI = $appdata & "\Mozilla\Firefox\profiles.ini"
__dbgOut("Found the Firefox ini! Ini = " & $firefoxINI)

__dbgOut("Loading Profiles...")
Local $profiles = IniReadSectionNames($firefoxINI)
_ArrayDelete($profiles,"0;1")
__dbgOut("Loaded Profiles!")


__dbgOut("Checking how many Profiles exist...")
local $numberOfProfiles = IniReadSectionNames($firefoxINI)[0] - 1
__dbgOut($numberOfProfiles & " Profiles are existent")



if $numberOfProfiles > 1 Then
	for $i = 1 to $numberOfProfiles
		__dbgOut($i & ") Sectionname: " & $profiles[$i - 1] & " Profilename: " & IniRead($firefoxINI,$profiles[$i - 1],"Name","ERROR"))
	Next
	
	__dbgOut("Please Select the Profile you want to copy to local")
		
	$ProfileSelection = GUICreate("ProfileSelection",159,82,-1,-1,-1,-1)
	$iOkButton = GUICtrlCreateButton("Ok",10,38,139,30,-1,-1)
	$dropbox = GUICtrlCreateCombo("",10,10,139,21,-1,-1)
	for $i = 1 to $numberOfProfiles
		GUICtrlSetData(-1,IniRead($firefoxINI,$profiles[$i - 1],"Name","ERROR"))
	Next
	
	GUISetState(@SW_SHOW,$ProfileSelection)
	
	local $message
	While $message <> $GUI_EVENT_CLOSE
		$message = GUIGetMsg()
		
		if $message == $iOkButton Then
			GUISetState(@SW_HIDE,$ProfileSelection)
			ExitLoop
		EndIf
		
		Sleep(50)
	WEnd
	
	$selection = _GUICtrlComboBox_FindStringExact($dropbox,GUICtrlRead($dropbox))
	
	__dbgOut("User Selected: " & GUICtrlRead($dropbox))
Else
	__dbgOut("Only 1 Profile, dont show dialog...")	
	$selection = 0
EndIf

__dbgOut("Checking State of Profile")
If IniRead($firefoxINI,$profiles[$selection],"IsRelative",0) == 0 Then
	__dbgOut("It seems the Profile has been already modifed..")
	__dbgOut("Aborting...")
	MsgBox(0,"Goodbye","Aborting, profile is already modified..")
	Exit
EndIf

__dbgOut("Getting Profile Path...")
$profilePath = $appdata & "\Mozilla\Firefox\" & IniRead($firefoxINI,$profiles[$selection],"Path","ERROR")
__dbgOut("Got Profile Path: " & $profilePath)

__dbgOut("Plotting Desitination Path...")
$localPath = $userprofile & "\appdata\Local\Mozilla\LocalProfile"
__dbgOut("Got Loacal Path: " & $localPath)

__dbgOut("Copying Folder to local Path...")
DirCopy($profilePath,$localPath,1)
__dbgOut("Done Copying")

__dbgOut("Writing changes INI...")
IniWrite($firefoxINI,$profiles[$selection],"IsRelative",0)
IniWrite($firefoxINI,$profiles[$selection],"Path",$localPath)
__dbgOut("Done writing changes")
__dbgOut("Program is finished.")
__dbgOut("Program wishes you a good day.")
__dbgOut("Program will now stop talking about itself in 3rd Person.")
MsgBox(0,"Goodbye","Moved Profile to Local..")