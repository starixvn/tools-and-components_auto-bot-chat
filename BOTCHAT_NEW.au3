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
#include <Date.au3>
#include <Dependencies\WinHttp.au3>
#include <Dependencies\JSON.au3>
#include <FileConstants.au3>
#include <WinAPIFiles.au3>

;
; AutoIt Version: 3.0
; Language:       English
; Platform:       Win9x/NT
; Author:         JamesN
; Editor: 		  Larry.Tran
; Script Function:
;  Auto chat skype/Line
;------------------------------------------------------------------------------------------

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


Func Skypechat($vUsername, $vContent)
	If $vUsername <> "" Then
		Local $wktitle = WinGetTitle("Skype™","")
		WinActivate($wktitle)
		ControlFocus($wktitle, "","[CLASS:TConversationsControl; INSTANCE:1")
		Sleep(500)
		ControlClick($wktitle, "","[CLASS:TSearchControl; INSTANCE:1]")
		;AutoItSetOption("SendKeyDelay", 10)
		Send($vUsername)
		Sleep(500)
		; Send("{TAB}")
		; Send("{TAB}")
		Send("{ENTER}")
		Sleep(500)
		For $i=0 To UBound($vContent) - 1
		   If $vContent[$i]<>"" Then
			   Send($vContent[$i])
			   Send("{LSHIFT}+{ENTER}")
			   EndIf
			Next
		Send("________________________________")
		Send("{ENTER}")
		Sleep(1000)
	EndIf
EndFunc

Func linechat($lUsername, $lContent)
	If $lUsername <> "" Then
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
		Sleep(1000)
		MouseClick($MOUSE_CLICK_LEFT,$gX,$gY,2) ;Double click on search result name by coordinate
		Sleep(1500)
		Local $wlusertitle = WinGetTitle("[ACTIVE]") ; Check User exist or Not
		If $wlusertitle = $lUsername Then ;If exist then input content
			For $i=0 To UBound($lContent) - 1
			   Send($lContent[$i]&"{LSHIFT}+{ENTER}")
			  ;Send("{LSHIFT}{ENTER}")
			   Sleep(200)
			Next
			Send("{ENTER}")
			Send("{ESCAPE}")
			Sleep(500)
		EndIf
	EndIf
EndFunc

Func GetMessage($logItem)
	Local $messageContent =[]

	Local $category = Json_Get($logItem,'.Category.CategoryName')
	_ArrayAdd($messageContent,"Category: "&$category)

	Local $Timestamp = StringReplace(Json_Get($logItem,'.Timestamp'),"T"," ")
	_ArrayAdd($messageContent,"Timestamp: "&$Timestamp)

	Local $Severity = Json_Get($logItem,'.Severity')
	_ArrayAdd($messageContent,"Severity: "&$Severity)

	Local $Message = Json_Get($logItem,'.Message')
	_ArrayAdd($messageContent,"Message: "&$Message)

	Local $URL = Json_Get($logItem,'.Url')
	_ArrayAdd($messageContent,"URL: "&$URL)

	Local $referrer = Json_Get($logItem,'.Referrer')
	_ArrayAdd($messageContent,"REFERRER: "&$referrer)

	Local $domain =Json_Get($logItem,'.AppDomainName')
	_ArrayAdd($messageContent,"DOMAIN: "&$domain)

	Local $Machine = Json_Get($logItem,'.Machine.MachineName')
	_ArrayAdd($messageContent,"MACHINE: "&$Machine)

	Return $messageContent;
EndFunc

Func botchatskype($Data)
	For $i=0 to UBound($Data)-1
		Local $logItem = $Data[$i]

		Local $messageContent = GetMessage($logItem)

		Local $SkypeGroup = Json_Get($logItem,'.GroupChat.SkypeGroup')

		Skypechat($SkypeGroup,$messageContent)
	Next
EndFunc

Func botchatline($Data)
	For $i=0 to UBound($Data)-1
		Local $logItem = $Data[$i]

		Local $messageContent = GetMessage($logItem)

		Local $lineGroup = Json_Get($logItem,'.GroupChat.LineGroup')

		Linechat($lineGroup,$messageContent)
	Next
EndFunc

Func GetAppLog($sAPILink, $user, $password)
	; Creating the object
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	$oHTTP.Open("GET",$sAPILink, False)
	$oHTTP.SetCredentials($user,$password, 0)
	; Performing the Request
	$oHTTP.Send()

	; Download the body response if any, and get the server status response code.
	Local $oReceived = $oHTTP.ResponseText
	Local $oStatusCode = $oHTTP.Status

	If $oStatusCode <> 200 then
		MsgBox($MB_SYSTEMMODAL, "Response code", $oStatusCode)
	EndIf

	;Decode Json data
	Local $Data = Json_Decode($oReceived)

	Return $Data
EndFunc

Func EncodeDateTime($dateTime)
	Local $result = StringReplace(StringReplace($dateTime,"/","%2f")," ","+")

	Return $result
EndFunc


Func Initialize()
	;===========Config=============
	Opt("SendKeyDelay", 0)

	;Local Environment:
	;Local $sAPILink = "http://10.18.200.114:81/api/LogManager/GetAppLog"
	;Local $user = "spvn\jenkins.ci"
	;Local $password = "sunrise"

	;Production Environment:
	Local $sAPILink = "http://63.216.192.186/applogapi/api/LogManager/GetAppLog"
	Local $user = "kbt\webdeployer.vn"
	Local $password = "&hdke839D#4GY!)"

	; Logs from last 5 min till now
	Local $toDateTime = _NowCalc()
	Local $fromDateTime = _DateAdd('n', -5, $toDateTime)
	$toDateTime = EncodeDateTime($toDateTime)
	$fromDateTime = EncodeDateTime($fromDateTime)

	$sAPILink = $sAPILink & '?FromDate=' & $fromDateTime & '&ToDate=' & $toDateTime &  '&ClientTimeZone=7&IsProduction=True&Severity=Error%2c+Critical'
	;debug
	;$sAPILink = $sAPILink&'?FromDate=2015%2f11%2f03+12:55:00&ToDate=2015%2f11%2f03+17:00:00&ClientTimeZone=7&IsProduction=True&Severity=Error%2c+Critical'
	;MsgBox($MB_SYSTEMMODAL, "API Link", $sAPILink)

	Local $logData = GetAppLog($sAPILink, $user, $password)

	If UBound($logData) > 0 Then
		botchatskype($logData)

		;checklinestatus()
		;botchatline($logData)
	EndIf

EndFunc

;====END FUNCs===


;===========Main Steps=============
Initialize()