#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_x64=aaa.Exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Constants.au3>
#include <file.au3>
#include <array.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <String.au3>
#include <Dependencies\WinHttp.au3>
#include <Dependencies\JSON.au3>
;#include <Dependencies\JSON_Translate.au3> ; examples of translator functions, includes JSON_pack and JSON_unpack
#include <FileConstants.au3>
#include <WinAPIFiles.au3>

;
; AutoIt Version: 3.0
; Language:       English
; Platform:       Win9x/NT
; Author:         JamesN
; Script Function:
;  Auto chat skype/Line

;http://10.18.200.114:81/api/LogManager/GetAppLog
; The data to be sent

$APIink = "http://63.216.192.186/applogapi/api/LogManager/GetAppLog"

; Logs from last 5 min till now
$fromtime = @MON & "%2f" & @MDAY &"%2f"& @YEAR & "+"& @HOUR &":"&@MIN-5&":"&@SEC
$totime =@MON &"%2f"&@MDAY&"%2f"&@YEAR& "+"& @HOUR&":"&@MIN&":"&@SEC
$sPD = $APIink&'?Todate='&$totime&'&FromDate='&$fromtime&'&ClientTimeZone=7&IsProduction=1&Severity=Error%2c+Critical'
;$sPD = $APIink&'?Todate=10%2f30%2f2015+14:57:39&FromDate=10%2f30%2f2015+14:52:39&ClientTimeZone=7&IsProduction=1&Severity=Error%2c+Critical'

; Creating the object
$oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
$oHTTP.Open("GET",$sPD, False)
$oHTTP.SetCredentials("kbt\webdeployer.vn","&hdke839D#4GY!)", 0)
; Performing the Request
$oHTTP.Send()

; Download the body response if any, and get the server status response code.
$oReceived = $oHTTP.ResponseText
$oStatusCode = $oHTTP.Status

If $oStatusCode <> 200 then
 MsgBox(4096, "Response code", $oStatusCode)
EndIf


;Decode Json data
Local $Data = Json_Decode($oReceived)


;===========Config=============
Opt("SendKeyDelay", 0)
;====END CONFIG===


;===========Functions=============


Func LoginLine($userid, $pwd)
	WinActivate("[Class:Qt5QWindowIcon]")
	local $a = WinGetPos("[CLASS:Qt5QWindowIcon]")
	local $gX =$a[0]+100
	Local $gY =$a[1]+165
	MouseClick($MOUSE_CLICK_LEFT,$gX,$gY,3)
	Sleep(1000)
	Send($userid)
	Send("{TAB}")
	Send($pwd)
	Send("{ENTER}")
	Sleep(3000)
EndFunc

Func checklinestatus()
	Run("C:\Program Files (x86)\LINE\LINE.exe")
	Sleep(2000)
	$hwnd = WinGetHandle("[ACTIVE]")
	$aStyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $hwnd, "int", -16)
	$aExStyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $hwnd, "int", -20)
	Local $gstyle=Hex($aStyle[0])
	Local $gexstyle=Hex($aExStyle[0])
	;If Line is logged user out then relogin
	If $gstyle<>"96CF0000" And $aExStyle<>"00000100" Then
	  WinActivate("[Class:Qt5QWindowIcon]")
	  Send("{ENTER}")
	  Sleep(2000)
	  loginLine("it@starixsoft.com","2211aa")
	EndIf
EndFunc


Func Skypechat(ByRef $vUsername, ByRef $vContent)
	Local $wktitle = WinGetTitle("Skype™","")
	WinActivate($wktitle)
	ControlFocus($wktitle, "","[CLASS:TConversationsControl; INSTANCE:1")
	Sleep(500)
	ControlClick($wktitle, "","[CLASS:TSearchControl; INSTANCE:1]")
	;AutoItSetOption("SendKeyDelay", 10)
	Send($vUsername)
	Sleep(2000)
	; Send("{TAB}")
	; Send("{TAB}")
	Send("{ENTER}")
	Sleep(1000)
	For $i=0 To UBound($vContent) - 1
	   If $vContent[$i]<>"" Then
		   Send($vContent[$i])
		   Send("{LSHIFT}+{ENTER}")
		   EndIf
		Next
	Send("________________________________")
	Send("{ENTER}")
EndFunc

Func linechat($lUsername, $lContent)
	;Capture  LINE UI  by Class properties
	Local $linetitle =  WinWait("[CLASS:Qt5QWindowIcon]", "", 3)
	WinActivate($linetitle)
	local $a = WinGetPos("[CLASS:Qt5QWindowIcon]")
	local $gX =$a[0]+150
	Local $gY =$a[1]+180
	MouseClick($MOUSE_CLICK_LEFT,$a[0]+75,$a[1]+70,1) ;click Contact tab by coordinate
	Sleep(1000)
	Send("{TAB}")
	Send($lUsername)
	Sleep(2000)
	MouseClick($MOUSE_CLICK_LEFT,$gX,$gY,2) ;Double click on search result name by coordinate
	Sleep(1500)
	Local $wlusertitle = WinGetTitle("[ACTIVE]") ; Check User exist or Not
	If $wlusertitle = $lUsername Then ;If exist then input content
		for $i=0 To UBound($lContent) - 1
		   Send($lContent[$i]&"{LSHIFT}+{ENTER}")
		  ;Send("{LSHIFT}{ENTER}")
		   Sleep(200)
		Next
		Send("{ENTER}")
		Send("{ESCAPE}")
		Sleep(500)
	EndIf
EndFunc


Func botchatskype()
   For $i=0 to UBound($Data)-1
   Local $Tempcontent =[]
   Local $category =   Json_Get($Data[$i],'.Category.CategoryName')
   _ArrayAdd($Tempcontent,"Category: "&$category)
   Local $Timestamp1 = StringSplit (Json_Get($Data[$i],'.Timestamp'),"T",1)
   Local $Timestamp = @MON & "/" & @MDAY &"/"& @YEAR & " " & $Timestamp1[2]
    _ArrayAdd($Tempcontent,"Timestamp: "&$Timestamp)
   Local $Severity = Json_Get($Data[$i],'.Severity')
    _ArrayAdd($Tempcontent,"Severity: "&$Severity)
   Local $Message = StringReplace(Json_Get($Data[$i],'.Message'),@CR,"")
   _ArrayAdd($Tempcontent,"Message: "&$Message)
   Local $URL =StringReplace(Json_Get($Data[$i],'.Url'),@CR,"")
   _ArrayAdd($Tempcontent,"URL: "&$URL)
   Local $referrer =StringReplace(Json_Get($Data[$i],'.Referrer'),@CR,"")
   _ArrayAdd($Tempcontent,"REFERRER: "&$referrer)
   Local $domain =Json_Get($Data[$i],'.AppDomainName')
   _ArrayAdd($Tempcontent,"DOMAIN: "&$domain)
   Local $Machine = Json_Get($Data[$i],'.Machine.MachineName')
   _ArrayAdd($Tempcontent,"MACHINE: "&$Machine)
   Local $SkypeGroup = Json_Get($Data[$i],'.GroupChat.SkypeGroup')
   Skypechat($SkypeGroup,$Tempcontent)
Next
 EndFunc

Func botchatline()
	For $i=0 to UBound($Data)-1
	   Local $Tempcontent =[]
	   Local $category =   Json_Get($Data[$i],'.Category.CategoryName')
	   _ArrayAdd($Tempcontent,"Category: "&$category)
	   Local $Timestamp1 = StringSplit (Json_Get($Data[$i],'.Timestamp'),"T",1)
	   Local $Timestamp = @MON & "/" & @MDAY &"/"& @YEAR & " " & $Timestamp1[2]
		_ArrayAdd($Tempcontent,"Timestamp: "&$Timestamp)
	   Local $Severity = Json_Get($Data[$i],'.Severity')
		_ArrayAdd($Tempcontent,"Severity: "&$Severity)
	   Local $Message = StringReplace(Json_Get($Data[$i],'.Message'),@CR,"")
	   _ArrayAdd($Tempcontent,"Message: "&$Message)
	   Local $URL =StringReplace(Json_Get($Data[$i],'.Url'),@CR,"")
	   _ArrayAdd($Tempcontent,"URL: "&$URL)
	   Local $referrer =StringReplace(Json_Get($Data[$i],'.Referrer'),@CR,"")
	   _ArrayAdd($Tempcontent,"REFERRER: "&$referrer)
	   Local $domain =Json_Get($Data[$i],'.AppDomainName')
	   _ArrayAdd($Tempcontent,"DOMAIN: "&$domain)
	   Local $Machine = Json_Get($Data[$i],'.Machine.MachineName')
	   _ArrayAdd($Tempcontent,"MACHINE: "&$Machine)
	   ;Local $SkypeGroup = Json_Get($Data[$i],'.GroupChat.SkypeGroup')
	   Linechat("teka",$Tempcontent)
	Next
EndFunc





;====END FUNCs===


;===========Main Steps=============
;Star Line and Skype apps
;checklinestatus()
botchatskype()
;botchatline()

