#Include %A_ScriptDir%\Include\Logging.ahk
#Include %A_ScriptDir%\Include\ADB.ahk
#Include %A_ScriptDir%\Include\Gdip_All.ahk
#Include %A_ScriptDir%\Include\Gdip_Imagesearch.ahk

; BallCity - 2025.20.25 - Add OCR library for Username if Inject is on
#Include *i %A_ScriptDir%\Include\OCR.ahk
#Include *i %A_ScriptDir%\Include\Gdip_Extra.ahk


#SingleInstance on
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetBatchLines, -1
SetTitleMatchMode, 3
CoordMode, Pixel, Screen
#NoEnv

; Allocate and hide the console window to reduce flashing
DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")

global winTitle, changeDate, failSafe, openPack, Delay, failSafeTime, StartSkipTime, Columns, failSafe, scriptName, GPTest, StatusText, defaultLanguage, setSpeed, jsonFileName, pauseToggle, SelectedMonitorIndex, swipeSpeed, godPack, scaleParam, deleteMethod, packs, FriendID, friendIDs, Instances, username, friendCode, stopToggle, friended, runMain, Mains, showStatus, injectMethod, packMethod, loadDir, loadedAccount, nukeAccount, CheckShinyPackOnly, TrainerCheck, FullArtCheck, RainbowCheck, ShinyCheck, dateChange, foundGP, friendsAdded, PseudoGodPack, packArray, CrownCheck, ImmersiveCheck, InvalidCheck, slowMotion, screenShot, accountFile, invalid, starCount, keepAccount
global Mewtwo, Charizard, Pikachu, Mew, Dialga, Palkia, Arceus, Shining, Solgaleo, Lunala
global shinyPacks, minStars, minStarsShiny, minStarsA1Mewtwo, minStarsA1Charizard, minStarsA1Pikachu, minStarsA1a, minStarsA2Dialga, minStarsA2Palkia, minStarsA2a, minStarsA2b, minStarsA3Solgaleo, minStarsA3Lunala
global DeadCheck
global variablePackCount
global s4tEnabled, s4tSilent, s4t3Dmnd, s4t4Dmnd, s4t1Star, s4tGholdengo, s4tWP, s4tWPMinCards, s4tDiscordWebhookURL, s4tDiscordUserId, s4tSendAccountXml
global avgtotalSeconds
global verboseLogging := false  ; Set to true only for debugging

; ===== NEW GLOBAL VARIABLES FOR ENHANCED INJECTION SYSTEM =====
global injectSortMethod := "ModifiedAsc"  ; Default sort method (oldest accounts first)
global injectMinPacks := 0       ; Minimum pack count for injection (0 = no minimum)
global injectMaxPacks := 39     ; Maximum pack count for injection (default for regular "Inject")
global injectVariable := 15      ; User-defined pack count for "Inject Variable"
global injectMaxValue := 39      ; User input for max value (Inject/Inject long)
global injectMinValue := 35      ; User input for min value (Inject for Reroll)
global injectRange := ""         ; User input for range (Inject Range)
global waitForEligibleAccounts, maxWaitHours
global isWaitingForAccounts := false
global lastAccountCheckTime := 0

global accountOpenPacks, accountFileName, accountFileNameOrig, accountFileNameTmp, accountHasPackInfo, ocrSuccess, packsInPool, packsThisRun, aminutes, aseconds, rerolls, rerollStartTime, maxAccountPackNum, cantOpenMorePacks

cantOpenMorePacks := 0
maxAccountPackNum := 40
aminutes := 0
aseconds := 0

global beginnerMissionsDone, soloBattleMissionDone, intermediateMissionsDone, specialMissionsDone, resetSpecialMissionsDone, accountHasPackInTesting

beginnerMissionsDone := 0
soloBattleMissionDone := 0
intermediateMissionsDone := 0
specialMissionsDone := 0
resetSpecialMissionsDone := 0
accountHasPackInTesting := 0

global rerolls_local, rerollStartTime_local

rerolls_local := 0
rerollStartTime_local := A_TickCount

global dbg_bbox, dbg_bboxNpause, dbg_bbox_click

dbg_bbox :=0
dbg_bboxNpause :=0
dbg_bbox_click :=0


scriptName := StrReplace(A_ScriptName, ".ahk")
winTitle := scriptName
foundGP := false
injectMethod := false
pauseToggle := false
showStatus := true
friended := false
dateChange := false
jsonFileName := A_ScriptDir . "\..\json\Packs.json"
IniRead, FriendID, %A_ScriptDir%\..\Settings.ini, UserSettings, FriendID
IniRead, waitTime, %A_ScriptDir%\..\Settings.ini, UserSettings, waitTime, 5
IniRead, Delay, %A_ScriptDir%\..\Settings.ini, UserSettings, Delay, 250
IniRead, folderPath, %A_ScriptDir%\..\Settings.ini, UserSettings, folderPath, C:\Program Files\Netease
IniRead, Columns, %A_ScriptDir%\..\Settings.ini, UserSettings, Columns, 5
IniRead, godPack, %A_ScriptDir%\..\Settings.ini, UserSettings, godPack, Continue
IniRead, Instances, %A_ScriptDir%\..\Settings.ini, UserSettings, Instances, 1
IniRead, defaultLanguage, %A_ScriptDir%\..\Settings.ini, UserSettings, defaultLanguage, Scale125
IniRead, rowGap, %A_ScriptDir%\..\Settings.ini, UserSettings, rowGap, 100
IniRead, SelectedMonitorIndex, %A_ScriptDir%\..\Settings.ini, UserSettings, SelectedMonitorIndex, 1
IniRead, swipeSpeed, %A_ScriptDir%\..\Settings.ini, UserSettings, swipeSpeed, 300
IniRead, deleteMethod, %A_ScriptDir%\..\Settings.ini, UserSettings, deleteMethod, 3 Pack
IniRead, runMain, %A_ScriptDir%\..\Settings.ini, UserSettings, runMain, 1
IniRead, Mains, %A_ScriptDir%\..\Settings.ini, UserSettings, Mains, 1
IniRead, AccountName, %A_ScriptDir%\..\Settings.ini, UserSettings, AccountName, ""
IniRead, nukeAccount, %A_ScriptDir%\..\Settings.ini, UserSettings, nukeAccount, 0
IniRead, packMethod, %A_ScriptDir%\..\Settings.ini, UserSettings, packMethod, 0
IniRead, CheckShinyPackOnly, %A_ScriptDir%\..\Settings.ini, UserSettings, CheckShinyPackOnly, 0
IniRead, TrainerCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, TrainerCheck, 0
IniRead, FullArtCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, FullArtCheck, 0
IniRead, RainbowCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, RainbowCheck, 0
IniRead, ShinyCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, ShinyCheck, 0
IniRead, CrownCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, CrownCheck, 0
IniRead, ImmersiveCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, ImmersiveCheck, 0
IniRead, InvalidCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, InvalidCheck, 0
IniRead, PseudoGodPack, %A_ScriptDir%\..\Settings.ini, UserSettings, PseudoGodPack, 0
IniRead, minStars, %A_ScriptDir%\..\Settings.ini, UserSettings, minStars, 0
IniRead, minStarsShiny, %A_ScriptDir%\..\Settings.ini, UserSettings, minStarsShiny, 0
IniRead, Solgaleo, %A_ScriptDir%\..\Settings.ini, UserSettings, Solgaleo, 1
IniRead, Lunala, %A_ScriptDir%\..\Settings.ini, UserSettings, Lunala, 1
IniRead, Shining, %A_ScriptDir%\..\Settings.ini, UserSettings, Shining, 0
IniRead, Arceus, %A_ScriptDir%\..\Settings.ini, UserSettings, Arceus, 0
IniRead, Dialga, %A_ScriptDir%\..\Settings.ini, UserSettings, Dialga, 0
IniRead, Palkia, %A_ScriptDir%\..\Settings.ini, UserSettings, Palkia, 0
IniRead, Mewtwo, %A_ScriptDir%\..\Settings.ini, UserSettings, Mewtwo, 0
IniRead, Charizard, %A_ScriptDir%\..\Settings.ini, UserSettings, Charizard, 0
IniRead, Pikachu, %A_ScriptDir%\..\Settings.ini, UserSettings, Pikachu, 0
IniRead, Mew, %A_ScriptDir%\..\Settings.ini, UserSettings, Mew, 0
IniRead, slowMotion, %A_ScriptDir%\..\Settings.ini, UserSettings, slowMotion, 0
IniRead, DeadCheck, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck, 0
IniRead, ocrLanguage, %A_ScriptDir%\..\Settings.ini, UserSettings, ocrLanguage, en
IniRead, variablePackCount, %A_ScriptDir%\..\Settings.ini, UserSettings, variablePackCount, 15
IniRead, injectSortMethod, %A_ScriptDir%\..\Settings.ini, UserSettings, injectSortMethod, ModifiedAsc
IniRead, injectVariable, %A_ScriptDir%\..\Settings.ini, UserSettings, variablePackCount, 15
IniRead, waitForEligibleAccounts, %A_ScriptDir%\..\Settings.ini, UserSettings, waitForEligibleAccounts, 1
IniRead, maxWaitHours, %A_ScriptDir%\..\Settings.ini, UserSettings, maxWaitHours, 24

IniRead, minStarsA1Mewtwo, %A_ScriptDir%\..\Settings.ini, UserSettings, minStarsA1Mewtwo, 0
IniRead, minStarsA1Charizard, %A_ScriptDir%\..\Settings.ini, UserSettings, minStarsA1Charizard, 0
IniRead, minStarsA1Pikachu, %A_ScriptDir%\..\Settings.ini, UserSettings, minStarsA1Pikachu, 0
IniRead, minStarsA1a, %A_ScriptDir%\..\Settings.ini, UserSettings, minStarsA1a, 0
IniRead, minStarsA2Dialga, %A_ScriptDir%\..\Settings.ini, UserSettings, minStarsA2Dialga, 0
IniRead, minStarsA2Palkia, %A_ScriptDir%\..\Settings.ini, UserSettings, minStarsA2Palkia, 0
IniRead, minStarsA2a, %A_ScriptDir%\..\Settings.ini, UserSettings, minStarsA2a, 0
IniRead, minStarsA2b, %A_ScriptDir%\..\Settings.ini, UserSettings, minStarsA2b, 0
IniRead, minStarsA3Solgaleo, %A_ScriptDir%\..\Settings.ini, UserSettings, minStarsA3Solgaleo, 0
IniRead, minStarsA3Lunala, %A_ScriptDir%\..\Settings.ini, UserSettings, minStarsA3Lunala, 0

IniRead, s4tEnabled, %A_ScriptDir%\..\Settings.ini, UserSettings, s4tEnabled, 0
IniRead, s4tSilent, %A_ScriptDir%\..\Settings.ini, UserSettings, s4tSilent, 1
IniRead, s4t3Dmnd, %A_ScriptDir%\..\Settings.ini, UserSettings, s4t3Dmnd, 0
IniRead, s4t4Dmnd, %A_ScriptDir%\..\Settings.ini, UserSettings, s4t4Dmnd, 0
IniRead, s4t1Star, %A_ScriptDir%\..\Settings.ini, UserSettings, s4t1Star, 0
IniRead, s4tGholdengo, %A_ScriptDir%\..\Settings.ini, UserSettings, s4tGholdengo, 0
IniRead, s4tWP, %A_ScriptDir%\..\Settings.ini, UserSettings, s4tWP, 0
IniRead, s4tWPMinCards, %A_ScriptDir%\..\Settings.ini, UserSettings, s4tWPMinCards, 1
IniRead, s4tDiscordWebhookURL, %A_ScriptDir%\..\Settings.ini, UserSettings, s4tDiscordWebhookURL
IniRead, s4tDiscordUserId, %A_ScriptDir%\..\Settings.ini, UserSettings, s4tDiscordUserId
IniRead, s4tSendAccountXml, %A_ScriptDir%\..\Settings.ini, UserSettings, s4tSendAccountXml, 1

IniRead, rerolls, %A_ScriptDir%\%scriptName%.ini, Metrics, rerolls, 0
IniRead, rerollStartTime, %A_ScriptDir%\%scriptName%.ini, Metrics, rerollStartTime, 0

IniRead, injectMaxValue, %A_ScriptDir%\..\Settings.ini, UserSettings, injectMaxValue, 39
IniRead, injectMinValue, %A_ScriptDir%\..\Settings.ini, UserSettings, injectMinValue, 35
IniRead, injectRange, %A_ScriptDir%\..\Settings.ini, UserSettings, injectRange, ""

; Force proper initialization of rerollStartTime
if (rerollStartTime = 0 || rerollStartTime = "ERROR") {
    rerollStartTime := A_TickCount
    IniWrite, %rerollStartTime%, %A_ScriptDir%\%scriptName%.ini, Metrics, rerollStartTime
}

pokemonList := ["Mewtwo", "Charizard", "Pikachu", "Mew", "Dialga", "Palkia", "Arceus", "Shining", "Solgaleo", "Lunala"]

pokemonList := ["Mewtwo", "Charizard", "Pikachu", "Mew", "Dialga", "Palkia", "Arceus", "Shining", "Solgaleo", "Lunala"]
shinyPacks := {"Shining": 1, "Solgaleo": 1, "Lunala": 1}

packArray := []  ; Initialize an empty array

Loop, % pokemonList.MaxIndex()  ; Loop through the array
{
    pokemon := pokemonList[A_Index]  ; Get the variable name as a string
    if (%pokemon%)  ; Dereference the variable using %pokemon%
        packArray.push(pokemon)  ; Add the name to packArray
}

changeDate := getChangeDateTime() ; get server reset time

if(heartBeat)
    IniWrite, 1, %A_ScriptDir%\..\HeartBeat.ini, HeartBeat, Instance%scriptName%

SetTimer, RefreshAccountLists, 3600000  ; 3,600,000 ms = 1 hour

; Set default rowGap if not defined
if (!rowGap)
    rowGap := 100

Sleep, % scriptName * 1000

; Validate scaleParam early
if (InStr(defaultLanguage, "100")) {
    scaleParam := 287
} else {
    scaleParam := 277
}
DirectlyPositionWindow()
Sleep, 1000

ConnectAdb(folderPath)

resetWindows()
MaxRetries := 10
RetryCount := 0
Loop {
    try {
        WinGetPos, x, y, Width, Height, %winTitle%
        sleep, 2000
        ;Winset, Alwaysontop, On, %winTitle%
        OwnerWND := WinExist(winTitle)
        x4 := x + 5
        y4 := y +535
        buttonWidth := 50
        if (scaleParam = 287)
            buttonWidth := buttonWidth + 5

        Gui, New, +Owner%OwnerWND% -AlwaysOnTop +ToolWindow -Caption +LastFound -DPIScale 
        Gui, Default
        Gui, Margin, 4, 4  ; Set margin for the GUI
        Gui, Font, s5 cGray Norm Bold, Segoe UI  ; Normal font for input labels
        Gui, Add, Button, % "x" . (buttonWidth * 0) . " y0 w" . buttonWidth . " h25 gReloadScript", Reload  (Shift+F5)
        Gui, Add, Button, % "x" . (buttonWidth * 1) . " y0 w" . buttonWidth . " h25 gPauseScript", Pause (Shift+F6)
        Gui, Add, Button, % "x" . (buttonWidth * 2) . " y0 w" . buttonWidth . " h25 gResumeScript", Resume (Shift+F6)
        Gui, Add, Button, % "x" . (buttonWidth * 3) . " y0 w" . buttonWidth . " h25 gStopScript", Stop (Shift+F7)
		;if(winTitle=1)
        Gui, Add, Button, % "x" . (buttonWidth * 4) . " y0 w" . buttonWidth . " h25 gDevMode", Dev Mode (Shift+F8)
        DllCall("SetWindowPos", "Ptr", WinExist(), "Ptr", 1  ; HWND_BOTTOM
                , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)  ; SWP_NOSIZE, SWP_NOMOVE, SWP_NOACTIVATE
        Gui, Show, NoActivate x%x4% y%y4%  w275 h30
        break
    }
    catch {
        RetryCount++
        if (RetryCount >= MaxRetries) {
            CreateStatusMessage("Failed to create button GUI.",,,, false)
            break
        }
        Sleep, 1000
    }
    Delay(1)
    CreateStatusMessage("Trying to create button GUI...")
}

if (!godPack)
    godPack = 1
else if (godPack = "Close")
    godPack = 1
else if (godPack = "Pause")
    godPack = 2
if (godPack = "Continue")
    godPack = 3

if (!setSpeed)
    setSpeed = 1
if (setSpeed = "2x")
    setSpeed := 1
else if (setSpeed = "1x/2x")
    setSpeed := 2
else if (setSpeed = "1x/3x")
    setSpeed := 3

setSpeed := 3 ;always 1x/3x

if(InStr(deleteMethod, "Inject"))
    injectMethod := true

initializeAdbShell()

createAccountList(scriptName)

if(injectMethod) {
    loadedAccount := loadAccount()
    nukeAccount := false
}

clearMissionCache()

if(!injectMethod || !loadedAccount)
    restartGameInstance("Initializing bot...", false)

pToken := Gdip_Startup()
packsInPool := 0
packsThisRun := 0

; Define default swipe params.
adbSwipeX1 := Round(35 / 277 * 535)
adbSwipeX2 := Round(267 / 277 * 535)
adbSwipeY := Round((327 - 44) / 489 * 960)
global adbSwipeParams := adbSwipeX1 . " " . adbSwipeY . " " . adbSwipeX2 . " " . adbSwipeY . " " . swipeSpeed

if(DeadCheck = 1){
    IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
}
if(DeadCheck = 1 && !injectMethod){
    friended:= true
	menuDeleteStart()
	Reload
} else {
	;in injection mode, we don't need to reload
    Loop {
		clearMissionCache()
        Randmax := packArray.Length()
        Random, rand, 1, Randmax
        openPack := packArray[rand]
        friended := false
        IniWrite, 1, %A_ScriptDir%\..\HeartBeat.ini, HeartBeat, Instance%scriptName%

		changeDate := getChangeDateTime() ; get server reset time

		if (avgtotalSeconds > 0 ) {
			StartTime := changeDate
			StartTime += -(1.5*avgtotalSeconds), Seconds
			EndTime := changeDate
			EndTime += (1.5*avgtotalSeconds), Seconds
		} else {
			StartTime := changeDate
			StartTime += -10, minutes
			EndTime := changeDate
			EndTime += 5, minutes
		}

		StartCurrentTimeDiff := A_Now
		EnvSub, StartCurrentTimeDiff, %StartTime%, Seconds
		EndCurrentTimeDiff := A_Now
		EnvSub, EndCurrentTimeDiff, %EndTime%, Seconds

		dateChange := false

		while (StartCurrentTimeDiff > 0 && EndCurrentTimeDiff < 0) {
            CreateStatusMessage("I need a break... Sleeping until " . EndTime ,,,, false)
            dateChange := true
            Sleep, 5000

			StartCurrentTimeDiff := A_Now
			EnvSub, StartCurrentTimeDiff, %StartTime%, Seconds
			EndCurrentTimeDiff := A_Now
			EnvSub, EndCurrentTimeDiff, %EndTime%, Seconds
		}


        if(dateChange)
	   ; This resets the counter for liking showcase to 5
	     IniWrite, 5, %A_ScriptDir%\..\Settings.ini, UserSettings, showcaseLikes ;###✔️✔️

	    ;always call it. it will updates the list every 1h
             createAccountList(scriptName)

        FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
        if(setSpeed = 3)
            FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
        else
            FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
        Delay(1)
        adbClick_wbb(41, 296)
        Delay(1)

		cantOpenMorePacks := 0
		packsInPool := 0
		packsThisRun := 0
        keepAccount := false

        ; BallCity 2025.02.21 - Keep track of additional metrics
        now := A_NowUTC
        IniWrite, %now%, %A_ScriptDir%\%scriptName%.ini, Metrics, LastStartTimeUTC
        EnvSub, now, 1970, seconds
        IniWrite, %now%, %A_ScriptDir%\%scriptName%.ini, Metrics, LastStartEpoch

        if(!injectMethod || !loadedAccount) {
            DoTutorial()
			accountOpenPacks := 0 ;tutorial packs don't count
		}
		
        ;    SquallTCGP 2025.03.12 -     Adding the delete method 5 Pack (Fast) to the wonder pick check.
        if(deleteMethod = "5 Pack" || deleteMethod = "5 Pack (Fast)" || deleteMethod = "13 Pack" || (injectMethod && !loadedAccount))
            wonderPicked := DoWonderPick()
friendsAdded := AddFriends()
        SelectPack("First")
		if(cantOpenMorePacks)
			Goto, MidOfRun
			
		PackOpening()
		if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
			Goto, MidOfRun

        if(packMethod) {
            friendsAdded := AddFriends(true)
            SelectPack()
			if(cantOpenMorePacks)
				Goto, MidOfRun
        }

        PackOpening()
		if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
			Goto, MidOfRun

        if(!injectMethod || !loadedAccount)
            HourglassOpening() ;deletemethod check in here at the start

        if(wonderPicked && !loadedAccount) {
            ; SquallTCGP 2025.03.12 - Added a check to not add friends if the delete method is 5 Pack (Fast). When using this method (5 Pack (Fast)),
            ;                         it goes to the social menu and clicks the home button to exit (instead of opening all packs directly)
            ;                         just to get around the checking for a level after opening a pack. This change is made based on the
            ;                         5p-no delete community mod created by DietPepperPhD in the discord server.

            if(deleteMethod = "5 Pack" || packMethod) {
                friendsAdded := AddFriends(true)
				SelectPack("HGPack")
				PackOpening()
            } else {
				HourglassOpening(true)
            }

            if(packMethod) {
                friendsAdded := AddFriends(true)
                SelectPack("HGPack")
                PackOpening()
            }
            else {
                HourglassOpening(true)
            }
		}

MidOfRun:

if(!(!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
	if(!beginnerMissionsDone && (deleteMethod = "13 Pack" || (injectMethod && !loadedAccount) || (deleteMethod = "Inject long" && loadedAccount))) {
		
		; Special handling for Inject long
		if (deleteMethod = "Inject long" && loadedAccount) {
			; Check if setting exists, if not, use default (false/0)
			IniRead, skipMissions, %A_ScriptDir%\..\Settings.ini, UserSettings, skipMissionsInjectLong, 0
			
			; If user has explicitly set the setting to 1, skip missions
			if (skipMissions == 1) {
				LogToFile("Skipping missions in Inject long mode (user setting)")
				beginnerMissionsDone := 1
				if(injectMethod && loadedAccount)
					setMetaData()
				Goto, EndOfRun
			}
			
			; Otherwise use a simplified mission approach
			LogToFile("Using simplified mission approach for Inject long mode")
			GoToMain()
			
			; Try a direct approach to check if missions are already done
			missionCheck := HomeAndMission(0, true) ; Try with second mission flag
			
			; If missions not completed, try a simplified direct path
			if(!beginnerMissionsDone) {
				; Try to access packs directly and see if that works
				SelectPack("HGPack")
				if(cantOpenMorePacks)
					Goto, EndOfRun
					
				PackOpening()
				if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
					Goto, EndOfRun
					
				; Mark missions as done to avoid getting stuck in loops
				beginnerMissionsDone := 1
				if(injectMethod && loadedAccount)
					setMetaData()
			}
			
			; Skip the rest of the regular mission flow
			Goto, EndOfRun
		}
		
		;-----------------------------
		;if error during mission collection, try commenting the first line and uncommenting the second
		HomeAndMission()
		;HomeAndMission(0,true)
		;-----------------------------
		if(beginnerMissionsDone)
			Goto, EndOfRun

		SelectPack("HGPack")
		if(cantOpenMorePacks)
			Goto, EndOfRun
			
		PackOpening() ;6
		if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
			Goto, EndOfRun
			
		HourglassOpening(true) ;7
		if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
			Goto, EndOfRun

		HomeAndMission()
		if(beginnerMissionsDone)
			Goto, EndOfRun
			
		SelectPack("HGPack")
		if(cantOpenMorePacks)
			Goto, EndOfRun
		PackOpening() ;8
		if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
			Goto, EndOfRun
			
		HourglassOpening(true) ;9
		if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
			Goto, EndOfRun

		HomeAndMission()
		if(beginnerMissionsDone)
			Goto, EndOfRun
			
		SelectPack("HGPack")
		if(cantOpenMorePacks)
			Goto, EndOfRun
		PackOpening() ;10
		if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
			Goto, EndOfRun
			
		HourglassOpening(true) ;11
		if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
			Goto, EndOfRun
		
		if(injectMethod && loadedAccount && deleteMethod = "Inject long" ){				
			HomeAndMission()
			if(beginnerMissionsDone)
				Goto, EndOfRun
				
			;TODO click on complete all missions and open packs until not nough items
			;TODO return all missions done and open packs until not enough items
			
			SelectPack("HGPack")
			if(cantOpenMorePacks)
				Goto, EndOfRun
			PackOpening() ;12?
			if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
				Goto, EndOfRun
			
			HourglassOpening(true) ;13?
			if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
				Goto, EndOfRun
		}
		
		HomeAndMission(1)
		SelectPack("HGPack")
		if(cantOpenMorePacks)
			Goto, EndOfRun
		PackOpening() ;12
		if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
			Goto, EndOfRun
		
		HomeAndMission(1)
		SelectPack("HGPack")
		if(cantOpenMorePacks)
			Goto, EndOfRun
		PackOpening() ;13
		if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
			Goto, EndOfRun
			
		beginnerMissionsDone := 1
		if(injectMethod && loadedAccount)
			setMetaData()
	}

EndOfRun:
				
		if(!(!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum)) {
			; For Special Missions 2025
			IniRead, claimSpecialMissions, %A_ScriptDir%\..\Settings.ini, UserSettings, claimSpecialMissions, 0
			if(claimSpecialMissions = 1 && !specialMissionsDone)  ; Only run if checkbox is checked (value = 1)
			{   
				GoToMain()
				HomeAndMission(1)
				GetEventRewards(true) ;collects all the Special mission hourglass
				specialMissionsDone := 1
				cantOpenMorePacks := 0
				if(injectMethod && loadedAccount)
					setMetaData()
			}
			
			IniRead, spendHourGlass, %A_ScriptDir%\..\Settings.ini, UserSettings, spendHourGlass, 0
			if(spendHourGlass = 1)  ; Only run if checkbox is checked (value = 1)
			{
				SpendAllHourglass()
			}
		}

		AppendToJsonFile(packsThisRun)

; Remove friends before loading next account if using any inject method
if (injectMethod && friended && !keepAccount) {
    RemoveFriends()
}

; BallCity 2025.02.21 - Keep track of additional metrics
now := A_NowUTC
IniWrite, %now%, %A_ScriptDir%\%scriptName%.ini, Metrics, LastEndTimeUTC
EnvSub, now, 1970, seconds
IniWrite, %now%, %A_ScriptDir%\%scriptName%.ini, Metrics, LastEndEpoch

; DIRECT CALCULATION - Don't use function
rerolls++
rerolls_local++
IniWrite, %rerolls%, %A_ScriptDir%\%scriptName%.ini, Metrics, rerolls

totalSeconds := Round((A_TickCount - rerollStartTime) / 1000) ; Total time in seconds
totalSeconds_local := Round((A_TickCount - rerollStartTime_local) / 1000) 
avgtotalSeconds := Round(totalSeconds_local / rerolls_local) ; Average time per run in seconds
aminutes := Floor(avgtotalSeconds / 60) ; Average minutes
aseconds := Mod(avgtotalSeconds, 60) ; Average remaining seconds
mminutes := Floor(totalSeconds / 60) ; Total minutes
sseconds := Mod(totalSeconds, 60) ; Total remaining seconds

; Display the times
CreateStatusMessage("Avg: " . aminutes . "m " . aseconds . "s | Runs: " . rerolls . " | Account Packs " . accountOpenPacks, "AvgRuns", 0, 605, false, true)

; Log to file
LogToFile("Packs: " . packsThisRun . " | Total time: " . mminutes . "m " . sseconds . "s | Avg: " . aminutes . "m " . aseconds . "s | Runs: " . rerolls)

        if ((!injectMethod || !loadedAccount) && (!nukeAccount || keepAccount)) {
            ; Doing the following because:
            ; - not using the inject method
            ; - or using the inject method but an hasn't been loaded
            ; - and...
            ; - not using menu delete account
            ; - or the current account opened a desirable pack and shouldn't be deleted
            saveAccount("All")
			
			beginnerMissionsDone := 0
			soloBattleMissionDone := 0
			intermediateMissionsDone := 0
			specialMissionsDone := 0
			accountHasPackInTesting := 0

			if(!injectMethod)
				restartGameInstance("New Run", false)
        } else {
            ; Reached here because:
            ; - using the inject method
            ; - or the account was deleted because no desirable packs were found during the last run

            if (stopToggle) {
                CreateStatusMessage("Stopping...",,,, false)
				;TODO force stop, remove account
                ExitApp
            }
			if(!injectMethod)
				CreateStatusMessage("New Run",,,, false)
        }
		
if (stopToggle) {
    CreateStatusMessage("Stopping...",,,, false)
    ;TODO force stop, remove account
    ExitApp
}
if (injectMethod) ; try loading new account
    loadedAccount := loadAccount()
if (injectMethod && !loadedAccount) {
    ; Skip waiting if feature is disabled
    if (!waitForEligibleAccounts) {
        DeadCheck := 0
        restartGameInstance("Finished injecting. New Run", false)
        Continue
    }
    
    ; If not already waiting, log the start of waiting
    if (!isWaitingForAccounts) {
        isWaitingForAccounts := true
        lastAccountCheckTime := A_TickCount
        LogToFile("No eligible accounts for injection. Entering wait mode...")
        CreateStatusMessage("No accounts to inject. Waiting for eligible accounts...",,,, false)
    }
    
    ; Calculate how long we've been waiting
    waitTimeElapsed := (A_TickCount - lastAccountCheckTime) / 1000 / 60  ; in minutes
    
    ; Check if maximum wait time has been exceeded
    if (maxWaitHours > 0 && waitTimeElapsed >= (maxWaitHours * 60)) {
        LogToFile("Maximum wait time of " . maxWaitHours . " hours exceeded. Creating new account.")
        CreateStatusMessage("Max wait time reached. Creating new account...",,,, false)
        isWaitingForAccounts := false
        DeadCheck := 0
        restartGameInstance("Finished injecting. New Run", false)
        Continue
    }
    
    ; Check for accounts hourly
    if (waitTimeElapsed >= 60) {
        LogToFile("Checking for eligible accounts after waiting " . Round(waitTimeElapsed) . " minutes")
        CreateStatusMessage("Checking for eligible accounts...",,,, false)
        
        ; Regenerate account lists
        createAccountList(scriptName)
        
        ; Try loading an account
        potentialAccount := loadAccount()
        
        if (potentialAccount) {
            ; Found an account, exit waiting mode
            isWaitingForAccounts := false
            loadedAccount := potentialAccount
            LogToFile("Found eligible account after waiting. Continuing with injection.")
            CreateStatusMessage("Found eligible account. Continuing with injection...",,,, false)
        } else {
            ; Reset timer for next hourly check
            lastAccountCheckTime := A_TickCount
            LogToFile("Still no eligible accounts. Continuing to wait...")
            CreateStatusMessage("No eligible accounts found. Continuing to wait...",,,, false)
        }
    } else {
        ; Display waiting status with countdown to next check
        timeToNextCheck := 60 - Round(waitTimeElapsed)
        CreateStatusMessage("Waiting for eligible accounts. Next check in " . timeToNextCheck . " minutes.",,,, false)
        Sleep, 30000  ; Sleep for 30 seconds before updating status
    }
    
    ; Skip the rest of the loop iteration
    Continue
}
    }
}
return

HomeAndMission(homeonly := 0, completeSecondMission=false) {
	Sleep, 250
	Leveled := 0
	
	; Add a direct exit for "Inject long" if appropriate
	if (deleteMethod = "Inject long" && loadedAccount) {
		; Check if setting exists, if not, use default (false/0)
		IniRead, skipMissions, %A_ScriptDir%\..\Settings.ini, UserSettings, skipMissionsInjectLong, 0
		
		; Only skip if explicitly enabled
		if (skipMissions == 1) {
			LogToFile("Skipping missions in Inject long mode (user setting)")
			return Leveled
		}
		
		; Otherwise, we'll try a simplified approach with better error handling
		LogToFile("Using modified mission approach for Inject long mode")
	}
	
	Loop {
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			if(!Leveled)
				Leveled := LevelUp()
			else
				LevelUp()
				
			; This is where the bot gets stuck - enhance the exit condition
			FindImageAndClick(191, 393, 211, 411, , "Shop", 146, 470, 500, 1)
			
			if(FindImageAndClick(120, 188, 140, 208, , "Album", 79, 86 , 500, 1)){
				FindImageAndClick(191, 393, 211, 411, , "Shop", 142, 488, 500)
				break
			}
			failSafeTime := (A_TickCount - failSafe) // 1000
			
			; Add additional exit condition for stuck state in Inject long mode
			if (failSafeTime > 15 && deleteMethod = "Inject long" && loadedAccount) {
				LogToFile("Potential stuck state in HomeAndMission for Inject long - forcing exit")
				return Leveled
			}
		}
		
		if(!homeonly){
			FindImageAndClick(191, 393, 211, 411, , "Shop", 142, 488, 500)
			FindImageAndClick(180, 498, 190, 508, , "Mission_dino1", 261, 478, 1000)
			
			wonderpicked := 0
			failSafe := A_TickCount
			failSafeTime := 0
			Loop {
				Delay(1)
				if (completeSecondMission){
					adbClick_wbb(150, 390)
				}
				else {
					adbClick_wbb(150, 286)
				}
				Delay(1)
				
				if(FindOrLoseImage(136, 158, 156, 190, , "Mission_dino2", 0, failSafeTime))
					break
				
				if(FindOrLoseImage(108, 180, 177, 208, , "1solobattlemission", 0, failSafeTime)) {
					beginnerMissionsDone := 1
					if(injectMethod && loadedAccount)
						setMetaData()
					
					return
				}  
				
				if (FindOrLoseImage(150, 159, 176, 206, , "missionwonder", 0, failSafeTime)){
					adbClick_wbb(141, 396) ; click try it and go to wonderpick page
					DoWonderPickOnly()
					wonderpicked := 1
					break
				}
				
				failSafeTime := (A_TickCount - failSafe) // 1000
				
				; Add exit condition for stuck state in Inject long mode
				if (failSafeTime > 15 && deleteMethod = "Inject long" && loadedAccount) {
					LogToFile("Potential stuck state in mission navigation for Inject long - forcing exit")
					return Leveled
				}
			}
			if(!wonderpicked)
				break
			
		} else 
			break
	}

	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		Delay(1)
		adbClick_wbb(139, 424) ;clicks complete mission
		Delay(1)
		clickButton := FindOrLoseImage(145, 447, 258, 480, 80, "Button", 0, failSafeTime)
		if(clickButton) {
			adbClick_wbb(110, 369)
		}
		else if(FindOrLoseImage(191, 393, 211, 411, , "Shop", 1, failSafeTime)) {
			adbInputEvent("111") ;send ESC
			sleep, 1500
		}
		else
			break
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for WonderPick. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for WonderPick. " . failSafeTime "/45 seconds")
		
		; Add exit condition for stuck state in Inject long mode
		if (failSafeTime > 15 && deleteMethod = "Inject long" && loadedAccount) {
			LogToFile("Potential stuck state in mission completion for Inject long - forcing exit")
			return Leveled
		}
	}
	return Leveled
}

clearMissionCache() {
    adbShell.StdIn.WriteLine("rm /data/data/jp.pokemon.pokemontcgp/files/UserPreferences/v1/MissionUserPrefs")
    waitadb()
	Sleep, 500
	;TODO delete all user preferences?
}
RemoveFriends() {
    global friendIDs, friended

	if(!friendIDs && friendID = "") {
		friended := false
		return false
	}
	
	packsInPool := 0 ; if friends are removed, clear the pool

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbClick_wbb(143, 518)
        if(FindOrLoseImage(120, 500, 155, 530, , "Social", 0, failSafeTime))
            break
        else if(FindOrLoseImage(175, 165, 255, 235, , "Hourglass3", 0)) {
            Delay(3)
            adbClick_wbb(146, 441) ; 146 440
            Delay(3)
            adbClick_wbb(146, 441)
            Delay(3)
            adbClick_wbb(146, 441)
            Delay(3)

            FindImageAndClick(98, 184, 151, 224, , "Hourglass1", 168, 438, 500, 5) ;stop at hourglasses tutorial 2
            Delay(1)

            adbClick_wbb(203, 436) ; 203 436
        }
        Sleep, 500
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Social`n(" . failSafeTime . "/90 seconds)")
    }
    FindImageAndClick(226, 100, 270, 135, , "Add", 38, 460, 500)
    FindImageAndClick(205, 430, 255, 475, , "Search", 240, 120, 1500)
    FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
    if(!friendIDs) {
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            adbInput(FriendID)
            Delay(1)
            if(FindOrLoseImage(205, 430, 255, 475, , "Search", 0, failSafeTime)) {
                FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
                EraseInput(1,1)
            } else if(FindOrLoseImage(205, 430, 255, 475, , "Search2", 0, failSafeTime)) {
                break
            }
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for AddFriends1`n(" . failSafeTime . "/45 seconds)")
        }
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            adbClick_wbb(232, 453)
            if(FindOrLoseImage(165, 250, 190, 275, , "Send", 0, failSafeTime)) {
                break
            } else if(FindOrLoseImage(165, 250, 190, 275, , "Accepted", 0, failSafeTime)) {
                FindImageAndClick(135, 355, 160, 385, , "Remove", 193, 258, 500)
                FindImageAndClick(165, 250, 190, 275, , "Send", 200, 372, 2000)
                break
            } else if(FindOrLoseImage(165, 240, 255, 270, , "Withdraw", 0, failSafeTime)) {
                FindImageAndClick(165, 250, 190, 275, , "Send", 243, 258, 2000)
                break
            }
            Sleep, 750
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for AddFriends2`n(" . failSafeTime . "/45 seconds)")
        }
        n := 1 ;how many friends added needed to return number for remove friends
    } else {
        ;randomize friend id list to not back up mains if running in groups since they'll be sent in a random order.
        n := friendIDs.MaxIndex()
        Loop % n
        {
            i := n - A_Index + 1
            Random, j, 1, %i%
            ; Force string assignment with quotes
            temp := friendIDs[i] . ""  ; Concatenation ensures string type
            friendIDs[i] := friendIDs[j] . ""
            friendIDs[j] := temp . ""
        }
        for index, value in friendIDs {
            if (StrLen(value) != 16) {
                ; Wrong id value
                continue
            }
            failSafe := A_TickCount
            failSafeTime := 0
            Loop {
                adbInput(value)
                Delay(1)
                if(FindOrLoseImage(205, 430, 255, 475, , "Search", 0, failSafeTime)) {
                    FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
                    EraseInput()
                } else if(FindOrLoseImage(205, 430, 255, 475, , "Search2", 0, failSafeTime)) {
                    break
                }
                failSafeTime := (A_TickCount - failSafe) // 1000
                CreateStatusMessage("Waiting for AddFriends3`n(" . failSafeTime . "/45 seconds)")
            }
            failSafe := A_TickCount
            failSafeTime := 0
            Loop {
                adbClick_wbb(232, 453)
                if(FindOrLoseImage(165, 250, 190, 275, , "Send", 0, failSafeTime)) {
                    break
                } else if(FindOrLoseImage(165, 250, 190, 275, , "Accepted", 0, failSafeTime)) {
                    FindImageAndClick(135, 355, 160, 385, , "Remove", 193, 258, 500)
                    FindImageAndClick(165, 250, 190, 275, , "Send", 200, 372, 500)
                    break
                } else if(FindOrLoseImage(165, 240, 255, 270, , "Withdraw", 0, failSafeTime)) {
                    FindImageAndClick(165, 250, 190, 275, , "Send", 243, 258, 2000)
                    break
                }
                Sleep, 750
                failSafeTime := (A_TickCount - failSafe) // 1000
                CreateStatusMessage("Waiting for AddFriends4`n(" . failSafeTime . "/45 seconds)")
            }
            if(index != friendIDs.maxIndex()) {
                FindImageAndClick(205, 430, 255, 475, , "Search2", 150, 50, 1500)
                FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
                EraseInput(index, n)
            }
        }
    }
    friended := false
}

TradeTutorial() {
    if(FindOrLoseImage(100, 120, 175, 145, , "Trade", 0)) {
        FindImageAndClick(15, 455, 40, 475, , "Add2", 188, 449)
        Sleep, 1000
        FindImageAndClick(226, 100, 270, 135, , "Add", 38, 460, 500)
    }
    Delay(1)
}

AddFriends(renew := false, getFC := false) {
    global FriendID, friendIds, waitTime, friendCode, scriptName
    IniWrite, 1, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
    friendIDs := ReadFile("ids")
    count := 0
    friended := true
    failSafe := A_TickCount
    failSafeTime := 0

	if(!getFC && !friendIDs && friendID = "")
		return false

    Loop {
        if(count > waitTime) {
            break
        }
        if(count = 0) {
            failSafe := A_TickCount
            failSafeTime := 0
            Loop {
                adbClick_wbb(143, 518)
                Delay(1)
                if(FindOrLoseImage(120, 500, 155, 530, , "Social", 0, failSafeTime)) {
                    break
                }
                else if(!renew && !getFC) {
                    clickButton := FindOrLoseImage(75, 340, 195, 530, 80, "Button", 0)
                    if(clickButton) {
                        StringSplit, pos, clickButton, `,  ; Split at ", "
                        if (scaleParam = 287) {
                            pos2 += 5
                        }
                        adbClick_wbb(pos1, pos2)
                    }
                }
                else if(FindOrLoseImage(175, 165, 255, 235, , "Hourglass3", 0)) {
                    Delay(3)
                    adbClick_wbb(146, 441) ; 146 440
                    Delay(3)
                    adbClick_wbb(146, 441)
                    Delay(3)
                    adbClick_wbb(146, 441)
                    Delay(3)

                    FindImageAndClick(98, 184, 151, 224, , "Hourglass1", 168, 438, 500, 5) ;stop at hourglasses tutorial 2
                    Delay(1)

                    adbClick_wbb(203, 436) ; 203 436
                }
                failSafeTime := (A_TickCount - failSafe) // 1000
                CreateStatusMessage("Waiting for Social`n(" . failSafeTime . "/90 seconds)")
            }
            FindImageAndClick(226, 100, 270, 135, , "Add", 38, 460, 500)
            FindImageAndClick(205, 430, 255, 475, , "Search", 240, 120, 1500)
            if(getFC) {
                Delay(3)
                adbClick_wbb(210, 342)
                Delay(3)
                friendCode := Clipboard
                return friendCode
            }
            FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
            if(!friendIDs) {
                failSafe := A_TickCount
                failSafeTime := 0
                Loop {
                    adbInput(FriendID)
                    Delay(1)
                    if(FindOrLoseImage(205, 430, 255, 475, , "Search", 0, failSafeTime)) {
                        FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
                        EraseInput(1,1)
                    } else if(FindOrLoseImage(205, 430, 255, 475, , "Search2", 0, failSafeTime)) {
                        break
                    }
                    failSafeTime := (A_TickCount - failSafe) // 1000
                    CreateStatusMessage("Waiting for AddFriends1`n(" . failSafeTime . "/45 seconds)")
                }
                failSafe := A_TickCount
                failSafeTime := 0
                Loop {
                    adbClick_wbb(232, 453)
                    if(FindOrLoseImage(165, 250, 190, 275, , "Send", 0, failSafeTime)) {
                        adbClick_wbb(243, 258)
                        Delay(2)
                        break
                    }
                    else if(FindOrLoseImage(165, 240, 255, 270, , "Withdraw", 0, failSafeTime)) {
                        break
                    }
                    else if(FindOrLoseImage(165, 250, 190, 275, , "Accepted", 0, failSafeTime)) {
                        if(renew){
                            FindImageAndClick(135, 355, 160, 385, , "Remove", 193, 258, 500)
                            FindImageAndClick(165, 250, 190, 275, , "Send", 200, 372, 500)
                            if(!friended)
                                ExitApp
                            Delay(2)
                            adbClick_wbb(243, 258)
                        }
                        break
                    }
                    Sleep, 750
                    failSafeTime := (A_TickCount - failSafe) // 1000
                    CreateStatusMessage("Waiting for AddFriends2`n(" . failSafeTime . "/45 seconds)")
                }
                n := 1 ;how many friends added needed to return number for remove friends
            }
            else {
                ;randomize friend id list to not back up mains if running in groups since they'll be sent in a random order.
                n := friendIDs.MaxIndex()
                Loop % n
                {
                    i := n - A_Index + 1
                    Random, j, 1, %i%
                    ; Force string assignment with quotes
                    temp := friendIDs[i] . ""  ; Concatenation ensures string type
                    friendIDs[i] := friendIDs[j] . ""
                    friendIDs[j] := temp . ""
                }
                for index, value in friendIDs {
                    if (StrLen(value) != 16) {
                        ; Wrong id value
                        continue
                    }
                    failSafe := A_TickCount
                    failSafeTime := 0
                    Loop {
                        adbInput(value)
                        Delay(1)
                        if(FindOrLoseImage(205, 430, 255, 475, , "Search", 0, failSafeTime)) {
                            FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
                            EraseInput()
                        } else if(FindOrLoseImage(205, 430, 255, 475, , "Search2", 0, failSafeTime)) {
                            break
                        }
                        failSafeTime := (A_TickCount - failSafe) // 1000
                        CreateStatusMessage("Waiting for AddFriends3`n(" . failSafeTime . "/45 seconds)")
                    }
                    failSafe := A_TickCount
                    failSafeTime := 0
                    Loop {
                        adbClick_wbb(232, 453)
                        if(FindOrLoseImage(165, 250, 190, 275, , "Send", 0, failSafeTime)) {
                            adbClick_wbb(243, 258)
                            Delay(2)
                            break
                        }
                        else if(FindOrLoseImage(165, 240, 255, 270, , "Withdraw", 0, failSafeTime)) {
                            break
                        }
                        else if(FindOrLoseImage(165, 250, 190, 275, , "Accepted", 0, failSafeTime)) {
                            if(renew){
                                FindImageAndClick(135, 355, 160, 385, , "Remove", 193, 258, 500)
                                FindImageAndClick(165, 250, 190, 275, , "Send", 200, 372, 500)
                                Delay(2)
                                adbClick_wbb(243, 258)
                            }
                            break
                        }
                        Sleep, 750
                        failSafeTime := (A_TickCount - failSafe) // 1000
                        CreateStatusMessage("Waiting for AddFriends4`n(" . failSafeTime . "/45 seconds)")
                    }
                    if(index != friendIDs.maxIndex()) {
                        FindImageAndClick(205, 430, 255, 475, , "Search2", 150, 50, 1500)
                        FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
                        EraseInput(index, n)
                    }
                }
            }
            FindImageAndClick(120, 500, 155, 530, , "Social", 143, 518, 500)
IniRead, showcaseNumber, %A_ScriptDir%\..\Settings.ini, UserSettings, showcaseLikes, 1
			if ( showcaseNumber > 0)
			{
				showcaseNumber -= 1
				IniWrite, %showcaseNumber%, %A_ScriptDir%\..\Settings.ini, UserSettings, showcaseLikes
				Delay(5)
				; Liking friend showcase script
				; clicking showcase button
				adbClick_wbb(80, 400)
				Delay(10)
				;MsgBox, showcaseNumber is > 0
				Loop, Read, %A_ScriptDir%\..\showcase_ids.txt
				{
					showcaseID := Trim(A_LoopReadLine)
					; clicking friend id search
					adbClick_wbb(220, 467)
					Delay(3)
					; clicking search bar
					adbClick_wbb(152, 272)
					Delay(3)
					;pasting id
					adbInput(showcaseID)
					Delay(1)
					;MsgBox, % showcaseID
					;pressing ok
					adbClick_wbb(212, 384)
					Delay(3)
					;pressing like on showcase
					adbClick_wbb(133, 192)
					Delay(3)
					;going back to community showcases
					adbClick_wbb(133, 492)
					Delay(3)
				}
			}
                    FindImageAndClick(20, 500, 55, 530, , "Home", 40, 516, 500)
        }
        CreateStatusMessage("Waiting for friends to accept request`n(" . count . "/" . waitTime . " seconds)")
        sleep, 1000
        count++
    }
    return n ;return added friends so we can dynamically update the .txt in the middle of a run without leaving friends at the end
}

ChooseTag() {
	FindImageAndClick(120, 500, 155, 530, , "Social", 143, 518, 500)
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		FindImageAndClick(20, 500, 55, 530, , "Home", 40, 516, 500, 2)
		LevelUp()
		if(FindImageAndClick(203, 272, 237, 300, , "Profile", 143, 95, 500, 2, failSafeTime))
			break
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Profile. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for Profile. " . failSafeTime "/45 seconds")
	}
	FindImageAndClick(205, 310, 220, 319, , "ChosenTag", 143, 306, 1000)
	FindImageAndClick(53, 218, 63, 228, , "Badge", 143, 466, 500)
	FindImageAndClick(203, 272, 237, 300, , "Profile", 61, 112, 500)
	if(FindOrLoseImage(145, 140, 157, 155, , "Eevee", 1)) {
		FindImageAndClick(163, 200, 173, 207, , "ChooseEevee", 147, 207, 1000)
		FindImageAndClick(53, 218, 63, 228, , "Badge", 143, 466, 500)
	}
}

EraseInput(num := 0, total := 0) {
    if(num)
        CreateStatusMessage("Removing friend ID " . num . "/" . total,,,, false)
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
	    adbClick_wbb(50, 500)
		Sleep,10
	    adbClick_wbb(50, 500)
		Sleep,10
            adbInputEvent("67")
        if(FindOrLoseImage(15, 500, 68, 520, , "Erase", 0, failSafeTime))
            break
    }

    failSafeTime := (A_TickCount - failSafe) // 1000
    CreateStatusMessage("Waiting for EraseInput`n(" . failSafeTime . "/45 seconds)")
}

FindOrLoseImage(X1, Y1, X2, Y2, searchVariation := "", imageName := "DEFAULT", EL := 1, safeTime := 0) {
    global winTitle, failSafe
    if(slowMotion) {
        if(imageName = "Platin" || imageName = "One" || imageName = "Two" || imageName = "Three")
            return true
    }
    if(searchVariation = "")
        searchVariation := 20
    imagePath := A_ScriptDir . "\" . defaultLanguage . "\"
    confirmed := false

    CreateStatusMessage("Finding " . imageName . "...")
    pBitmap := from_window(WinExist(winTitle))
    Path = %imagePath%%imageName%.png
    pNeedle := GetNeedle(Path)

    ; 100% scale changes
    if (scaleParam = 287) {
        Y1 -= 8 ; offset, should be 44-36 i think?
        Y2 -= 8
        if (Y1 < 0) {
            Y1 := 0
        }
        if (imageName = "Bulba") { ; too much to the left? idk how that happens
            X1 := 200
            Y1 := 220
            X2 := 230
            Y2 := 260
        } else if (imageName = "Erika") { ; 100% fix for Erika avatar
            X1 := 149
            Y1 := 153
            X2 := 159
            Y2 := 162
        } else if (imageName = "DeleteAll") { ; 100% for Deleteall offset
            X1 := 200
            Y1 := 340
            X2 := 265
            Y2 := 530
        }
    }

    ; ImageSearch within the region
    vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, X1, Y1, X2, Y2, searchVariation)
    if(EL = 0)
        GDEL := 1
    else
        GDEL := 0
    if (!confirmed && vRet = GDEL && GDEL = 1) {
        confirmed := vPosXY
    } else if(!confirmed && vRet = GDEL && GDEL = 0) {
        confirmed := true
    }
    Path = %imagePath%App.png
    pNeedle := GetNeedle(Path)
    ; ImageSearch within the region
    vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, 225, 300, 242, 314, searchVariation)
    if (vRet = 1) {
        restartGameInstance("Stuck at " . imageName . "...")
    }
    if(imageName = "Social" || imageName = "Add" || imageName = "Search") {
        TradeTutorial()
    }
    if(imageName = "Social" || imageName = "Country" || imageName = "Account2" || imageName = "Account" || imageName = "Points") { ;only look for deleted account on start up.
        Path = %imagePath%NoSave.png ; look for No Save Data error message > if loaded account > delete xml > reload
        pNeedle := GetNeedle(Path)
        ; ImageSearch within the region
        vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, 30, 331, 50, 449, searchVariation)
        if (scaleParam = 287) {
            vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, 30, 325, 55, 445, searchVariation)
        }
        if (vRet = 1) {
            adbShell.StdIn.WriteLine("rm -rf /data/data/jp.pokemon.pokemontcgp/cache/*") ; clear cache
            waitadb()
            CreateStatusMessage("Loaded deleted account. Deleting XML...",,,, false)
            if(loadedAccount) {
                FileDelete, %loadedAccount%
                IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
            }
            LogToFile("Restarted game for instance " . scriptName . ". Reason: No save data found", "Restart.txt")
            Reload
        }
    }
    if(imageName = "Points" || imageName = "Home") { ;look for level up ok "button"
        LevelUp()
    }
	;country for new accounts, social for inject with friend id, points for inject without friend id
    if(imageName = "Country" || imageName = "Social" || imageName = "Points")
        FSTime := 90
    else
        FSTime := 45
    if (safeTime >= FSTime) {
        restartGameInstance("Stuck at " . imageName . "...")
        failSafe := A_TickCount
    }
    Gdip_DisposeImage(pBitmap)
    return confirmed
}
FindImageAndClick(X1, Y1, X2, Y2, searchVariation := "", imageName := "DEFAULT", clickx := 0, clicky := 0, sleepTime := "", skip := false, safeTime := 0) {
    global winTitle, failSafe, confirmed, slowMotion

    if(slowMotion) {
        if(imageName = "Platin" || imageName = "One" || imageName = "Two" || imageName = "Three")
            return true
    }
    if(searchVariation = "")
        searchVariation := 20
    if (sleepTime = "") {
        global Delay
        sleepTime := Delay
    }
    imagePath := A_ScriptDir . "\" defaultLanguage "\"
    click := false
    if(clickx > 0 and clicky > 0)
        click := true
    x := 0
    y := 0
    StartSkipTime := A_TickCount

    confirmed := false

    ; 100% scale changes
    if (scaleParam = 287) {
        Y1 -= 8 ; offset, should be 44-36 i think?
        Y2 -= 8
        if (Y1 < 0) {
            Y1 := 0
        }

        clicky += 2 ; clicky offset
        if (imageName = "Platin") { ; can't do text so purple box
            X1 := 141
            Y1 := 189
            X2 := 208
            Y2 := 224
        } else if (imageName = "Opening") { ; Opening click (to skip cards) can't click on the immersive skip with 239, 497
            X1 := 10
            Y1 := 80
            X2 := 50
            Y2 := 115
            clickx := 250
            clicky := 505
        } else if (imageName = "SelectExpansion") { ; SelectExpansion
            X1 := 120
            Y1 := 135
            X2 := 161
            Y2 := 145
        } else if (imageName = "CountrySelect2") { ; SelectExpansion
            X1 := 120
            Y1 := 130
            X2 := 174
            Y2 := 155
        } else if (imageName = "Profile") { ; ChangeTag GP found
            X1 := 213
            Y1 := 273
            X2 := 226
            Y2 := 286
        } else if (imageName = "ChosenTag") { ; ChangeTag GP found
            X1 := 218
            Y1 := 307
            X2 := 231
            Y2 := 312
        } else if (imageName = "Badge") { ; ChangeTag GP found
            X1 := 48
            Y1 := 204
            X2 := 72
            Y2 := 230
        } else if (imageName = "ChooseErika") { ; ChangeTag GP found
            X1 := 150
            Y1 := 286
            X2 := 155
            Y2 := 291
        } else if (imageName = "ChooseEevee") { ; Change Eevee Avatar
            X1 := 157
            Y1 := 195
            X2 := 162
            Y2 := 200
            clickx := 147
            clicky := 207
        }
    }

    if(click) {
        adbClick_wbb(clickx, clicky)
        clickTime := A_TickCount
    }
    CreateStatusMessage("Finding and clicking " . imageName . "...")

    messageTime := 0
    firstTime := true
    Loop { ; Main loop
        Sleep, 10
        if(click) {
            ElapsedClickTime := A_TickCount - clickTime
            if(ElapsedClickTime > sleepTime) {
                adbClick_wbb(clickx, clicky)
                clickTime := A_TickCount
            }
        }

        if (confirmed) {
            continue
        }

        pBitmap := from_window(WinExist(winTitle))
        Path = %imagePath%%imageName%.png
        pNeedle := GetNeedle(Path)
        ; ImageSearch within the region
        vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, X1, Y1, X2, Y2, searchVariation)
        if (!confirmed && vRet = 1) {
            confirmed := vPosXY
        } else {
            ElapsedTime := (A_TickCount - StartSkipTime) // 1000
            if(imageName = "Country")
                FSTime := 90
            else if(imageName = "Proceed") ; Decrease time for Marowak
                FSTime := 8
            else
                FSTime := 45
            if(!skip) {
                if(ElapsedTime - messageTime > 0.5 || firstTime) {
                    CreateStatusMessage("Looking for " . imageName . " for " . ElapsedTime . "/" . FSTime . " seconds")
                    messageTime := ElapsedTime
                    firstTime := false
                }
            }
            if (ElapsedTime >= FSTime || safeTime >= FSTime) {
                CreateStatusMessage("Instance " . scriptName . " has been stuck for 90s. Killing it...")
				if (injectMethod){
                    RemoveFriends()
				}
                restartGameInstance("Stuck at " . imageName . "...") ; change to reset the instance and delete data then reload script
                StartSkipTime := A_TickCount
                failSafe := A_TickCount
            }
        }
Path = %imagePath%Error.png
        pNeedle := GetNeedle(Path)
        ; ImageSearch within the region
        vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, 120, 187, 155, 210, searchVariation)
        if (vRet = 1) {
            CreateStatusMessage("Error message in " . scriptName . ". Clicking retry...",,,, false)
            adbClick_wbb(82, 389)
            Delay(1)
            adbClick_wbb(139, 386)
            Sleep, 1000
        }
        Path = %imagePath%App.png
        pNeedle := GetNeedle(Path)
        ; ImageSearch within the region
        vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, 225, 300, 242, 314, searchVariation)
        if (vRet = 1) {
            restartGameInstance("Stuck at " . imageName . "...")
        }
        if(imageName = "Social" || imageName = "Country" || imageName = "Account2" || imageName = "Account") { ;only look for deleted account on start up.
            Path = %imagePath%NoSave.png ; look for No Save Data error message > if loaded account > delete xml > reload
            pNeedle := GetNeedle(Path)
            ; ImageSearch within the region
            vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, 30, 331, 50, 449, searchVariation)
            if (scaleParam = 287) {
                vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, 30, 325, 55, 445, searchVariation)
            }
            if (vRet = 1) {
                adbShell.StdIn.WriteLine("rm -rf /data/data/jp.pokemon.pokemontcgp/cache/*") ; clear cache
                waitadb()
                CreateStatusMessage("Loaded deleted account. Deleting XML...",,,, false)
                if(loadedAccount) {
                    FileDelete, %loadedAccount%
                    IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
                }
                LogToFile("Restarted game for instance " . scriptName . ". Reason: No save data found", "Restart.txt")
                Reload
            }
        }

        if(imageName = "Missions") { ; may input extra ESC and stuck at exit game
            Path = %imagePath%Delete2.png
            pNeedle := GetNeedle(Path)
            ; ImageSearch within the region
            vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, 118, 353, 135, 390, searchVariation)
            if (vRet = 1) {
                adbClick_wbb(74, 353)
                Delay(1)
            }
        }
		if(imageName = "Skip2" || imageName = "Pack" || imageName = "Hourglass2") {
			Path = %imagePath%notenoughitems.png
            pNeedle := GetNeedle(Path)
            vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, 92, 299, 115, 317, 0)
			if(vRet = 1) {
				cantOpenMorePacks := 1
				return 0
				;restartGameInstance("Not Enough Items")
			}
		}
		if(imageName = "Mission_dino2") {
			Path = %imagePath%1solobattlemission.png
            pNeedle := GetNeedle(Path)
            vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, 108, 180, 177, 208, 0)
			if(vRet = 1) {
				beginnerMissionsDone := 1
				if(injectMethod && loadedAccount)
					setMetaData()
				return
				;restartGameInstance("beginner missions done except solo battle")
			}
		}

        Gdip_DisposeImage(pBitmap)
        if(imageName = "Points" || imageName = "Home") { ;look for level up ok "button"
            LevelUp()
        }
        if(imageName = "Social" || imageName = "Add" || imageName = "Search") {
            TradeTutorial()
        }
        if(skip) {
            ElapsedTime := (A_TickCount - StartSkipTime) // 1000
            if(ElapsedTime - messageTime > 0.5 || firstTime) {
                CreateStatusMessage("Looking for " . imageName . "`nSkipping in " . (skip - ElapsedTime) . " seconds...")
                messageTime := ElapsedTime
                firstTime := false
            }
            if (ElapsedTime >= skip) {
                confirmed := false
                ElapsedTime := ElapsedTime/2
                break
            }
        }
        if (confirmed) {
            break
        }
    }
    Gdip_DisposeImage(pBitmap)
    return confirmed
}

LevelUp() {
    Leveled := FindOrLoseImage(100, 86, 167, 116, , "LevelUp", 0)
    if(Leveled) {
        clickButton := FindOrLoseImage(75, 340, 195, 530, 80, "Button", 0, failSafeTime)
        StringSplit, pos, clickButton, `,  ; Split at ", "
        if (scaleParam = 287) {
            pos2 += 5
        }
        adbClick_wbb(pos1, pos2)
    }
    Delay(1)
}

resetWindows() {
    global Columns, winTitle, SelectedMonitorIndex, scaleParam, defaultLanguage, rowGap
    
    ; Simply call our direct positioning function
    DirectlyPositionWindow()
    
    return true
}

DirectlyPositionWindow() {
    global Columns, runMain, Mains, scaleParam, winTitle, SelectedMonitorIndex, rowGap
    
    ; Make sure rowGap is defined
    if (!rowGap)
        rowGap := 100
        
    ; Get monitor information
    SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
    SysGet, Monitor, Monitor, %SelectedMonitorIndex%
    
    ; Calculate position based on instance number
    Title := winTitle
    
    if (runMain) {
        instanceIndex := (Mains - 1) + Title + 1
    } else {
        instanceIndex := Title
    }
    
    rowHeight := 533
    currentRow := Floor((instanceIndex - 1) / Columns)
    
    ; Calculate absolute coordinates with MonitorTop/Left
    y := MonitorTop + (currentRow * rowHeight) + (currentRow * rowGap)
    x := MonitorLeft + (Mod((instanceIndex - 1), Columns) * scaleParam)
    
    ; Position window directly without any additional checks
    WinSet, Style, -0xC00000, %Title% ; Remove title bar temporarily
    WinMove, %Title%, , %x%, %y%, %scaleParam%, 537
    WinSet, Style, +0xC00000, %Title% ; Restore title bar
    WinSet, Redraw, , %Title% ; Force redraw
    
    CreateStatusMessage("Positioned window at x:" . x . " y:" . y,,,, false)
    
    return true
}
restartGameInstance(reason, RL := true) {
    global friended, scriptName, packsThisRun, injectMethod, loadedAccount, DeadCheck, starCount, packsInPool, openPack, invalid, accountFile, username, stopToggle

    if (Debug)
        CreateStatusMessage("Restarting game reason:`n" . reason)
    else if (InStr(reason, "Stuck"))
        CreateStatusMessage("Stuck! Restarting game...",,,, false)
    else
        CreateStatusMessage("Restarting game...",,,, false)

    if (RL = "GodPack") {
        LogToFile("Restarted game for instance " . scriptName . ". Reason: " reason, "Restart.txt")
        IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
        AppendToJsonFile(packsThisRun)
        
        if (stopToggle) {
            CreateStatusMessage("Stopping...",,,, false)
            ;TODO force stop, remove account
            ExitApp
        }

        Reload
    } else {
        waitadb()
        adbShell.StdIn.WriteLine("am force-stop jp.pokemon.pokemontcgp")
        waitadb()
        Sleep, 2000
        ;MsgBox, 1
        clearMissionCache()
        if (!RL && DeadCheck = 0) {
            ;MsgBox, 2
            adbShell.StdIn.WriteLine("rm /data/data/jp.pokemon.pokemontcgp/shared_prefs/deviceAccount:.xml") ; delete account data
            ;MsgBox, 3
            ;TODO improve friend list cluter with deadcheck/stuck at, for injection. need to check also loadAccount at the beggining
        }
        waitadb()
        Sleep, 500
        adbShell.StdIn.WriteLine("am start -n jp.pokemon.pokemontcgp/com.unity3d.player.UnityPlayerActivity")
        
        waitadb()
        Sleep, 5000
        ;MsgBox, 4
        if (RL) {
            
            AppendToJsonFile(packsThisRun)
            ;if(!injectMethod || !loadedAccount) 
            if(!injectMethod) {
                if (menuDeleteStart()) {
                    IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
                    logMessage := "\n" . username . "\n[" . (starCount ? starCount : "0") . "/5][" . (packsInPool ? packsInPool : 0) . "P][" . openPack . "] " . (invalid ? invalid . " God Pack" : "Some sort of pack") . " found in instance: " . scriptName . "\nFile name: " . accountFile . "\nGot stuck doing something. Check Log_" . scriptName . ".txt."
                    LogToFile(Trim(StrReplace(logMessage, "\n", " ")))
                    ; Logging to Discord is temporarily disabled until all of the scenarios which could cause the script to end up here are fully understood.
                    ;LogToDiscord(logMessage,, true)
                }
            }
            LogToFile("Restarted game for instance " . scriptName . ". Reason: " reason, "Restart.txt")

            if (stopToggle) {
                CreateStatusMessage("Stopping...",,,, false)
                ;TODO force stop, remove account
                ExitApp
            }
            
            Reload
        }

        if (stopToggle) {
            CreateStatusMessage("Stopping...",,,, false)
            ;TODO force stop, remove account
            ExitApp
        }
    }
}

menuDelete() {
    sleep, %Delay%
    failSafe := A_TickCount
    failSafeTime := 0
    Loop
    {
        sleep, %Delay%
        sleep, %Delay%
        adbClick_wbb(245, 518)
        if(FindImageAndClick(90, 260, 126, 290, , "Settings", , , , 1, failSafeTime)) ;wait for settings menu
            break
        sleep, %Delay%
        sleep, %Delay%
        adbClick_wbb(50, 100)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Settings`n(" . failSafeTime . " seconds)")
    }
    Sleep,%Delay%
    FindImageAndClick(24, 158, 57, 189, , "Account", 140, 440, 2000) ;wait for other menu
    Sleep,%Delay%
    FindImageAndClick(56, 435, 108, 460, , "Account2", 79, 256, 1000) ;wait for account menu
    Sleep,%Delay%

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            clickButton := FindOrLoseImage(75, 340, 195, 530, 40, "Button2", 0, failSafeTime)
            if(!clickButton) {
                ; fix https://discord.com/channels/1330305075393986703/1354775917288882267/1355090394307887135
                clickImage := FindOrLoseImage(200, 340, 250, 530, 60, "DeleteAll", 0, failSafeTime)
                if(clickImage) {
                    StringSplit, pos, clickImage, `,  ; Split at ", "
                    if (scaleParam = 287) {
                        pos2 += 5
                    }
                    adbClick_wbb(pos1, pos2)
                }
                else {
                    adbClick_wbb(230, 506)
                }
                Delay(1)
                failSafeTime := (A_TickCount - failSafe) // 1000
                CreateStatusMessage("Waiting to click delete`n(" . failSafeTime . "/45 seconds)")
            }
            else {
                break
            }
            Sleep,%Delay%
        }
        StringSplit, pos, clickButton, `,  ; Split at ", "
        if (scaleParam = 287) {
            pos2 += 5
        }
        adbClick_wbb(pos1, pos2)
        break
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting to click delete`n(" . failSafeTime . "/45 seconds)")
    }

    Sleep, 2500
}

menuDeleteStart() {
    global friended
    if(keepAccount) {
        return keepAccount
    }
    if(friended) {
        FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
        if(setSpeed = 3)
            FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
        else
            FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
        Delay(1)
        adbClick_wbb(41, 296)
        Delay(1)
    }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        if(!friended)
            break
        adbClick_wbb(255, 83)
        if(FindOrLoseImage(105, 396, 121, 406, , "Country", 0, failSafeTime)) { ;if at country continue
            break
        }
        else if(FindOrLoseImage(20, 120, 50, 150, , "Menu", 0, failSafeTime)) { ; if the clicks in the top right open up the game settings menu then continue to delete account
            Sleep,%Delay%
            FindImageAndClick(56, 435, 108, 460, , "Account2", 79, 256, 1000) ;wait for account menu
            Sleep,%Delay%
            failSafe := A_TickCount
            failSafeTime := 0
            Loop {
                clickButton := FindOrLoseImage(75, 340, 195, 530, 80, "Button", 0, failSafeTime)
                if(!clickButton) {
                    clickImage := FindOrLoseImage(200, 340, 250, 530, 60, "DeleteAll", 0, failSafeTime)
                    if(clickImage) {
                        StringSplit, pos, clickImage, `,  ; Split at ", "
                        if (scaleParam = 287) {
                            pos2 += 5
                        }
                        adbClick_wbb(pos1, pos2)
                    }
                    else {
                        adbClick_wbb(230, 506)
                    }
                    Delay(1)
                    failSafeTime := (A_TickCount - failSafe) // 1000
                    CreateStatusMessage("Waiting to click delete`n(" . failSafeTime . "/45 seconds)")
                }
                else {
                    break
                }
                Sleep,%Delay%
            }
            StringSplit, pos, clickButton, `,  ; Split at ", "
            if (scaleParam = 287) {
                pos2 += 5
            }
            adbClick_wbb(pos1, pos2)
            break
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting to click delete`n(" . failSafeTime . "/45 seconds)")
        }
        CreateStatusMessage("Looking for Country/Menu")
        Delay(1)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Country/Menu`n(" . failSafeTime . "/45 seconds)")
    }
    if(loadedAccount) {
    ;    FileDelete, %loadedAccount%
    }
}
CheckPack() {
    ; Update pack count.
	accountOpenPacks += 1
	if (injectMethod && loadedAccount)
		UpdateAccount()
		
	
    packsInPool += 1
    packsThisRun += 1
		
	if(!friendIDs && friendID = "" && !s4tEnabled && !ImmersiveCheck && !CrownCheck && !ShinyCheck)
		return false

    ; Wait for cards to render before checking.
    Loop {
        if (FindBorders("lag") = 0)
            break
        Delay(1)
    }

    ; Define a variable to contain whatever is found based on settings.
    foundLabel := false

    ; Before doing anything else, check if the current pack is valid.
    foundShiny := FindBorders("shiny2star") + FindBorders("shiny1star")
    foundCrown := FindBorders("crown")
    foundImmersive := FindBorders("immersive")
    foundInvalid := foundShiny + foundCrown + foundImmersive

    if (foundInvalid) {
        ; Pack is invalid...
		foundInvalidGP := FindGodPack(true) ; GP is never ignored
        if (!foundInvalidGP && !InvalidCheck) {
			; If not a GP and not "ignore invalid packs" , check what cards the current pack contains which make it invalid, and if user want to save them.
            if (ShinyCheck && foundShiny && !foundLabel)
                foundLabel := "Shiny"
            if (ImmersiveCheck && foundImmersive && !foundLabel)
                foundLabel := "Immersive"
            if (CrownCheck && foundCrown && !foundLabel)
                foundLabel := "Crown"

            ; Report invalid cards found.
            if (foundLabel) {
                FoundStars(foundLabel)
                restartGameInstance(foundLabel . " found. Continuing...", "GodPack")
            }
        }

        IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck

        return
    }

    ; Check for god pack. if found we know its not invalid
    foundGP := FindGodPack()

    if (foundGP) {
        if (loadedAccount) {
			    accountHasPackInTesting := 1
                            setMetaData()
            IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
        }

        restartGameInstance("God Pack found. Continuing...", "GodPack")
        return
    }

    ; if not invalid and no GP, Check for 2-star cards.
    if (!CheckShinyPackOnly || shinyPacks.HasKey(openPack)) {
        foundTrainer := false
        foundRainbow := false
        foundFullArt := false
        2starCount := false

        if (PseudoGodPack && !foundLabel) {
            foundTrainer := FindBorders("trainer")
            foundRainbow := FindBorders("rainbow")
            foundFullArt := FindBorders("fullart")
            2starCount := foundTrainer + foundRainbow + foundFullArt
            if (2starCount > 1)
                foundLabel := "Double two star"
        }
        if (TrainerCheck && !foundLabel) {
			if(!PseudoGodPack)
				foundTrainer := FindBorders("trainer")
            if (foundTrainer)
                foundLabel := "Trainer"
        }
        if (RainbowCheck && !foundLabel) {
            if(!PseudoGodPack)
				foundRainbow := FindBorders("rainbow")
            if (foundRainbow)
                foundLabel := "Rainbow"
        }
        if (FullArtCheck && !foundLabel) {
            if(!PseudoGodPack)
				foundFullArt := FindBorders("fullart")
            if (foundFullArt)
                foundLabel := "Full Art"
        }

        if (foundLabel) {
            if (loadedAccount) {
                    accountHasPackInTesting := 1
                    setMetaData()
                IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
            }

            FoundStars(foundLabel)
            restartGameInstance(foundLabel . " found. Continuing...", "GodPack")
        }
    }

    ; Check for tradeable cards.
    if (s4tEnabled) {
        found3Dmnd := 0
        found4Dmnd := 0
        found1Star := 0
        foundGimmighoul := 0

        if (s4t3Dmnd) {
            found3Dmnd += FindBorders("3diamond")
        }
        if (s4t1Star) {
            found1Star += FindBorders("1star")
        }

        if (s4t4Dmnd) {
            ; Detecting a 4-diamond EX card isn't possible using a needle.
            ; Start with 5 and substract other card types as efficiently as possible.
            found4Dmnd := 5 - FindBorders("normal")

            if (found4Dmnd > 0) {
                if (s4t3Dmnd)
                    found4Dmnd -= found3Dmnd
                else
                    found4Dmnd -= FindBorders("3diamond")
            }
            if (found4Dmnd > 0) {
                if (s4t1Star)
                    found4Dmnd -= found1Star
                else
                    found4Dmnd -= FindBorders("1star")
            }

            if (found4Dmnd > 0 && PseudoGodPack) {
                found4Dmnd -= 2starCount
            } else {
                if (found4Dmnd > 0) {
                    if (TrainerCheck)
                        found4Dmnd -= foundTrainer
                    else
                        found4Dmnd -= FindBorders("trainer")
                }
                if (found4Dmnd > 0) {
                    if (RainbowCheck)
                        found4Dmnd -= foundRainbow
                    else
                        found4Dmnd -= FindBorders("rainbow")
                }
                if (found4Dmnd > 0) {
                    if (FullArtCheck)
                        found4Dmnd -= foundFullArt
                    else
                        found4Dmnd -= FindBorders("fullart")
                }
            }
        }

        if (s4tGholdengo && openPack = "Shining") {
            foundGimmighoul += FindCard("gimmighoul")
        }

        foundTradeable := found3Dmnd + found4Dmnd + found1Star + foundGimmighoul

        if (foundTradeable > 0)
            FoundTradeable(found3Dmnd, found4Dmnd, found1Star, foundGimmighoul)
    }
}

FoundTradeable(found3Dmnd := 0, found4Dmnd := 0, found1Star := 0, foundGimmighoul := 0) {
    ; Not dead.
    IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck

    ; Keep account.
    keepAccount := true

    foundTradeable := found3Dmnd + found4Dmnd + found1Star + foundGimmighoul

    packDetailsFile := ""
    packDetailsMessage := ""

    if (found3Dmnd > 0) {
        packDetailsFile .= "3DmndX" . found3Dmnd . "_"
        packDetailsMessage .= "Three Diamond (x" . found3Dmnd . "), "
    }
    if (found4Dmnd > 0) {
        packDetailsFile .= "4DmndX" . found4Dmnd . "_"
        packDetailsMessage .= "Four Diamond EX (x" . found4Dmnd . "), "
    }
    if (found1Star > 0) {
        packDetailsFile .= "1StarX" . found1Star . "_"
        packDetailsMessage .= "One Star (x" . found1Star . "), "
    }
    if (foundGimmighoul > 0) {
        packDetailsFile .= "GimmighoulX" . foundGimmighoul . "_"
        packDetailsMessage .= "Gimmighoul (x" . foundGimmighoul . "), "
    }

    packDetailsFile := RTrim(packDetailsFile, "_")
    packDetailsMessage := RTrim(packDetailsMessage, ", ")

    accountFullPath := ""
    accountFile := saveAccount("Tradeable", accountFullPath, packDetailsFile)
    screenShot := Screenshot("Tradeable", "Trades", screenShotFileName)

    statusMessage := "Tradeable cards found"
    if (username)
        statusMessage .= " by " . username

    if (!s4tWP || (s4tWP && foundTradeable < s4tWPMinCards)) {
        CreateStatusMessage("Tradeable cards found! Continuing...",,,, false)

        logMessage := statusMessage . " in instance: " . scriptName . " (" . packsInPool . " packs, " . openPack . ") File name: " . accountFile . " Screenshot file: " . screenShotFileName . " Backing up to the Accounts\\Trades folder and continuing..."
        LogToFile(logMessage, "S4T.txt")

        if (!s4tSilent && s4tDiscordWebhookURL) {
            discordMessage := statusMessage . " in instance: " . scriptName . " (" . packsInPool . " packs, " . openPack . ")\nFound: " . packDetailsMessage . "\nFile name: " . accountFile . "\nBacking up to the Accounts\\Trades folder and continuing..."
            LogToDiscord(discordMessage, screenShot, true, (s4tSendAccountXml ? accountFullPath : ""),, s4tDiscordWebhookURL, s4tDiscordUserId)
        }

        return
    }

    friendCode := getFriendCode()

    Sleep, 8000
    fcScreenshot := Screenshot("FRIENDCODE", "Trades")

    ; If we're doing the inject method, try to OCR our Username
    try {
        if (injectMethod && IsFunc("ocr")) {
            ocrText := Func("ocr").Call(fcScreenshot, ocrLanguage)
            ocrLines := StrSplit(ocrText, "`n")
            len := ocrLines.MaxIndex()
            if(len > 1) {
                playerName := ocrLines[1]
                playerID := RegExReplace(ocrLines[2], "[^0-9]", "")
                ; playerID := SubStr(ocrLines[2], 1, 19)
                username := playerName
            }
        }
    } catch e {
        LogToFile("Failed to OCR the friend code: " . e.message, "OCR.txt")
    }

    statusMessage := "Tradeable cards found"
    if (username)
        statusMessage .= " by " . username
    if (friendCode)
        statusMessage .= " (" . friendCode . ")"

    logMessage := statusMessage . " in instance: " . scriptName . " (" . packsInPool . " packs, " . openPack . ")\nFile name: " . accountFile . "\nScreenshot file: " . screenShotFileName . "\nBacking up to the Accounts\\Trades folder and continuing..."
    LogToFile(StrReplace(logMessage, "\n", " "), "S4T.txt")

    if (s4tDiscordWebhookURL) {
        discordMessage := statusMessage . " in instance: " . scriptName . " (" . packsInPool . " packs, " . openPack . ")\nFound: " . packDetailsMessage . "\nFile name: " . accountFile . "\nBacking up to the Accounts\\Trades folder and continuing..."
        LogToDiscord(discordMessage, screenShot, true, (s4tSendAccountXml ? accountFullPath : ""), fcScreenshot, s4tDiscordWebhookURL, s4tDiscordUserId)
    }

    restartGameInstance("Tradeable cards found. Continuing...", "GodPack")
}
FoundStars(star) {
    global scriptName, DeadCheck, ocrLanguage, injectMethod, openPack

    ; Not dead.
    IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck

    ; Keep account.
    keepAccount := true

    screenShot := Screenshot(star)
    accountFullPath := ""
    accountFile := saveAccount(star, accountFullPath)
    friendCode := getFriendCode()

    ; Pull back screenshot of the friend code/name (good for inject method)
    Sleep, 8000
    fcScreenshot := Screenshot("FRIENDCODE")

    if(star = "Crown" || star = "Immersive" || star = "Shiny")
        RemoveFriends()
    else {
        ; If we're doing the inject method, try to OCR our Username
        try {
            if (injectMethod && IsFunc("ocr")) {
                ocrText := Func("ocr").Call(fcScreenshot, ocrLanguage)
                ocrLines := StrSplit(ocrText, "`n")
                len := ocrLines.MaxIndex()
                if(len > 1) {
                    playerName := ocrLines[1]
                    playerID := RegExReplace(ocrLines[2], "[^0-9]", "")
                    ; playerID := SubStr(ocrLines[2], 1, 19)
                    username := playerName
                }
            }
        } catch e {
            LogToFile("Failed to OCR the friend code: " . e.message, "OCR.txt")
        }
    }

    CreateStatusMessage(star . " found!",,,, false)

    statusMessage := star . " found"
    if (username)
        statusMessage .= " by " . username
    if (friendCode)
        statusMessage .= " (" . friendCode . ")"

    logMessage := statusMessage . " in instance: " . scriptName . " (" . packsInPool . " packs, " . openPack . ")\nFile name: " . accountFile . "\nBacking up to the Accounts\\SpecificCards folder and continuing..."
    LogToDiscord(logMessage, screenShot, true, (sendAccountXml ? accountFullPath : ""), fcScreenshot)
    LogToFile(StrReplace(logMessage, "\n", " "), "GPlog.txt")
    if(star != "Crown" && star != "Immersive" && star != "Shiny")
        ChooseTag()
}

FindBorders(prefix) {
    count := 0
    searchVariation := 40
    borderCoords := [[30, 284, 83, 286]
        ,[113, 284, 166, 286]
        ,[196, 284, 249, 286]
        ,[70, 399, 123, 401]
        ,[155, 399, 208, 401]]
    if (prefix = "shiny1star" || prefix = "shiny2star") {
        borderCoords := [[90, 261, 93, 283]
        ,[173, 261, 176, 283]
        ,[255, 261, 258, 283]
        ,[130, 376, 133, 398]
        ,[215, 376, 218, 398]]
    }
    ; 100% scale changes
    if (scaleParam = 287) {
        if (prefix = "shiny1star" || prefix = "shiny2star") {
            borderCoords := [[91, 253, 95, 278]
            ,[175, 253, 179, 278]
            ,[259, 253, 263, 278]
            ,[132, 370, 136, 395]
            ,[218, 371, 222, 394]]
        } else {
            borderCoords := [[26, 278, 84, 280]
            ,[110, 278, 168, 280]
            ,[194, 278, 252, 280]
            ,[67, 395, 125, 397]
            ,[153, 395, 211, 397]]
        }
    }
    pBitmap := from_window(WinExist(winTitle))
    ; imagePath := "C:\Users\Arturo\Desktop\PTCGP\GPs\" . Clipboard . ".png"
    ; pBitmap := Gdip_CreateBitmapFromFile(imagePath)
    for index, value in borderCoords {
        coords := borderCoords[A_Index]
        Path = %A_ScriptDir%\%defaultLanguage%\%prefix%%A_Index%.png
        if (FileExist(Path)) {
            pNeedle := GetNeedle(Path)
            vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, coords[1], coords[2], coords[3], coords[4], searchVariation)
            if (vRet = 1) {
                count += 1
            }
        }
    }
    Gdip_DisposeImage(pBitmap)
    return count
}

FindCard(prefix) {
    count := 0
    searchVariation := 40
    borderCoords := [[23, 191, 76, 193]
        ,[106, 191, 159, 193]
        ,[189, 191, 242, 193]
        ,[63, 306, 116, 308]
        ,[146, 306, 199, 308]]
    ; 100% scale changes
    if (scaleParam = 287) {
        borderCoords := [[23, 184, 81, 186]
            ,[107, 184, 165, 186]
            ,[191, 184, 249, 186]
            ,[64, 301, 122, 303]
            ,[148, 301, 206, 303]]
    }
    pBitmap := from_window(WinExist(winTitle))
    for index, value in borderCoords {
        coords := borderCoords[A_Index]
        Path = %A_ScriptDir%\%defaultLanguage%\%prefix%%A_Index%.png
        if (FileExist(Path)) {
            pNeedle := GetNeedle(Path)
            vRet := Gdip_ImageSearch_wbb(pBitmap, pNeedle, vPosXY, coords[1], coords[2], coords[3], coords[4], searchVariation)
            if (vRet = 1) {
                count += 1
            }
        }
    }
    Gdip_DisposeImage(pBitmap)
    return count
}

FindGodPack(invalidPack := false) {
    ; Check for normal borders.
    normalBorders := FindBorders("normal")
    if (normalBorders) {
        CreateStatusMessage("Not a God Pack...",,,, false)
        return false
    }

    ; A god pack (although possibly invalid) has been found.
    keepAccount := true
    accountHasPackInTesting := 1  ; Add this line

    ; Count stars if required.
    packMinStars := minStars
    if (openPack = "Solgaleo") {
        packMinStars := minStarsA3Solgaleo
    } else if (openPack = "Lunala") {
        packMinStars := minStarsA3Lunala
    } else if (openPack = "Shining") {
        packMinStars := minStarsA2b
    } else if (openPack = "Arceus") {
        packMinStars := minStarsA2a
    } else if (openPack = "Dialga") {
        packMinStars := minStarsA2Dialga
    } else if (openPack = "Palkia") {
        packMinStars := minStarsA2Palkia
    } else if (openPack = "Mewtwo") {
        packMinStars := minStarsA1Mewtwo
    } else if (openPack = "Charizard") {
        packMinStars := minStarsA1Charizard
    } else if (openPack = "Pikachu") {
        packMinStars := minStarsA1Pikachu
    } else if (openPack = "Mew") {
        packMinStars := minStarsA1a
    }

    if (!invalidPack && packMinStars > 0) {
        starCount := 5 - FindBorders("1star")
        if (starCount < packMinStars) {
            CreateStatusMessage("Pack doesn't contain enough 2 stars...",,,, false)
            invalidPack := true
        }
    }

    if (invalidPack) {
        GodPackFound("Invalid")

        RemoveFriends()
        IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
    } else {
        GodPackFound("Valid")
    }

    return keepAccount
}

GodPackFound(validity) {
    global scriptName, DeadCheck, ocrLanguage, injectMethod, openPack

    IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck

    if(validity = "Valid") {
        Praise := ["Congrats!", "Congratulations!", "GG!", "Whoa!", "Praise Helix! ༼ つ ◕_◕ ༽つ", "Way to go!", "You did it!", "Awesome!", "Nice!", "Cool!", "You deserve it!", "Keep going!", "This one has to be live!", "No duds, no duds, no duds!", "Fantastic!", "Bravo!", "Excellent work!", "Impressive!", "You're amazing!", "Well done!", "You're crushing it!", "Keep up the great work!", "You're unstoppable!", "Exceptional!", "You nailed it!", "Hats off to you!", "Sweet!", "Kudos!", "Phenomenal!", "Boom! Nailed it!", "Marvelous!", "Outstanding!", "Legendary!", "Youre a rock star!", "Unbelievable!", "Keep shining!", "Way to crush it!", "You're on fire!", "Killing it!", "Top-notch!", "Superb!", "Epic!", "Cheers to you!", "Thats the spirit!", "Magnificent!", "Youre a natural!", "Gold star for you!", "You crushed it!", "Incredible!", "Shazam!", "You're a genius!", "Top-tier effort!", "This is your moment!", "Powerful stuff!", "Wicked awesome!", "Props to you!", "Big win!", "Yesss!", "Champion vibes!", "Spectacular!"]
        invalid := ""
    } else {
        Praise := ["Uh-oh!", "Oops!", "Not quite!", "Better luck next time!", "Yikes!", "That didn't go as planned.", "Try again!", "Almost had it!", "Not your best effort.", "Keep practicing!", "Oh no!", "Close, but no cigar.", "You missed it!", "Needs work!", "Back to the drawing board!", "Whoops!", "That's rough!", "Don't give up!", "Ouch!", "Swing and a miss!", "Room for improvement!", "Could be better.", "Not this time.", "Try harder!", "Missed the mark.", "Keep at it!", "Bummer!", "That's unfortunate.", "So close!", "Gotta do better!"]
        invalid := validity
    }
    Randmax := Praise.Length()
    Random, rand, 1, Randmax
    Interjection := Praise[rand]
    starCount := 5 - FindBorders("1star") - FindBorders("shiny1star")
    screenShot := Screenshot(validity)
    accountFullPath := ""
    accountFile := saveAccount(validity, accountFullPath)
    friendCode := getFriendCode()

    ; Pull screenshot of the Friend code page; wait so we don't get the clipboard pop up; good for the inject method
    Sleep, 8000
    fcScreenshot := Screenshot("FRIENDCODE")

    ; If we're doing the inject method, try to OCR our Username
    try {
        if (injectMethod && IsFunc("ocr")) {
            ocrText := Func("ocr").Call(fcScreenshot, ocrLanguage)
            ocrLines := StrSplit(ocrText, "`n")
            len := ocrLines.MaxIndex()
            if(len > 1) {
                playerName := ocrLines[1]
                playerID := RegExReplace(ocrLines[2], "[^0-9]", "")
                ; playerID := SubStr(ocrLines[2], 1, 19)
                username := playerName
            }
        }
    } catch e {
        LogToFile("Failed to OCR the friend code: " . e.message, "OCR.txt")
    }

    CreateStatusMessage(Interjection . (invalid ? " " . invalid : "") . " God Pack found!",,,, false)
    logMessage := Interjection . "\n" . username . " (" . friendCode . ")\n[" . starCount . "/5][" . packsInPool . "P][" . openPack . "] " . invalid . " God Pack found in instance: " . scriptName . "\nFile name: " . accountFile . "\nBacking up to the Accounts\\GodPacks folder and continuing..."
    LogToFile(StrReplace(logMessage, "\n", " "), "GPlog.txt")

    ; Adjust the below to only send a 'ping' to Discord friends on Valid packs
    if (validity = "Valid") {
        LogToDiscord(logMessage, screenShot, true, (sendAccountXml ? accountFullPath : ""), fcScreenshot)
        ChooseTag()
    } else if (!InvalidCheck) {
        LogToDiscord(logMessage, screenShot, true, (sendAccountXml ? accountFullPath : ""), fcScreenshot)
    }
}

loadAccount() {
    global beginnerMissionsDone, soloBattleMissionDone, intermediateMissionsDone, specialMissionsDone, resetSpecialMissionsDone
    global stopToggle, scriptName, accountFileName, accountOpenPacks, accountFileNameTmp, accountFileNameOrig, accountHasPackInfo
    global deleteMethod, injectMaxValue, injectMinValue, injectRange

    beginnerMissionsDone := 0
    soloBattleMissionDone := 0
    intermediateMissionsDone := 0
    specialMissionsDone := 0
    accountHasPackInTesting := 0
    resetSpecialMissionsDone := 0

    if (stopToggle) {
        CreateStatusMessage("Stopping...",,,, false)
        ExitApp
    }

    ; Re-read the latest injection parameters from settings
    IniRead, injectMaxValue, %A_ScriptDir%\..\Settings.ini, UserSettings, injectMaxValue, 39
    IniRead, injectMinValue, %A_ScriptDir%\..\Settings.ini, UserSettings, injectMinValue, 35
    IniRead, injectRange, %A_ScriptDir%\..\Settings.ini, UserSettings, injectRange, ""
    
    LogToFile("Current injection values - Max: " . injectMaxValue . ", Min: " . injectMinValue . ", Range: '" . injectRange . "'")

    ; Debug log to see what's happening
    LogToFile("Loading account... Delete Method: " . deleteMethod)
    CreateStatusMessage("Loading account... Delete Method: " . deleteMethod,,,, false)

    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle

    outputTxt := saveDir . "\list_current.txt"
    
    accountFileName := ""
    accountOpenPacks := 0
    accountFileNameTmp := ""
    accountFileNameOrig := ""
    accountHasPackInfo := 0
    
    ; First, check if list_current.txt exists and has content
    if FileExist(outputTxt) {
        FileGetSize, fileSize, %outputTxt%
        
        if (fileSize <= 0) {
            ; File exists but is empty - log this
            LogToFile("list_current.txt exists but is empty. Regenerating account list...")
            
            ; Force regenerate the account list by deleting the timestamp file
            lastGenFile := saveDir . "\list_last_generated.txt"
            if (FileExist(lastGenFile))
                FileDelete, %lastGenFile%
                
            ; Now regenerate the list
            FileDelete, %outputTxt%
            createAccountList(scriptName)
        }
    } else {
        ; File doesn't exist at all, generate it
        LogToFile("list_current.txt doesn't exist. Creating account list...")
        createAccountList(scriptName)
    }
    
    ; Check file again after potential regeneration
    if FileExist(outputTxt) {
        cycle := 0
        Loop {
            FileRead, fileContent, %outputTxt%  ; Read entire file
            fileLines := StrSplit(fileContent, "`n", "`r")  ; Split into lines
                
            ; Log the number of accounts found
            LogToFile("Found " . (fileLines.MaxIndex() ? fileLines.MaxIndex() : 0) . " accounts in list_current.txt")
            
            if (fileLines.MaxIndex() >= 1) {
                CreateStatusMessage("Making sure XML is > 24 hours old: " . cycle . " attempts")
                loadFile := ""
                foundValidAccount := false
                foundIndex := 0
                
                ; Loop through available accounts to find one matching our criteria
                Loop, % fileLines.MaxIndex() {
                    currentFile := fileLines[A_Index]
                    if (StrLen(currentFile) < 5)  ; Skip empty or too short lines
                        continue
                        
                    testFile := saveDir . "\" . currentFile
                    if (!FileExist(testFile))
                        continue
                        
                    if (!InStr(currentFile, "xml"))
                        continue
                    
                    ; Check if the file is old enough
                    FileGetTime, accountFileTime, %testFile%, M  ; Get last modified time of account file
                    accountModifiedTimeDiff := A_Now
                    EnvSub, accountModifiedTimeDiff, %accountFileTime%, Hours
                    if (accountModifiedTimeDiff >= 24) {
                        ; ADDITIONAL CHECK: Verify pack count is still within range
                        packCount := 0
                        if (RegExMatch(currentFile, "^(\d+)P", packMatch)) {
                            packCount := packMatch1 + 0  ; Force numeric conversion
                        } else {
                            ; If no pack count in filename, assume it's a fresh account (0 packs)
                            packCount := 0
                        }
                        
                        ; Determine current injection ranges based on method
                        isValidForCurrentMethod := false
                        if (deleteMethod = "Inject") {
                            ; Inject: 0 to Max (inclusive)
                            isValidForCurrentMethod := (packCount >= 0 && packCount <= injectMaxValue)
                            LogToFile("Checking account " . currentFile . " for Inject method: " . packCount . " packs, range 0-" . injectMaxValue . " = " . (isValidForCurrentMethod ? "VALID" : "INVALID"))
                        }
                        else if (deleteMethod = "Inject long") {
                            ; Inject long: 0 to Max (inclusive) - SAME AS INJECT
                            isValidForCurrentMethod := (packCount >= 0 && packCount <= injectMaxValue)
                            LogToFile("Checking account " . currentFile . " for Inject long method: " . packCount . " packs, range 0-" . injectMaxValue . " = " . (isValidForCurrentMethod ? "VALID" : "INVALID"))
                        }
                        else if (deleteMethod = "Inject for Reroll") {
                            ; Inject for Reroll: Min and above (no upper limit)
                            isValidForCurrentMethod := (packCount >= injectMinValue)
                            LogToFile("Checking account " . currentFile . " for Inject for Reroll method: " . packCount . " packs, range " . injectMinValue . "+ = " . (isValidForCurrentMethod ? "VALID" : "INVALID"))
                        }
                        else if (deleteMethod = "Inject Range") {
                            ; Inject Range: Specific range from user input
                            if (injectRange != "" && InStr(injectRange, "-")) {
                                rangeParts := StrSplit(injectRange, "-")
                                if (rangeParts.Length() >= 2) {
                                    minPacks := rangeParts[1] + 0
                                    maxPacks := rangeParts[2] + 0
                                    isValidForCurrentMethod := (packCount >= minPacks && packCount <= maxPacks)
                                    LogToFile("Checking account " . currentFile . " for Inject Range method: " . packCount . " packs, range " . minPacks . "-" . maxPacks . " = " . (isValidForCurrentMethod ? "VALID" : "INVALID"))
                                } else {
                                    LogToFile("ERROR: Invalid range format for " . currentFile . ": " . injectRange)
                                    isValidForCurrentMethod := false
                                }
                            } else {
                                LogToFile("ERROR: Empty or invalid range for Inject Range method with " . currentFile . ": '" . injectRange . "'")
                                isValidForCurrentMethod := false
                            }
                        }
                        else {
                            ; Unknown inject method
                            LogToFile("WARNING: Unknown delete method '" . deleteMethod . "' for account " . currentFile)
                            isValidForCurrentMethod := false
                        }
                        
                        if (isValidForCurrentMethod) {
                            loadFile := testFile
                            accountFileName := currentFile
                            foundValidAccount := true
                            foundIndex := A_Index
                            
                            ; Log the selected account
                            LogToFile("Selected account: " . accountFileName . " (Modified " . accountModifiedTimeDiff . " hours ago, " . packCount . " packs)")
                            
                            ; Remove this account from the list
                            newListContent := ""
                            Loop, % fileLines.MaxIndex() {
                                if (A_Index != foundIndex)
                                    newListContent .= fileLines[A_Index] "`r`n"
                            }
                            
                            FileDelete, %outputTxt%  ; Delete old file
                            FileAppend, %newListContent%, %outputTxt%  ; Write back without the selected account
                            
                            break
                        } else {
                            LogToFile("Skipping account " . currentFile . " - doesn't match current injection criteria")
                        }
                    } else {
                        LogToFile("Skipping account " . currentFile . " - only " . accountModifiedTimeDiff . " hours old (need 24+)")
                    }
                }
                
                if (foundValidAccount)
                    break
                    
                cycle++
                Delay(1)
                
                if (cycle > 50) {
                    ; Too many attempts, likely no valid accounts for current method
                    LogToFile("No valid accounts found for method '" . deleteMethod . "' after 50 attempts")
                    LogToFile("Current ranges - Max: " . injectMaxValue . ", Min: " . injectMinValue . ", Range: '" . injectRange . "'")
                    return false
                }
            } else {
                ; No accounts in list
                LogToFile("No accounts in list_current.txt for method: " . deleteMethod)
                return false
            }
        }
    } else {
        ; File still doesn't exist after regeneration attempts
        LogToFile("Failed to create list_current.txt")
        return false
    }

    ; If we've reached this point, we have a valid account to load
    waitadb()
    adbShell.StdIn.WriteLine("am force-stop jp.pokemon.pokemontcgp")
    waitadb()

    Sleep, 3000
    RunWait, % adbPath . " -s 127.0.0.1:" . adbPort . " push " . loadFile . " /sdcard/deviceAccount.xml",, Hide

    Sleep, 3000
    waitadb()
    adbShell.StdIn.WriteLine("cp /sdcard/deviceAccount.xml /data/data/jp.pokemon.pokemontcgp/shared_prefs/deviceAccount:.xml")
    waitadb()
    adbShell.StdIn.WriteLine("rm /sdcard/deviceAccount.xml")
    waitadb()
    Sleep, 3000
    adbShell.StdIn.WriteLine("am start -n jp.pokemon.pokemontcgp/com.unity3d.player.UnityPlayerActivity")
    waitadb()
    Sleep, 1000

    ; Check if account file has pack number information
    if (InStr(accountFileName, "P")) {
        ; has pack information
        accountFileNameParts := StrSplit(accountFileName, "P")  ; Split at P
        accountOpenPacks := accountFileNameParts[1]
        accountFileNameTmp := accountFileNameParts[2]
        accountHasPackInfo := 1
        
        ; Log the pack count
        LogToFile("Account has " . accountOpenPacks . " packs")
    } else {
        accountFileNameOrig := accountFileName
        LogToFile("Account has no pack information in filename")
    }
    
    getMetaData()
    
    ; Track this account as used to prevent immediate reuse
    TrackUsedAccount(accountFileName)
    
    LogToFile("Successfully loaded account: " . accountFileName . " for method: " . deleteMethod)
    return loadFile
}

saveAccount(file := "Valid", ByRef filePath := "", packDetails := "") {

    filePath := ""

    if (file = "All") {
		metadata := ""
		if(beginnerMissionsDone)
			metadata .= "B"
		if(soloBattleMissionDone)
			metadata .= "S"
		if(intermediateMissionsDone)
			metadata .= "I"
		if(specialMissionsDone)
			metadata .= "X"
                if(accountHasPackInTesting)
                        metadata .= "T"
			
        saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
        filePath := saveDir . "\" . accountOpenPacks . "P_" . A_Now . "_" . winTitle . "(" . metadata . ").xml"
    } else if (file = "Valid" || file = "Invalid") {
        saveDir := A_ScriptDir "\..\Accounts\GodPacks\"
        xmlFile := A_Now . "_" . winTitle . "_" . file . "_" . packsInPool . "_packs.xml"
        filePath := saveDir . xmlFile
    } else if (file = "Tradeable") {
        saveDir := A_ScriptDir "\..\Accounts\Trades\"
		;packsInPool doesn't make sense but nothing does, really.
        xmlFile := A_Now . "_" . winTitle . "_" . file . (packDetails ? "_" . packDetails : "") . "_" . packsInPool . "_packs.xml"
        filePath := saveDir . xmlFile
    } else {
        saveDir := A_ScriptDir "\..\Accounts\SpecificCards\"
        xmlFile := A_Now . "_" . winTitle . "_" . file . "_" . packsInPool . "_packs.xml"
        filePath := saveDir . xmlFile
    }

    if !FileExist(saveDir) ; Check if the directory exists
        FileCreateDir, %saveDir% ; Create the directory if it doesn't exist

    count := 0
    Loop {
        if (Debug)
            CreateStatusMessage("Attempting to save account - " . count . "/10")
        else
            CreateStatusMessage("Saving account...",,,, false)

        adbShell.StdIn.WriteLine("cp -f /data/data/jp.pokemon.pokemontcgp/shared_prefs/deviceAccount:.xml /sdcard/deviceAccount.xml")
        waitadb()
        Sleep, 500

        RunWait, % adbPath . " -s 127.0.0.1:" . adbPort . " pull /sdcard/deviceAccount.xml """ . filePath,, Hide

        Sleep, 500

        adbShell.StdIn.WriteLine("rm /sdcard/deviceAccount.xml")

        Sleep, 500

        FileGetSize, OutputVar, %filePath%

        if(OutputVar > 0)
            break

        if(count > 10 && file != "All") {
            CreateStatusMessage("Account not saved. Pausing...",,,, false)
            LogToDiscord("Attempted to save account in " . scriptName . " but was unsuccessful. Pausing. You will need to manually extract.", Screenshot(), true)
            Pause, On
        }
        count++
    }

    return xmlFile
}

; Function to track used accounts to prevent immediate reuse
TrackUsedAccount(fileName) {
    global winTitle
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    usedAccountsLog := saveDir . "\used_accounts.txt"
    
    ; Append the file name with timestamp
    currentTime := A_Now
    FileAppend, % fileName . "|" . currentTime . "`n", %usedAccountsLog%
}
UpdateAccount() {
    global accountOpenPacks, accountFileName, accountFileNameParts, accountFileNameOrig, ocrSuccess, winTitle
    global aminutes, aseconds, rerolls
    
    accountOpenPacksStr := accountOpenPacks
    if(accountOpenPacks<10)
        accountOpenPacksStr := "0" . accountOpenPacks ; add a trailing 0 for sorting
        
    if(InStr(accountFileName, "P")){
        AccountName := StrSplit(accountFileName , "P")
        accountFileNameParts := StrSplit(accountFileName, "P")  ; Split at P
        AccountNewName := accountOpenPacksStr . "P" . accountFileNameParts[2]
    } else if (ocrSuccess)
        AccountNewName := accountOpenPacksStr . "P_" . accountFileNameOrig
    else
        return ; if OCR is not successful, don't modify account file
    
    if(!InStr(accountFileName, "P") || accountOpenPacks > 0) {          
        saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
        accountFile := saveDir . "\" . accountFileName
        accountNewFile := saveDir . "\" . AccountNewName
        FileMove, %accountFile% , %accountNewFile% ;TODO enable
        FileSetTime,, %accountNewFile%
        accountFileName := AccountNewName
    }
    
    ; Direct display of metrics rather than calling function
    CreateStatusMessage("Avg: " . aminutes . "m " . aseconds . "s | Runs: " . rerolls . " | Account Packs " . accountOpenPacks, "AvgRuns", 0, 605, false, true)
}
ControlClick(X, Y) {
    global winTitle
    ControlClick, x%X% y%Y%, %winTitle%
}

DownloadFile(url, filename) {
    url := url  ; Change to your hosted .txt URL "https://pastebin.com/raw/vYxsiqSs"
    localPath = %A_ScriptDir%\..\%filename% ; Change to the folder you want to save the file
    errored := false
    try {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url, true)
        whr.Send()
        whr.WaitForResponse()
        ids := whr.ResponseText
    } catch {
        errored := true
    }
    if(!errored) {
        FileDelete, %localPath%
        FileAppend, %ids%, %localPath%
    }
}

ReadFile(filename, numbers := false) {
    FileRead, content, %A_ScriptDir%\..\%filename%.txt

    if (!content)
        return false

    values := []
    for _, val in StrSplit(Trim(content), "`n") {
        cleanVal := RegExReplace(val, "[^a-zA-Z0-9]") ; Remove non-alphanumeric characters
        if (cleanVal != "")
            values.Push(cleanVal)
    }

    return values.MaxIndex() ? values : false
}


Screenshot_dev(fileType := "Dev",subDir := "") {
	global adbShell, scriptName, ocrLanguage, loadDir

	SetWorkingDir %A_ScriptDir%  ; Ensures the working directory is the script's directory

	; Define folder and file paths
	fileDir := A_ScriptDir "\..\Screenshots"
	if !FileExist(fileDir)
		FileCreateDir, %fileDir%
    if (subDir) {
        fileDir .= "\" . subDir
    }
	if !FileExist(fileDir)
		FileCreateDir, %fileDir%
		
	; File path for saving the screenshot locally
    fileName := A_Now . "_" . winTitle . "_" . fileType . ".png"
    filePath := fileDir "\" . fileName

	pBitmapW := from_window(WinExist(winTitle))
	Gdip_SaveBitmapToFile(pBitmapW, filePath) 
	
	sleep 100
	
    try {
        OwnerWND := WinExist(winTitle)
        buttonWidth := 40

        Gui, DevMode_ss%winTitle%:New, +LastFound -DPIScale
		Gui, DevMode_ss%winTitle%:Add, Picture, x0 y0 w275 h534, %filePath%
		Gui, DevMode_ss%winTitle%:Show, w275 h534, Screensho %winTitle%
		
		sleep 100
		msgbox click on top-left corner and bottom-right corners
		
		KeyWait, LButton, D
		MouseGetPos , X1, Y1, OutputVarWin, OutputVarControl
		KeyWait, LButton, U
		Y1 -= 31
		;MsgBox, The cursor is at X%X1% Y%Y1%.
		
		KeyWait, LButton, D
		MouseGetPos , X2, Y2, OutputVarWin, OutputVarControl
		KeyWait, LButton, U
		Y2 -= 31
		;MsgBox, The cursor is at X%X2% Y%Y2%.
		
		W:=X2-X1
		H:=Y2-Y1
		
		pBitmap := Gdip_CloneBitmapArea(pBitmapW, X1, Y1, W, H)
		
		InputBox, fileName, ,"Enter the name of the needle to save"
		
		fileDir := A_ScriptDir . "\Scale125"
		filePath := fileDir "\" . fileName . ".png"
		Gdip_SaveBitmapToFile(pBitmap, filePath) 
		
		msgbox click on coordinate for adbClick
		
		KeyWait, LButton, D
		MouseGetPos , X3, Y3, OutputVarWin, OutputVarControl
		KeyWait, LButton, U
		Y3 -= 31
		
		
		MsgBox, 	
		(LTrim
			ctrl+C to copy: 
			FindOrLoseImage(%X1%, %Y1%, %X2%, %Y2%, , "%fileName%", 0, failSafeTime)
            FindImageAndClick(%X1%, %Y1%, %X2%, %Y2%, , "%fileName%", %X3%, %Y3%, sleepTime)
			adbClick_wbb(%X3%, %Y3%)
		)
    }
    catch {
            msgbox Failed to create screenshot GUI
    }	
	return filePath
}

Screenshot(fileType := "Valid", subDir := "", ByRef fileName := "") {
    global adbShell, adbPath, packs
    SetWorkingDir %A_ScriptDir%  ; Ensures the working directory is the script's directory
		
    ; Define folder and file paths
    fileDir := A_ScriptDir "\..\Screenshots"
    if !FileExist(fileDir)
        FileCreateDir, fileDir
    if (subDir) {
        fileDir .= "\" . subDir
		if !FileExist(fileDir)
			FileCreateDir, fileDir
    }
	if (filename = "PACKSTATS") {
        fileDir .= "\temp"
		if !FileExist(fileDir)
			FileCreateDir, fileDir
	}

    ; File path for saving the screenshot locally
    fileName := A_Now . "_" . winTitle . "_" . fileType . "_" . packsInPool . "_packs.png"
    if (filename = "PACKSTATS") 
        fileName := "packstats_temp.png"
    filePath := fileDir "\" . fileName

    pBitmapW := from_window(WinExist(winTitle))
    pBitmap := Gdip_CloneBitmapArea(pBitmapW, 18, 175, 240, 227)
    ;scale 100%
    if (scaleParam = 287) {
        pBitmap := Gdip_CloneBitmapArea(pBitmapW, 17, 168, 245, 230)
    }
    Gdip_DisposeImage(pBitmapW)
    Gdip_SaveBitmapToFile(pBitmap, filePath)

    ; Don't dispose pBitmap if it's a PACKSTATS screenshot
    if (filename != "PACKSTATS") {
        Gdip_DisposeImage(pBitmap)
		return filePath
    }
    
    ; For PACKSTATS, return both values and delete temp file after OCR is done
    return {filepath: filePath, bitmap: pBitmap, deleteAfterUse: true}
}


; Pause Script
PauseScript:
    CreateStatusMessage("Pausing...",,,, false)
    Pause, On
return

; Resume Script
ResumeScript:
    CreateStatusMessage("Resuming...",,,, false)
    StartSkipTime := A_TickCount ;reset stuck timers
    failSafe := A_TickCount
    Pause, Off
return

; Stop Script
StopScript:
    ToggleStop()
return

DevMode:
	ToggleDevMode()
return

ShowStatusMessages:
    ToggleStatusMessages()
return

ReloadScript:
    Reload
return

TestScript:
    ToggleTestScript()
return

ToggleStop() {
    global stopToggle, friended
    stopToggle := true
    if (!friended)
        ExitApp
    else
        CreateStatusMessage("Stopping script at the end of the run...",,,, false)
}

ToggleTestScript() {
    global GPTest
    if(!GPTest) {
        CreateStatusMessage("In GP Test Mode",,,, false)
        GPTest := true
    }
    else {
        CreateStatusMessage("Exiting GP Test Mode",,,, false)
        ;Winset, Alwaysontop, On, %winTitle%
        GPTest := false
    }
}

; Function to append a time and variable pair to the JSON file
AppendToJsonFile(variableValue) {
    global jsonFileName
    if (!jsonFileName || !variableValue) {
        return
    }

    ; Read the current content of the JSON file
    FileRead, jsonContent, %jsonFileName%
    if (jsonContent = "") {
        jsonContent := "[]"
    }

    ; Parse and modify the JSON content
    jsonContent := SubStr(jsonContent, 1, StrLen(jsonContent) - 1) ; Remove trailing bracket
    if (jsonContent != "[")
        jsonContent .= ","
    jsonContent .= "{""time"": """ A_Now """, ""variable"": " variableValue "}]"

    ; Write the updated JSON back to the file
    FileDelete, %jsonFileName%
    FileAppend, %jsonContent%, %jsonFileName%
}

from_window(ByRef image) {
    ; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517

    ; Get the handle to the window.
    image := (hwnd := WinExist(image)) ? hwnd : image

    ; Restore the window if minimized! Must be visible for capture.
    if DllCall("IsIconic", "ptr", image)
        DllCall("ShowWindow", "ptr", image, "int", 4)

    ; Get the width and height of the client window.
    VarSetCapacity(Rect, 16) ; sizeof(RECT) = 16
    DllCall("GetClientRect", "ptr", image, "ptr", &Rect)
        , width  := NumGet(Rect, 8, "int")
        , height := NumGet(Rect, 12, "int")

    ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
    hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
    VarSetCapacity(bi, 40, 0)                ; sizeof(bi) = 40
        , NumPut(       40, bi,  0,   "uint") ; Size
        , NumPut(    width, bi,  4,   "uint") ; Width
        , NumPut(  -height, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
        , NumPut(        1, bi, 12, "ushort") ; Planes
        , NumPut(       32, bi, 14, "ushort") ; BitCount / BitsPerPixel
        , NumPut(        0, bi, 16,   "uint") ; Compression = BI_RGB
        , NumPut(        3, bi, 20,   "uint") ; Quality setting (3 = low quality, no anti-aliasing)
    hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits:=0, "ptr", 0, "uint", 0, "ptr")
    obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

    ; Print the window onto the hBitmap using an undocumented flag. https://stackoverflow.com/a/40042587
    DllCall("PrintWindow", "ptr", image, "ptr", hdc, "uint", 0x3) ; PW_CLIENTONLY | PW_RENDERFULLCONTENT
    ; Additional info on how this is implemented: https://www.reddit.com/r/windows/comments/8ffr56/altprintscreen/

    ; Convert the hBitmap to a Bitmap using a built in function as there is no transparency.
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hbm, "ptr", 0, "ptr*", pBitmap:=0)

    ; Cleanup the hBitmap and device contexts.
    DllCall("SelectObject", "ptr", hdc, "ptr", obm)
    DllCall("DeleteObject", "ptr", hbm)
    DllCall("DeleteDC",     "ptr", hdc)

    return pBitmap
}

~+F5::Reload
~+F6::Pause
~+F7::ToggleStop()
~+F8::ToggleDevMode()
;~+F8::ToggleStatusMessages()
;~F9::restartGameInstance("F9")

ToggleDevMode() {
	
    try {
        OwnerWND := WinExist(winTitle)
        x4 := x + 5
        y4 := y + 44
        buttonWidth := 40

        Gui, DevMode%winTitle%:New, +LastFound
        Gui, DevMode%winTitle%:Font, s5 cGray Norm Bold, Segoe UI  ; Normal font for input labels
        Gui, DevMode%winTitle%:Add, Button, % "x" . (buttonWidth * 0) . " y0 w" . buttonWidth . " h25 gbboxScript", bound box
		
		Gui, DevMode%winTitle%:Add, Button, % "x" . (buttonWidth * 1) . " y0 w" . buttonWidth . " h25 gbboxNpauseScript", bbox pause
		
		Gui, DevMode%winTitle%:Add, Button, % "x" . (buttonWidth * 2) . " y0 w" . buttonWidth . " h25 gscreenshotscript", screen grab
		
		Gui, DevMode%winTitle%:Show, w250 h100, Dev Mode %winTitle%
		
    }
    catch {
            CreateStatusMessage("Failed to create button GUI.",,,, false)
    }	
}

screenshotscript:
	Screenshot_dev()
return

bboxScript:
    ToggleBBox()
return

ToggleBBox() {
	dbg_bbox := !dbg_bbox
}

bboxNpauseScript:
    TogglebboxNpause()
return

TogglebboxNpause() {
	dbg_bboxNpause := !dbg_bboxNpause
}

dbg_bbox :=0
dbg_bboxNpause :=0
dbg_bbox_click :=0

ToggleStatusMessages() {
    if(showStatus) {
        showStatus := False
    }
    else
        showStatus := True
}

RefreshAccountLists:
    createAccountList(scriptName)
    Return


bboxDraw(X1, Y1, X2, Y2, color) {
	WinGetPos, xwin, ywin, Width, Height, %winTitle%
    BoxWidth := X2-X1
    BoxHeight := Y2-Y1
    ; Create a GUI
    Gui, BoundingBox%winTitle%:+AlwaysOnTop +ToolWindow -Caption +E0x20
    Gui, BoundingBox%winTitle%:Color, 123456
    Gui, BoundingBox%winTitle%:+LastFound  ; Make the GUI window the last found window for use by the line below. (straght from documentation)
    WinSet, TransColor, 123456 ; Makes that specific color transparent in the gui

    ; Create the borders and show
	Gui, BoundingBox%winTitle%:Add, Progress, x0 y0 w%BoxWidth% h2 %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x0 y0 w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%BoxWidth% y0 w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x0 y%BoxHeight% w%BoxWidth% h2 %color%
	
	xshow := X1+xwin
	yshow := Y1+ywin
	Gui, BoundingBox%winTitle%:Show, x%xshow% y%yshow% NoActivate
    Sleep, 100

}


bboxDraw2(X1, Y1, X2, Y2, color) {
	WinGetPos, xwin, ywin, Width, Height, %winTitle%
    BoxWidth := 10
    BoxHeight := 10
	Xm1:=X1-(BoxWidth/2)
	Xm2:=X2-(BoxWidth/2)
	Ym1:=Y1-(BoxWidth/2)
	Ym2:=Y2-(BoxWidth/2)
	Xh1:=Xm1+BoxWidth
	Xh2:=Xm2+BoxWidth
	Yh1:=Ym1+BoxHeight
	Yh2:=Ym2+BoxHeight
	
    ; Create a GUI
    Gui, BoundingBox%winTitle%:+AlwaysOnTop +ToolWindow -Caption +E0x20
    Gui, BoundingBox%winTitle%:Color, 123456
    Gui, BoundingBox%winTitle%:+LastFound  ; Make the GUI window the last found window for use by the line below. (straght from documentation)
    WinSet, TransColor, 123456 ; Makes that specific color transparent in the gui

    ; Create the borders and show
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm1% y%Ym1% w%BoxWidth% h2 %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm1% y%Ym1% w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xh1% y%Ym1% w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm1% y%Yh1% w%BoxWidth% h2 %color%
	
    ; Create the borders and show
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm2% y%Ym2% w%BoxWidth% h2 %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm2% y%Ym2% w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xh2% y%Ym2% w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm2% y%Yh2% w%BoxWidth% h2 %color%
	
	xshow := xwin
	yshow := ywin
	Gui, BoundingBox%winTitle%:Show, x%xshow% y%yshow% NoActivate
    Sleep, 100

}

adbSwipe_wbb(params) {
	if(dbg_bbox)
		bboxAndPause_swipe(params, dbg_bboxNpause)
    adbSwipe(params)
}

bboxAndPause_swipe(params, doPause := False) {
	paramsplit := StrSplit(params , " ")
	X1:=round(paramsplit[1] / 535 * 277)
	Y1:=round((paramsplit[2] / 960 * 489) + 44)
	X2:=round(paramsplit[3] / 535 * 277)
	Y2:=round((paramsplit[4] / 960 * 489) + 44)
	speed:=paramsplit[5]
	CreateStatusMessage("Swiping (" . X1 . "," . Y1 . ") to (" . X2 . "," . Y2 . ") speed " . speed,,,, false)
	
	color := "BackgroundYellow"
	
	;bboxDraw2(X1, Y1, X2, Y2, color)
	
	bboxDraw(X1-5, Y1-5, X1+5, Y1+5, color)
    if (doPause) {
        Pause
    }
    Gui, BoundingBox%winTitle%:Destroy
	
	bboxDraw(X2-5, Y2-5, X2+5, Y2+5, color)
    if (doPause) {
        Pause
    }
	Gui, BoundingBox%winTitle%:Destroy
}

adbClick_wbb(X,Y)  {
	if(dbg_bbox)
		bboxAndPause_click(X, Y, dbg_bboxNpause)
	adbClick(X,Y)
}

bboxAndPause_click(X, Y, doPause := False) {
	CreateStatusMessage("Clicking X " . X . " Y " . Y,,,, false)
	
	color := "BackgroundBlue"
	
	bboxDraw(X-5, Y-5, X+5, Y+5, color)
	
    if (doPause) {
        Pause
    }

    if GetKeyState("F4", "P") {
        Pause
    }
    Gui, BoundingBox%winTitle%:Destroy
}

bboxAndPause_immage(X1, Y1, X2, Y2, pNeedleObj, vret := False, doPause := False) {
	CreateStatusMessage("Searching " . pNeedleObj.Name . " returns " . vret,,,, false)
	
	if(vret>0) {
		color := "BackgroundGreen"
	} else {
		color := "BackgroundRed"
	}
	
	bboxDraw(X1, Y1, X2, Y2, color)
	
    if (doPause && vret) {
        Pause
    }

    if GetKeyState("F4", "P") {
        Pause
    }
    Gui, BoundingBox%winTitle%:Destroy
}


Gdip_ImageSearch_wbb(pBitmapHaystack,pNeedle,ByRef OutputList=""
,OuterX1=0,OuterY1=0,OuterX2=0,OuterY2=0,Variation=0,Trans=""
,SearchDirection=1,Instances=1,LineDelim="`n",CoordDelim=",") {

	vret := Gdip_ImageSearch(pBitmapHaystack,pNeedle.needle,OutputList,OuterX1,OuterY1,OuterX2,OuterY2,Variation,Trans,SearchDirection,Instances,LineDelim,CoordDelim)
	if(dbg_bbox)
		bboxAndPause_immage(OuterX1, OuterY1, OuterX2, OuterY2, pNeedle, vret, dbg_bboxNpause)
	return vret
}

GetNeedle(Path) {
    static NeedleBitmaps := Object()
	
    if (NeedleBitmaps.HasKey(Path)) {
        return NeedleBitmaps[Path]
    } else {
        pNeedle := Gdip_CreateBitmapFromFile(Path)
		needleObj := Object()
		needleObj.Path := Path
		pathsplit := StrSplit(Path , "\")
		needleObj.Name := pathsplit[pathsplit.MaxIndex()]
		needleObj.needle := pNeedle
        NeedleBitmaps[Path] := needleObj
        return needleObj
    }
		
    if (NeedleBitmaps.HasKey(Path)) {
        return NeedleBitmaps[Path]
    } else {
        pNeedle := Gdip_CreateBitmapFromFile(Path)
        NeedleBitmaps[Path] := pNeedle
        return pNeedle
    }
}
MonthToDays(year, month) {
    static DaysInMonths := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    days := 0
    Loop, % month - 1 {
        days += DaysInMonths[A_Index]
    }
    if (month > 2 && IsLeapYear(year))
        days += 1
    return days
}

IsLeapYear(year) {
    return (Mod(year, 4) = 0 && Mod(year, 100) != 0) || Mod(year, 400) = 0
}

Delay(n) {
    global Delay
    msTime := Delay * n
    Sleep, msTime
}

DoTutorial() {
    FindImageAndClick(105, 396, 121, 406, , "Country", 143, 370) ;select month and year and click

    Delay(1)
    adbClick_wbb(80, 400)
    Delay(1)
    adbClick_wbb(80, 375)
    Delay(1)
    failSafe := A_TickCount
    failSafeTime := 0

    Loop
    {
        Delay(1)
        if(FindImageAndClick(100, 386, 138, 416, , "Month", , , , 1, failSafeTime))
            break
        Delay(1)
        adbClick_wbb(142, 159)
        Delay(1)
        adbClick_wbb(80, 400)
        Delay(1)
        adbClick_wbb(80, 375)
        Delay(1)
        adbClick_wbb(82, 422)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Month`n(" . failSafeTime . "/45 seconds)")
    } ;select month and year and click

    adbClick_wbb(200, 400)
    Delay(1)
    adbClick_wbb(200, 375)
    Delay(1)
    failSafe := A_TickCount
    failSafeTime := 0
    Loop ;select month and year and click
    {
        Delay(1)
        if(FindImageAndClick(148, 384, 256, 419, , "Year", , , , 1, failSafeTime))
            break
        Delay(1)
        adbClick_wbb(142, 159)
        Delay(1)
        adbClick_wbb(142, 159)
        Delay(1)
        adbClick_wbb(200, 400)
        Delay(1)
        adbClick_wbb(200, 375)
        Delay(1)
        adbClick_wbb(142, 159)
        Delay(1)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Year`n(" . failSafeTime . "/45 seconds)")
    } ;select month and year and click

    Delay(1)
    if(FindOrLoseImage(93, 471, 122, 485, , "CountrySelect", 0)) {
        FindImageAndClick(110, 134, 164, 160, , "CountrySelect2", 141, 237, 500)
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            countryOK := FindOrLoseImage(93, 450, 122, 470, , "CountrySelect", 0, failSafeTime)
            birthFound := FindOrLoseImage(116, 352, 138, 389, , "Birth", 0, failSafeTime)
            if(countryOK)
                adbClick_wbb(124, 250)
            else if(!birthFound)
                    adbClick_wbb(140, 474)
            else if(birthFound)
                break
            Delay(2)
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for country select for " . failSafeTime . "/45 seconds")
        }
    } else {
        FindImageAndClick(116, 352, 138, 389, , "Birth", 140, 474, 1000)
    }

    ;wait date confirmation screen while clicking ok

    FindImageAndClick(210, 285, 250, 315, , "TosScreen", 203, 371, 1000) ;wait to be at the tos screen while confirming birth

    FindImageAndClick(129, 477, 156, 494, , "Tos", 139, 299, 1000) ;wait for tos while clicking it

    FindImageAndClick(210, 285, 250, 315, , "TosScreen", 142, 486, 1000) ;wait to be at the tos screen and click x

    FindImageAndClick(129, 477, 156, 494, , "Privacy", 142, 339, 1000) ;wait to be at the tos screen

    FindImageAndClick(210, 285, 250, 315, , "TosScreen", 142, 486, 1000) ;wait to be at the tos screen, click X

    Delay(1)
    adbClick_wbb(261, 374)

    Delay(1)
    adbClick_wbb(261, 406)

    Delay(1)
    adbClick_wbb(145, 484)

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        if(FindImageAndClick(30, 336, 53, 370, , "Save", 145, 484, , 2, failSafeTime)) ;wait to be at create save data screen while clicking
            break
        Delay(1)
        adbClick_wbb(261, 406)
        if(FindImageAndClick(30, 336, 53, 370, , "Save", 145, 484, , 2, failSafeTime)) ;wait to be at create save data screen while clicking
            break
        Delay(1)
        adbClick_wbb(261, 374)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Save`n(" . failSafeTime . "/45 seconds)")
    }

    Delay(1)

    adbClick_wbb(143, 348)

    Delay(1)

    FindImageAndClick(51, 335, 107, 359, , "Link") ;wait for link account screen%
    Delay(1)
    failSafe := A_TickCount
    failSafeTime := 0
        Loop {
            if(FindOrLoseImage(51, 335, 107, 359, , "Link", 0, failSafeTime)) {
                adbClick_wbb(140, 460)
                Loop {
                    Delay(1)
                    if(FindOrLoseImage(51, 335, 107, 359, , "Link", 1, failSafeTime)) {
                        adbClick_wbb(140, 380) ; click ok on the interrupted while opening pack prompt
                        break
                    }
                    failSafeTime := (A_TickCount - failSafe) // 1000
                }
            } else if(FindOrLoseImage(110, 350, 150, 404, , "Confirm", 0, failSafeTime)) {
                adbClick_wbb(203, 364)
            } else if(FindOrLoseImage(215, 371, 264, 418, , "Complete", 0, failSafeTime)) {
                adbClick_wbb(140, 370)
            } else if(FindOrLoseImage(0, 46, 20, 70, , "Cinematic", 0, failSafeTime)) {
                break
            }
            Delay(1)
            failSafeTime := (A_TickCount - failSafe) // 1000
        }

        if(setSpeed = 3) {
            FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
            FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
            Delay(1)
            adbClick_wbb(41, 296)
            Delay(1)
        }

        FindImageAndClick(110, 230, 182, 257, , "Welcome", 253, 506, 110) ;click through cutscene until welcome page

        if(setSpeed = 3) {
            FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings

            FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
            Delay(1)
            adbClick_wbb(41, 296)
        }
    FindImageAndClick(190, 241, 225, 270, , "Name", 189, 438) ;wait for name input screen
    ;choose any
    Delay(1)
    if(FindOrLoseImage(147, 160, 157, 169, , "Erika", 1)) {
        adbClick_wbb(143, 207)
        Delay(1)
        adbClick_wbb(143, 207)
        FindImageAndClick(165, 294, 173, 301, , "ChooseErika", 143, 306)
        FindImageAndClick(190, 241, 225, 270, , "Name", 143, 462) ;wait for name input screen
    }
    FindImageAndClick(0, 476, 40, 502, , "OK", 139, 257) ;wait for name input screen

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
    ; Check for AccountName in Settings.ini
    IniRead, accountNameValue, %A_ScriptDir%\..\Settings.ini, UserSettings, AccountName, ERROR

    ; Use AccountName if it exists and isn't empty
    if (accountNameValue != "ERROR" && accountNameValue != "") {
        Random, randomNum, 1, 500 ; Generate random number from 1 to 500
        username := accountNameValue . "-" . randomNum
        username := SubStr(username, 1, 14)  ; max character limit
        LogToFile("Using AccountName: " . username)
    } else {
        fileName := A_ScriptDir . "\..\usernames.txt"
        if(FileExist(fileName))
            name := ReadFile("usernames")
        else
            name := ReadFile("usernames_default")

        Random, randomIndex, 1, name.MaxIndex()
        username := name[randomIndex]
        username := SubStr(username, 1, 14)  ; max character limit
        LogToFile("Using random username: " . username)
    }

    adbInput(username)
    Delay(1)
    if(FindImageAndClick(121, 490, 161, 520, , "Return", 185, 372, , 10)) ;click through until return button on open pack
        break
    adbClick_wbb(90, 370)
    Delay(1)
    adbClick_wbb(139, 254) ; 139 254 194 372
    Delay(1)
    adbClick_wbb(139, 254)
    Delay(1)
    EraseInput() ; incase the random pokemon is not accepted
    failSafeTime := (A_TickCount - failSafe) // 1000
    CreateStatusMessage("In failsafe for Trace. " . failSafeTime "/45 seconds")
    if(failSafeTime > 45)
        restartGameInstance("Stuck at name")
}


    Delay(1)

    adbClick_wbb(140, 424)

    FindImageAndClick(225, 273, 235, 290, , "Pack", 140, 424) ;wait for pack to be ready  to trace
        if(setSpeed > 1) {
            FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
            FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
            Delay(1)
        }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbSwipe_wbb(adbSwipeParams)
        Sleep, 10
        if (FindOrLoseImage(225, 273, 235, 290, , "Pack", 1, failSafeTime)){
            if(setSpeed > 1) {
                if(setSpeed = 3)
                        FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click 3x
                else
                        FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click 2x
            }
            adbClick_wbb(41, 296)
                break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Pack`n(" . failSafeTime . "/45 seconds)")
    }

    FindImageAndClick(34, 99, 74, 131, , "Swipe", 140, 375) ;click through cards until needing to swipe up
        if(setSpeed > 1) {
            FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
            FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
            Delay(1)
        }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbSwipe_wbb("266 770 266 355 60")
        Sleep, 10
        if (FindOrLoseImage(120, 70, 150, 95, , "SwipeUp", 0, failSafeTime)){
            if(setSpeed > 1) {
                if(setSpeed = 3)
                        FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
                else
                        FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
            }
            adbClick_wbb(41, 296)
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for swipe up for " . failSafeTime . "/45 seconds")
        Delay(1)
    }

Delay(1)
    if(setSpeed > 2) {
        FindImageAndClick(136, 420, 151, 436, , "Move", 134, 375, 500) ; click through until move
        FindImageAndClick(50, 394, 86, 412, , "Proceed", 141, 483, 750) ;wait for menu to proceed then click ok. increased delay in between clicks to fix freezing on 3x speed
    }
    else {
        FindImageAndClick(136, 420, 151, 436, , "Move", 134, 375) ; click through until move
        FindImageAndClick(50, 394, 86, 412, , "Proceed", 141, 483) ;wait for menu to proceed then click ok
    }

    Delay(1)
    adbClick_wbb(204, 371)

    FindImageAndClick(46, 368, 103, 411, , "Gray") ;wait for for missions to be clickable

    Delay(1)
    adbClick_wbb(247, 472)

    FindImageAndClick(115, 97, 174, 150, , "Pokeball", 247, 472, 5000) ; click through missions until missions is open

    Delay(1)
    adbClick_wbb(141, 294)
    Delay(1)
    adbClick_wbb(141, 294)
    Delay(1)
    FindImageAndClick(124, 168, 162, 207, , "Register", 141, 294, 1000) ; wait for register screen
    Delay(6)
    adbClick_wbb(140, 500)

    FindImageAndClick(115, 255, 176, 308, , "Mission") ; wait for mission complete screen

    FindImageAndClick(46, 368, 103, 411, , "Gray", 143, 360) ;wait for for missions to be clickable

    FindImageAndClick(170, 160, 220, 200, , "Notifications", 145, 194) ;click on packs. stop at booster pack tutorial

    Delay(3)
    adbClick_wbb(142, 436)
    Delay(3)
    adbClick_wbb(142, 436)
    Delay(3)
    adbClick_wbb(142, 436)
    Delay(3)
    adbClick_wbb(142, 436)

    FindImageAndClick(225, 273, 235, 290, , "Pack", 239, 497) ;wait for pack to be ready  to Trace
        if(setSpeed > 1) {
            FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
            FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
            Delay(1)
        }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbSwipe_wbb(adbSwipeParams)
        Sleep, 10
        if (FindOrLoseImage(225, 273, 235, 290, , "Pack", 1, failSafeTime)){
        if(setSpeed > 1) {
            if(setSpeed = 3)
                        FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
            else
                        FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
        }
                adbClick_wbb(41, 296)
                break
            }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Pack`n(" . failSafeTime . "/45 seconds)")
        Delay(1)
    }

    FindImageAndClick(0, 98, 116, 125, 5, "Opening", 239, 497) ;skip through cards until results opening screen

    FindImageAndClick(233, 486, 272, 519, , "Skip", 146, 496) ;click on next until skip button appears

    FindImageAndClick(120, 70, 150, 100, , "Next", 239, 497, , 2)

    FindImageAndClick(53, 281, 86, 310, , "Wonder", 146, 494) ;click on next until skip button appearsstop at hourglasses tutorial

    Delay(3)

    adbClick_wbb(140, 358)

    FindImageAndClick(191, 393, 211, 411, , "Shop", 146, 444) ;click until at main menu

    FindImageAndClick(87, 232, 131, 266, , "Wonder2", 79, 411) ; click until wonder pick tutorial screen

    FindImageAndClick(114, 430, 155, 441, , "Wonder3", 190, 437) ; click through tutorial

    Delay(2)

    FindImageAndClick(155, 281, 192, 315, , "Wonder4", 202, 347, 500) ; confirm wonder pick selection

    Delay(2)

    adbClick_wbb(208, 461)

    if(setSpeed = 3) ;time the animation
        Sleep, 1500
    else
        Sleep, 2500

    FindImageAndClick(60, 130, 202, 142, 10, "Pick", 208, 461, 350) ;stop at pick a card

    Delay(1)

    adbClick_wbb(187, 345)

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        if(setSpeed = 3)
            continueTime := 1
        else
            continueTime := 3

        if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime)) {
            adbClick_wbb(239, 497)
        } else if(FindOrLoseImage(110, 230, 182, 257, , "Welcome", 0, failSafeTime)) { ;click through to end of tut screen
            break
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next2", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        }
        else {
            adbClick_wbb(187, 345)
            Delay(1)
            adbClick_wbb(143, 492)
            Delay(1)
            adbClick_wbb(143, 492)
            Delay(1)
        }
        Delay(1)

        ; adbClick_wbb(66, 446)
        ; Delay(1)
        ; adbClick_wbb(66, 446)
        ; Delay(1)
        ; adbClick_wbb(66, 446)
        ; Delay(1)
        ; adbClick_wbb(187, 345)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for End`n(" . failSafeTime . "/45 seconds)")
    }

    FindImageAndClick(120, 316, 143, 335, , "Main", 192, 449) ;click until at main menu

    return true
}

SelectPack(HG := false) {
    global openPack, packArray
	
	; define constants
	MiddlePackX := 140
	RightPackX := 215
	LeftPackX := 60
	HomeScreenAllPackY := 203
	
	PackScreenAllPackY := 320
	
	SelectExpansionFirstRowY := 275
	SelectExpansionSecondRowY := 410
	
	SelectExpansionRightCollumnMiddleX := 200
	SelectExpansionLeftCollumnMiddleX := 73
	3PackExpansionLeft := -40
	3PackExpansionRight := 40
	2PackExpansionLeft := -20
	2PackExpansionRight := 20
	
	inselectexpansionscreen := 0
	
    packy := HomeScreenAllPackY
    if (openPack = "Solgaleo") {
        packx := MiddlePackX
    } else if (openPack = "Lunala") {
        packx := RightPackX
    } else {
        packx := LeftPackX
    }
	
	if(openPack = "Solgaleo" || openPack = "Lunala" || openPack = "Shining") {
		PackIsInHomeScreen := 1
	} else {
		PackIsInHomeScreen := 0
	}
	
	if(openPack = "Solgaleo" || openPack = "Lunala") {
		PackIsLatest := 1
	} else {
		PackIsLatest := 0
	}
		
	if (openPack = "Solgaleo" || openPack = "Lunala" || openPack = "Shining" || openPack = "Arceus" || openPack = "Dialga" || openPack = "Palkia") {
		packInTopRowsOfSelectExpansion := 1
	} else {
		packInTopRowsOfSelectExpansion := 0
	}
	
	

	if(HG = "First" && injectMethod && loadedAccount ){
		; when First and injection, if there are free packs, we don't land/start in home screen, 
		; and we have also to search for closed during pack, hourglass, etc.
		
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			adbClick_wbb(PackX, HomeScreenAllPackY) ; click until points appear (if free packs, will land in pack scree, if no free packs, this will select the middle pack and go to same screen as if there were free packs)
			Delay(1)
			if(FindOrLoseImage(233, 400, 264, 428, , "Points", 0, failSafeTime)) {
				break
			}
			else if(!renew && !getFC) {
				if(FindOrLoseImage(241, 377, 269, 407, , "closeduringpack", 0)) {
					adbClick_wbb(139, 371)
				}
			}
			else if(FindOrLoseImage(175, 165, 255, 235, , "Hourglass3", 0)) {
				;TODO hourglass tutorial still broken after injection
				Delay(3)
				adbClick_wbb(146, 441) ; 146 440
				Delay(3)
				adbClick_wbb(146, 441)
				Delay(3)
				adbClick_wbb(146, 441)
				Delay(3)

				FindImageAndClick(98, 184, 151, 224, , "Hourglass1", 168, 438, 500, 5) ;stop at hourglasses tutorial 2
				Delay(1)

				adbClick_wbb(203, 436) ; 203 436
				FindImageAndClick(236, 198, 266, 226, , "Hourglass2", 180, 436, 500) ;stop at hourglasses tutorial 2 180 to 203?
			}

			failSafeTime := (A_TickCount - failSafe) // 1000
			CreateStatusMessage("Waiting for Points`n(" . failSafeTime . "/90 seconds)")
		}
		
		if(!friendIDs && friendID = "") {
			; if we don't need to add any friends we can select directly the latest packs, or go directly to select other booster screen, 
				
			if(PackIsLatest) {   ; if selected pack is the latest pack select directly from the pack select screen
				packy := PackScreenAllPackY ; Y coordinate is lower when in pack select screen then in home screen
				
				if(packx != MiddlePackX) { ; if it is already the middle Pack, no need to click again
					Delay(10)
					adbClick_wbb(packx, packy) 
					Delay(10)
				}
			} else {
				FindImageAndClick(115, 140, 160, 155, , "SelectExpansion", 248, 459, 3000) ; if selected pack is not the latest pack click directly select other boosters
				
				if(PackIsInHomeScreen) {
					; the only one that is not handled below because should show in home page
					inselectexpansionscreen := 1
				}
			} 
		}
	} else {
		; if not first or not injected, or friends were added, always start from home page
		FindImageAndClick(233, 400, 264, 428, , "Points", packx, packy, 3000)  ; open selected pack from home page
	}

	; if not the ones showing in home screen, click select other booster packs
    if (!PackIsInHomeScreen && !inselectexpansionscreen) {
        FindImageAndClick(115, 140, 160, 155, , "SelectExpansion", 248, 459, 3000)
		inselectexpansionscreen := 1
	}
	
	if(inselectexpansionscreen) {
        if (!packInTopRowsOfSelectExpansion) {
            ; Swipe down
            adbSwipe("266 770 266 355 160")
            Sleep, 500

            packy := 470 ; after swiping use this Y coordinate
			
			if (openPack = "Mew") {
                packx := SelectExpansionLeftCollumnMiddleX
            } else if (openPack = "Charizard") {
                packx := SelectExpansionRightCollumnMiddleX + 3PackExpansionLeft
            } else if (openPack = "Mewtwo") {
                packx := SelectExpansionRightCollumnMiddleX
            } else if (openPack = "Pikachu") {
                packx := SelectExpansionRightCollumnMiddleX + 3PackExpansionRight
            
            }
        } else {
            if (openPack = "Solgaleo") {
				packy := SelectExpansionFirstRowY
                packx := SelectExpansionLeftCollumnMiddleX + 2PackExpansionLeft
            } else if (openPack = "Lunala") {
				packy := SelectExpansionFirstRowY
                packx := SelectExpansionLeftCollumnMiddleX + 2PackExpansionRight
            } else if (openPack = "Shining") {
				packy := SelectExpansionFirstRowY
                packx := SelectExpansionRightCollumnMiddleX 
            } else if (openPack = "Arceus") {
				packy := SelectExpansionSecondRowY
                packx := SelectExpansionLeftCollumnMiddleX
            } else if (openPack = "Dialga") {
				packy := SelectExpansionSecondRowY
                packx := SelectExpansionRightCollumnMiddleX + 2PackExpansionLeft
            } else if (openPack = "Palkia") {
				packy := SelectExpansionSecondRowY
                packx := SelectExpansionRightCollumnMiddleX + 2PackExpansionRight
            }
        }

        FindImageAndClick(233, 400, 264, 428, , "Points", packx, packy)
    }
	
	
	if(HG = "First" && injectMethod && loadedAccount && !accountHasPackInfo) {
		FindPackStats()
	}
	
	
    if(HG = "Tutorial") {
        FindImageAndClick(236, 198, 266, 226, , "Hourglass2", 180, 436, 500) ;stop at hourglasses tutorial 2 180 to 203?
    }
    else if(HG = "HGPack") {
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(49, 449, 70, 474, , "HourGlassAndPokeGoldPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(60, 440, 90, 480, , "PokeGoldPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(92, 299, 115, 317, , "notenoughitems", 0)) {
                cantOpenMorePacks := 1
            }
			if(cantOpenMorePacks)
				return
            adbClick_wbb(146, 439)
            Delay(1)
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for HourglassPack3`n(" . failSafeTime . "/45 seconds)")
        }
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 1, failSafeTime)) {
                break
            }
            adbClick_wbb(205, 458)
            Delay(1)
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for HourglassPack4`n(" . failSafeTime . "/45 seconds)")
        }
    }
    ;if(HG != "Tutorial")
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            if(FindImageAndClick(233, 486, 272, 519, , "Skip2", 172, 430, , 2)) { ;click on open button until skip button appears
                break
			} else if(FindOrLoseImage(92, 299, 115, 317, , "notenoughitems", 0)) {
				cantOpenMorePacks := 1
			}
			if(cantOpenMorePacks)
				return
            Delay(1)
            adbClick_wbb(200, 451) ;for hourglass???
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for Skip2`n(" . failSafeTime . "/45 seconds)")
        }
}
PackOpening() {
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbClick_wbb(146, 439)
		;stuck here if not enough items for the second pack
        Delay(1)
        if(FindOrLoseImage(225, 273, 235, 290, , "Pack", 0, failSafeTime)) {
            break ;wait for pack to be ready to Trace and click skip
		} else if(FindOrLoseImage(92, 299, 115, 317, , "notenoughitems", 0)) {
			cantOpenMorePacks := 1
		} else {
            adbClick_wbb(239, 497)
		}
		
		if(cantOpenMorePacks)
			return
		
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Pack`n(" . failSafeTime . "/45 seconds)")
        if(failSafeTime > 45){
		    if(friended){
			RemoveFriends()
			}
            restartGameInstance("Stuck at Pack")
		}
    }

    if(setSpeed > 1) {
    FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
    FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
        Delay(1)
    }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbSwipe_wbb(adbSwipeParams)
        Sleep, 10
        if (FindOrLoseImage(225, 273, 235, 290, , "Pack", 1, failSafeTime)){
        if(setSpeed > 1) {
            if(setSpeed = 3)
                    FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
            else
                    FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
        }
            adbClick_wbb(41, 296)
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Trace`n(" . failSafeTime . "/45 seconds)")
        Delay(1)
    }

    FindImageAndClick(0, 98, 116, 125, 5, "Opening", 239, 497) ;skip through cards until results opening screen

    CheckPack()
	
	if(!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum) 
		return

    ;FindImageAndClick(233, 486, 272, 519, , "Skip", 146, 494) ;click on next until skip button appears

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        Delay(1)
        if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime)) {
            adbClick_wbb(239, 497)
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next2", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(121, 465, 140, 485, , "ConfirmPack", 0, failSafeTime)) {
            break
        } else if(FindOrLoseImage(178, 193, 251, 282, , "Hourglass", 0, failSafeTime)) {
            break
		} else {
			adbClick_wbb(146, 494) ;146, 494
		} 
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Home`n(" . failSafeTime . "/45 seconds)")
        if(failSafeTime > 45)
            restartGameInstance("Stuck at Home")
    }
}

HourglassOpening(HG := false, NEIRestart := true) {
    if(!HG) {
        Delay(3)
        adbClick_wbb(146, 441) ; 146 440
        Delay(3)
        adbClick_wbb(146, 441)
        Delay(3)
        adbClick_wbb(146, 441)
        Delay(3)

        FindImageAndClick(98, 184, 151, 224, , "Hourglass1", 168, 438, 500, 5) ;stop at hourglasses tutorial 2
        Delay(1)

        adbClick_wbb(203, 436) ; 203 436

        if(packMethod) {
            AddFriends(true)
            SelectPack("Tutorial")
        }
        else {
            FindImageAndClick(236, 198, 266, 226, , "Hourglass2", 180, 436, 500) ;stop at hourglasses tutorial 2 180 to 203?
			
			if(cantOpenMorePacks)
				return
        }
    }
    if(!packMethod) {
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(40, 440, 70, 474, , "HourGlassAndPokeGoldPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(60, 440, 90, 480, , "PokeGoldPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(92, 299, 115, 317, , "notenoughitems", 0)) {
                cantOpenMorePacks := 1
            }
			if(cantOpenMorePacks)
				return
            adbClick_wbb(146, 439)
            Delay(1)
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for HourglassPack`n(" . failSafeTime . "/45 seconds)")
        }
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 1, failSafeTime)) {
                break
            }
            adbClick_wbb(205, 458)
            Delay(1)
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for HourglassPack2`n(" . failSafeTime . "/45 seconds)")
        }
    }
    Loop {
        adbClick_wbb(146, 439)
        Delay(1)
        if(FindOrLoseImage(225, 273, 235, 290, , "Pack", 0, failSafeTime))
            break ;wait for pack to be ready to Trace and click skip
        else
            adbClick_wbb(239, 497)
			
		if(cantOpenMorePacks)
			return
		
        clickButton := FindOrLoseImage(145, 440, 258, 480, 80, "Button", 0, failSafeTime)
        if(clickButton) {
            StringSplit, pos, clickButton, `,  ; Split at ", "
            if (scaleParam = 287) {
                pos2 += 5
            }
            adbClick_wbb(pos1, pos2)
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Pack`n(" . failSafeTime . "/45 seconds)")
        if(failSafeTime > 45){
		    if(friended){
			RemoveFriends()
			}
            restartGameInstance("Stuck at Pack")
		}
    }

    if(setSpeed > 1) {
    FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
    FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
        Delay(1)
    }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbSwipe_wbb(adbSwipeParams)
        Sleep, 10
        if (FindOrLoseImage(225, 273, 235, 290, , "Pack", 1, failSafeTime)){
        if(setSpeed > 1) {
            if(setSpeed = 3)
                    FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
            else
                    FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
        }
            adbClick_wbb(41, 296)
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Trace`n(" . failSafeTime . "/45 seconds)")
        Delay(1)
    }

    FindImageAndClick(0, 98, 116, 125, 5, "Opening", 239, 497) ;skip through cards until results opening screen

    CheckPack()
	
	if(!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum) 
		return

    ;FindImageAndClick(233, 486, 272, 519, , "Skip", 146, 494) ;click on next until skip button appears

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        Delay(1)
        if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime)) {
            adbClick_wbb(239, 497)
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next2", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(121, 465, 140, 485, , "ConfirmPack", 0, failSafeTime)) {
            break
        } else {
			adbClick_wbb(146, 494) ;146, 494
		} 
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for ConfirmPack`n(" . failSafeTime . "/45 seconds)")
        if(failSafeTime > 45)
            restartGameInstance("Stuck at ConfirmPack")
    }
}

getFriendCode() {
    global friendCode
    CreateStatusMessage("Getting friend code...",,,, false)
    Sleep, 2000
    FindImageAndClick(233, 486, 272, 519, , "Skip", 146, 494) ;click on next until skip button appears
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        Delay(1)
        if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime)) {
            adbClick_wbb(239, 497)
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next2", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(121, 465, 140, 485, , "ConfirmPack", 0, failSafeTime)) {
            break
        }
        else if(FindOrLoseImage(20, 500, 55, 530, , "Home", 0, failSafeTime)) {
            break
        }
failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Home`n(" . failSafeTime . "/45 seconds)")
        if(failSafeTime > 45)
            restartGameInstance("Stuck at Home")
    }
    friendCode := AddFriends(false, true)

    return friendCode
}

SortArraysByProperty(fileNames, fileTimes, packCounts, property, ascending) {
    n := fileNames.MaxIndex()
    
    ; Create an array of indices for sorting
    indices := []
    Loop, %n% {
        indices.Push(A_Index)
    }
    
    ; Sort the indices based on the specified property
    if (property == "time") {
        if (ascending) {
            ; Sort by time ascending
            Sort(indices, Func("CompareIndicesByTimeAsc").Bind(fileTimes))
        } else {
            ; Sort by time descending
            Sort(indices, Func("CompareIndicesByTimeDesc").Bind(fileTimes))
        }
    } else if (property == "packs") {
        if (ascending) {
            ; Sort by pack count ascending
            Sort(indices, Func("CompareIndicesByPacksAsc").Bind(packCounts))
        } else {
            ; Sort by pack count descending
            Sort(indices, Func("CompareIndicesByPacksDesc").Bind(packCounts))
        }
    }
    
    ; Create temporary arrays for sorted values
    sortedFileNames := []
    sortedFileTimes := []
    sortedPackCounts := []
    
    ; Populate sorted arrays based on sorted indices
    Loop, %n% {
        idx := indices[A_Index]
        sortedFileNames.Push(fileNames[idx])
        sortedFileTimes.Push(fileTimes[idx])
        sortedPackCounts.Push(packCounts[idx])
    }
    
    ; Copy sorted values back to original arrays
    Loop, %n% {
        fileNames[A_Index] := sortedFileNames[A_Index]
        fileTimes[A_Index] := sortedFileTimes[A_Index]
        packCounts[A_Index] := sortedPackCounts[A_Index]
    }
}

; Helper function to sort an array using a custom comparison function
Sort(array, compareFunc) {
    QuickSort(array, 1, array.MaxIndex(), compareFunc)
    return array
}

QuickSort(array, left, right, compareFunc) {
    ; Create a manual stack to avoid deep recursion
    stack := []
    stack.Push([left, right])
    
    ; Process all partitions iteratively
    while (stack.Length() > 0) {
        current := stack.Pop()
        currentLeft := current[1]
        currentRight := current[2]
        
        if (currentLeft < currentRight) {
            ; Use middle element as pivot
            pivotIndex := Floor((currentLeft + currentRight) / 2)
            pivotValue := array[pivotIndex]
            
            ; Move pivot to end
            temp := array[pivotIndex]
            array[pivotIndex] := array[currentRight]
            array[currentRight] := temp
            
            ; Move all elements smaller than pivot to the left
            storeIndex := currentLeft
            i := currentLeft
            while (i < currentRight) {
                if (compareFunc.Call(array[i], array[currentRight]) < 0) {
                    ; Swap elements
                    temp := array[i]
                    array[i] := array[storeIndex]
                    array[storeIndex] := temp
                    storeIndex++
                }
                i++
            }
            
            ; Move pivot to its final place
            temp := array[storeIndex]
            array[storeIndex] := array[currentRight]
            array[currentRight] := temp
            
            ; Push the larger partition first (optimization)
            if (storeIndex - currentLeft < currentRight - storeIndex) {
                stack.Push([storeIndex + 1, currentRight])
                stack.Push([currentLeft, storeIndex - 1])
            } else {
                stack.Push([currentLeft, storeIndex - 1])
                stack.Push([storeIndex + 1, currentRight])
            }
        }
    }
}

; Comparison functions for different sorting criteria
CompareIndicesByTimeAsc(times, a, b) {
    timeA := times[a]
    timeB := times[b]
    return timeA < timeB ? -1 : (timeA > timeB ? 1 : 0)
}

CompareIndicesByTimeDesc(times, a, b) {
    timeA := times[a]
    timeB := times[b]
    return timeB < timeA ? -1 : (timeB > timeA ? 1 : 0)
}

CompareIndicesByPacksAsc(packs, a, b) {
    packsA := packs[a]
    packsB := packs[b]
    return packsA < packsB ? -1 : (packsA > packsB ? 1 : 0)
}

CompareIndicesByPacksDesc(packs, a, b) {
    packsA := packs[a]
    packsB := packs[b]
    return packsB < packsA ? -1 : (packsB > packsA ? 1 : 0)
}

; Function to create the sorted account list for injection
createAccountList(instance) {
    global injectSortMethod, deleteMethod, injectVariable, winTitle, verboseLogging
    global injectMaxValue, injectMinValue, injectRange
    
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . instance
    outputTxt := saveDir . "\list.txt"
    outputTxt_current := saveDir . "\list_current.txt"
    lastGeneratedFile := saveDir . "\list_last_generated.txt"
    
    ; Check if we need to regenerate the lists
    needRegeneration := false
    
    ; Check if list files exist
    if (!FileExist(outputTxt) || !FileExist(outputTxt_current)) {
        needRegeneration := true
        LogToFile("List files don't exist, regenerating...")
    } else {
        ; Check when lists were last generated
        lastGenTime := 0
        if (FileExist(lastGeneratedFile)) {
            FileRead, lastGenTime, %lastGeneratedFile%
        }
        
        ; Calculate time difference
        timeDiff := A_Now
        EnvSub, timeDiff, %lastGenTime%, Minutes
        
        ; Regenerate if it's been more than 60 minutes (1 hour)
        regenerationInterval := 60  ; in minutes
        if (timeDiff > regenerationInterval || !lastGenTime) {
            needRegeneration := true
            LogToFile("Lists last generated " . timeDiff . " minutes ago, regenerating...")
        } else {
            LogToFile("Lists generated " . timeDiff . " minutes ago, reusing existing lists")
            return  ; Exit the function early, no need to regenerate
        }
    }
    
    ; If we don't need to regenerate, exit the function
    if (!needRegeneration) {
        return
    }
    
    ; Default sort method if not defined
    if (!injectSortMethod)
        injectSortMethod := "ModifiedAsc"  ; Default sort method
    
    ; Re-read injection values to ensure we have the latest
    IniRead, injectMaxValue, %A_ScriptDir%\..\Settings.ini, UserSettings, injectMaxValue, 39
    IniRead, injectMinValue, %A_ScriptDir%\..\Settings.ini, UserSettings, injectMinValue, 35
    IniRead, injectRange, %A_ScriptDir%\..\Settings.ini, UserSettings, injectRange, ""
    
    ; Parse inject method from deleteMethod and set proper ranges
    parseInjectType := "Inject"  ; Default
    
    ; NEW LOGIC: Parse the deleteMethod to determine the injection type and ranges
    if (deleteMethod = "Inject") {
        parseInjectType := "Inject"
        minPacks := 0
        maxPacks := injectMaxValue + 0  ; Use user-defined max value, force numeric
        LogToFile("Inject mode: Using max value " . injectMaxValue . " (range: 0-" . injectMaxValue . ")")
    }
    else if (deleteMethod = "Inject long") {
        parseInjectType := "Inject Long"
        minPacks := 0
        maxPacks := injectMaxValue + 0  ; Use user-defined max value, force numeric
        LogToFile("Inject long mode: Using max value " . injectMaxValue . " (range: 0-" . injectMaxValue . ")")
    }
    else if (deleteMethod = "Inject for Reroll") {
        parseInjectType := "Inject for Reroll"
        minPacks := injectMinValue + 0  ; Use user-defined min value, force numeric
        maxPacks := 9999  ; No upper limit for reroll
        LogToFile("Inject for Reroll mode: Using min value " . injectMinValue . " (range: " . injectMinValue . "+)")
    }
    else if (deleteMethod = "Inject Range") {
        parseInjectType := "Inject Range"
        
        ; Parse the range from injectRange field
        if (injectRange != "" && InStr(injectRange, "-")) {
            rangeParts := StrSplit(injectRange, "-")
            if (rangeParts.Length() >= 2) {
                minPacks := rangeParts[1] + 0  ; Force numeric conversion
                maxPacks := rangeParts[2] + 0
                LogToFile("Inject Range mode: Using range " . minPacks . "-" . maxPacks . " from user input: " . injectRange)
            } else {
                ; Fallback if format is incorrect
                minPacks := 35
                maxPacks := 45
                LogToFile("ERROR: Invalid injectRange format: " . injectRange . ", using default 35-45")
            }
        } else {
            ; Default range if field is empty or invalid
            minPacks := 35
            maxPacks := 45
            LogToFile("Inject Range mode: Empty or invalid range field '" . injectRange . "', using default 35-45")
        }
    }
    else {
        ; Fallback for any other inject methods
        parseInjectType := "Unknown Inject"
        minPacks := 0
        maxPacks := 39
        LogToFile("Unknown inject method: " . deleteMethod . ", using default 0-39")
    }
    
    LogToFile("Final injection parameters - Type: " . parseInjectType . ", Min packs: " . minPacks . ", Max packs: " . maxPacks)
    
    usedAccountsLog := saveDir . "\used_accounts.txt"  ; Track used accounts
    
    ; Initialize or load used accounts tracking
    usedAccounts := {}
    if (FileExist(usedAccountsLog)) {
        FileRead, usedAccountsContent, %usedAccountsLog%
        Loop, Parse, usedAccountsContent, `n, `r
        {
            if (A_LoopField) {
                parts := StrSplit(A_LoopField, "|")
                if (parts.Length() >= 1) {
                    usedAccounts[parts[1]] := 1
                }
            }
        }
        LogToFile("Loaded " . usedAccounts.Count() . " used accounts from log")
    }
    
    ; Delete existing list files before regenerating
    if FileExist(outputTxt)
        FileDelete, %outputTxt%
    if FileExist(outputTxt_current)
        FileDelete, %outputTxt_current%
    
    ; Log current time for debugging
    FormatTime, currentTimeStr, %A_Now%, yyyy-MM-dd HH:mm:ss
    LogToFile("Creating new lists at: " . currentTimeStr . " (" . A_Now . ")")

    ; Create arrays to store files with their timestamps
    fileNames := []
    fileTimes := []
    packCounts := []
    
    ; First pass: gather all eligible files with their timestamps
    Loop, %saveDir%\*.xml {
        xml := saveDir . "\" . A_LoopFileName
        
        ; Skip if this account was recently used
        if (usedAccounts.HasKey(A_LoopFileName)) {
            if (verboseLogging)
                LogToFile("Skipping recently used account: " . A_LoopFileName)
            continue
        }
        
        ; Get file modification time
        modTime := ""
        FileGetTime, modTime, %xml%, M
        
        ; Calculate hours difference properly
        hoursDiff := A_Now
        timeVar := modTime
        EnvSub, hoursDiff, %timeVar%, Hours
        
        ; Skip files less than 24 hours old
        if (hoursDiff < 24) {
            if (verboseLogging)
                LogToFile("Skipping account less than 24 hours old: " . A_LoopFileName . " (age: " . hoursDiff . " hours)")
            continue
        }
        
        ; Extract pack count from filename
        packCount := 0
        
        ; Extract the number before P
        if (RegExMatch(A_LoopFileName, "^(\d+)P", packMatch)) {
            ; Force numeric conversion
            packCount := packMatch1 + 0
        } else {
            ; Default for unrecognized formats - assume fresh account
            packCount := 0
            if (verboseLogging)
                LogToFile("No pack info in filename: " . A_LoopFileName . ", assigned default pack count: 0")
        }
        
        ; Format for logging
        if (verboseLogging) {
            FormatTime, modTimeStr, %modTime%, yyyy-MM-dd HH:mm:ss
            LogToFile("File: " . A_LoopFileName . ", Modified: " . modTimeStr . ", Age: " . hoursDiff . " hours, Packs: " . packCount)
        }
        
        ; Check if pack count fits the current injection range
        if (packCount < minPacks || packCount > maxPacks) {
            if (verboseLogging)
                LogToFile("  - SKIPPING: Pack count " . packCount . " outside range " . minPacks . "-" . maxPacks)
            continue
        }
        
        ; Store filename, modification time, and pack count
        fileNames.Push(A_LoopFileName)
        fileTimes.Push(modTime)
        packCounts.Push(packCount)
        if (verboseLogging)
            LogToFile("  - KEEPING: Pack count " . packCount . " inside range " . minPacks . "-" . maxPacks)
    }
    
    ; Log counts
    totalFound := fileNames.MaxIndex() ? fileNames.MaxIndex() : 0
    LogToFile("Found " . totalFound . " eligible files (>= 24 hours old, not recently used, packs: " . minPacks . "-" . maxPacks . ")")
    
    ; Sort files based on selected method (default to oldest modified first)
    if (totalFound > 0) {
        ; Determine sort method based on global setting
        sortMethod := (injectSortMethod) ? injectSortMethod : "ModifiedAsc"
        LogToFile("Sorting " . totalFound . " files by method: " . sortMethod)
        
        ; Sort the arrays based on chosen method
        if (sortMethod == "ModifiedAsc") {
            ; Oldest modified first (default)
            SortArraysByProperty(fileNames, fileTimes, packCounts, "time", 1)
        } else if (sortMethod == "ModifiedDesc") {
            ; Newest modified first
            SortArraysByProperty(fileNames, fileTimes, packCounts, "time", 0)
        } else if (sortMethod == "PacksAsc") {
            ; Fewest packs first
            SortArraysByProperty(fileNames, fileTimes, packCounts, "packs", 1)
        } else if (sortMethod == "PacksDesc") {
            ; Most packs first
            SortArraysByProperty(fileNames, fileTimes, packCounts, "packs", 0)
        }
        
        ; Prepare content for output files
        outputContent := ""
        For i, fileName in fileNames {
            outputContent .= fileName . "`n"
            
            ; Log first 10 files for verification
            if (i <= 10) {
                FormatTime, fileTimeStr, % fileTimes[i], yyyy-MM-dd HH:mm:ss
                LogToFile(i . ": " . fileName . " (Modified: " . fileTimeStr . ", Packs: " . packCounts[i] . ")")
            }
        }
        
        ; Write sorted files to output files
        FileAppend, %outputContent%, %outputTxt%
        FileAppend, %outputContent%, %outputTxt_current%
        
        LogToFile("Successfully wrote " . totalFound . " files to lists")
    } else {
        LogToFile("No eligible files found, creating empty lists")
        ; Create empty files to prevent repeated regeneration attempts
        FileAppend, "", %outputTxt%
        FileAppend, "", %outputTxt_current%
    }
    
    ; Create a file that tracks when the list was last regenerated
    FileDelete, % lastGeneratedFile
    FileAppend, % A_Now, % lastGeneratedFile
}

DoWonderPickOnly() {

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbClick_wbb(80, 460)
        if(FindOrLoseImage(240, 80, 265, 100, , "WonderPick", 1, failSafeTime)) {
            clickButton := FindOrLoseImage(100, 367, 190, 480, 100, "Button", 0, failSafeTime)
            if(clickButton) {
                StringSplit, pos, clickButton, `,  ; Split at ", "
                    ; Adjust pos2 if scaleParam is 287 for 100%
                    if (scaleParam = 287) {
                        pos2 += 5
                    }
                    adbClick_wbb(pos1, pos2)
                Delay(3)
            }
            if(FindOrLoseImage(160, 330, 200, 370, , "Card", 0, failSafeTime))
                break
        }
        Delay(1)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for WonderPick`n(" . failSafeTime . "/45 seconds)")
    }
    Sleep, 300
    if(slowMotion)
        Sleep, 3000
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbClick_wbb(183, 350) ; click card
        if(FindOrLoseImage(160, 330, 200, 370, , "Card", 1, failSafeTime)) {
            break
        }
        Delay(1)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Card`n(" . failSafeTime . "/45 seconds)")
    }
    failSafe := A_TickCount
    failSafeTime := 0
	;TODO thanks and wonder pick 5 times for missions
    Loop {
        adbClick_wbb(146, 494)
        if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime) || FindOrLoseImage(240, 80, 265, 100, , "WonderPick", 0, failSafeTime))
            break
        if(FindOrLoseImage(160, 330, 200, 370, , "Card", 0, failSafeTime)) {
            adbClick_wbb(183, 350) ; click card
        }
        delay(1)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Shop`n(" . failSafeTime . "/45 seconds)")
    }
	
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        Delay(2)
        if(FindOrLoseImage(191, 393, 211, 411, , "Shop", 0, failSafeTime))
            break
        else if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime))
            adbClick_wbb(239, 497)
        else
            adbInputEvent("111") ;send ESC
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Shop`n(" . failSafeTime . "/45 seconds)")
    }
}

DoWonderPick() {
    FindImageAndClick(191, 393, 211, 411, , "Shop", 40, 515) ;click until at main menu
    FindImageAndClick(240, 80, 265, 100, , "WonderPick", 59, 429) ;click until in wonderpick Screen
	
	DoWonderPickOnly()
	
    FindImageAndClick(2, 85, 34, 120, , "Missions", 261, 478, 500)
    ;FindImageAndClick(130, 170, 170, 205, , "WPMission", 150, 286, 1000)
    FindImageAndClick(120, 185, 150, 215, , "FirstMission", 150, 286, 1000)
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        Delay(1)
        adbClick_wbb(139, 424)
        Delay(1)
        clickButton := FindOrLoseImage(145, 447, 258, 480, 80, "Button", 0, failSafeTime)
        if(clickButton) {
            adbClick_wbb(110, 369)
        }
        else if(FindOrLoseImage(191, 393, 211, 411, , "Shop", 1, failSafeTime))
            ;adbInputEvent("111") ;send ESC
			adbClick_wbb(139, 492)
        else
            break
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for WonderPick`n(" . failSafeTime . "/45 seconds)")
    }
    return true
}

getChangeDateTime() {
	offset := A_Now
	currenttimeutc := A_NowUTC
	EnvSub, offset, %currenttimeutc%, Hours   ;offset from local timezone to UTC

    resetTime := SubStr(A_Now, 1, 8) "060000" ;today at 6am [utc] zero seconds is the reset time at UTC
	resetTime += offset, Hours                ;reset time in local timezone

	;find the closest reset time
	currentTime := A_Now
	timeToReset := resetTime
	EnvSub, timeToReset, %currentTime%, Hours
	if(timeToReset > 12) {
		resetTime += -1, Days
	} else if (timeToReset < -12) {
		resetTime += 1, Days
	}

    return resetTime
}

getMetaData() {
    beginnerMissionsDone := 0
    soloBattleMissionDone := 0
    intermediateMissionsDone := 0
    specialMissionsDone := 0
    accountHasPackInTesting := 0

    ; check if account file has metadata information
    if(InStr(accountFileName, "(")) {
        accountFileNameParts1 := StrSplit(accountFileName, "(")  ; Split at (
        if(InStr(accountFileNameParts1[2], ")")) {
            ; has metadata information
            accountFileNameParts2 := StrSplit(accountFileNameParts1[2], ")")  ; Split at )
            metadata := accountFileNameParts2[1]
            if(InStr(metadata, "B"))
                beginnerMissionsDone := 1
            if(InStr(metadata, "S"))
                soloBattleMissionDone := 1
            if(InStr(metadata, "I"))
                intermediateMissionsDone := 1
            if(InStr(metadata, "X"))
                specialMissionsDone := 1
            if(InStr(metadata, "T"))  ; Add this line
                accountHasPackInTesting := 1  ; Add this line
        }
    }
    
    if(resetSpecialMissionsDone)
        specialMissionsDone := 0 ; when special mission event is over can be reset
}

setMetaData() {
	hasMetaData := 0
	NamePartRightOfMeta := ""
	NamePartLeftOfMeta := ""
	
	; check if account file has metadata information
	if(InStr(accountFileName, "(")) {
		accountFileNameParts1 := StrSplit(accountFileName, "(")  ; Split at (
		NamePartLeftOfMeta := accountFileNameParts1[1]
		if(InStr(accountFileNameParts1[2], ")")) {
			; has metadata information
			accountFileNameParts2 := StrSplit(accountFileNameParts1[2], ")")  ; Split at )
			NamePartRightOfMeta := accountFileNameParts2[2]
			;metadata := accountFileNameParts2[1]
			
			hasMetaData := 1
		}
	}
	
	metadata := ""
	if(beginnerMissionsDone)
		metadata .= "B"
	if(soloBattleMissionDone)
		metadata .= "S"
	if(intermediateMissionsDone)
		metadata .= "I"
	if(specialMissionsDone)
		metadata .= "X"
	if(accountHasPackInTesting)
		metadata .= "T"  ; Add T metadata for pack in testing
	
	if(hasMetaData) {
		AccountNewName := NamePartLeftOfMeta . "(" . metadata . ")" . NamePartRightOfMeta
	} else {
		NameAndExtension := StrSplit(accountFileName, ".")  ; Split the extension
		AccountNewName := NameAndExtension[1] . "(" . metadata . ").xml"
	}
	
	; Log the metadata update
	LogToFile("Updating account metadata to: " . metadata)
	
	saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
	accountFile := saveDir . "\" . accountFileName
	accountNewFile := saveDir . "\" . AccountNewName
	FileMove, %accountFile%, %accountNewFile%
	accountFileName := AccountNewName
}

SpendAllHourglass() {
    HomeAndMission(1)
    
	;if SelectPack("HGPack", false) != "Not Enough Items" ;don't restart game when not enough items and just continue
	
	SelectPack("HGPack")
	if(cantOpenMorePacks)
		return
	
	;PackOpening(false)
	
	PackOpening()
	if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
		return
			
	while true{ ;keep opening packs until not enough items
		;if HourglassOpening(true, false) == "Not Enough Items"
		;	break
		;if accountOpenPacks > 35
		;	break
			
		HourglassOpening(True)
		if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
			return
			
	}
    
}

; For Special Missions 2025
GetEventRewards(frommain := true){
    swipeSpeed := 300
    adbSwipeX3 := Round(211 / 277 * 535)
    adbSwipeX4 := Round(11 / 277 * 535)
    adbSwipeY2 := Round((453 - 44) / 489 * 960)
    adbSwipeParams2 := adbSwipeX3 . " " . adbSwipeY2 . " " . adbSwipeX4 . " " . adbSwipeY2 . " " . swipeSpeed
    if (frommain){
        FindImageAndClick(2, 85, 34, 120, , "Missions", 261, 478, 500)
    }
    Delay(4)
    if(setSpeed > 1) {
    FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
    FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
        Delay(1)
    }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop{
        adbSwipe(adbSwipeParams2)
        Sleep, 10
        if (FindOrLoseImage(225, 444, 272, 470, , "Premium", 0, failSafeTime)){
            if(setSpeed > 1) {
                if(setSpeed = 3)
                        FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
                else
                        FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
            }
                adbClick_wbb(41, 296)
                break
            }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Trace`n(" . failSafeTime . "/45 seconds)")
        Delay(1)
    }
    adbClick_wbb(120, 465)
    failSafe := A_TickCount
    failSafeTime := 0
    Loop{
        Delay(2)
        adbClick_wbb(172, 427) ;clicks complete all and ok
        Delay(2)
        adbClick_wbb(152, 464) ;when to many rewards ok button goes lower
        if FindOrLoseImage(244, 406, 273, 449, , "GotAllMissions", 0, 0) {
            break
        }
        else if (failSafeTime > 60){
            GotRewards := false
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
    }
    GoToMain()
}

GetAllRewards(tomain := true){
    FindImageAndClick(2, 85, 34, 120, , "Missions", 261, 478, 500)
    Delay(4)
    failSafe := A_TickCount
    failSafeTime := 0
    GotRewards := true
    Loop{
        Delay(2)
        adbClick(172, 427)
        if FindOrLoseImage(244, 406, 273, 449, , "GotAllMissions", 0, 0) {
            break
        }
        else if (failSafeTime > 20){
            GotRewards := false
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
    }
    if (tomain) {
        GoToMain()
    }
}

GoToMain() {
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        ; First, try to click the home button
        adbClick_wbb(40, 516)
        Delay(2)
        
        ; Check if we're at the main menu
        if(FindOrLoseImage(191, 393, 211, 411, , "Shop", 0, failSafeTime)) {
            break
        }
        else {
            ; If not, try sending ESC key
            adbInputEvent("111") ;send ESC
            Delay(1)
        }
        
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Trying to go to main menu: " . failSafeTime . "/45 seconds")
        
        if (failSafeTime > 45) {
            LogToFile("Failed to return to main menu - restarting from current state")
            break
        }
    }
}

;levelUp()
;FindOrLoseImage(118, 167, 167, 203, , "unlocked", 0, failSafeTime)
;FindImageAndClick(118, 167, 167, 203, , "unlocked", 144, 396, sleepTime)
;adbClick_wbb(144, 396)

;FindOrLoseImage(53, 280, 81, 306, , "unlockdisplayboard", 0, failSafeTime)
;FindImageAndClick(53, 280, 81, 306, , "unlockdisplayboard", 137, 362, sleepTime)
;adbClick_wbb(137, 362)
^e::
    pToken := Gdip_Startup()
    Screenshot_dev()
return

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Find Card Count and Relevant Functions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


FindPackStats() {
    global adbShell, scriptName, ocrLanguage, loadDir

	failSafe := A_TickCount
	failSafeTime := 0
    ; Click for hamburger menu and wait for profile
    Loop {
        adbClick(240, 499)
        if(FindOrLoseImage(230, 120, 260, 150, , "UserProfile", 0, failSafeTime)) {
            break
        } else {
            clickButton := FindOrLoseImage(75, 340, 195, 530, 80, "Button", 0)
            if(clickButton) {
                StringSplit, pos, clickButton, `,  ; Split at ", "
                if (scaleParam = 287) {
                    pos2 += 5
                }
                adbClick(pos1, pos2)
			}
		}
		levelUp()
        Delay(1)
		failSafeTime := (A_TickCount - failSafe) // 1000
    }
	
	FindImageAndClick(203, 272, 237, 300, , "Profile", 210, 140, 200) ; Open profile/stats page and wait
	
    ; Swipe until you get to trophy
	failSafe := A_TickCount
	failSafeTime := 0
    Loop {
        adbSwipe("266 770 266 355 300")
		if(FindOrLoseImage(13, 110, 31, 129, , "trophy", 0, failSafeTime)) 
			break
		failSafeTime := (A_TickCount - failSafe) // 1000
			
    }

	FindImageAndClick(122, 375, 161, 390, , "trophyPage", 50, 107, 200) ; Open pack trophy page
	
    ; Take screenshot and prepare for OCR
    Sleep, 100
	
	tempDir := A_ScriptDir . "\temp"
    if !FileExist(tempDir)
        FileCreateDir, %tempDir%
		
	fullScreenshotFile := tempDir . "\" .  winTitle . "_AccountPacks.png"
	adbTakeScreenshot(fullScreenshotFile)
    
	Sleep, 100
    
    packValue := 0
	ocrText := ""
    
	;214, 438, 111x30
	;214, 434, 111x38
	;214, 441, 111x24
	ocrSuccess := 0 
    if(ParseCardCount(fullScreenshotFile, 214, 438, 111, 30, "0123456789,/", "^\d{1,3}(,\d{3})?\/\d{1,3}(,\d{3})?$", ocrText)) {
		;MsgBox, %ocrText%
		ocrParts := StrSplit(ocrText, "/")
		accountOpenPacks := ocrParts[1]
		;MsgBox, %accountOpenPacks%
		ocrSuccess := 1
		
		UpdateAccount()
	}

	if (FileExist(fullScreenshotFile))
		FileDelete, %fullScreenshotFile%
	
	FindImageAndClick(230, 120, 260, 150, , "UserProfile", 140, 496, 200) ; go back to hamburger menu
	
    Loop {
        adbClick(34,65)
			Delay(1)
        adbClick(34,65)
			Delay(1)
        adbClick(34,65)
			Delay(1)
        if(FindOrLoseImage(233, 400, 264, 428, , "Points", 0, failSafeTime)) {
            break
        } else {
			adbClick_wbb(141, 480)
			Delay(1)
		}
		failSafeTime := (A_TickCount - failSafe) // 1000
    }
}

; Attempts to extract and validate text from a specified region of a screenshot using OCR.
ParseCardCount(screenshotFile, x, y, w, h, allowedChars, validPattern, ByRef output) {
    success := False
    ;blowUp := [200, 500, 1000, 2000, 100, 250, 300, 350, 400, 450, 550, 600, 700, 800, 900]
    blowUp := [500, 1000, 2000, 100, 200, 250, 300, 350, 400, 450, 550, 600, 700, 800, 900]
    Loop, % blowUp.Length() {
        ; Get the formatted pBitmap
        pBitmap := CropAndFormatForOcr(screenshotFile, x, y, w, h, blowUp[A_Index])
        ; Run OCR
        output := GetTextFromBitmap(pBitmap, allowedChars)
        ; Validate result
        if (RegExMatch(output, validPattern)) {
            success := True
            break
        }
    }
    return success
}

TestInjectLongLogic() {
    global deleteMethod, injectMaxValue, injectMinValue, injectRange
    
    ; Force read current values
    IniRead, injectMaxValue, %A_ScriptDir%\..\Settings.ini, UserSettings, injectMaxValue, 39
    IniRead, injectMinValue, %A_ScriptDir%\..\Settings.ini, UserSettings, injectMinValue, 35
    IniRead, injectRange, %A_ScriptDir%\..\Settings.ini, UserSettings, injectRange, ""
    
    LogToFile("=== TESTING INJECT LONG WITH MAX=" . injectMaxValue . " ===")
    
    ; Simulate test accounts with different pack counts
    testAccounts := ["0P_test.xml", "10P_test.xml", "25P_test.xml", "30P_test.xml", "33P_test.xml", "34P_test.xml", "35P_test.xml", "36P_test.xml", "39P_test.xml", "40P_test.xml"]
    
    for index, testFile in testAccounts {
        packCount := 0
        if (RegExMatch(testFile, "^(\d+)P", packMatch)) {
            packCount := packMatch1 + 0
        }
        
        ; Test the logic for Inject long
        isValid := (packCount >= 0 && packCount <= injectMaxValue)
        LogToFile("Test: " . testFile . " (" . packCount . " packs) = " . (isValid ? "SHOULD BE INCLUDED" : "SHOULD BE EXCLUDED"))
    }
    
    LogToFile("Expected: 0P through " . injectMaxValue . "P should be INCLUDED, " . (injectMaxValue + 1) . "P+ should be EXCLUDED")
    LogToFile("=== END TEST ===")
}

; Crops an image, scales it up, converts it to grayscale, and enhances contrast to improve OCR accuracy.
CropAndFormatForOcr(inputFile, x := 0, y := 0, width := 200, height := 200, scaleUpPercent := 200) {
    ; Get bitmap from file
    pBitmapOrignal := Gdip_CreateBitmapFromFile(inputFile)
    ; Crop to region, Scale up the image, Convert to greyscale, Increase contrast
    pBitmapFormatted := Gdip_CropResizeGreyscaleContrast(pBitmapOrignal, x, y, width, height, scaleUpPercent, 25)
    
	filePath := A_ScriptDir . "\temp\" .  winTitle . "_AccountPacks_crop.png"
    Gdip_SaveBitmapToFile(pBitmap, filePath)
	; Cleanup references
    Gdip_DisposeImage(pBitmapOrignal)
    return pBitmapFormatted
}

; Extracts text from a bitmap using OCR. Converts the bitmap to a format usable by Windows OCR, performs OCR, and optionally removes characters not in the allowed character list.
GetTextFromBitmap(pBitmap, charAllowList := "") {
    global ocrLanguage
    ocrText := ""
    ; OCR the bitmap directly
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    pIRandomAccessStream := HBitmapToRandomAccessStream(hBitmap)
    ocrText := ocr(pIRandomAccessStream, ocrLanguage)
    ; Cleanup references
    DeleteObject(hBitmapFriendCode)
    ; Remove disallowed characters
    if (charAllowList != "") {
        allowedPattern := "[^" RegExEscape(charAllowList) "]"
        ocrText := RegExReplace(ocrText, allowedPattern)
    }

    return Trim(ocrText, " `t`r`n")
}

; Escapes special characters in a string for use in a regular expression. 
RegExEscape(str) {
    return RegExReplace(str, "([-[\]{}()*+?.,\^$|#\s])", "\$1")
}