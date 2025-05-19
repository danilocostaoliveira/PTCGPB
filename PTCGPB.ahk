#Include %A_ScriptDir%\Scripts\Include\Logging.ahk
#Include %A_ScriptDir%\Scripts\Include\ADB.ahk

version = Arturos PTCGP Bot
#SingleInstance, force
CoordMode, Mouse, Screen
SetTitleMatchMode, 3

OnError("ErrorHandler")  ; Add this line here

global STATIC_BRUSH := 0

githubUser := "Arturo-1212"
repoName := "PTCGPB"
localVersion := "v6.3.29"
scriptFolder := A_ScriptDir
zipPath := A_Temp . "\update.zip"
extractPath := A_Temp . "\update"

; GUI dimensions constants
global GUI_WIDTH := 480
global GUI_HEIGHT := 750

; Image scaling and ratio constants for 720p compatibility
global IMG_SCALE_RATIO := 0.5625 ; 720/1280 for aspect ratio preservation
global UI_ELEMENT_SCALE := 0.85  ; Scale UI elements to fit smaller dimensions

; Added new global variable for background image toggle
global useBackgroundImage := true

global scriptName, winTitle, FriendID, Instances, instanceStartDelay, jsonFileName, PacksText, runMain, Mains, AccountName, scaleParam
global CurrentVisibleSection
global FriendID_Divider, Instance_Divider3
global System_Divider1, System_Divider2, System_Divider3, System_Divider4
global Pack_Divider1, Pack_Divider2, Pack_Divider3
global SaveForTradeDivider_1, SaveForTradeDivider_2
global Discord_Divider3
global tesseractPath, applyRoleFilters, debugMode, statusMessage
global tesseractOption
global variablePackCount
global claimSpecialMissions, spendHourGlass
global rowGap
global injectSortMethodCreated := false
global injectSortMethod := "ModifiedAsc"  ; Default sort method
global SortMethodLabel, InjectSortMethodDropdown
global sortByCreated := false
global SortByText, SortByDropdown
global injectRange

if not A_IsAdmin
{
    ; Relaunch script with admin rights
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

; Check for debugMode and display license notification if not in debug mode
IniRead, debugMode, Settings.ini, UserSettings, debugMode, 0
if (!debugMode)
{
    MsgBox, 64, The project is now licensed under CC BY-NC 4.0, The original intention of this project was not for it to be used for paid services even those disguised as 'donations.' I hope people respect my wishes and those of the community. `nThe project is now licensed under CC BY-NC 4.0, which allows you to use, modify, and share the software only for non-commercial purposes. Commercial use, including using the software to provide paid services or selling it (even if donations are involved), is not allowed under this license. The new license applies to this and all future releases.
}

; Define refined global color variables for consistent theming
global DARK_BG := "121621"          ; Deeper, darker blue-black
global DARK_CONTROL_BG := "1A1E2E"  ; Darker panel background for more contrast
global DARK_ACCENT := "3390FF"      ; More muted blue accent
global DARK_TEXT := "FFFFFF"        ; Pure white for maximum visibility
global DARK_TEXT_SECONDARY := "D0E4FF" ; Slightly muted blue-white for secondary text

global LIGHT_BG := "F8FAFF"         ; Very light blue-white background
global LIGHT_CONTROL_BG := "FFFFFF" ; Pure white for controls
global LIGHT_ACCENT := "0055AA"     ; Darker accent for contrast
global LIGHT_TEXT := "000000"       ; Black text for maximum contrast
global LIGHT_TEXT_SECONDARY := "333333" ; Dark gray with slight blue tint

; Define input field colors for light and dark themes
global DARK_INPUT_BG := "151B2C"    ; Darker but with some contrast against background
global DARK_INPUT_TEXT := "FFFFFF"  ; White text in inputs
global LIGHT_INPUT_BG := "F0F5FF"   ; Very light blue for contrast
global LIGHT_INPUT_TEXT := "000000" ; Black text in inputs

; Section colors - Dark theme with increased brightness/contrast
global DARK_SECTION_COLORS := {}
DARK_SECTION_COLORS["RerollSettings"] := "50B0FF"   ; Brighter but not neon blue
DARK_SECTION_COLORS["FriendID"] := "50B0FF"         ; Brighter but not neon blue
DARK_SECTION_COLORS["InstanceSettings"] := "50B0FF" ; Brighter but not neon blue
DARK_SECTION_COLORS["TimeSettings"] := "50B0FF"     ; Brighter but not neon blue
DARK_SECTION_COLORS["SystemSettings"] := "40E0E0"   ; Brighter teal
DARK_SECTION_COLORS["PackSettings"] := "E070D0"     ; Brighter but softer purple
DARK_SECTION_COLORS["SaveForTrade"] := "FF9955"     ; Kept bright orange for visibility
DARK_SECTION_COLORS["DiscordSettings"] := "7289DA"  ; Discord's official blue - brighter
DARK_SECTION_COLORS["DownloadSettings"] := "60D090" ; Brighter green

; Section colors - Light theme
global LIGHT_SECTION_COLORS := {}
LIGHT_SECTION_COLORS["RerollSettings"] := "0066CC"   ; Bolder blue
LIGHT_SECTION_COLORS["FriendID"] := "0066CC"         ; Bolder blue
LIGHT_SECTION_COLORS["InstanceSettings"] := "0066CC" ; Bolder blue
LIGHT_SECTION_COLORS["TimeSettings"] := "0066CC"     ; Bolder blue
LIGHT_SECTION_COLORS["SystemSettings"] := "008080"   ; Bold teal
LIGHT_SECTION_COLORS["PackSettings"] := "8B008B"     ; Bold purple
LIGHT_SECTION_COLORS["SaveForTrade"] := "CC5500"     ; Bold orange
LIGHT_SECTION_COLORS["DiscordSettings"] := "4A55CC"  ; Bold Discord blue
LIGHT_SECTION_COLORS["DownloadSettings"] := "006400" ; Bold forest green

IsNumeric(var) {
    if var is number
        return true
    return false
}

; Improved font functions with better hierarchy and reduced sizes
SetArturoFont() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT
    if (isDarkTheme)
        Gui, Font, s12 bold c%DARK_TEXT%, Segoe UI
    else
        Gui, Font, s12 bold c%LIGHT_TEXT%, Segoe UI
}

SetTitleFont() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT
    if (isDarkTheme)
        Gui, Font, s10 bold c%DARK_TEXT%, Segoe UI
    else
        Gui, Font, s10 bold c%LIGHT_TEXT%, Segoe UI
}

SetSectionFont() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT
    if (isDarkTheme)
        Gui, Font, s10 bold c%DARK_TEXT%, Segoe UI
    else
        Gui, Font, s10 bold c%LIGHT_TEXT%, Segoe UI
}

SetHeaderFont() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT
    if (isDarkTheme)
        Gui, Font, s9 bold c%DARK_TEXT%, Segoe UI
    else
        Gui, Font, s9 bold c%LIGHT_TEXT%, Segoe UI
}

SetNormalFont() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT
    if (isDarkTheme)
        Gui, Font, s8 c%DARK_TEXT%, Segoe UI
    else
        Gui, Font, s8 c%LIGHT_TEXT%, Segoe UI
}

SetSmallFont() {
    global isDarkTheme, DARK_TEXT_SECONDARY, LIGHT_TEXT_SECONDARY
    if (isDarkTheme)
        Gui, Font, s7 c%DARK_TEXT_SECONDARY%, Segoe UI
    else
        Gui, Font, s7 c%LIGHT_TEXT_SECONDARY%, Segoe UI
}

SetInputFont() {
    global isDarkTheme, DARK_INPUT_TEXT, LIGHT_INPUT_TEXT
    if (isDarkTheme)
        Gui, Font, s8 c%DARK_INPUT_TEXT%, Segoe UI
    else
        Gui, Font, s8 c%LIGHT_INPUT_TEXT%, Segoe UI
}

; ===== NEW: Helper Functions for Code Optimization =====

; Function to apply text color based on current theme
ApplyTextColor(controlName) {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT

    textColor := isDarkTheme ? DARK_TEXT : LIGHT_TEXT
    GuiControl, +c%textColor%, %controlName%
}

; Function to apply input field styling based on current theme
ApplyInputStyle(controlName) {
    global isDarkTheme, DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT

    inputBgColor := isDarkTheme ? DARK_INPUT_BG : LIGHT_INPUT_BG
    inputTextColor := isDarkTheme ? DARK_INPUT_TEXT : LIGHT_INPUT_TEXT
    GuiControl, +Background%inputBgColor% +c%inputTextColor%, %controlName%
}

; Function to apply style to multiple text controls at once
ApplyTextColorToMultiple(controlList) {
    Loop, Parse, controlList, `,
    {
        if (A_LoopField)
            ApplyTextColor(A_LoopField)
    }
}

; Function to apply style to multiple input fields at once
ApplyInputStyleToMultiple(controlList) {
    Loop, Parse, controlList, `,
    {
        if (A_LoopField)
            ApplyInputStyle(A_LoopField)
    }
}

; Function to show multiple controls at once
ShowControls(controlList) {
    Loop, Parse, controlList, `,
    {
        if (A_LoopField)
            GuiControl, Show, %A_LoopField%
    }
}

; Function to hide multiple controls at once
HideControls(controlList) {
    Loop, Parse, controlList, `,
    {
        if (A_LoopField)
            GuiControl, Hide, %A_LoopField%
    }
}

; Unified function to save all settings to INI file - UPDATED
SaveAllSettings() {
    global FriendID, AccountName, waitTime, Delay, folderPath, discordWebhookURL, discordUserId, Columns, godPack
    global Instances, instanceStartDelay, defaultLanguage, SelectedMonitorIndex, swipeSpeed, deleteMethod
    global runMain, Mains, heartBeat, heartBeatWebhookURL, heartBeatName, nukeAccount, packMethod
    global CheckShinyPackOnly, TrainerCheck, FullArtCheck, RainbowCheck, ShinyCheck, CrownCheck
    global InvalidCheck, ImmersiveCheck, PseudoGodPack, minStars, Palkia, Dialga, Arceus, Shining
    global Mew, Pikachu, Charizard, Mewtwo, Solgaleo, Lunala, slowMotion, ocrLanguage, clientLanguage, autoLaunchMonitor
    global CurrentVisibleSection, heartBeatDelay, sendAccountXml, showcaseEnabled, showcaseURL, isDarkTheme
    global useBackgroundImage, tesseractPath, applyRoleFilters, debugMode, tesseractOption, statusMessage
    global s4tEnabled, s4tSilent, s4t3Dmnd, s4t4Dmnd, s4t1Star, s4tGholdengo, s4tWP, s4tWPMinCards
    global s4tDiscordUserId, s4tDiscordWebhookURL, s4tSendAccountXml, minStarsShiny, instanceLaunchDelay, mainIdsURL, vipIdsURL
    global variablePackCount, claimSpecialMissions, spendHourGlass, injectSortMethod, rowGap, SortByDropdown
    global injectRange 
    
    ; Make sure all values are properly synced from GUI before saving
    Gui, Submit, NoHide
    
    ; Update injectSortMethod based on dropdown if available
    if (sortByCreated) {
        GuiControlGet, selectedOption,, SortByDropdown
        if (selectedOption = "Oldest First")
            injectSortMethod := "ModifiedAsc"
        else if (selectedOption = "Newest First")
            injectSortMethod := "ModifiedDesc"
        else if (selectedOption = "Fewest Packs First")
            injectSortMethod := "PacksAsc"
        else if (selectedOption = "Most Packs First")
            injectSortMethod := "PacksDesc"
    }
    
    ; Save pack selections directly without resetting them
    IniWrite, %Palkia%, Settings.ini, UserSettings, Palkia
    IniWrite, %Dialga%, Settings.ini, UserSettings, Dialga
    IniWrite, %Arceus%, Settings.ini, UserSettings, Arceus
    IniWrite, %Shining%, Settings.ini, UserSettings, Shining
    IniWrite, %Mew%, Settings.ini, UserSettings, Mew
    IniWrite, %Pikachu%, Settings.ini, UserSettings, Pikachu
    IniWrite, %Charizard%, Settings.ini, UserSettings, Charizard
    IniWrite, %Mewtwo%, Settings.ini, UserSettings, Mewtwo
    IniWrite, %Solgaleo%, Settings.ini, UserSettings, Solgaleo
    IniWrite, %Lunala%, Settings.ini, UserSettings, Lunala
    
    ; Save basic settings
    IniWrite, %FriendID%, Settings.ini, UserSettings, FriendID
    IniWrite, %AccountName%, Settings.ini, UserSettings, AccountName
    IniWrite, %waitTime%, Settings.ini, UserSettings, waitTime
    IniWrite, %Delay%, Settings.ini, UserSettings, Delay
    IniWrite, %folderPath%, Settings.ini, UserSettings, folderPath
    IniWrite, %discordWebhookURL%, Settings.ini, UserSettings, discordWebhookURL
    IniWrite, %discordUserId%, Settings.ini, UserSettings, discordUserId
    IniWrite, %Columns%, Settings.ini, UserSettings, Columns
    IniWrite, %godPack%, Settings.ini, UserSettings, godPack
    IniWrite, %Instances%, Settings.ini, UserSettings, Instances
    IniWrite, %instanceStartDelay%, Settings.ini, UserSettings, instanceStartDelay
    IniWrite, %defaultLanguage%, Settings.ini, UserSettings, defaultLanguage
    IniWrite, %rowGap%, Settings.ini, UserSettings, rowGap
    IniWrite, %SelectedMonitorIndex%, Settings.ini, UserSettings, SelectedMonitorIndex
    IniWrite, %swipeSpeed%, Settings.ini, UserSettings, swipeSpeed
    IniWrite, %deleteMethod%, Settings.ini, UserSettings, deleteMethod
    IniWrite, %runMain%, Settings.ini, UserSettings, runMain
    IniWrite, %Mains%, Settings.ini, UserSettings, Mains
    IniWrite, %heartBeat%, Settings.ini, UserSettings, heartBeat
    IniWrite, %heartBeatWebhookURL%, Settings.ini, UserSettings, heartBeatWebhookURL
    IniWrite, %heartBeatName%, Settings.ini, UserSettings, heartBeatName
    IniWrite, %heartBeatDelay%, Settings.ini, UserSettings, heartBeatDelay
    IniWrite, %nukeAccount%, Settings.ini, UserSettings, nukeAccount
    IniWrite, %packMethod%, Settings.ini, UserSettings, packMethod
    IniWrite, %CheckShinyPackOnly%, Settings.ini, UserSettings, CheckShinyPackOnly
    IniWrite, %TrainerCheck%, Settings.ini, UserSettings, TrainerCheck
    IniWrite, %FullArtCheck%, Settings.ini, UserSettings, FullArtCheck
    IniWrite, %RainbowCheck%, Settings.ini, UserSettings, RainbowCheck
    IniWrite, %ShinyCheck%, Settings.ini, UserSettings, ShinyCheck
    IniWrite, %CrownCheck%, Settings.ini, UserSettings, CrownCheck
    IniWrite, %InvalidCheck%, Settings.ini, UserSettings, InvalidCheck
    IniWrite, %ImmersiveCheck%, Settings.ini, UserSettings, ImmersiveCheck
    IniWrite, %PseudoGodPack%, Settings.ini, UserSettings, PseudoGodPack
    IniWrite, %minStars%, Settings.ini, UserSettings, minStars
    IniWrite, %slowMotion%, Settings.ini, UserSettings, slowMotion
    IniWrite, %ocrLanguage%, Settings.ini, UserSettings, ocrLanguage
    IniWrite, %clientLanguage%, Settings.ini, UserSettings, clientLanguage
    IniWrite, %mainIdsURL%, Settings.ini, UserSettings, mainIdsURL
    IniWrite, %vipIdsURL%, Settings.ini, UserSettings, vipIdsURL
    IniWrite, %autoLaunchMonitor%, Settings.ini, UserSettings, autoLaunchMonitor
    IniWrite, %instanceLaunchDelay%, Settings.ini, UserSettings, instanceLaunchDelay
    IniWrite, %variablePackCount%, Settings.ini, UserSettings, variablePackCount
    IniWrite, %claimSpecialMissions%, Settings.ini, UserSettings, claimSpecialMissions
    IniWrite, %spendHourGlass%, Settings.ini, UserSettings, spendHourGlass
    IniWrite, %injectSortMethod%, Settings.ini, UserSettings, injectSortMethod
    IniWrite, %injectRange%, Settings.ini, UserSettings, injectRange

    ; Save showcase settings
    IniWrite, %showcaseEnabled%, Settings.ini, UserSettings, showcaseEnabled
    IniWrite, 5, Settings.ini, UserSettings, showcaseLikes

    ; Save advanced settings
    IniWrite, %minStars%, Settings.ini, UserSettings, minStarsA1Mewtwo
    IniWrite, %minStars%, Settings.ini, UserSettings, minStarsA1Charizard
    IniWrite, %minStars%, Settings.ini, UserSettings, minStarsA1Pikachu
    IniWrite, %minStars%, Settings.ini, UserSettings, minStarsA1a
    IniWrite, %minStars%, Settings.ini, UserSettings, minStarsA2Dialga
    IniWrite, %minStars%, Settings.ini, UserSettings, minStarsA2Palkia
    IniWrite, %minStars%, Settings.ini, UserSettings, minStarsA2a
    IniWrite, %minStarsShiny%, Settings.ini, UserSettings, minStarsA2b
    IniWrite, %minStarsShiny%, Settings.ini, UserSettings, minStarsA3Solgaleo
    IniWrite, %minStarsShiny%, Settings.ini, UserSettings, minStarsA3Lunala

    IniWrite, %heartBeatDelay%, Settings.ini, UserSettings, heartBeatDelay
    IniWrite, %sendAccountXml%, Settings.ini, UserSettings, sendAccountXml

    ; Save S4T settings
    IniWrite, %s4tEnabled%, Settings.ini, UserSettings, s4tEnabled
    IniWrite, %s4tSilent%, Settings.ini, UserSettings, s4tSilent
    IniWrite, %s4t3Dmnd%, Settings.ini, UserSettings, s4t3Dmnd
    IniWrite, %s4t4Dmnd%, Settings.ini, UserSettings, s4t4Dmnd
    IniWrite, %s4t1Star%, Settings.ini, UserSettings, s4t1Star
    IniWrite, %s4tGholdengo%, Settings.ini, UserSettings, s4tGholdengo
    IniWrite, %s4tWP%, Settings.ini, UserSettings, s4tWP
    IniWrite, %s4tWPMinCards%, Settings.ini, UserSettings, s4tWPMinCards
    IniWrite, %s4tDiscordUserId%, Settings.ini, UserSettings, s4tDiscordUserId
    IniWrite, %s4tDiscordWebhookURL%, Settings.ini, UserSettings, s4tDiscordWebhookURL
    IniWrite, %s4tSendAccountXml%, Settings.ini, UserSettings, s4tSendAccountXml

    ; Save extra settings
    IniWrite, %tesseractPath%, Settings.ini, UserSettings, tesseractPath
    IniWrite, %applyRoleFilters%, Settings.ini, UserSettings, applyRoleFilters
    IniWrite, %debugMode%, Settings.ini, UserSettings, debugMode
    IniWrite, %tesseractOption%, Settings.ini, UserSettings, tesseractOption
    IniWrite, %statusMessage%, Settings.ini, UserSettings, statusMessage

    ; Save theme settings
    IniWrite, %isDarkTheme%, Settings.ini, UserSettings, isDarkTheme
    IniWrite, %useBackgroundImage%, Settings.ini, UserSettings, useBackgroundImage
}

; Function to update ALL text controls with appropriate color
SetAllTextColors(textColor) {
    ; Create a string with all control names separated by commas
    controlList := "Txt_Instances,Txt_InstanceStartDelay,Txt_Columns,runMain,Txt_AccountName,"
    controlList .= "Txt_Delay,Txt_WaitTime,Txt_SwipeSpeed,slowMotion,"
    controlList .= "Txt_Monitor,Txt_Scale,Txt_FolderPath,Txt_OcrLanguage,Txt_ClientLanguage,"
    controlList .= "Txt_InstanceLaunchDelay,autoLaunchMonitor,"
    controlList .= "Txt_MinStars,Txt_ShinyMinStars,Txt_DeleteMethod,packMethod,nukeAccount,"

    controlList .= "FullArtCheck,TrainerCheck,RainbowCheck,PseudoGodPack,CheckShinyPackOnly,"
    controlList .= "InvalidCheck,CrownCheck,ShinyCheck,ImmersiveCheck,"
    controlList .= "s4tEnabled,s4tSilent,s4t3Dmnd,s4t4Dmnd,s4t1Star,s4tGholdengo,s4tWP,"
    controlList .= "s4tWPMinCardsLabel,s4tGholdengoArrow,"
    controlList .= "Txt_DiscordID,Txt_DiscordWebhook,sendAccountXml,"
    controlList .= "heartBeat,hbName,hbURL,hbDelay,"
    controlList .= "Txt_S4T_DiscordID,Txt_S4T_DiscordWebhook,s4tSendAccountXml,"
    controlList .= "DownloadSettingsHeading,Txt_MainIdsURL,Txt_VipIdsURL,"
    controlList .= "ActiveSection,VersionInfo,HeaderTitle,"
    controlList .= "FriendIDLabel,InstanceSettingsLabel,TimeSettingsLabel,SystemSettingsLabel,"
    controlList .= "PackSettingsLabel,SaveForTradeLabel,DiscordSettingsLabel,DownloadSettingsLabel,"
    controlList .= "ExtraSettingsHeading,tesseractOption,Txt_TesseractPath,applyRoleFilters,"
    controlList .= "debugMode,statusMessage"

    ; Apply color to all controls in the list
    Loop, Parse, controlList, `,
    {
        if (A_LoopField)
            GuiControl, +c%textColor%, %A_LoopField%
    }
}

; Function to apply theme colors to the GUI
ApplyTheme() {
    global isDarkTheme, DARK_BG, DARK_CONTROL_BG, DARK_TEXT, DARK_INPUT_BG, DARK_INPUT_TEXT
    global LIGHT_BG, LIGHT_CONTROL_BG, LIGHT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT
    global CurrentVisibleSection, DARK_SECTION_COLORS, LIGHT_SECTION_COLORS

    if (isDarkTheme) {
        ; Dark theme with better contrast
        Gui, Color, %DARK_BG%, %DARK_CONTROL_BG%
        GuiControl, +Background%DARK_CONTROL_BG% +c%DARK_TEXT%, ThemeToggle

        ; Update input fields for dark theme
        SetInputBackgrounds(DARK_INPUT_BG, DARK_INPUT_TEXT)

        ; Update all text labels with dark theme colors
        SetAllTextColors(DARK_TEXT)
    } else {
        ; Light theme with better contrast
        Gui, Color, %LIGHT_BG%, %LIGHT_CONTROL_BG%
        GuiControl, +Background%LIGHT_CONTROL_BG% +c%LIGHT_TEXT%, ThemeToggle

        ; Update input fields for light theme
        SetInputBackgrounds(LIGHT_INPUT_BG, LIGHT_INPUT_TEXT)

        ; Update all text labels with light theme colors
        SetAllTextColors(LIGHT_TEXT)
    }

    ; Apply section-specific color to active section title (if any)
    if (CurrentVisibleSection != "") {
        sectionColor := isDarkTheme ? DARK_SECTION_COLORS[CurrentVisibleSection] : LIGHT_SECTION_COLORS[CurrentVisibleSection]
        GuiControl, +c%sectionColor%, ActiveSection
    }

    ; Update section headers with appropriate colors
    UpdateSectionHeaders()

    ; Force a redraw of the GUI to apply colors immediately
    WinSet, Redraw,, A
}

; Helper function to reset button colors to default
ResetButtonColors() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT

    defaultColor := isDarkTheme ? DARK_TEXT : LIGHT_TEXT

    GuiControl, +c%defaultColor%, Btn_RerollSettings
    GuiControl, +c%defaultColor%, Btn_SystemSettings
    GuiControl, +c%defaultColor%, Btn_PackSettings
    GuiControl, +c%defaultColor%, Btn_SaveForTrade
    GuiControl, +c%defaultColor%, Btn_DiscordSettings
    GuiControl, +c%defaultColor%, Btn_DownloadSettings
}

; Helper function to update all input field backgrounds
SetInputBackgrounds(bgColor, textColor) {
    ; Create a list of all input controls
    inputList := "FriendID,Instances,instanceStartDelay,Columns,Mains,"
    inputList .= "Delay,waitTime,swipeSpeed,folderPath,instanceLaunchDelay,"
    inputList .= "minStars,minStarsShiny,discordUserId,discordWebhookURL,"
    inputList .= "heartBeatName,heartBeatWebhookURL,heartBeatDelay,"
    inputList .= "mainIdsURL,vipIdsURL,s4tWPMinCards,"
    inputList .= "s4tDiscordUserId,s4tDiscordWebhookURL,SelectedMonitorIndex,"
    inputList .= "defaultLanguage,ocrLanguage,clientLanguage,deleteMethod,tesseractPath,"
    inputList .= "variablePackCount,rowGap"

    ; Apply style to all inputs
    Loop, Parse, inputList, `,
    {
        if (A_LoopField)
            GuiControl, +Background%bgColor% +c%textColor%, %A_LoopField%
    }
}

AddSectionDivider(x, y, w, vName) {
    ; Create a subtle divider line with a variable name for showing/hiding
    Gui, Add, Text, x%x% y%y% w%w% h1 +0x10 v%vName% Hidden, ; Horizontal line divider
}

UpdateSectionHeaders() {
    global isDarkTheme, CurrentVisibleSection
    global DARK_SECTION_COLORS, LIGHT_SECTION_COLORS

    if (CurrentVisibleSection = "")
        return

    ; Get the appropriate color for the current section
    sectionColor := isDarkTheme ? DARK_SECTION_COLORS[CurrentVisibleSection] : LIGHT_SECTION_COLORS[CurrentVisibleSection]

    ; Apply color to section headers based on current section
    if (CurrentVisibleSection = "InstanceSettings") {
        GuiControl, +c%sectionColor%, Txt_Instances
    }
    else if (CurrentVisibleSection = "TimeSettings") {
        GuiControl, +c%sectionColor%, Txt_Delay
    }
    else if (CurrentVisibleSection = "PackSettings") {
        GuiControl, +c%sectionColor%, PackSettingsLabel
    }
    else if (CurrentVisibleSection = "SaveForTrade") {
        GuiControl, +c%sectionColor%, s4tEnabled
    }
    else if (CurrentVisibleSection = "DownloadSettings") {
        GuiControl, +c%sectionColor%, DownloadSettingsHeading
    }
}

; Function to toggle background image visibility
ToggleBackgroundImage() {
    global useBackgroundImage, isDarkTheme

    ; Toggle the setting
    useBackgroundImage := !useBackgroundImage

    ; Save the setting
    IniWrite, %useBackgroundImage%, Settings.ini, UserSettings, useBackgroundImage

    ; Update the GUI
    if (useBackgroundImage) {
        ; Update button text
        GuiControl,, BackgroundToggle, Background Off
        ; Show background image if it exists
        GuiControl, Show, BackgroundPic
    } else {
        ; Update button text
        GuiControl,, BackgroundToggle, Background On
        ; Hide background image
        GuiControl, Hide, BackgroundPic
    }

    ; Update the solid background color to ensure it shows through
    bgColor := isDarkTheme ? DARK_BG : LIGHT_BG
    Gui, Color, %bgColor%
}

; Trace hide and show
global CurrentVisibleSection := ""

; ========== hide all section ==========
HideAllSections() {
    ; OPTIMIZED: Using control lists and helper function

    ; Create control lists grouped by sections
    friendIDControls := "FriendIDHeading,FriendID,FriendIDLabel,FriendIDSeparator"
    instanceControls := "InstanceSettingsHeading,Txt_Instances,Instances,Txt_InstanceStartDelay,instanceStartDelay,"
    instanceControls .= "Txt_Columns,Columns,runMain,Mains,Txt_AccountName,AccountName"
    timeControls := "TimeSettingsHeading,Txt_Delay,Delay,Txt_WaitTime,waitTime,Txt_SwipeSpeed,swipeSpeed,"
    timeControls .= "slowMotion,TimeSettingsSeparator"
systemControls := "SystemSettingsHeading,Txt_Monitor,SelectedMonitorIndex,Txt_Scale,defaultLanguage,"
    systemControls .= "Txt_FolderPath,folderPath,Txt_OcrLanguage,ocrLanguage,Txt_ClientLanguage,clientLanguage,"
    systemControls .= "Txt_RowGap,rowGap,"
    systemControls .= "Txt_InstanceLaunchDelay,instanceLaunchDelay,autoLaunchMonitor,SystemSettingsSeparator"
    extraControls := "ExtraSettingsHeading,tesseractOption,Txt_TesseractPath,tesseractPath,"
    extraControls .= "applyRoleFilters,debugMode,statusMessage"
    packControls := "PackSettingsHeading,PackSettingsSubHeading1,Txt_MinStars,minStars,"
    packControls .= "PackSettingsHeading,PackSettingsSubHeading1,Txt_MinStars,minStars,"
    packControls .= "Txt_ShinyMinStars,minStarsShiny,Txt_DeleteMethod,deleteMethod,packMethod,nukeAccount,"
    packControls .= "Pack_Divider1,PackSettingsSubHeading2,PackSelectionList,"
    packControls .= "Pack_Divider2,PackSettingsSubHeading3,ShinyCheck,"
    packControls .= "FullArtCheck,TrainerCheck,RainbowCheck,PseudoGodPack,Txt_vector,InvalidCheck,"
    packControls .= "CheckShinyPackOnly,CrownCheck,ImmersiveCheck,Pack_Divider3,PackSettingsLabel"
    packControls .= ",Txt_VariablePackCount,variablePackCount,spendHourGlass,claimSpecialMissions" ; Add these controls
    packControls .= ",Txt_InjectRange,injectRange"
    s4tControls := "SaveForTradeHeading,s4tEnabled,s4tSilent,s4t3Dmnd,s4t4Dmnd,s4t1Star,"
    s4tControls .= "s4tGholdengo,s4tGholdengoEmblem,s4tGholdengoArrow,Txt_S4TSeparator,s4tWP,"
    s4tControls .= "s4tWPMinCardsLabel,s4tWPMinCards,S4TDiscordSettingsSubHeading,Txt_S4T_DiscordID,"
    s4tControls .= "s4tDiscordUserId,Txt_S4T_DiscordWebhook,s4tDiscordWebhookURL,s4tSendAccountXml,"
    s4tControls .= "SaveForTradeDivider_1,SaveForTradeDivider_2"
    discordControls := "DiscordSettingsHeading,Txt_DiscordID,discordUserId,Txt_DiscordWebhook,"
    discordControls .= "discordWebhookURL,sendAccountXml,HeartbeatSettingsSubHeading,heartBeat,"
    discordControls .= "hbName,heartBeatName,hbURL,heartBeatWebhookURL,hbDelay,heartBeatDelay,"
    discordControls .= "DiscordSettingsSeparator,Discord_Divider3"
    downloadControls := "DownloadSettingsHeading,Txt_MainIdsURL,mainIdsURL,Txt_VipIdsURL,vipIdsURL,"
    downloadControls .= "showcaseEnabled,Txt_ShowcaseURL,showcaseURL"

    ; Hide section headings
    GuiControl, Hide, PackSettingsLabel
    
    ; Hide all controls by section using helper function
    HideControls(friendIDControls)
    HideControls(instanceControls)
    HideControls(timeControls)
    HideControls(systemControls)
    HideControls(extraControls)
    HideControls(packControls)
    HideControls(s4tControls)
    HideControls(discordControls)
    HideControls(downloadControls)

    ; Explicitly hide these checkboxes to ensure they don't appear in wrong sections
    GuiControl, Hide, spendHourGlass
    GuiControl, Hide, claimSpecialMissions

    ; Hide separators
    GuiControl, Hide, RerollSettingsSeparator

    ; Hide Sort By controls if they exist
    global sortByCreated
    if (sortByCreated) {
        GuiControl, Hide, SortByText
        GuiControl, Hide, SortByDropdown
    }

    ; Hide ALL divider elements
    dividerList := "FriendID_Divider,Instance_Divider3,System_Divider1,System_Divider2,System_Divider3,"
    dividerList .= "System_Divider4,Pack_Divider1,Pack_Divider2,Pack_Divider3,Discord_Divider3,"
    dividerList .= "SaveForTrade_Divider1,SaveForTrade_Divider2"
    HideControls(dividerList)
}

; ========== show Reroll Settings section ==========
ShowRerollSettingsSection() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT
    global DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT
    global DARK_SECTION_COLORS, LIGHT_SECTION_COLORS

    SetNormalFont()

    ; First, make sure all other sections are hidden
    HideAllSections()

    ; Get the section color
    sectionColor := isDarkTheme ? DARK_SECTION_COLORS["RerollSettings"] : LIGHT_SECTION_COLORS["RerollSettings"]

    ; === Friend ID Section with Heading ===
    ; Define lists of controls to show
    friendIDControls := "FriendIDHeading,FriendIDLabel,FriendID,FriendID_Divider"
    instanceControls := "InstanceSettingsHeading,Txt_Instances,Instances,Txt_Columns,Columns,"
    instanceControls .= "Txt_InstanceStartDelay,instanceStartDelay,runMain,Txt_AccountName,AccountName,Instance_Divider3"
    timeControls := "TimeSettingsHeading,Txt_Delay,Delay,Txt_WaitTime,waitTime,Txt_SwipeSpeed,swipeSpeed,slowMotion"

    ; Show controls using helper function
    ShowControls(friendIDControls)
    ShowControls(instanceControls)
    ShowControls(timeControls)

    ; Apply section colors to headings
    GuiControl, +c%sectionColor%, FriendIDHeading
    GuiControl, +c%sectionColor%, InstanceSettingsHeading
    GuiControl, +c%sectionColor%, TimeSettingsHeading

    ; Show Mains if runMain is checked
    GuiControlGet, runMain
    if (runMain) {
        GuiControl, Show, Mains
    }

    ; Apply styling based on theme
    textColor := isDarkTheme ? DARK_TEXT : LIGHT_TEXT
    inputBgColor := isDarkTheme ? DARK_INPUT_BG : LIGHT_INPUT_BG
    inputTextColor := isDarkTheme ? DARK_INPUT_TEXT : LIGHT_INPUT_TEXT

    ; Text controls
    textControls := "FriendIDLabel,Txt_Instances,Txt_InstanceStartDelay,Txt_Columns,runMain,"
    textControls .= "Txt_AccountName,Txt_Delay,Txt_WaitTime,Txt_SwipeSpeed,slowMotion"

    ; Input controls
    inputControls := "FriendID,Instances,instanceStartDelay,Columns,AccountName,Delay,waitTime,swipeSpeed"

    ; Apply text styling
    Loop, Parse, textControls, `,
    {
        if (A_LoopField)
            GuiControl, +c%textColor%, %A_LoopField%
    }

    ; Apply input styling
    Loop, Parse, inputControls, `,
    {
        if (A_LoopField)
            GuiControl, +Background%inputBgColor% +c%inputTextColor%, %A_LoopField%
    }

    ; Apply styling to Mains if shown
    if (runMain)
        GuiControl, +Background%inputBgColor% +c%inputTextColor%, Mains

    ; Update section headers with appropriate colors
    UpdateSectionHeaders()
}

; ========== show System Settings Section ==========
ShowSystemSettingsSection() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT, DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT
    global DARK_SECTION_COLORS, LIGHT_SECTION_COLORS

    SetNormalFont()

    ; First, make sure all other sections are hidden
    HideAllSections()

    ; Get the section color
    sectionColor := isDarkTheme ? DARK_SECTION_COLORS["SystemSettings"] : LIGHT_SECTION_COLORS["SystemSettings"]

    ; Show main heading
    GuiControl, Show, SystemSettingsHeading
    GuiControl, +c%sectionColor%, SystemSettingsHeading

    ; Define control lists for better organization
    monitorControls := "Txt_Monitor,SelectedMonitorIndex,Txt_Scale,defaultLanguage"
    pathControls := "Txt_FolderPath,folderPath,Txt_OcrLanguage,ocrLanguage,Txt_ClientLanguage,clientLanguage"
    instanceControls := "Txt_RowGap,rowGap,Txt_InstanceLaunchDelay,instanceLaunchDelay,autoLaunchMonitor"
    extraControls := "ExtraSettingsHeading,tesseractOption,applyRoleFilters,debugMode,statusMessage"

    ; Show controls by group
    ShowControls(monitorControls)
    ShowControls(pathControls)
    ShowControls(instanceControls)
    ShowControls(extraControls)
    
    ; Check if tesseractOption is checked
    GuiControlGet, tesseractOption
    if (tesseractOption) {
        GuiControl, Show, Txt_TesseractPath
        GuiControl, Show, tesseractPath
        ApplyTextColor("Txt_TesseractPath")
        ApplyInputStyle("tesseractPath")
    }

    ; Apply text styling to all text controls
    textControls := "Txt_Monitor,Txt_Scale,Txt_FolderPath,Txt_OcrLanguage,Txt_ClientLanguage,"
    textControls .= "Txt_RowGap,Txt_InstanceLaunchDelay,autoLaunchMonitor,"
    textControls .= "ExtraSettingsHeading,tesseractOption,applyRoleFilters,debugMode,statusMessage"
    ApplyTextColorToMultiple(textControls)

    ; Apply input styling to all input fields
    inputControls := "SelectedMonitorIndex,defaultLanguage,folderPath,ocrLanguage,clientLanguage,"
    inputControls .= "rowGap,instanceLaunchDelay"
    ApplyInputStyleToMultiple(inputControls)

    ; Update section headers with appropriate colors
    UpdateSectionHeaders()
}

; ========== show Pack Settings Section ==========
ShowPackSettingsSection() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT, DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT
    global DARK_SECTION_COLORS, LIGHT_SECTION_COLORS, deleteMethod, nukeAccount, injectRange
    global Shining, Arceus, Palkia, Dialga, Pikachu, Charizard, Mewtwo, Mew, Solgaleo, Lunala
    global sortByCreated

    SetNormalFont()

    ; First, make sure all other sections are hidden
    HideAllSections()

    ; Get the section color
    sectionColor := isDarkTheme ? DARK_SECTION_COLORS["PackSettings"] : LIGHT_SECTION_COLORS["PackSettings"]

    ; === God Pack Settings Subsection ===
    ; Define control lists for each subsection
    godPackControls := "PackSettingsSubHeading1,Txt_MinStars,minStars,Txt_ShinyMinStars,minStarsShiny,"
    godPackControls .= "Txt_DeleteMethod,deleteMethod,packMethod,Pack_Divider1"

    packSelectionControls := "PackSettingsSubHeading2,PackSelectionList,Pack_Divider2"

    cardDetectionControls := "PackSettingsSubHeading3,FullArtCheck,TrainerCheck,RainbowCheck,"
    cardDetectionControls .= "PseudoGodPack,Txt_vector,CrownCheck,ShinyCheck,ImmersiveCheck,"
    cardDetectionControls .= "InvalidCheck,CheckShinyPackOnly,Pack_Divider3"

    ; Show controls by subsection
    ShowControls(godPackControls)
    ShowControls(packSelectionControls)
    ShowControls(cardDetectionControls)

    ; Apply section colors to headings
    GuiControl, +c%sectionColor%, PackSettingsSubHeading1
    GuiControl, +c%sectionColor%, PackSettingsSubHeading2
    GuiControl, +c%sectionColor%, PackSettingsSubHeading3

    ; Check if deleteMethod is "inject" and create controls if needed
    GuiControlGet, deleteMethod
    
    if (InStr(deleteMethod, "Inject")) {
        ; First make sure to hide nukeAccount which isn't applicable for Inject methods
        GuiControl, Hide, nukeAccount
        GuiControl,, nukeAccount, 0  ; Uncheck the checkbox when hidden
        
        ; Show claim special missions for Inject methods and ensure it's visible
        GuiControl, Show, claimSpecialMissions
        ApplyTextColor("claimSpecialMissions")
        
        ; Create Sort By controls if they don't exist yet
        if (!sortByCreated) {
            ; Create Sort By label and dropdown
            SetNormalFont()
            
            ; Determine which option to pre-select
            sortOption := 1 ; Default (ModifiedAsc)
            if (injectSortMethod = "ModifiedDesc")
                sortOption := 2
            else if (injectSortMethod = "PacksAsc")
                sortOption := 3
            else if (injectSortMethod = "PacksDesc")
                sortOption := 4
            
            ; Create the controls with static positions but unique variable names
            Gui, Add, Text, x170 y250 vSortByText, Sort By:
            Gui, Add, DropDownList, x270 y248 w170 vSortByDropdown gSortByDropdownHandler Choose%sortOption%, Oldest First|Newest First|Fewest Packs First|Most Packs First
            
            ; Apply styling
            ApplyTextColor("SortByText")
            
            ; Mark as created
            sortByCreated := true
        } else {
            ; Just show the existing controls
            GuiControl, Show, SortByText
            GuiControl, Show, SortByDropdown
        }
        
        ; NEW CODE: Handle method-specific settings during initial load
        ; "Inject variable" specific settings
        if (deleteMethod = "Inject variable") {
            GuiControl, Show, Txt_VariablePackCount
            GuiControl, Show, variablePackCount
            GuiControl, Hide, Txt_InjectRange
            GuiControl, Hide, injectRange
            
            ApplyTextColor("Txt_VariablePackCount")
            ApplyInputStyle("variablePackCount")
        } 
        ; NEW CODE: Handle "Inject Range" on initialization
        else if (deleteMethod = "Inject Range") {
            GuiControl, Show, Txt_InjectRange
            GuiControl, Show, injectRange
            GuiControl, Hide, Txt_VariablePackCount
            GuiControl, Hide, variablePackCount
            
            ApplyTextColor("Txt_InjectRange")
            ApplyInputStyle("injectRange")
        }
        else {
            GuiControl, Hide, Txt_VariablePackCount
            GuiControl, Hide, variablePackCount
            GuiControl, Hide, Txt_InjectRange
            GuiControl, Hide, injectRange
        }
    } else {
        ; Non-Inject method selected
        GuiControl, Show, nukeAccount
        GuiControl, Hide, claimSpecialMissions
        GuiControl,, claimSpecialMissions, 0
        GuiControl, Hide, Txt_VariablePackCount
        GuiControl, Hide, variablePackCount
        GuiControl, Hide, Txt_InjectRange
        GuiControl, Hide, injectRange
        
        ; Hide Sort By controls if they exist
        if (sortByCreated) {
            GuiControl, Hide, SortByText
            GuiControl, Hide, SortByDropdown
        }
        
        ; Apply styling
        ApplyTextColor("nukeAccount")
    }

    ; Always show spendHourGlass
    GuiControl, Show, spendHourGlass
    ApplyTextColor("spendHourGlass")

    ; Initialize ListView for pack selection
    LV_Delete()

    ; Add all items in the specified order
    LV_Add("", "Solgaleo")
    LV_Add("", "Lunala") 
    LV_Add("", "Shining")
    LV_Add("", "Arceus")
    LV_Add("", "Palkia")
    LV_Add("", "Dialga")
    LV_Add("", "Pikachu")
    LV_Add("", "Charizard")
    LV_Add("", "Mewtwo")
    LV_Add("", "Mew")

    ; Then check rows based on the actual variable values
    Loop, % LV_GetCount()
    {
        LV_GetText(packName, A_Index)
    
        ; Check if the corresponding variable is 1
        isChecked := false
        if (packName = "Solgaleo" && Solgaleo = 1)
            isChecked := true
        else if (packName = "Lunala" && Lunala = 1)
            isChecked := true
        else if (packName = "Shining" && Shining = 1)
            isChecked := true
        else if (packName = "Arceus" && Arceus = 1)
            isChecked := true
        else if (packName = "Palkia" && Palkia = 1)
            isChecked := true
        else if (packName = "Dialga" && Dialga = 1)
            isChecked := true
        else if (packName = "Pikachu" && Pikachu = 1)
            isChecked := true
        else if (packName = "Charizard" && Charizard = 1)
            isChecked := true
        else if (packName = "Mewtwo" && Mewtwo = 1)
            isChecked := true
        else if (packName = "Mew" && Mew = 1)
            isChecked := true
    
        ; Check or uncheck the row based on the variable value
        if (isChecked)
            LV_Modify(A_Index, "Check")
    }

    ; Apply theme-based styling
    textColor := isDarkTheme ? DARK_TEXT : LIGHT_TEXT
    inputBgColor := isDarkTheme ? DARK_INPUT_BG : LIGHT_INPUT_BG
    inputTextColor := isDarkTheme ? DARK_INPUT_TEXT : LIGHT_INPUT_TEXT

    ; God Pack Settings text controls
    godPackTextControls := "Txt_MinStars,Txt_ShinyMinStars,Txt_DeleteMethod,packMethod,spendHourGlass"
    if (!InStr(deleteMethod, "Inject")) {
        godPackTextControls .= ",nukeAccount"
    } else {
        godPackTextControls .= ",claimSpecialMissions"
    }

    ; Card Detection text controls
    cardDetectionTextControls := "FullArtCheck,TrainerCheck,RainbowCheck,PseudoGodPack,"
    cardDetectionTextControls .= "CrownCheck,ShinyCheck,ImmersiveCheck,InvalidCheck,CheckShinyPackOnly"

    ; Input controls
    inputControls := "minStars,minStarsShiny"

    ; Apply text styling to all controls
    ApplyTextColorToMultiple(godPackTextControls)
    ApplyTextColorToMultiple(cardDetectionTextControls)

    ; Apply input styling
    ApplyInputStyleToMultiple(inputControls)
    
    ; Apply styling to the ListView
    if (isDarkTheme) {
        GuiControl, +Background%DARK_INPUT_BG% +c%DARK_INPUT_TEXT%, PackSelectionList
    } else {
        GuiControl, +Background%LIGHT_INPUT_BG% +c%LIGHT_INPUT_TEXT%, PackSelectionList
    }

    ; Update section headers with appropriate colors
    UpdateSectionHeaders()
}

; ========== Show Save For Trade Section ==========
ShowSaveForTradeSection() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT, DARK_TEXT_SECONDARY, LIGHT_TEXT_SECONDARY
    global DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT
    global DARK_SECTION_COLORS, LIGHT_SECTION_COLORS

    SetNormalFont()

    ; First, make sure all other sections are hidden
    HideAllSections()

    ; Get the section color
    sectionColor := isDarkTheme ? DARK_SECTION_COLORS["SaveForTrade"] : LIGHT_SECTION_COLORS["SaveForTrade"]

    ; Show main heading
    GuiControl, Show, SaveForTradeHeading
    GuiControl, +c%sectionColor%, SaveForTradeHeading

    ; Show s4tEnabled toggle
    GuiControl, Show, s4tEnabled
    GuiControl, +c%sectionColor%, s4tEnabled

    ; Show dividers
    GuiControl, Show, SaveForTradeDivider_1
    GuiControl, Show, SaveForTradeDivider_2

    ; Check if s4tEnabled is checked to show related controls
    GuiControlGet, s4tEnabled
    if (s4tEnabled) {
        ; Define control lists for enabled state
        mainS4TControls := "s4tSilent,s4t3Dmnd,s4t4Dmnd,s4t1Star,Txt_S4TSeparator,s4tWP"
        ShowControls(mainS4TControls)

        ; Discord subsection controls
        s4tDiscordControls := "S4TDiscordSettingsSubHeading,Txt_S4T_DiscordID,s4tDiscordUserId,"
        s4tDiscordControls .= "Txt_S4T_DiscordWebhook,s4tDiscordWebhookURL,s4tSendAccountXml"
        ShowControls(s4tDiscordControls)

        ; Apply section color to sub-heading
        GuiControl, +c%sectionColor%, S4TDiscordSettingsSubHeading

        ; Apply text styling
        textColor := isDarkTheme ? DARK_TEXT : LIGHT_TEXT
        secondaryTextColor := isDarkTheme ? DARK_TEXT_SECONDARY : LIGHT_TEXT_SECONDARY

        ; Set text colors
        mainTextControls := "s4tSilent,s4t3Dmnd,s4t4Dmnd,s4t1Star,s4tWP,"
        mainTextControls .= "Txt_S4T_DiscordID,Txt_S4T_DiscordWebhook,s4tSendAccountXml"
        ApplyTextColorToMultiple(mainTextControls)

        ; Set secondary text color
        GuiControl, +c%secondaryTextColor%, Txt_S4TSeparator

        ; Apply input styling to fields
        inputControls := "s4tDiscordUserId,s4tDiscordWebhookURL"
        ApplyInputStyleToMultiple(inputControls)

        ; Check if Shining is enabled to show Gholdengo
        GuiControlGet, Shining
        if (Shining) {
            GuiControl, Show, s4tGholdengo
            GuiControl, Show, s4tGholdengoEmblem
            GuiControl, Show, s4tGholdengoArrow

            gholdengoControls := "s4tGholdengo,s4tGholdengoArrow"
            ApplyTextColorToMultiple(gholdengoControls)
        }

        ; Check if s4tWP is checked to show min cards
        GuiControlGet, s4tWP
        if (s4tWP) {
            GuiControl, Show, s4tWPMinCardsLabel
            GuiControl, Show, s4tWPMinCards

            ApplyTextColor("s4tWPMinCardsLabel")
            ApplyInputStyle("s4tWPMinCards")
        }
    }

    ; Update section headers with appropriate colors
    UpdateSectionHeaders()
}

; ========== Show Discord Settings Section ==========
ShowDiscordSettingsSection() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT
    global DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT
    global DARK_SECTION_COLORS, LIGHT_SECTION_COLORS

    SetNormalFont()

    ; First, make sure all other sections are hidden
    HideAllSections()

    ; Get the section color
    sectionColor := isDarkTheme ? DARK_SECTION_COLORS["DiscordSettings"] : LIGHT_SECTION_COLORS["DiscordSettings"]

    ; Define control lists
    mainDiscordControls := "DiscordSettingsHeading,Txt_DiscordID,discordUserId,"
    mainDiscordControls .= "Txt_DiscordWebhook,discordWebhookURL,sendAccountXml"

    heartbeatHeadingControls := "HeartbeatSettingsSubHeading,Discord_Divider3,heartBeat"

    ; Show main Discord controls
    ShowControls(mainDiscordControls)
    ShowControls(heartbeatHeadingControls)

    ; Apply section color to headings
    GuiControl, +c%sectionColor%, DiscordSettingsHeading
    GuiControl, +c%sectionColor%, HeartbeatSettingsSubHeading

    ; Apply text styling
    textColor := isDarkTheme ? DARK_TEXT : LIGHT_TEXT
    mainTextControls := "Txt_DiscordID,Txt_DiscordWebhook,sendAccountXml,heartBeat"
    ApplyTextColorToMultiple(mainTextControls)

    ; Apply input styling
    inputControls := "discordUserId,discordWebhookURL"
    ApplyInputStyleToMultiple(inputControls)

    ; Check if heartBeat is enabled to show related controls
    GuiControlGet, heartBeat
    if (heartBeat) {
        heartbeatControls := "hbName,heartBeatName,hbURL,heartBeatWebhookURL,hbDelay,heartBeatDelay"
        ShowControls(heartbeatControls)

        ; Apply text styling to heartbeat controls
        heartbeatTextControls := "hbName,hbURL,hbDelay"
        ApplyTextColorToMultiple(heartbeatTextControls)

        ; Apply input styling to heartbeat fields
        heartbeatInputControls := "heartBeatName,heartBeatWebhookURL,heartBeatDelay"
        ApplyInputStyleToMultiple(heartbeatInputControls)
    }

    ; Show the bottom separator
    GuiControl, Show, DiscordSettingsSeparator

    ; Update section headers with appropriate colors
    UpdateSectionHeaders()
}

; ========== Download Settings Section ==========
ShowDownloadSettingsSection() {
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT
    global DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT
    global DARK_SECTION_COLORS, LIGHT_SECTION_COLORS
    global showcaseEnabled

    SetNormalFont()

    ; First, make sure all other sections are hidden
    HideAllSections()

    ; Define control lists
    mainControls := "DownloadSettingsHeading,Txt_MainIdsURL,mainIdsURL,Txt_VipIdsURL,vipIdsURL,showcaseEnabled"
    ShowControls(mainControls)

    ; Get section color and apply to heading
    sectionColor := isDarkTheme ? DARK_SECTION_COLORS["DownloadSettings"] : LIGHT_SECTION_COLORS["DownloadSettings"]
    GuiControl, +c%sectionColor%, DownloadSettingsHeading

    ; Apply text styling
    textColor := isDarkTheme ? DARK_TEXT : LIGHT_TEXT
    mainTextControls := "Txt_MainIdsURL,Txt_VipIdsURL,showcaseEnabled"
    ApplyTextColorToMultiple(mainTextControls)

    ; Apply input styling
    inputControls := "mainIdsURL,vipIdsURL"
    ApplyInputStyleToMultiple(inputControls)

    ; Update section headers with appropriate colors
    UpdateSectionHeaders()
}

; Add ListBox item selection helper function
LB_SelectItem(controlID, itemText) {
    SendMessage, 0x18A, 0, 0,, ahk_id %controlID% ; LB_GETCOUNT
    itemCount := ErrorLevel
    
    Loop, %itemCount% {
        SendMessage, 0x186, A_Index-1, 0,, ahk_id %controlID% ; LB_GETTEXT
        currText := ErrorLevel
        if (currText = itemText) {
            SendMessage, 0x185, A_Index-1, 1,, ahk_id %controlID% ; LB_SETSEL (select)
            break
        }
    }
}

; Handle keyboard shortcuts
HandleKeyboardShortcut(sectionIndex) {
    ; Create array for sections (updated to new structure)
    sections := []
    sections.Push("RerollSettings")
    sections.Push("SystemSettings")
    sections.Push("PackSettings")
    sections.Push("SaveForTrade")
    sections.Push("DiscordSettings")
    sections.Push("DownloadSettings")

    ; Check if the index is valid
    if (sectionIndex > 0 && sectionIndex <= sections.MaxIndex()) {
        ; Get the section name
        sectionName := sections[sectionIndex]

        ; Hide all sections
        HideAllSections()

        ; Show the selected section based on its name
        if (sectionName = "RerollSettings")
            ShowRerollSettingsSection()
        else if (sectionName = "SystemSettings")
            ShowSystemSettingsSection()
        else if (sectionName = "PackSettings")
            ShowPackSettingsSection()
        else if (sectionName = "SaveForTrade")
            ShowSaveForTradeSection()
        else if (sectionName = "DiscordSettings")
            ShowDiscordSettingsSection()
        else if (sectionName = "DownloadSettings")
            ShowDownloadSettingsSection()

        ; Update current section and tab highlighting
        CurrentVisibleSection := sectionName

        ; Set section title
        friendlyName := GetFriendlyName(sectionName)
        GuiControl,, ActiveSection, Current Section: %friendlyName%

; Update section color
        sectionColor := isDarkTheme ? DARK_SECTION_COLORS[sectionName] : LIGHT_SECTION_COLORS[sectionName]
        GuiControl, +c%sectionColor%, ActiveSection
        
        ; Save current settings after changing sections
        SaveAllSettings()
    }
}

HandleFunctionKeyShortcut(functionIndex) {
    if (functionIndex = 1)
        gosub, LaunchAllMumu     ; F1: Launch all Mumu
    else if (functionIndex = 2)
        gosub, ArrangeWindows    ; F2: Arrange Windows
    else if (functionIndex = 3)
        gosub, StartBot          ; F3: Start Bot
}

; Function to show help menu with keyboard shortcuts
ShowHelpMenu() {
    global isDarkTheme, useBackgroundImage

    helpText := "Keyboard Shortcuts:`n`n"
    helpText .= "Ctrl+1: Reroll Settings`n"
    helpText .= "Ctrl+2: System Settings`n"
    helpText .= "Ctrl+3: Pack Settings`n"
    helpText .= "Ctrl+4: Save For Trade`n"
    helpText .= "Ctrl+5: Discord Settings`n"
    helpText .= "Ctrl+6: Download Settings`n"
    helpText .= "`nFunction Keys:`n"
    helpText .= "F1: Launch All Mumu`n"
    helpText .= "F2: Arrange Windows`n"
    helpText .= "F3: Start Bot`n"
    helpText .= "F4: Show This Help Menu`n"
    helpText .= "Shift+F7: Send All Offline Status & Exit`n`n"
    helpText .= "Interface Settings:`n"
    helpText .= "Current Theme: " . (isDarkTheme ? "Dark" : "Light") . "`n"
    helpText .= "Background Image: " . (useBackgroundImage ? "Enabled" : "Disabled") . "`n"
    helpText .= "Toggle theme with the button at the top of the window."
    helpText .= "Toggle background image with the BG button."

    MsgBox, 64, Keyboard Shortcuts Help, %helpText%
}

; Helper function to convert section names to friendly names
GetFriendlyName(sectionName) {
    if (sectionName = "RerollSettings")
        return "Reroll Settings"
    else if (sectionName = "SystemSettings")
        return "System Settings"
    else if (sectionName = "PackSettings")
        return "Pack Settings"
    else if (sectionName = "SaveForTrade")
        return "Save For Trade"
    else if (sectionName = "DiscordSettings")
        return "Discord Settings"
    else if (sectionName = "DownloadSettings")
        return "Download Settings"
    else
        return sectionName
}

; Function to load settings from INI file
LoadSettingsFromIni() {
    global

    ; Check if Settings.ini exists
    if (FileExist("Settings.ini")) {
        ; Read basic settings with default values if they don't exist in the file
        IniRead, FriendID, Settings.ini, UserSettings, FriendID, ""
        IniRead, waitTime, Settings.ini, UserSettings, waitTime, 5
        IniRead, Delay, Settings.ini, UserSettings, Delay, 250
        IniRead, folderPath, Settings.ini, UserSettings, folderPath, C:\Program Files\Netease
        IniRead, Columns, Settings.ini, UserSettings, Columns, 5
        IniRead, godPack, Settings.ini, UserSettings, godPack, Continue
        IniRead, Instances, Settings.ini, UserSettings, Instances, 1
        IniRead, instanceStartDelay, Settings.ini, UserSettings, instanceStartDelay, 0
        IniRead, defaultLanguage, Settings.ini, UserSettings, defaultLanguage, Scale125
        IniRead, rowGap, Settings.ini, UserSettings, rowGap, 100
        IniRead, SelectedMonitorIndex, Settings.ini, UserSettings, SelectedMonitorIndex, 1
        IniRead, swipeSpeed, Settings.ini, UserSettings, swipeSpeed, 300
        IniRead, deleteMethod, Settings.ini, UserSettings, deleteMethod, 3 Pack
        IniRead, runMain, Settings.ini, UserSettings, runMain, 1
        IniRead, Mains, Settings.ini, UserSettings, Mains, 1
        IniRead, AccountName, Settings.ini, UserSettings, AccountName, ""
        IniRead, heartBeat, Settings.ini, UserSettings, heartBeat, 0
        IniRead, heartBeatWebhookURL, Settings.ini, UserSettings, heartBeatWebhookURL, ""
        IniRead, heartBeatName, Settings.ini, UserSettings, heartBeatName, ""
        IniRead, nukeAccount, Settings.ini, UserSettings, nukeAccount, 0
        IniRead, packMethod, Settings.ini, UserSettings, packMethod, 0
        IniRead, CheckShinyPackOnly, Settings.ini, UserSettings, CheckShinyPackOnly, 0
        IniRead, TrainerCheck, Settings.ini, UserSettings, TrainerCheck, 0
        IniRead, FullArtCheck, Settings.ini, UserSettings, FullArtCheck, 0
        IniRead, RainbowCheck, Settings.ini, UserSettings, RainbowCheck, 0
        IniRead, ShinyCheck, Settings.ini, UserSettings, ShinyCheck, 0
        IniRead, CrownCheck, Settings.ini, UserSettings, CrownCheck, 0
        IniRead, ImmersiveCheck, Settings.ini, UserSettings, ImmersiveCheck, 0
        IniRead, InvalidCheck, Settings.ini, UserSettings, InvalidCheck, 0
        IniRead, PseudoGodPack, Settings.ini, UserSettings, PseudoGodPack, 0
        IniRead, minStars, Settings.ini, UserSettings, minStars, 0
        IniRead, Palkia, Settings.ini, UserSettings, Palkia, 0
        IniRead, Dialga, Settings.ini, UserSettings, Dialga, 0
        IniRead, Arceus, Settings.ini, UserSettings, Arceus, 0
        IniRead, Shining, Settings.ini, UserSettings, Shining, 0
        IniRead, Mew, Settings.ini, UserSettings, Mew, 0
        IniRead, Pikachu, Settings.ini, UserSettings, Pikachu, 0
        IniRead, Charizard, Settings.ini, UserSettings, Charizard, 0
        IniRead, Mewtwo, Settings.ini, UserSettings, Mewtwo, 0
        IniRead, Solgaleo, Settings.ini, UserSettings, Solgaleo, 1
        IniRead, Lunala, Settings.ini, UserSettings, Lunala, 1
        IniRead, slowMotion, Settings.ini, UserSettings, slowMotion, 0
        IniRead, ocrLanguage, Settings.ini, UserSettings, ocrLanguage, en
        IniRead, clientLanguage, Settings.ini, UserSettings, clientLanguage, en
        IniRead, autoLaunchMonitor, Settings.ini, UserSettings, autoLaunchMonitor, 1
        IniRead, mainIdsURL, Settings.ini, UserSettings, mainIdsURL, ""
        IniRead, vipIdsURL, Settings.ini, UserSettings, vipIdsURL, ""
        IniRead, instanceLaunchDelay, Settings.ini, UserSettings, instanceLaunchDelay, 5
        IniRead, variablePackCount, Settings.ini, UserSettings, variablePackCount, 15
        IniRead, claimSpecialMissions, Settings.ini, UserSettings, claimSpecialMissions, 0
        IniRead, spendHourGlass, Settings.ini, UserSettings, spendHourGlass, 0
        IniRead, injectSortMethod, Settings.ini, UserSettings, injectSortMethod, ModifiedAsc
        IniRead, injectRange, Settings.ini, UserSettings, injectRange, ""
        
        ; Read S4T settings
        IniRead, s4tEnabled, Settings.ini, UserSettings, s4tEnabled, 0
        IniRead, s4tSilent, Settings.ini, UserSettings, s4tSilent, 1
        IniRead, s4t3Dmnd, Settings.ini, UserSettings, s4t3Dmnd, 0
        IniRead, s4t4Dmnd, Settings.ini, UserSettings, s4t4Dmnd, 0
        IniRead, s4t1Star, Settings.ini, UserSettings, s4t1Star, 0
        IniRead, s4tGholdengo, Settings.ini, UserSettings, s4tGholdengo, 0
        IniRead, s4tWP, Settings.ini, UserSettings, s4tWP, 0
        IniRead, s4tWPMinCards, Settings.ini, UserSettings, s4tWPMinCards, 1
        IniRead, s4tDiscordWebhookURL, Settings.ini, UserSettings, s4tDiscordWebhookURL, ""
        IniRead, s4tDiscordUserId, Settings.ini, UserSettings, s4tDiscordUserId, ""
        IniRead, s4tSendAccountXml, Settings.ini, UserSettings, s4tSendAccountXml, 1

        ; Advanced settings
        IniRead, minStarsShiny, Settings.ini, UserSettings, minStarsShiny, 0
        IniRead, minStarsA1Charizard, Settings.ini, UserSettings, minStarsA1Charizard, 0
        IniRead, minStarsA1Mewtwo, Settings.ini, UserSettings, minStarsA1Mewtwo, 0
        IniRead, minStarsA1Pikachu, Settings.ini, UserSettings, minStarsA1Pikachu, 0
        IniRead, minStarsA1a, Settings.ini, UserSettings, minStarsA1a, 0
        IniRead, minStarsA2Dialga, Settings.ini, UserSettings, minStarsA2Dialga, 0
        IniRead, minStarsA2Palkia, Settings.ini, UserSettings, minStarsA2Palkia, 0
        IniRead, minStarsA2a, Settings.ini, UserSettings, minStarsA2a, 0
        IniRead, minStarsA3Solgaleo, Settings.ini, UserSettings, minStarsA3Solgaleo, 0
        IniRead, minStarsA3Lunala, Settings.ini, UserSettings, minStarsA3Lunala, 0

        IniRead, heartBeatDelay, Settings.ini, UserSettings, heartBeatDelay, 30
        IniRead, sendAccountXml, Settings.ini, UserSettings, sendAccountXml, 0
        IniRead, showcaseEnabled, Settings.ini, UserSettings, showcaseEnabled, 0
        IniRead, showcaseLikes, Settings.ini, UserSettings, showcaseLikes, 5
        IniRead, isDarkTheme, Settings.ini, UserSettings, isDarkTheme, 1
        IniRead, useBackgroundImage, Settings.ini, UserSettings, useBackgroundImage, 1

        ; Extra Settings
        IniRead, tesseractPath, Settings.ini, UserSettings, tesseractPath, C:\Program Files\Tesseract-OCR\tesseract.exe
        IniRead, applyRoleFilters, Settings.ini, UserSettings, applyRoleFilters, 0
        IniRead, debugMode, Settings.ini, UserSettings, debugMode, 0
        IniRead, tesseractOption, Settings.ini, UserSettings, tesseractOption, 0
        IniRead, statusMessage, Settings.ini, UserSettings, statusMessage, 1

        ; Validate numeric values
        if (!IsNumeric(Instances) || Instances < 1)
            Instances := 1
        if (!IsNumeric(Columns) || Columns < 1)
            Columns := 5
        if (!IsNumeric(waitTime) || waitTime < 0)
            waitTime := 5
        if (!IsNumeric(Delay) || Delay < 10)
            Delay := 250

        ; Return success
        return true
    } else {
        ; Settings file doesn't exist, will use defaults
        return false
    }
}

; Function to create the default settings file if it doesn't exist
CreateDefaultSettingsFile() {
    if (!FileExist("Settings.ini")) {
        ; Create default settings file
        IniWrite, "", Settings.ini, UserSettings, FriendID
        IniWrite, "", Settings.ini, UserSettings, AccountName
        IniWrite, 5, Settings.ini, UserSettings, waitTime
        IniWrite, 250, Settings.ini, UserSettings, Delay
        IniWrite, C:\Program Files\Netease, Settings.ini, UserSettings, folderPath
        IniWrite, 5, Settings.ini, UserSettings, Columns
        IniWrite, Continue, Settings.ini, UserSettings, godPack
        IniWrite, 1, Settings.ini, UserSettings, Instances
        IniWrite, 0, Settings.ini, UserSettings, instanceStartDelay
        IniWrite, Scale125, Settings.ini, UserSettings, defaultLanguage
        IniWrite, 1, Settings.ini, UserSettings, SelectedMonitorIndex
        IniWrite, 300, Settings.ini, UserSettings, swipeSpeed
        IniWrite, 1, Settings.ini, UserSettings, runMain
        IniWrite, 1, Settings.ini, UserSettings, Mains
        IniWrite, 0, Settings.ini, UserSettings, heartBeat
        IniWrite, "", Settings.ini, UserSettings, heartBeatWebhookURL
        IniWrite, "", Settings.ini, UserSettings, heartBeatName
        IniWrite, 30, Settings.ini, UserSettings, heartBeatDelay
        IniWrite, C:\Program Files\Tesseract-OCR\tesseract.exe, Settings.ini, UserSettings, tesseractPath
        IniWrite, 0, Settings.ini, UserSettings, applyRoleFilters
        IniWrite, 0, Settings.ini, UserSettings, debugMode
        IniWrite, 0, Settings.ini, UserSettings, tesseractOption
        IniWrite, 1, Settings.ini, UserSettings, statusMessage
        IniWrite, 0, Settings.ini, UserSettings, showcaseEnabled
        IniWrite, "", Settings.ini, UserSettings, showcaseURL
        IniWrite, 5, Settings.ini, UserSettings, showcaseLikes
        IniWrite, 1, Settings.ini, UserSettings, isDarkTheme
        IniWrite, 1, Settings.ini, UserSettings, useBackgroundImage
        IniWrite, 100, Settings.ini, UserSettings, rowGap
        IniWrite, 15, Settings.ini, UserSettings, variablePackCount
        IniWrite, 0, Settings.ini, UserSettings, claimSpecialMissions
        IniWrite, 0, Settings.ini, UserSettings, spendHourGlass
        IniWrite, ModifiedAsc, Settings.ini, UserSettings, injectSortMethod
        IniWrite, "", Settings.ini, UserSettings, injectRange

        return true
    }
    return false
}

resetWindows(Title, SelectedMonitorIndex, silent := true) {
    global Columns, runMain, Mains, scaleParam, debugMode, rowGap
    RetryCount := 0
    MaxRetries := 10
    
    ; Use the configurable rowGap with fallback default of 100
    if (!rowGap)
        rowGap := 100
    
    Loop
    {
        try {
            ; Get monitor origin from index
            SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
            SysGet, Monitor, Monitor, %SelectedMonitorIndex%
            
            if (runMain) {
                if (InStr(Title, "Main") = 1) {
                    instanceIndex := StrReplace(Title, "Main", "")
                    if (instanceIndex = "")
                        instanceIndex := 1
                } else {
                    instanceIndex := (Mains - 1) + Title + 1
                }
            } else {
                instanceIndex := Title
            }

            rowHeight := 533  ; Adjust the height of each row
            currentRow := Floor((instanceIndex - 1) / Columns)
            y := currentRow * rowHeight + (currentRow * rowGap)  ; Use the configurable gap
            x := Mod((instanceIndex - 1), Columns) * scaleParam
            WinMove, %Title%, , % (MonitorLeft + x), % (MonitorTop + y), scaleParam, 537
            break
        }
        catch {
            RetryCount++
            if (RetryCount > MaxRetries) {
                if (!silent && debugMode)
                    MsgBox, Failed to position window %Title% after %MaxRetries% attempts
                return false
            }
        }
        Sleep, 1000
    }
    return true
}

; First, try to load existing settings
settingsLoaded := LoadSettingsFromIni()

; If no settings were loaded, create a default settings file
if (!settingsLoaded) {
    CreateDefaultSettingsFile()
    ; Now load the default settings we just created
    LoadSettingsFromIni()
}

CheckForUpdate()
KillADBProcesses()
scriptName := StrReplace(A_ScriptName, ".ahk")
winTitle := scriptName
showStatus := true
totalFile := A_ScriptDir . "\json\total.json"
backupFile := A_ScriptDir . "\json\total-backup.json"
if FileExist(totalFile) ; Check if the file exists
{
    FileCopy, %totalFile%, %backupFile%, 1 ; Copy source file to target
    if (ErrorLevel)
        MsgBox, Failed to create %backupFile%. Ensure permissions and paths are correct.
}
FileDelete, %totalFile%
packsFile := A_ScriptDir . "\json\Packs.json"
backupFile := A_ScriptDir . "\json\Packs-backup.json"
if FileExist(packsFile) ; Check if the file exists
{
    FileCopy, %packsFile%, %backupFile%, 1 ; Copy source file to target
    if (ErrorLevel)
        MsgBox, Failed to create %backupFile%. Ensure permissions and paths are correct.
}
InitializeJsonFile() ; Create or open the JSON file

; Initialize with dark theme
if (isDarkTheme)
    Gui, Color, %DARK_BG%, %DARK_CONTROL_BG%  ; Dark theme
else
    Gui, Color, %LIGHT_BG%, %LIGHT_CONTROL_BG%  ; Light theme

; Header section with enhanced styling
SetArturoFont()

if (isDarkTheme) {
    Gui, Add, Text, x15 y15 c%DARK_TEXT% vHeaderTitle, % "Arturo's PTCGP Bot"
} else {
    Gui, Add, Text, x15 y15 c%LIGHT_TEXT% vHeaderTitle, % "Arturo's PTCGP Bot"
}

; Better styled theme toggle button - adjusted position and size
Gui, Font, s8, Segoe UI  ; Smaller font size

; Add theme toggle button and background toggle button
Gui, Add, Button, x250 y15 w100 h25 gToggleTheme vThemeToggle, % isDarkTheme ? "Light Mode" : "Dark Mode"

; Add background toggle button next to theme toggle
Gui, Add, Button, x+15 w100 h25 gToggleBackground vBackgroundToggle, % useBackgroundImage ? "Background Off" : "Background On"

; Status indicator for active section - moved above Reroll Settings
SetTitleFont()
Gui, Add, Edit, x15 y+15 w450 h28 vActiveSection +Center +ReadOnly -Border -VScroll, Ready to start
; Navigation sidebar with improved styling and adjusted sizes
SetHeaderFont()

; Navigation buttons
Gui, Add, Button, x15 y100 w140 h25 gToggleSection vBtn_RerollSettings, Reroll Settings

Gui, Add, Button, y+5 w140 h25 gToggleSection vBtn_SystemSettings, System Settings

Gui, Add, Button, y+5 w140 h25 gToggleSection vBtn_PackSettings, Pack Settings

Gui, Add, Button, y+20 w140 h25 gToggleSection vBtn_SaveForTrade, Save For Trade

Gui, Add, Button, y+20 w140 h25 gToggleSection vBtn_DiscordSettings, Discord Settings

Gui, Add, Button, y+5 w140 h25 gToggleSection vBtn_DownloadSettings, Download Settings

Gui, Add, Button, gOpenDiscord y+20 w140 h25 vJoinDiscord, 💬 Join Discord

Gui, Add, Button, gOpenLink y+5 w140 h25 vBuyMeACoffee, ☕ Buy Me a Coffee

Gui, Add, Button, gCheckForUpdate y+5 w140 h25 vCheckUpdates, 🔄 Check for Updates

Gui, Add, Button, gBalanceXMLs y+5 w140 h25 vBalanceXMLs, ⚖️ Balance XMLs

; ========== Friend ID Section ==========
SetHeaderFont()
Gui, Add, Text, x170 y100 vFriendIDHeading Hidden, Friend ID Settings

SetInputFont()
Gui, Add, Text, x170 y+20 vFriendIDLabel, Your Friend ID:
if(FriendID = "ERROR" || FriendID = "") {
    Gui, Add, Edit, vFriendID w290 y+10 h25 Hidden
} else {
    Gui, Add, Edit, vFriendID w290 y+10 h25 Hidden, %FriendID%
}

; Add divider for Friend ID section
AddSectionDivider(170, "+20", 290, "FriendID_Divider")

; ========== Instance Settings Section ==========
SetHeaderFont()
Gui, Add, Text, y+17 vInstanceSettingsHeading Hidden, Instance Settings

SetNormalFont()
Gui, Add, Text, y+17 Hidden vTxt_Instances, Instances:
Gui, Add, Edit, vInstances w45 x260 y+-17 h25 Center Hidden, %Instances%

Gui, Add, Text, x170 y+17 Hidden vTxt_InstanceStartDelay, Start Delay:
Gui, Add, Edit, vinstanceStartDelay w45 x260 y+-17 h25 Center Hidden, %instanceStartDelay%

Gui, Add, Text, x170 y+17 Hidden vTxt_Columns, Columns:
Gui, Add, Edit, vColumns w45 x260 y+-17 h25 Center Hidden, %Columns%

Gui, Add, Checkbox, % "vrunMain gmainSettings x170 y+17 Hidden" . (runMain ? " Checked" : ""), % "Run Main(s)"
Gui, Add, Edit, % "vMains w45 x260 y+-17 h25 Center Hidden " . (runMain ? "" : "Hidden"), %Mains%

Gui, Add, Text, x170 y+17 Hidden vTxt_AccountName, Account Name:
Gui, Add, Edit, vAccountName w200 x260 y+-17 h25 Hidden, %AccountName%

; Add dividers for Instance Settings section
AddSectionDivider(170, "+25", 290, "Instance_Divider3")

; ========== Time Settings Section ==========
SetHeaderFont()
Gui, Add, Text, y+25 vTimeSettingsHeading Hidden, Time Settings

SetNormalFont()
Gui, Add, Text, y+20 Hidden vTxt_Delay, Delay:
Gui, Add, Edit, vDelay w45 x260 y+-17 h25 Center Hidden, %Delay%

Gui, Add, Text, x170 y+17 Hidden vTxt_WaitTime, Wait Time:
Gui, Add, Edit, vwaitTime w45 x260 y+-17 h25 Center Hidden, %waitTime%

Gui, Add, Text, x170 y+17  Hidden vTxt_SwipeSpeed, Swipe Speed:
Gui, Add, Edit, vswipeSpeed w45 x260 y+-17 h25 Center Hidden, %swipeSpeed%

Gui, Add, Checkbox, % (slowMotion ? "Checked" : "") " vslowMotion x170 y+12 Hidden", Base Game Compatibility

; ========== System Settings Section ==========
SetSectionFont()
Gui, Add, Text, x170 y100 vSystemSettingsHeading Hidden, System Settings

SetNormalFont()
SysGet, MonitorCount, MonitorCount
MonitorOptions := ""
Loop, %MonitorCount% {
    SysGet, MonitorName, MonitorName, %A_Index%
    SysGet, Monitor, Monitor, %A_Index%
    MonitorOptions .= (A_Index > 1 ? "|" : "") "" A_Index ": (" MonitorRight - MonitorLeft "x" MonitorBottom - MonitorTop ")"
}
SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")

Gui, Add, Text, y+20 Hidden vTxt_Monitor, Monitor:
Gui, Add, DropDownList, x285 y+-17 w95 h300 vSelectedMonitorIndex Choose%SelectedMonitorIndex% Hidden, %MonitorOptions%

Gui, Add, Text, x170 y+17 Hidden vTxt_Scale, Scale:
if (defaultLanguage = "Scale125") {
    defaultLang := 1
    scaleParam := 277
} else if (defaultLanguage = "Scale100") {
    defaultLang := 2
    scaleParam := 287
}

Gui, Add, DropDownList, x285 y+-17 w95 vdefaultLanguage gdefaultLangSetting choose%defaultLang% Hidden, Scale125

Gui, Add, Text, x170 y+17 Hidden vTxt_RowGap, Row Gap:
Gui, Add, Edit, vrowGap w55 x285 y+-17 h25 Center Hidden, %rowGap%

Gui, Add, Text, x170 y+17 Hidden vTxt_FolderPath, Folder Path:
Gui, Add, Edit, vfolderPath x285 y+-17 w180 h25 Hidden, %folderPath%
Gui, Add, Text, x170 y+17 Hidden vTxt_OcrLanguage, OCR:
; ========== Language Pack list ==========
ocrLanguageList := "en|zh|es|de|fr|ja|ru|pt|ko|it|tr|pl|nl|sv|ar|uk|id|vi|th|he|cs|no|da|fi|hu|el|zh-TW"
if (ocrLanguage != "")
{
    index := 0
    Loop, Parse, ocrLanguageList, |
    {
        index++
        if (A_LoopField = ocrLanguage)
        {
            defaultOcrLang := index
            break
        }
    }
}

Gui, Add, DropDownList, vocrLanguage choose%defaultOcrLang% x285 y+-17 w65 Hidden, %ocrLanguageList%

Gui, Add, Text, x170 y+17 Hidden vTxt_ClientLanguage, Client:

; ========== Client Language Pack list ==========
clientLanguageList := "en|es|fr|de|it|pt|jp|ko|cn"

if (clientLanguage != "")
{
    index := 0
    Loop, Parse, clientLanguageList, |
    {
        index++
        if (A_LoopField = clientLanguage)
        {
            defaultClientLang := index
            break
        }
    }
}

Gui, Add, DropDownList, vclientLanguage choose%defaultClientLang% x285 y+-17 w65 Hidden, %clientLanguageList%

Gui, Add, Text, x170 y+17 Hidden vTxt_InstanceLaunchDelay, Launch Mumu Delay:
Gui, Add, Edit, vinstanceLaunchDelay x285 y+-17 w55 h25 Center Hidden, %instanceLaunchDelay%

Gui, Add, Checkbox, % (autoLaunchMonitor ? "Checked" : "") " vautoLaunchMonitor x170 y+17 Hidden", Auto Launch Monitor

SetHeaderFont()
Gui, Add, Text, x170 y+30 Hidden vExtraSettingsHeading, Extra Settings
SetNormalFont()

; First add Role-Based Filters
Gui, Add, Checkbox, % (applyRoleFilters ? "Checked" : "") " vapplyRoleFilters x170 y+10 Hidden", Use Role-Based Filters

; Then add Debug Mode
Gui, Add, Checkbox, % (debugMode ? "Checked" : "") " vdebugMode x170 y+10 Hidden", Debug Mode

; Then add the Use Tesseract checkbox
Gui, Add, Checkbox, % (tesseractOption ? "Checked" : "") " vtesseractOption gTesseractOptionSettings x170 y+10 Hidden", Use Tesseract

; Then add status messages
Gui, Add, Checkbox, % (statusMessage || true ? "Checked" : "") " vstatusMessage x170 y+10 Hidden", Status Messages

; Keep Tesseract Path at the end
Gui, Add, Text, x170 y+20 Hidden vTxt_TesseractPath, Tesseract Path:
Gui, Add, Edit, vtesseractPath w290 x170 y+5 h25 Hidden, %tesseractPath%

; ========== Pack Settings Section ==========
SetHeaderFont()
Gui, Add, Text, x170 y100 c%sectionColor% Hidden vPackSettingsSubHeading1, God Pack Settings
GuiControl, Show, PackSettingsSubHeading1

SetNormalFont()

; === Min. 2★ and 2★ for Shiny Packs fields with ABSOLUTE positioning ===
; First row - left side
Gui, Add, Text, x170 y130 Hidden vTxt_MinStars, Min. 2 ★:
Gui, Add, Edit, vminStars w50 x230 y128 h25 Center Hidden, %minStars%

; First row - right side
Gui, Add, Text, x300 y130 Hidden vTxt_ShinyMinStars, 2 ★ for Shiny Packs:
Gui, Add, Edit, vminStarsShiny w50 x413 y128 h25 Center Hidden, %minStarsShiny%

; Second row - Method dropdown
Gui, Add, Text, x170 y165 Hidden vTxt_DeleteMethod, Method:

; Determine which option in the dropdown to select based on the loaded deleteMethod value
defaultDelete := 1 ; Default to the first option
if (deleteMethod = "5 Pack")
    defaultDelete := 1
else if (deleteMethod = "3 Pack")
    defaultDelete := 2
else if (deleteMethod = "5 Pack (Fast)")
    defaultDelete := 3
else if (deleteMethod = "13 Pack")
    defaultDelete := 4
else if (deleteMethod = "Inject")
    defaultDelete := 5
else if (deleteMethod = "Inject long")
    defaultDelete := 6
else if (deleteMethod = "Inject 39+")
    defaultDelete := 7
else if (deleteMethod = "Inject variable")
    defaultDelete := 8
else if (deleteMethod = "Inject Range")
    defaultDelete := 9

Gui, Add, DropDownList, vdeleteMethod gdeleteSettings choose%defaultDelete% x230 y163 w120 Hidden, 5 Pack|3 Pack|5 Pack (Fast)|13 Pack|Inject|Inject long|Inject 39+|Inject variable|Inject Range

Gui, Add, Text, x360 y165 Hidden vTxt_VariablePackCount, Packs:
Gui, Add, Edit, vvariablePackCount w45 x400 y163 h25 Center Hidden, %variablePackCount%

Gui, Add, Text, x360 y165 Hidden vTxt_InjectRange, Range:
Gui, Add, Edit, vinjectRange w45 x400 y163 h25 Center Hidden, %injectRange%

; Third row - Pack Method and Menu Delete
Gui, Add, Checkbox, % (packMethod ? "Checked" : "") " vpackMethod x170 y195 Hidden", 1 Pack Method
Gui, Add, Checkbox, % (nukeAccount ? "Checked" : "") " vnukeAccount x300 y195 Hidden", Menu Delete

; New checkboxes
Gui, Add, Checkbox, % (spendHourGlass ? "Checked" : "") " vspendHourGlass x170 y220 Hidden", Spend Hour Glass
Gui, Add, Checkbox, % (claimSpecialMissions ? "Checked" : "") " vclaimSpecialMissions x300 y220 Hidden", Claim Special Missions

; === Pack Selection Section ===
SetHeaderFont()
Gui, Add, Text, x175 y290 c%sectionColor% Hidden vPackSettingsSubHeading2, Pack Selection

SetNormalFont()

; Add a ListView with checkboxes for Pack Selection
Gui, Add, ListView, vPackSelectionList gUpdatePackSelection x170 y320 w290 h120 Checked Grid -Multi -HScroll AltSubmit Hidden, Pack Name
LV_ModifyCol(1, 270)

; Add the packs to the ListView
LV_Add("", "Solgaleo")
LV_Add("", "Lunala")
LV_Add("", "Shining")
LV_Add("", "Arceus")
LV_Add("", "Palkia")
LV_Add("", "Dialga")
LV_Add("", "Pikachu")
LV_Add("", "Charizard")
LV_Add("", "Mewtwo")
LV_Add("", "Mew")

; === Card Detection Section ===
; Keep the original Card Detection section code, but use absolute positioning
SetHeaderFont()
Gui, Add, Text, x170 y480 c%sectionColor% Hidden vPackSettingsSubHeading3, Card Detection

SetNormalFont()
; Left Column
Gui, Add, Checkbox, % (FullArtCheck ? "Checked" : "") " vFullArtCheck x170 y510 Hidden", Single Full Art
Gui, Add, Checkbox, % (TrainerCheck ? "Checked" : "") " vTrainerCheck x170 y540 Hidden", Single Trainer
Gui, Add, Checkbox, % (RainbowCheck ? "Checked" : "") " vRainbowCheck x170 y570 Hidden", Single Rainbow
Gui, Add, Checkbox, % (PseudoGodPack ? "Checked" : "") " vPseudoGodPack x170 y600 Hidden", Double 2 ★

; Show the divider between columns
Gui, Add, Text, x285 y490 w2 h110 Hidden vTxt_vector +0x10  ; Creates a vertical line
GuiControl, Show, Txt_vector

; Right Column
Gui, Add, Checkbox, % (CrownCheck ? "Checked" : "") " vCrownCheck x320 y510 Hidden", Save Crowns
Gui, Add, Checkbox, % (ShinyCheck ? "Checked" : "") " vShinyCheck x320 y540 Hidden", Save Shiny
Gui, Add, Checkbox, % (ImmersiveCheck ? "Checked" : "") " vImmersiveCheck x320 y570 Hidden", Save Immersives

; Bottom options
Gui, Add, Checkbox, % (CheckShinyPackOnly ? "Checked" : "") " vCheckShinyPackOnly x170 y630 Hidden", Only Shiny Packs
Gui, Add, Checkbox, % (InvalidCheck ? "Checked" : "") " vInvalidCheck x320 y630 Hidden", Ignore Invalid Packs

; ========== Save For Trade Section ==========
SetSectionFont()
; Add main heading for Save For Trade section
Gui, Add, Text, x170 y100 Hidden vSaveForTradeHeading, Save For Trade

SetNormalFont()
Gui, Add, Checkbox, % "vs4tEnabled gs4tSettings y+20 Hidden " . (s4tEnabled ? "Checked " : ""), Enable S4T

Gui, Add, Checkbox, % "vs4tSilent y+20 " . (!CurrentVisibleSection = "SaveForTrade" || !s4tEnabled ? "Hidden " : "") . (s4tSilent ? "Checked " : ""), Silent (No Ping)

Gui, Add, Checkbox, % "vs4t3Dmnd y+20 " . (!CurrentVisibleSection = "SaveForTrade" || !s4tEnabled ? "Hidden " : "") . (s4t3Dmnd ? "Checked " : ""), 3 ◆◆◆
Gui, Add, Checkbox, % "vs4t4Dmnd y+20 " . (!CurrentVisibleSection = "SaveForTrade" || !s4tEnabled ? "Hidden " : "") . (s4t4Dmnd ? "Checked " : ""), 4 ◆◆◆◆
Gui, Add, Checkbox, % "vs4t1Star y+20 " . (!CurrentVisibleSection = "SaveForTrade" || !s4tEnabled ? "Hidden " : "") . (s4t1Star ? "Checked " : ""), 1 ★

Gui, Add, Checkbox, % ((!CurrentVisibleSection = "SaveForTrade" || !s4tEnabled || !Shining) ? "Hidden " : "") . "vs4tGholdengo x395 y+-14" . (s4tGholdengo ? "Checked " : ""), % "➡"
Gui, Add, Picture, % ((!CurrentVisibleSection = "SaveForTrade" || !s4tEnabled || !Shining) ? "Hidden " : "") . "vs4tGholdengoEmblem w25 h25 x+0 y+-18", % A_ScriptDir . "\Scripts\Scale125\GholdengoEmblem.png"

AddSectionDivider(170, "+15", 290, "SaveForTradeDivider_1")

Gui, Add, Checkbox, % "vs4tWP gs4tWPSettings x170 y+20 " . (!CurrentVisibleSection = "SaveForTrade" || !s4tEnabled ? "Hidden " : "") . (s4tWP ? "Checked " : ""), Wonder Pick

Gui, Add, Text, % "vs4tWPMinCardsLabel x280 y+-14 " . (!CurrentVisibleSection = "SaveForTrade" || !s4tEnabled || !s4tWP ? "Hidden " : ""), Min. Cards:
Gui, Add, Edit, % "vs4tWPMinCards w35 x+20 y+-17 h25 Center " . (!CurrentVisibleSection = "SaveForTrade" || !s4tEnabled || !s4tWP ? "Hidden" : ""), %s4tWPMinCards%

AddSectionDivider(170, "+15", 290, "SaveForTradeDivider_2")
; === S4T Discord Settings (now part of Save For Trade) ===
SetHeaderFont()
Gui, Add, Text, x170 y+20 Hidden vS4TDiscordSettingsSubHeading, S4T Discord Settings

SetNormalFont()
if(StrLen(s4tDiscordUserId) < 3)
    s4tDiscordUserId =
if(StrLen(s4tDiscordWebhookURL) < 3)
    s4tDiscordWebhookURL =

Gui, Add, Text, y+20 Hidden vTxt_S4T_DiscordID, Discord ID:
Gui, Add, Edit, vs4tDiscordUserId w290 y+10 h25 Hidden, %s4tDiscordUserId%
Gui, Add, Text, y+20 Hidden vTxt_S4T_DiscordWebhook, Webhook URL:
Gui, Add, Edit, vs4tDiscordWebhookURL w290 y+10 h25 Center Hidden, %s4tDiscordWebhookURL%
Gui, Add, Checkbox, % (s4tSendAccountXml ? "Checked" : "") " vs4tSendAccountXml y+20 Hidden", Send Account XML

; ========== Discord Settings Section ==========
SetSectionFont()
; Add main heading for Discord Settings section
Gui, Add, Text, x170 y100 Hidden vDiscordSettingsHeading, Discord Settings

SetNormalFont()
Gui, Add, Text, y+20 Hidden vTxt_DiscordID, Discord ID:
Gui, Add, Edit, vdiscordUserId w290 y+10 h25 Hidden, %discordUserId%

Gui, Add, Text, y+20 Hidden vTxt_DiscordWebhook, Webhook URL:
Gui, Add, Edit, vdiscordWebhookURL w290 y+10 h25 Hidden, %discordWebhookURL%

Gui, Add, Checkbox, % (sendAccountXml ? "Checked" : "") " vsendAccountXml y+20 Hidden", Send Account XML

; Add divider after heading
AddSectionDivider(170, "+20", 290, "Discord_Divider3")
; === Heartbeat Settings (now part of Discord) ===
SetHeaderFont()
Gui, Add, Text, y+20 Hidden vHeartbeatSettingsSubHeading, Heartbeat Settings

SetNormalFont()
Gui, Add, Checkbox, % (heartBeat ? "Checked" : "") " vheartBeat gdiscordSettings y+20 Hidden", Discord Heartbeat

Gui, Add, Text, vhbName y+20 Hidden, Name:
Gui, Add, Edit, vheartBeatName w290 y+10 h25 Hidden, %heartBeatName%
Gui, Add, Text, vhbURL y+20 Hidden, Webhook URL:
Gui, Add, Edit, vheartBeatWebhookURL w290 y+10 h25 Center Hidden, %heartBeatWebhookURL%
Gui, Add, Text, vhbDelay y+20 Hidden, Heartbeat Delay (min):
Gui, Add, Edit, vheartBeatDelay x300 y+-17 w55 h25 Center Hidden, %heartBeatDelay%

; ========== Download Settings Section ==========
SetHeaderFont()
Gui, Add, Text, x170 y100 Hidden vDownloadSettingsHeading, Download Settings

SetNormalFont()
if(StrLen(mainIdsURL) < 3)
    mainIdsURL =
if(StrLen(vipIdsURL) < 3)
    vipIdsURL =

Gui, Add, Text, y+20 Hidden vTxt_MainIdsURL, ids.txt API:
Gui, Add, Edit, vmainIdsURL w290 y+10 h25 Center Hidden, %mainIdsURL%

Gui, Add, Text, y+20 Hidden vTxt_VipIdsURL, vip_ids.txt API:
Gui, Add, Edit, vvipIdsURL w290 y+10 h25 Center Hidden, %vipIdsURL%

; Add Showcase options to Download Settings Section
Gui, Add, Checkbox, % (showcaseEnabled ? "Checked" : "") " vshowcaseEnabled gshowcaseSettings x170 y+20 Hidden", Use Showcase from showcase_ids.txt

; ========== Action Buttons with New 3-Row Layout - Adjusted Positioning ==========
SetHeaderFont()

; Row 1 - Three buttons side by side - adjusted positions and sizes
Gui, Add, Button, gLaunchAllMumu x15 y655 w140 h25 vLaunchAllMumu, 🚀 Launch All Mumu

Gui, Add, Button, gArrangeWindows x+15 y655 w140 h25 vArrangeWindows, 🪟 Arrange Windows

Gui, Add, Button, gSaveReload x+15 y655 w140 h25 vReloadBtn, 🔄 Reload

; Row 2 - Full width button for Start Bot - adjusted position and size
Gui, Add, Button, gStartBot x15 y+10 w450 h30 vStartBot, ▶️ Start Bot ▶️

; Version info moved to the bottom - adjusted position
SetSmallFont()
Gui, Add, Text, x15 y+10 w450 vVersionInfo Center, PTCGPB %localVersion% (Licensed under CC BY-NC 4.0 International License)

; Add Reroll Settings separator
Gui, Add, Text, x170 y350 w220 h2 +0x10 vRerollSettingsSeparator Hidden  ; Horizontal separator - adjusted width

; Check for different possible background image files based on current theme
backgroundImagePath := ""

; Look for theme-specific backgrounds first (GUI_Dark.png or GUI_Light.png)
themeImageName := isDarkTheme ? "GUI_Dark" : "GUI_Light"

; Check for various file formats in order of preference
imageExtensions := ["png", "jpg", "jpeg", "bmp", "gif"]
for index, ext in imageExtensions {
    if FileExist(A_ScriptDir . "\" . themeImageName . "." . ext) {
        backgroundImagePath := A_ScriptDir . "\" . themeImageName . "." . ext
        break
    }
}

; If no theme-specific background found, fall back to generic GUI image
if (backgroundImagePath = "") {
    for index, ext in imageExtensions {
        if FileExist(A_ScriptDir . "\GUI." . ext) {
            backgroundImagePath := A_ScriptDir . "\GUI." . ext
            break
        }
    }
}

; Add the background image if a valid file was found
if (backgroundImagePath != "") {
    ; Add the "Hidden" option based on useBackgroundImage
    hiddenState := useBackgroundImage ? "" : "Hidden"
    Gui, Add, Picture, x0 y0 w%GUI_WIDTH% h%GUI_HEIGHT% +0x4000000 vBackgroundPic %hiddenState%, %backgroundImagePath%
}

; Initialize GUI with no section selected
Gui, Show, w%GUI_WIDTH% h%GUI_HEIGHT%, PTCGPB Bot Setup [Non-Commercial 4.0 International License]

; Hide all sections on startup
CurrentVisibleSection := ""
HideAllSections()

ApplyTheme()  ; Ensure everything is colored properly on startup

; Update the section title to indicate welcome screen
GuiControl,, ActiveSection, Welcome to PTCGP Bot - Select a section from the sidebar

; Update keyboard shortcuts for sections
^1::HandleKeyboardShortcut(1)    ; Reroll Settings
^2::HandleKeyboardShortcut(2)    ; System Settings
^3::HandleKeyboardShortcut(3)    ; Pack Settings
^4::HandleKeyboardShortcut(4)    ; Save For Trade
^5::HandleKeyboardShortcut(5)    ; Discord Settings
^6::HandleKeyboardShortcut(6)    ; Download Settings

; Function key shortcuts with the requested mapping
F1::HandleFunctionKeyShortcut(1)  ; Launch All Mumu
F2::HandleFunctionKeyShortcut(2)  ; Arrange Windows
F3::HandleFunctionKeyShortcut(3)  ; Start Bot
F4::ShowHelpMenu()                ; Help Menu
Return

; NEW: Handle drop-down changes for sort method
SortByDropdownHandler:
    Gui, Submit, NoHide
    GuiControlGet, selectedOption,, SortByDropdown
    
    ; Update injectSortMethod based on selected option
    if (selectedOption = "Oldest First")
        injectSortMethod := "ModifiedAsc"
    else if (selectedOption = "Newest First")
        injectSortMethod := "ModifiedDesc"
    else if (selectedOption = "Fewest Packs First")
        injectSortMethod := "PacksAsc"
    else if (selectedOption = "Most Packs First")
        injectSortMethod := "PacksDesc"
    
    ; Save the updated setting
    IniWrite, %injectSortMethod%, Settings.ini, UserSettings, injectSortMethod
    
    ; Save all settings to ensure consistency
    SaveAllSettings()
return

; NEW: Add function to handle updates to the Pack Selection ListBox
UpdatePackSelection:
    Gui, Submit, NoHide
    
    ; Reset all pack variables
    Shining := 0
    Arceus := 0
    Palkia := 0
    Dialga := 0
    Pikachu := 0
    Charizard := 0
    Mewtwo := 0
    Mew := 0
    Solgaleo := 0
    Lunala := 0
    
    ; Loop through all rows and check their state directly
    Loop, % LV_GetCount()
    {
        ; Check if current row is checked
        isChecked := LV_GetNext(A_Index-1, "Checked") = A_Index
        if (isChecked) {
            ; Get the pack name from this row
            LV_GetText(packName, A_Index)
            
            ; Set the corresponding variable to 1
            if (packName = "Solgaleo")
                Solgaleo := 1
            else if (packName = "Lunala")
                Lunala := 1
            else if (packName = "Shining")
                Shining := 1
            else if (packName = "Arceus")
                Arceus := 1
            else if (packName = "Palkia")
                Palkia := 1
            else if (packName = "Dialga")
                Dialga := 1
            else if (packName = "Pikachu")
                Pikachu := 1
            else if (packName = "Charizard")
                Charizard := 1
            else if (packName = "Mewtwo")
                Mewtwo := 1
            else if (packName = "Mew")
                Mew := 1
        }
    }

    ; Explicitly save each pack variable to the INI file directly
    IniWrite, %Solgaleo%, Settings.ini, UserSettings, Solgaleo
    IniWrite, %Lunala%, Settings.ini, UserSettings, Lunala
    IniWrite, %Shining%, Settings.ini, UserSettings, Shining
    IniWrite, %Arceus%, Settings.ini, UserSettings, Arceus
    IniWrite, %Palkia%, Settings.ini, UserSettings, Palkia
    IniWrite, %Dialga%, Settings.ini, UserSettings, Dialga
    IniWrite, %Pikachu%, Settings.ini, UserSettings, Pikachu
    IniWrite, %Charizard%, Settings.ini, UserSettings, Charizard
    IniWrite, %Mewtwo%, Settings.ini, UserSettings, Mewtwo
    IniWrite, %Mew%, Settings.ini, UserSettings, Mew
    
    ; Also call SaveAllSettings to ensure other settings are saved as well
    SaveAllSettings()
    
    ; Update Gholdengo visibility if needed
    if (CurrentVisibleSection = "SaveForTrade" && s4tEnabled) {
        if (Shining) {
            GuiControl, Show, s4tGholdengo
            GuiControl, Show, s4tGholdengoEmblem
            GuiControl, Show, s4tGholdengoArrow
            
            ; Apply text styling
            if (isDarkTheme) {
                GuiControl, +c%DARK_TEXT%, s4tGholdengo
                GuiControl, +c%DARK_TEXT%, s4tGholdengoArrow
            } else {
                GuiControl, +c%LIGHT_TEXT%, s4tGholdengo
                GuiControl, +c%LIGHT_TEXT%, s4tGholdengoArrow
            }
        } else {
            GuiControl, Hide, s4tGholdengo
            GuiControl, Hide, s4tGholdengoEmblem
            GuiControl, Hide, s4tGholdengoArrow
        }
    }
return

ToggleTheme:
    ; Toggle the theme
    global isDarkTheme
    isDarkTheme := !isDarkTheme

    ; Update theme toggle button text
    GuiControl,, ThemeToggle, % isDarkTheme ? "Light Mode" : "Dark Mode"

    ; Apply the new theme - ensure all colors update
    ApplyTheme()

    ; Update header text and colors
    GuiControl,, HeaderTitle, % "Arturo's PTCGP Bot"
    if (isDarkTheme) {
        GuiControl, +c%DARK_TEXT%, HeaderTitle
    } else {
        GuiControl, +c%LIGHT_TEXT%, HeaderTitle
    }

    ; Make sure current section is properly colored based on new structure
    if (CurrentVisibleSection = "RerollSettings")
        ShowRerollSettingsSection()
    else if (CurrentVisibleSection = "SystemSettings")
        ShowSystemSettingsSection()
    else if (CurrentVisibleSection = "PackSettings")
        ShowPackSettingsSection()
    else if (CurrentVisibleSection = "SaveForTrade")
        ShowSaveForTradeSection()
    else if (CurrentVisibleSection = "DiscordSettings")
        ShowDiscordSettingsSection()
    else if (CurrentVisibleSection = "DownloadSettings")
        ShowDownloadSettingsSection()

    ; Save the theme setting
    IniWrite, %isDarkTheme%, Settings.ini, UserSettings, isDarkTheme
    
    ; Save all settings to ensure everything is remembered
    SaveAllSettings()

    ; Check for theme-specific background and update if needed
    themeImageName := isDarkTheme ? "GUI_Dark" : "GUI_Light"
    newBackgroundPath := ""

    ; Check for various file formats in preferred order
    imageExtensions := ["png", "jpg", "jpeg", "bmp", "gif"]
    for index, ext in imageExtensions {
        if FileExist(A_ScriptDir . "\" . themeImageName . "." . ext) {
            newBackgroundPath := A_ScriptDir . "\" . themeImageName . "." . ext
            break
        }
    }

    ; If theme-specific background found, update it
    if (newBackgroundPath != "") {
        GuiControl,, BackgroundPic, %newBackgroundPath%
    }
Return

ToggleBackground:
    ToggleBackgroundImage()
Return

ToggleSection:
    ; Get clicked button name
    ClickedButton := A_GuiControl

    ; First, save current settings in case we're leaving the current section
    SaveAllSettings()

    ; Extract just the section name without the "Btn_" prefix
    StringTrimLeft, SectionName, ClickedButton, 4

    ; Hide all sections - This will now explicitly hide the Range input controls
    HideAllSections()

    ; Show section based on new structure
    if (SectionName = "RerollSettings") {
        ShowRerollSettingsSection()
    } else if (SectionName = "SystemSettings") {
        ShowSystemSettingsSection()
    } else if (SectionName = "PackSettings") {
        ShowPackSettingsSection()
    } else if (SectionName = "SaveForTrade") {
        ShowSaveForTradeSection()
    } else if (SectionName = "DiscordSettings") {
        ShowDiscordSettingsSection()
    } else if (SectionName = "DownloadSettings") {
        ShowDownloadSettingsSection()
    }

    ; Update current section and tab highlighting
    CurrentVisibleSection := SectionName

    ; Set section title with section-specific color
    friendlyName := GetFriendlyName(SectionName)
    GuiControl,, ActiveSection, Current Section: %friendlyName%

    ; Get section color
    sectionColor := isDarkTheme ? DARK_SECTION_COLORS[SectionName] : LIGHT_SECTION_COLORS[SectionName]
    GuiControl, +c%sectionColor%, ActiveSection

    ; Update section headers with appropriate colors
    UpdateSectionHeaders()
    
    ; Force a thorough refresh of the GUI
    WinGet, hwnd, ID, A
    DllCall("InvalidateRect", "Ptr", hwnd, "Ptr", 0, "Int", 1)
    
    ; Send resize message to recalculate positions and layouts
    SendMessage, 0x5, 0, 0,, ahk_id %hwnd%
    
    ; Force redraw 
    WinSet, Redraw,, A
    
    ; Give a tiny delay for repainting to complete
    Sleep, 10
Return

CheckForUpdates:
    CheckForUpdate()
return

mainSettings:
    Gui, Submit, NoHide
    global isDarkTheme, DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT

    if (runMain) {
        GuiControl, Show, Mains

        ; Apply theme-specific styling
        if (isDarkTheme) {
            GuiControl, +Background%DARK_INPUT_BG% +c%DARK_INPUT_TEXT%, Mains
        } else {
            GuiControl, +Background%LIGHT_INPUT_BG% +c%LIGHT_INPUT_TEXT%, Mains
        }
    }
    else {
        GuiControl, Hide, Mains
    }
    
    ; Save settings after change
    SaveAllSettings()
return

discordSettings:
    Gui, Submit, NoHide
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT, DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT

    if (heartBeat) {
        heartbeatControls := "heartBeatName,heartBeatWebhookURL,heartBeatDelay,hbName,hbURL,hbDelay"
        ShowControls(heartbeatControls)

        ; Apply theme-specific styling using helper functions
        textControls := "hbName,hbURL,hbDelay"
        ApplyTextColorToMultiple(textControls)

        inputControls := "heartBeatName,heartBeatWebhookURL,heartBeatDelay"
        ApplyInputStyleToMultiple(inputControls)
    }
    else {
        heartbeatControls := "heartBeatName,heartBeatWebhookURL,heartBeatDelay,hbName,hbURL,hbDelay"
        HideControls(heartbeatControls)
    }
    ; Save settings when heartbeat settings are changed
    SaveAllSettings()
return

s4tSettings:
    Gui, Submit, NoHide
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT, DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT
    global SaveForTradeDivider_1, SaveForTradeDivider_2

    if (s4tEnabled) {
        ; Show main S4T controls
        s4tMainControls := "s4tSilent,s4t3Dmnd,s4t4Dmnd,s4t1Star,Txt_S4TSeparator,s4tWP,"
        s4tMainControls .= "S4TDiscordSettingsSubHeading,Txt_S4T_DiscordID,s4tDiscordUserId,"
        s4tMainControls .= "Txt_S4T_DiscordWebhook,s4tDiscordWebhookURL,s4tSendAccountXml,"
        s4tMainControls .= "SaveForTradeDivider_1,SaveForTradeDivider_2"
        ShowControls(s4tMainControls)

        ; Apply theme styling using helper functions
        textControls := "s4tSilent,s4t3Dmnd,s4t4Dmnd,s4t1Star,s4tWP,Txt_S4T_DiscordID,"
        textControls .= "Txt_S4T_DiscordWebhook,s4tSendAccountXml"
        ApplyTextColorToMultiple(textControls)

        inputControls := "s4tDiscordUserId,s4tDiscordWebhookURL"
        ApplyInputStyleToMultiple(inputControls)

        ; Apply section color to sub-heading
        sectionColor := isDarkTheme ? DARK_SECTION_COLORS["SaveForTrade"] : LIGHT_SECTION_COLORS["SaveForTrade"]
        GuiControl, +c%sectionColor%, S4TDiscordSettingsSubHeading

        ; Check if Shining is enabled to show Gholdengo - Important logic from PTCGPB.ahk
        GuiControlGet, Shining
        if (Shining) {
            GuiControl, Show, s4tGholdengo
            GuiControl, Show, s4tGholdengoEmblem
            GuiControl, Show, s4tGholdengoArrow

            ; Apply text styling
            if (isDarkTheme) {
                GuiControl, +c%DARK_TEXT%, s4tGholdengo
                GuiControl, +c%DARK_TEXT%, s4tGholdengoArrow
            } else {
                GuiControl, +c%LIGHT_TEXT%, s4tGholdengo
                GuiControl, +c%LIGHT_TEXT%, s4tGholdengoArrow
            }
        } else {
            GuiControl, Hide, s4tGholdengo
            GuiControl, Hide, s4tGholdengoEmblem
            GuiControl, Hide, s4tGholdengoArrow
        }

        ; Check if s4tWP is enabled
        if (s4tWP) {
            GuiControl, Show, s4tWPMinCardsLabel
            GuiControl, Show, s4tWPMinCards

            ; Apply styling
            ApplyTextColor("s4tWPMinCardsLabel")
            ApplyInputStyle("s4tWPMinCards")
        } else {
            GuiControl, Hide, s4tWPMinCardsLabel
            GuiControl, Hide, s4tWPMinCards
        }
} else {
        ; Hide all S4T controls
        s4tAllControls := "s4tSilent,s4t3Dmnd,s4t4Dmnd,s4t1Star,s4tGholdengo,s4tGholdengoEmblem,"
        s4tAllControls .= "s4tGholdengoArrow,Txt_S4TSeparator,s4tWP,s4tWPMinCardsLabel,s4tWPMinCards,"
        s4tAllControls .= "S4TDiscordSettingsSubHeading,Txt_S4T_DiscordID,s4tDiscordUserId,"
        s4tAllControls .= "Txt_S4T_DiscordWebhook,s4tDiscordWebhookURL,s4tSendAccountXml,"
        s4tAllControls .= "SaveForTradeDivider_1,SaveForTradeDivider_2"
        HideControls(s4tAllControls)
    }
    
    ; Save settings after changing S4T options
    SaveAllSettings()
return

s4tWPSettings:
    Gui, Submit, NoHide
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT, DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT

    if (s4tWP) {
        GuiControl, Show, s4tWPMinCardsLabel
        GuiControl, Show, s4tWPMinCards

        ; Apply styling using helper functions
        ApplyTextColor("s4tWPMinCardsLabel")
        ApplyInputStyle("s4tWPMinCards")
    } else {
        GuiControl, Hide, s4tWPMinCardsLabel
        GuiControl, Hide, s4tWPMinCards
    }
    
    ; Save settings after changing WP options
    SaveAllSettings()
return

TesseractOptionSettings:
    Gui, Submit, NoHide
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT, DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT

    if (tesseractOption) {
        GuiControl, Show, Txt_TesseractPath
        GuiControl, Show, tesseractPath

        ; Apply styling using helper functions
        ApplyTextColor("Txt_TesseractPath")
        ApplyInputStyle("tesseractPath")
    } else {
        GuiControl, Hide, Txt_TesseractPath
        GuiControl, Hide, tesseractPath
    }
    
    ; Save settings after changing tesseract options
    SaveAllSettings()
return

; For the deleteSettings function, add this to update dropdown mappings
deleteSettings:
    Gui, Submit, NoHide
    global scaleParam, defaultLanguage, sortByCreated, injectRange

    ; Store the current scaleParam value
    currentScaleParam := scaleParam

    ; Get the current value of deleteMethod control
    GuiControlGet, currentMethod,, deleteMethod

    if(InStr(currentMethod, "Inject")) {
        ; Hide nukeAccount checkbox
        GuiControl, Hide, nukeAccount
        GuiControl,, nukeAccount, 0  ; Uncheck the checkbox when hidden
        
        ; Show claim special missions for Inject methods and ensure it's visible
        GuiControl, Show, claimSpecialMissions
        ApplyTextColor("claimSpecialMissions")
        
        ; Show or create Sort By controls
        if (!sortByCreated) {
            ; Create Sort By controls if they don't exist yet
            SetNormalFont()
            
            ; Determine which option to pre-select
            sortOption := 1 ; Default (ModifiedAsc)
            if (injectSortMethod = "ModifiedDesc")
                sortOption := 2
            else if (injectSortMethod = "PacksAsc")
                sortOption := 3
            else if (injectSortMethod = "PacksDesc")
                sortOption := 4
            
            ; Create the controls with static positions
            Gui, Add, Text, x170 y250 vSortByText, Sort By:
            Gui, Add, DropDownList, x270 y248 w170 vSortByDropdown gSortByDropdownHandler Choose%sortOption%, Oldest First|Newest First|Fewest Packs First|Most Packs First
            
            ; Apply styling
            ApplyTextColor("SortByText")
            
            ; Mark as created
            sortByCreated := true
        } else {
            ; Show existing controls
            GuiControl, Show, SortByText
            GuiControl, Show, SortByDropdown
        }
        
        ; Reset fields when changing inject methods
        ; Hide all variable fields first
        GuiControl, Hide, Txt_VariablePackCount
        GuiControl, Hide, variablePackCount
        GuiControl, Hide, Txt_InjectRange
        GuiControl, Hide, injectRange
        
        ; Check for specific Inject methods
        if(currentMethod = "Inject variable") {
            ; Show variable pack count controls
            GuiControl, Show, Txt_VariablePackCount
            GuiControl, Show, variablePackCount
            
            ; Apply styling
            ApplyTextColor("Txt_VariablePackCount")
            ApplyInputStyle("variablePackCount")
            
            ; Reset the range in settings file
            IniWrite, "", %A_ScriptDir%\..\Settings.ini, UserSettings, injectRange
        } 
        else if(currentMethod = "Inject Range") {
            ; Show inject range controls
            GuiControl, Show, Txt_InjectRange
            GuiControl, Show, injectRange
            
            ; Apply styling
            ApplyTextColor("Txt_InjectRange")
            ApplyInputStyle("injectRange")
        }
        else {
            ; For other inject methods, clear fields to prevent stale values
            GuiControl,, variablePackCount, 15
            GuiControl,, injectRange, ""
            
            ; And also clear the Setting.ini values to avoid filters continuing to apply
            IniWrite, "", %A_ScriptDir%\..\Settings.ini, UserSettings, injectRange
            IniWrite, 15, %A_ScriptDir%\..\Settings.ini, UserSettings, variablePackCount
        }
    }
    else {
        ; For non-inject methods
        GuiControl, Show, nukeAccount
        GuiControl, Hide, claimSpecialMissions
        GuiControl,, claimSpecialMissions, 0  ; Uncheck the checkbox when hidden
        GuiControl, Hide, Txt_VariablePackCount
        GuiControl, Hide, variablePackCount
        GuiControl, Hide, Txt_InjectRange
        GuiControl, Hide, injectRange
        
        ; Clear values for non-inject methods to avoid confusion
        GuiControl,, variablePackCount, 15
        GuiControl,, injectRange, ""
        
        ; Hide Sort By controls if they exist
        if (sortByCreated) {
            GuiControl, Hide, SortByText
            GuiControl, Hide, SortByDropdown
        }
        
        ; Apply text color using helper function
        ApplyTextColor("nukeAccount")
    }

    ; Always show spendHourGlass
    GuiControl, Show, spendHourGlass
    ApplyTextColor("spendHourGlass")

    ; Ensure scaleParam value is preserved based on the currentLanguage
    if (defaultLanguage = "Scale125") {
        scaleParam := 277
    } else if (defaultLanguage = "Scale100") {
        scaleParam := 287
    }

    ; Only show a message if debugging is needed
    if (debugMode && scaleParam != currentScaleParam) {
        MsgBox, Scale parameter updated: %scaleParam% (Was: %currentScaleParam%)
    }
    
    ; Immediately save settings after changing delete method
    SaveAllSettings()
    
    ; Force regenerate the account lists on method change
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    lastGenFile := saveDir . "\list_last_generated.txt"
    if (FileExist(lastGenFile))
        FileDelete, %lastGenFile%
    
    ; Set up messages to let user know what happened
    if (debugMode) {
        MsgBox, Method changed to %currentMethod%. Account lists will be regenerated on next run.
    }
return

; Add a new function for showcase settings toggle
showcaseSettings:
    Gui, Submit, NoHide
    global isDarkTheme, DARK_TEXT, LIGHT_TEXT, DARK_INPUT_BG, DARK_INPUT_TEXT, LIGHT_INPUT_BG, LIGHT_INPUT_TEXT

    ; Save settings after changing showcase options
    SaveAllSettings()
return

defaultLangSetting:
    global scaleParam
    GuiControlGet, defaultLanguage,, defaultLanguage
    if (defaultLanguage = "Scale125") {
        scaleParam := 277
        MsgBox, Scale set to 125`% with scaleParam = %scaleParam%
    } else if (defaultLanguage = "Scale100") {
        scaleParam := 287
        MsgBox, Scale set to 100`% with scaleParam = %scaleParam%
    }
    
    ; Save settings after changing language
    SaveAllSettings()
return

ArrangeWindows:
    GuiControlGet, runMain,, runMain
    GuiControlGet, Mains,, Mains
    GuiControlGet, Instances,, Instances
    GuiControlGet, Columns,, Columns
    GuiControlGet, SelectedMonitorIndex,, SelectedMonitorIndex
    GuiControlGet, defaultLanguage,, defaultLanguage
    GuiControlGet, rowGap,, rowGap

    ; Re-validate scaleParam based on current language
    if (defaultLanguage = "Scale125") {
        scaleParam := 277
    } else if (defaultLanguage = "Scale100") {
        scaleParam := 287
    }

    windowsPositioned := 0

    if (runMain && Mains > 0) {
        Loop %Mains% {
            mainInstanceName := "Main" . (A_Index > 1 ? A_Index : "")
            if (WinExist(mainInstanceName)) {
                WinActivate, %mainInstanceName%
                WinGetPos, curX, curY, curW, curH, %mainInstanceName%
                
                ; Calculate position
                SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
                SysGet, Monitor, Monitor, %SelectedMonitorIndex%
                
                instanceIndex := A_Index
                rowHeight := 533
                currentRow := Floor((instanceIndex - 1) / Columns)
                y := MonitorTop + (currentRow * rowHeight) + (currentRow * rowGap)
                x := MonitorLeft + (Mod((instanceIndex - 1), Columns) * scaleParam)
                
                ; Move window
                WinMove, %mainInstanceName%,, %x%, %y%, %scaleParam%, 537
                WinSet, Redraw, , %mainInstanceName%
                
                windowsPositioned++
                sleep, 100
            }
        }
    }

    if (Instances > 0) {
        Loop %Instances% {
            if (WinExist(A_Index)) {
                WinActivate, %A_Index%
                WinGetPos, curX, curY, curW, curH, %A_Index%
                
                ; Calculate position
                SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
                SysGet, Monitor, Monitor, %SelectedMonitorIndex%
                
                if (runMain) {
                    instanceIndex := (Mains - 1) + A_Index + 1
                } else {
                    instanceIndex := A_Index
                }
                
                rowHeight := 533
                currentRow := Floor((instanceIndex - 1) / Columns)
                y := MonitorTop + (currentRow * rowHeight) + (currentRow * rowGap)
                x := MonitorLeft + (Mod((instanceIndex - 1), Columns) * scaleParam)
                
                ; Move window
                WinMove, %A_Index%,, %x%, %y%, %scaleParam%, 537
                WinSet, Redraw, , %A_Index%
                
                windowsPositioned++
                sleep, 100
            }
        }
    }

    if (debugMode && windowsPositioned == 0) {
        MsgBox, No windows found to arrange
    } else {
        MsgBox, Arranged %windowsPositioned% windows
    }
    
    ; Save settings after arranging windows
    SaveAllSettings()
return

LaunchAllMumu:
    GuiControlGet, Instances,, Instances
    GuiControlGet, folderPath,, folderPath
    GuiControlGet, runMain,, runMain
    GuiControlGet, Mains,, Mains
    GuiControlGet, instanceLaunchDelay,, instanceLaunchDelay

    ; Save settings before launching
    SaveAllSettings()
	
	if(StrLen(A_ScriptDir) > 200 || InStr(A_ScriptDir, " ")) {
		MsgBox, the path to the bot folder is too long or contain white spaces. move it to a shorter path without spaces
		return
	}
    
    launchAllFile := "LaunchAllMumu.ahk"
    if(FileExist(launchAllFile)) {
        Run, %launchAllFile%
    }
return

; Handle the link click
OpenLink:
    Run, https://buymeacoffee.com/aarturoo
return

OpenDiscord:
    Run, https://discord.gg/C9Nyf7P4sT
return

; IMPROVED: Ensure settings are saved completely before reload
SaveReload:
    ; Get the most current values from all controls
    Gui, Submit
    ; Save all settings using our comprehensive function
    SaveAllSettings()
    ; Reload the script
    Reload
return

BalanceXMLs:
    if(Instances>0) {
        ; Save all settings first to ensure Instances is up to date
        SaveAllSettings()

        ;get current # of instances in box
        GuiControlGet, Instances,, Instances

        ;todo better status message location or method
        GuiControlGet, ButtonPos, Pos, BalanceXMLs
        XTooltipPos = % ButtonPosX + 10
        YTooltipPos = % ButtonPosY + 140

        ;check folders
        saveDir := A_ScriptDir "\Accounts\Saved\"
		if !FileExist(saveDir) ; Check if the directory exists
			FileCreateDir, %saveDir% ; Create the directory if it doesn't exist

        tmpDir := A_ScriptDir "\Accounts\Saved\tmp"
		if !FileExist(tmpDir) ; Check if the directory exists
			FileCreateDir, %tmpDir% ; Create the directory if it doesn't exist
        
        ;lags gui for some reason
        Tooltip, Moving Files and Folders to tmp, XTooltipPos, YTooltipPos
        Loop, Files, %saveDir%*, D
            {
                if (A_LoopFilePath == tmpDir)
                    continue
                dest := tmpDir . "\" . A_LoopFileName
                
                FileMoveDir, %A_LoopFilePath%, %dest%, 1
            }
        Loop, Files, %saveDir%\*, F
            {
                dest := tmpDir . "\" . A_LoopFileName
                FileMove, %A_LoopFilePath%, %dest%, 1
            }

        ; create instance dirs
        Loop , %Instances%
		{ 
			instanceDir := saveDir . "\" . A_Index
			if !FileExist(instanceDir) ; Check if the directory exists
				FileCreateDir, %instanceDir% ; Create the directory if it doesn't exist
			listfile := instanceDir . "\list.txt"
			if FileExist(listfile) 
				FileDelete, %listfile% ; delete list if it exists
        }

        ToolTip, Checking for Duplicate names, XTooltipPos, YTooltipPos
        fileList := ""
        seenFiles := {}
        Loop, Files, %tmpDir%\*.xml, R
        {
            fileName := A_LoopFileName
            fileTime := A_LoopFileTimeModified
			; TODO can also sort by name (num packs), or time created
            fileTime := A_LoopFileTimeCreated 
            filePath := A_LoopFileFullPath
        
            if seenFiles.HasKey(fileName)
            {
                ; Compare the timestamps to determine which file is older
                prevTime := seenFiles[fileName].Time
                prevPath := seenFiles[fileName].Path
        
                if (fileTime > prevTime)
                {
                    ; Current file is newer, delete the previous one
                    FileDelete, %prevPath%
                    seenFiles[fileName] := {Time: fileTime, Path: filePath}
                }
                else
                {
                    ; Current file is older, delete it
                    FileDelete, %filePath%
                }
                continue
            }
        
            ; Store the file info
            seenFiles[fileName] := {Time: fileTime, Path: filePath}
            fileList .= fileTime "`t" filePath "`n"
        }
        
        ToolTip, Sorting by modified date, XTooltipPos, YTooltipPos
        Sort, fileList, R

        ToolTip, Distributing XMLs between folders...please wait, XTooltipPos, YTooltipPos
        instance := 1
        Loop, Parse, fileList, `n
        {
            if (A_LoopField = "")
                continue

            ; Split each line into timestamp and file path (split by tab)
            StringSplit, parts, A_LoopField, %A_Tab%
            tmpFile := parts2  ; Get the file path from the second part
            toDir := saveDir . "\" . instance

            ; Move the file
            FileMove, %tmpFile%, %toDir%, 1

            instance++
            if (instance > Instances)
                instance := 1
        }

        ;count number of xmls with date modified time over 24 hours in instance 1
        instanceOneDir := saveDir . "1"
        counter := 0
        counter2 := 0
        Loop, Files, %instanceOneDir%\*.xml
        {
            fileModifiedTimeDiff := A_Now
            FileGetTime, fileModifiedTime, %A_LoopFileFullPath%, M
            EnvSub, fileModifiedTimeDiff, %fileModifiedTime%, Hours
            if (fileModifiedTimeDiff >= 24)  ; 24 hours
                counter++
        }

        Tooltip ;clear tooltip
        MsgBox, Done balancing XMLs between %Instances% instances`n%counter% XMLs past 24 hours per instance
    }
return

StartBot:
    ; Force a complete refresh of all variables from the GUI
    Gui, Submit, NoHide

    ; Read from our dropdown if it exists
    if (InStr(deleteMethod, "Inject") && sortByCreated) {
        GuiControlGet, selectedSortOption,, SortByDropdown
        if (selectedSortOption = "Oldest First")
            injectSortMethod := "ModifiedAsc"
        else if (selectedSortOption = "Newest First")
            injectSortMethod := "ModifiedDesc"
        else if (selectedSortOption = "Fewest Packs First")
            injectSortMethod := "PacksAsc"
        else if (selectedSortOption = "Most Packs First")
            injectSortMethod := "PacksDesc"
    }

    ; Save ALL settings before starting
    SaveAllSettings()
	
	if(StrLen(A_ScriptDir) > 200 || InStr(A_ScriptDir, " ")) {
		MsgBox, the path to the bot folder is too long or contain white spaces. move it to a shorter path without spaces
		return
	}
    
    ; Now build the confirmation message with the freshly updated variables
    confirmMsg := "Selected Method: " . deleteMethod . "`n"
    
    ; Add method-specific details
    if (deleteMethod = "Inject Range" && injectRange != "") {
        confirmMsg .= "Range Value: " . injectRange . "`n"
    }
    else if (deleteMethod = "Inject variable") {
        confirmMsg .= "Variable Pack Count: " . variablePackCount . "`n"
    }
    
    confirmMsg .= "`nSelected Packs:`n"
    if (Solgaleo)
        confirmMsg .= "• Solgaleo`n"
    if (Lunala)
        confirmMsg .= "• Lunala`n"
    if (Shining)
        confirmMsg .= "• Shining`n"
    if (Arceus)
        confirmMsg .= "• Arceus`n"
    if (Palkia)
        confirmMsg .= "• Palkia`n"
    if (Dialga)
        confirmMsg .= "• Dialga`n"
    if (Pikachu)
        confirmMsg .= "• Pikachu`n"
    if (Charizard)
        confirmMsg .= "• Charizard`n"
    if (Mewtwo)
        confirmMsg .= "• Mewtwo`n"
    if (Mew)
        confirmMsg .= "• Mew`n"

    confirmMsg .= "`nAdditional settings:"
    additionalSettingsFound := false
    
    if (packMethod) {
        confirmMsg .= "`n• 1 Pack Method"
        additionalSettingsFound := true
    }
    if (nukeAccount && !InStr(deleteMethod, "Inject")) {
        confirmMsg .= "`n• Menu Delete"
        additionalSettingsFound := true
    }
    if (spendHourGlass) {
        confirmMsg .= "`n• Spend Hour Glass"
        additionalSettingsFound := true
    }
    if (claimSpecialMissions && InStr(deleteMethod, "Inject")) {
        confirmMsg .= "`n• Claim Special Missions"
        additionalSettingsFound := true
    }
    if (InStr(deleteMethod, "Inject") && sortByCreated) {
        confirmMsg .= "`n• Sort By: " . selectedSortOption
        additionalSettingsFound := true
    }
    if (!additionalSettingsFound)
        confirmMsg .= "`nNone"

    confirmMsg .= "`n`nCard Detection:"
    cardDetectionFound := false

    if (FullArtCheck) {
        confirmMsg .= "`n• Single Full Art"
        cardDetectionFound := true
    }
    if (TrainerCheck) {
        confirmMsg .= "`n• Single Trainer"
        cardDetectionFound := true
    }
    if (RainbowCheck) {
        confirmMsg .= "`n• Single Rainbow"
        cardDetectionFound := true
    }
    if (PseudoGodPack) {
        confirmMsg .= "`n• Double 2 ★"
        cardDetectionFound := true
    }
    if (CrownCheck) {
        confirmMsg .= "`n• Save Crowns"
        cardDetectionFound := true
    }
    if (ShinyCheck) {
        confirmMsg .= "`n• Save Shiny"
        cardDetectionFound := true
    }
    if (ImmersiveCheck) {
        confirmMsg .= "`n• Save Immersives"
        cardDetectionFound := true
    }
    if (CheckShinyPackOnly) {
        confirmMsg .= "`n• Only Shiny Packs"
        cardDetectionFound := true
    }
    if (InvalidCheck) {
        confirmMsg .= "`n• Ignore Invalid Packs"
        cardDetectionFound := true
    }

    if (!cardDetectionFound)
        confirmMsg .= "`nNone"

    confirmMsg .= "`n`nRow Gap: " . rowGap . " pixels"

    confirmMsg .= "`n`nClick 'Yes' to START THE BOT with these settings.`nClick 'No' to CHANGE settings."

    MsgBox, 4, Confirm Bot Settings, %confirmMsg%
    IfMsgBox, No
    {
        return  ; Return to GUI for user to modify settings
    }

    ; Re-validate scaleParam based on current language
    if (defaultLanguage = "Scale125") {
        scaleParam := 277
    } else if (defaultLanguage = "Scale100") {
         scaleParam := 287
    }

    ; Create the second page dynamically based on the number of instances
    Gui, Destroy ; Close the first page

    ; Using FriendID field to provide a URL to download ids.txt is deprecated.
    if (inStr(FriendID, "http")) {
        MsgBox, To provide a URL for friend IDs, please use the ids.txt API field and leave the Friend ID field empty.

        if (mainIdsURL = "") {
            IniWrite, "", Settings.ini, UserSettings, FriendID
            IniWrite, %FriendID%, Settings.ini, UserSettings, mainIdsURL
        }

        Reload
    }

    ; Download a new Main ID file prior to running the rest of the below
    if (mainIdsURL != "") {
        DownloadFile(mainIdsURL, "ids.txt")
    }

    ; Download showcase codes if enabled
    if (showcaseEnabled && showcaseURL != "") {
       DownloadFile(showcaseURL, "showcase_codes.txt")
    }

    ; Check for showcase_ids.txt if enabled
    if (showcaseEnabled) {
        if (!FileExist("showcase_ids.txt")) {
            MsgBox, 48, Showcase Warning, Showcase is enabled but showcase_ids.txt does not exist.`nPlease create this file in the same directory as the script.
        }
    }

    ; Run main before instances to account for instance start delay
    if (runMain) {
        Loop, %Mains%
        {
            if (A_Index != 1) {
                SourceFile := "Scripts\Main.ahk" ; Path to the source .ahk file
                TargetFolder := "Scripts\" ; Path to the target folder
                TargetFile := TargetFolder . "Main" . A_Index . ".ahk" ; Generate target file path
                FileDelete, %TargetFile%
                FileCopy, %SourceFile%, %TargetFile%, 1 ; Copy source file to target
                if (ErrorLevel)
                    MsgBox, Failed to create %TargetFile%. Ensure permissions and paths are correct.
            }

            mainInstanceName := "Main" . (A_Index > 1 ? A_Index : "")
            FileName := "Scripts\" . mainInstanceName . ".ahk"
            Command := FileName

            if (A_Index > 1 && instanceStartDelay > 0) {
                instanceStartDelayMS := instanceStartDelay * 1000
                Sleep, instanceStartDelayMS
            }

            Run, %Command%
        }
    }

; Loop to process each instance
    Loop, %Instances%
    {
        if (A_Index != 1) {
            SourceFile := "Scripts\1.ahk" ; Path to the source .ahk file
            TargetFolder := "Scripts\" ; Path to the target folder
            TargetFile := TargetFolder . A_Index . ".ahk" ; Generate target file path
            if(Instances > 1) {
                FileDelete, %TargetFile%
                FileCopy, %SourceFile%, %TargetFile%, 1 ; Copy source file to target
            }
            if (ErrorLevel)
                MsgBox, Failed to create %TargetFile%. Ensure permissions and paths are correct.
        }

        FileName := "Scripts\" . A_Index . ".ahk"
        Command := FileName

        if ((Mains > 1 || A_Index > 1) && instanceStartDelay > 0) {
            instanceStartDelayMS := instanceStartDelay * 1000
            Sleep, instanceStartDelayMS
        }

        ; Clear out the last run time so that our monitor script doesn't try to kill and refresh this instance right away
        metricFile := A_ScriptDir . "\Scripts\" . A_Index . ".ini"
        if (FileExist(metricFile)) {
            IniWrite, 0, %metricFile%, Metrics, LastEndEpoch
            IniWrite, 0, %metricFile%, UserSettings, DeadCheck
			IniWrite, 0, %metricFile%, Metrics, rerolls
			now := A_TickCount
			IniWrite, %now%, %metricFile%, Metrics, rerollStartTime
        }

        Run, %Command%
    }

    if(autoLaunchMonitor) {
        monitorFile := "Monitor.ahk"
        if(FileExist(monitorFile)) {
            Run, %monitorFile%
        }
    }

    ; Update ScaleParam for use in displaying the status
    SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
    SysGet, Monitor, Monitor, %SelectedMonitorIndex%
    rerollTime := A_TickCount

    typeMsg := "\nType: " . deleteMethod
    injectMethod := false
    if(InStr(deleteMethod, "Inject"))
        injectMethod := true
    if(packMethod)
        typeMsg .= " (1P Method)"
    if(nukeAccount && !injectMethod)
        typeMsg .= " (Menu Delete)"

    Selected := []
    selectMsg := "\nOpening: "
    if(Shining)
        Selected.Push("Shining")
    if(Arceus)
        Selected.Push("Arceus")
    if(Palkia)
        Selected.Push("Palkia")
    if(Dialga)
        Selected.Push("Dialga")
    if(Mew)
        Selected.Push("Mew")
    if(Pikachu)
        Selected.Push("Pikachu")
    if(Charizard)
        Selected.Push("Charizard")
    if(Mewtwo)
        Selected.Push("Mewtwo")
    if(Solgaleo)
        Selected.Push("Solgaleo")
    if(Lunala)
        Selected.Push("Lunala")

    for index, value in Selected {
        if(index = Selected.MaxIndex())
            commaSeparate := ","
        else
            commaSeparate := ", "
        if(value)
            selectMsg .= value . commaSeparate
        else
            selectMsg .= value . commaSeparate
    }

; Inside the StartBot main loop where heartbeat is handled
Loop {
    Sleep, 30000

    ; Check if Main toggled GP Test Mode and send notification if needed
    IniRead, mainTestMode, HeartBeat.ini, TestMode, Main, -1
    if (mainTestMode != -1) {
        ; Main has toggled test mode, get status and send notification
        IniRead, mainStatus, HeartBeat.ini, HeartBeat, Main, 0
        
        onlineAHK := ""
        offlineAHK := ""
        Online := []

        Loop %Instances% {
            IniRead, value, HeartBeat.ini, HeartBeat, Instance%A_Index%
            if(value)
                Online.Push(1)
            else
                Online.Push(0)
            IniWrite, 0, HeartBeat.ini, HeartBeat, Instance%A_Index%
        }

        for index, value in Online {
            if(index = Online.MaxIndex())
                commaSeparate := ""
            else
                commaSeparate := ", "
            if(value)
                onlineAHK .= A_Index . commaSeparate
            else
                offlineAHK .= A_Index . commaSeparate
        }

        if (runMain) {
            if(mainStatus) {
                if (onlineAHK)
                    onlineAHK := "Main, " . onlineAHK
                else
                    onlineAHK := "Main"
            }
            else {
                if (offlineAHK)
                    offlineAHK := "Main, " . offlineAHK
                else
                    offlineAHK := "Main"
            }
        }

        if(offlineAHK = "")
            offlineAHK := "Offline: none"
        else
            offlineAHK := "Offline: " . RTrim(offlineAHK, ", ")
        if(onlineAHK = "")
            onlineAHK := "Online: none"
        else
            onlineAHK := "Online: " . RTrim(onlineAHK, ", ")

        ; Create status message with all regular heartbeat info
        discMessage := heartBeatName ? "\n" . heartBeatName : ""
        discMessage .= "\n" . onlineAHK . "\n" . offlineAHK
        
        total := SumVariablesInJsonFile()
        totalSeconds := Round((A_TickCount - rerollTime) / 1000)
        mminutes := Floor(totalSeconds / 60)
        packStatus := "Time: " . mminutes . "m | Packs: " . total
        packStatus .= " | Avg: " . Round(total / mminutes, 2) . " packs/min"
        
        discMessage .= "\n" . packStatus . "\nVersion: " . RegExReplace(githubUser, "-.*$") . "-" . localVersion
        discMessage .= typeMsg
        discMessage .= selectMsg
        
; Add special note about Main's test mode status
        if (mainTestMode == "1")
            discMessage .= "\n\nMain entered GP Test Mode ✕"
        else
            discMessage .= "\n\nMain exited GP Test Mode ✓"
            
        ; Send the message
        LogToDiscord(discMessage,, false,,, heartBeatWebhookURL)
        
        ; Clear the flag
        IniDelete, HeartBeat.ini, TestMode, Main
    }

; Every 5 minutes, pull down the main ID list and showcase list
if(Mod(A_Index, 10) = 0) {
    if(mainIdsURL != "") {
        DownloadFile(mainIdsURL, "ids.txt")
    } else {
        if(FileExist("ids.txt"))
            FileDelete, ids.txt
    }
    
}
    
    ; Sum all variable values and write to total.json
    total := SumVariablesInJsonFile()
    totalSeconds := Round((A_TickCount - rerollTime) / 1000) ; Total time in seconds
    mminutes := Floor(totalSeconds / 60)

    packStatus := "Time: " . mminutes . "m Packs: " . total
    packStatus .= "   |   Avg: " . Round(total / mminutes, 2) . " packs/min"

    ; Display pack status at the bottom of the first reroll instance
    DisplayPackStatus(packStatus, ((runMain ? Mains * scaleParam : 0) + 5), 625)
    
    ; FIXED HEARTBEAT CODE
    if(heartBeat) {
        ; Each loop iteration is 30 seconds (0.5 minutes)
        ; So for X minutes, we need X * 2 iterations
        heartbeatIterations := heartBeatDelay * 2
        
        ; Send heartbeat at start (A_Index = 1) or every heartbeatDelay minutes
        if (A_Index = 1 || Mod(A_Index, heartbeatIterations) = 0) {

            onlineAHK := ""
            offlineAHK := ""
            Online := []

            Loop %Instances% {
                IniRead, value, HeartBeat.ini, HeartBeat, Instance%A_Index%
                if(value)
                    Online.Push(1)
                else
                    Online.Push(0)
                IniWrite, 0, HeartBeat.ini, HeartBeat, Instance%A_Index%
            }

            for index, value in Online {
                if(index = Online.MaxIndex())
                    commaSeparate := ""
                else
                    commaSeparate := ", "
                if(value)
                    onlineAHK .= A_Index . commaSeparate
                else
                    offlineAHK .= A_Index . commaSeparate
            }

            if(runMain) {
                IniRead, value, HeartBeat.ini, HeartBeat, Main
                if(value) {
                    if (onlineAHK)
                        onlineAHK := "Main, " . onlineAHK
                    else
                        onlineAHK := "Main"
                }
                else {
                    if (offlineAHK)
                        offlineAHK := "Main, " . offlineAHK
                    else
                        offlineAHK := "Main"
                }
                IniWrite, 0, HeartBeat.ini, HeartBeat, Main
            }

            if(offlineAHK = "")
                offlineAHK := "Offline: none"
            else
                offlineAHK := "Offline: " . RTrim(offlineAHK, ", ")
            if(onlineAHK = "")
                onlineAHK := "Online: none"
            else
                onlineAHK := "Online: " . RTrim(onlineAHK, ", ")

            discMessage := heartBeatName ? "\n" . heartBeatName : ""

            discMessage .= "\n" . onlineAHK . "\n" . offlineAHK . "\n" . packStatus . "\nVersion: " . RegExReplace(githubUser, "-.*$") . "-" . localVersion
            discMessage .= typeMsg
            discMessage .= selectMsg

            LogToDiscord(discMessage,, false,,, heartBeatWebhookURL)
            
            ; Optional debug log
            if (debugMode) {
                FileAppend, % A_Now . " - Heartbeat sent at iteration " . A_Index . "`n", %A_ScriptDir%\heartbeat_log.txt
            }
        }
    }
}   

Return

GuiClose:
    ; Save all settings before exiting
    SaveAllSettings()
    
    ; Kill all related scripts
    KillAllScripts()
    
    ExitApp
return

; New hotkey for sending "All Offline" status message
~+F7::
    SendAllInstancesOfflineStatus()
    ExitApp
return

; Function to send a Discord message with all instances marked as offline
SendAllInstancesOfflineStatus() {
    global heartBeatName, heartBeatWebhookURL, localVersion, githubUser, Instances, runMain, Mains
    global typeMsg, selectMsg, rerollTime, scaleParam

    ; Display visual feedback that the hotkey was triggered
    DisplayPackStatus("Shift+F7 pressed - Sending offline heartbeat to Discord...", ((runMain ? Mains * scaleParam : 0) + 5), 625)
    
    ; Create message showing all instances as offline
    offlineInstances := ""
    if (runMain) {
        offlineInstances := "Main"
        if (Mains > 1) {
            Loop, % Mains - 1
                offlineInstances .= ", Main" . (A_Index + 1)
        }
        if (Instances > 0)
            offlineInstances .= ", "
    }

    Loop, %Instances% {
        offlineInstances .= A_Index
        if (A_Index < Instances)
            offlineInstances .= ", "
    }

    ; Create status message with heartbeat info
    discMessage := heartBeatName ? "\n" . heartBeatName : ""
    discMessage .= "\nOnline: none"
    discMessage .= "\nOffline: " . offlineInstances

    ; Add pack statistics
    total := SumVariablesInJsonFile()
    totalSeconds := Round((A_TickCount - rerollTime) / 1000)
    mminutes := Floor(totalSeconds / 60)
    packStatus := "Time: " . mminutes . "m | Packs: " . total
    packStatus .= " | Avg: " . Round(total / mminutes, 2) . " packs/min"

    discMessage .= "\n" . packStatus . "\nVersion: " . RegExReplace(githubUser, "-.*$") . "-" . localVersion
    discMessage .= typeMsg
    discMessage .= selectMsg
    discMessage .= "\n\n All instances marked as OFFLINE"

    ; Send the message
    LogToDiscord(discMessage,, false,,, heartBeatWebhookURL)

    ; Display confirmation in the status bar
    DisplayPackStatus("Discord notification sent: All instances marked as OFFLINE", ((runMain ? Mains * scaleParam : 0) + 5), 625)
}

; Improved status display function
DisplayPackStatus(Message, X := 0, Y := 625) {
    global SelectedMonitorIndex
    static GuiName := "PackStatusGUI"

    ; Fixed light theme colors
    bgColor := "F0F5F9"      ; Light background
    textColor := "2E3440"    ; Dark text for contrast

    MaxRetries := 10
    RetryCount := 0

    try {
        ; Get monitor origin from index
        SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
        SysGet, Monitor, Monitor, %SelectedMonitorIndex%
        X := MonitorLeft + X
        
        ;Adjust Y position to be just above buttons
        Y := MonitorTop + 503  ; This is approximately where the buttons start - 30 (status height)

        ; Check if GUI already exists
        Gui %GuiName%:+LastFoundExist
        if WinExist() {
            GuiControl, %GuiName%:, PacksText, %Message%
        }
        else {
            ; Create a new GUI with light theme styling
            OwnerWND := WinExist(1)
            if(!OwnerWND)
                Gui, %GuiName%:New, +ToolWindow -Caption +LastFound -DPIScale
            else
                Gui, %GuiName%:New, +Owner%OwnerWND% +ToolWindow -Caption +LastFound -DPIScale

            Gui, %GuiName%:Color, %bgColor%  ; Light background
            Gui, %GuiName%:Margin, 2, 2
            Gui, %GuiName%:Font, s8 c%textColor% ; Dark text
            Gui, %GuiName%:Add, Text, vPacksText c%textColor%, %Message%

            ; Show the GUI without activating it
            Gui, %GuiName%:Show, NoActivate x%X% y%Y%, %GuiName%
        }
    } catch e {
        ; Silent error handling
    }
}

; Global variable to track the current JSON file
global jsonFileName := ""

; Function to create or select the JSON file
InitializeJsonFile() {
    global jsonFileName
    fileName := A_ScriptDir . "\json\Packs.json"

    ; Add this line to create the directory if it doesn't exist
    FileCreateDir, %A_ScriptDir%\json

    if FileExist(fileName)
        FileDelete, %fileName%
    if !FileExist(fileName) {
        ; Create a new file with an empty JSON array
        FileAppend, [], %fileName%  ; Write an empty JSON array
        jsonFileName := fileName
        return
    }
}

; Function to append a time and variable pair to the JSON file
AppendToJsonFile(variableValue) {
    global jsonFileName
    if (jsonFileName = "") {
        MsgBox, JSON file not initialized. Call InitializeJsonFile() first.
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

; Function to sum all variable values in the JSON file
SumVariablesInJsonFile() {
    global jsonFileName
    if (jsonFileName = "") {
        return 0  ; Return 0 instead of nothing if jsonFileName is empty
    }

    ; Read the file content
    FileRead, jsonContent, %jsonFileName%
    if (jsonContent = "") {
        return 0
    }

    ; Parse the JSON and calculate the sum
    sum := 0
    ; Clean and parse JSON content
    jsonContent := StrReplace(jsonContent, "[", "") ; Remove starting bracket
    jsonContent := StrReplace(jsonContent, "]", "") ; Remove ending bracket
    Loop, Parse, jsonContent, {, }
    {
        ; Match each variable value
        if (RegExMatch(A_LoopField, """variable"":\s*(-?\d+)", match)) {
            sum += match1
        }
    }

    ; Write the total sum to a file called "total.json"
    if(sum > 0) {
        totalFile := A_ScriptDir . "\json\total.json"
        totalContent := "{""total_sum"": " sum "}"
        FileDelete, %totalFile%
        FileAppend, %totalContent%, %totalFile%
    }

    return sum
}

CheckForUpdate() {
    global githubUser, repoName, localVersion, zipPath, extractPath, scriptFolder
    url := "https://api.github.com/repos/" githubUser "/" repoName "/releases/latest"

    response := HttpGet(url)
    if !response
    {
        MsgBox, Failed to fetch release info.
        return
    }
    latestReleaseBody := FixFormat(ExtractJSONValue(response, "body"))
    latestVersion := ExtractJSONValue(response, "tag_name")
    zipDownloadURL := ExtractJSONValue(response, "zipball_url")
    Clipboard := latestReleaseBody
    if (zipDownloadURL = "" || !InStr(zipDownloadURL, "http"))
    {
        MsgBox, Failed to find the ZIP download URL in the release.
        return
    }

    if (latestVersion = "")
    {
        MsgBox, Failed to retrieve version info.
        return
    }

    if (VersionCompare(latestVersion, localVersion) > 0)
    {
        ; Get release notes from the JSON (ensure this is populated earlier in the script)
        releaseNotes := latestReleaseBody  ; Assuming `latestReleaseBody` contains the release notes

        ; Show a message box asking if the user wants to download
        MsgBox, 4, Update Available %latestVersion%, %releaseNotes%`n`nDo you want to download the latest version?

        ; If the user clicks Yes (return value 6)
        IfMsgBox, Yes
        {
            MsgBox, 64, Downloading..., Downloading the latest version...

            ; Proceed with downloading the update
            URLDownloadToFile, %zipDownloadURL%, %zipPath%
            if ErrorLevel
            {
                MsgBox, Failed to download update.
                return
            }
            else {
                MsgBox, Download complete. Extracting...

                ; Create a temporary folder for extraction
                tempExtractPath := A_Temp "\PTCGPB_Temp"
                FileCreateDir, %tempExtractPath%

                ; Extract the ZIP file into the temporary folder
                RunWait, powershell -Command "Expand-Archive -Path '%zipPath%' -DestinationPath '%tempExtractPath%' -Force",, Hide

                ; Check if extraction was successful
                if !FileExist(tempExtractPath)
                {
                    MsgBox, Failed to extract the update.
                    return
                }

                ; Get the first subfolder in the extracted folder
                Loop, Files, %tempExtractPath%\*, D
                {
                    extractedFolder := A_LoopFileFullPath
                    break
                }

                ; Check if a subfolder was found and move its contents recursively to the script folder
                if (extractedFolder)
                {
                    MoveFilesRecursively(extractedFolder, scriptFolder)

                    ; Clean up the temporary extraction folder
                    FileRemoveDir, %tempExtractPath%, 1
                    MsgBox, Update installed. Restarting...
                    Reload
                }
                else
                {
                    MsgBox, Failed to find the extracted contents.
                    return
                }
            }
        }
        else
        {
            MsgBox, The update was canceled.
            return
        }
    }
    else
    {
        MsgBox, You are running the latest version (%localVersion%).
    }
}

MoveFilesRecursively(srcFolder, destFolder) {
    ; Loop through all files and subfolders in the source folder
    Loop, Files, % srcFolder . "\*", R
    {
        ; Get the relative path of the file/folder from the srcFolder
        relativePath := SubStr(A_LoopFileFullPath, StrLen(srcFolder) + 2)

        ; Create the corresponding destination path
        destPath := destFolder . "\" . relativePath

        ; If it's a directory, create it in the destination folder
        if (A_LoopIsDir)
        {
            ; Ensure the directory exists, if not, create it
            FileCreateDir, % destPath
        }
        else
        {
            if ((relativePath = "ids.txt" && FileExist(destPath))
                || (relativePath = "usernames.txt" && FileExist(destPath))
                || (relativePath = "discord.txt" && FileExist(destPath))
                || (relativePath = "vip_ids.txt" && FileExist(destPath))) {
                continue
            }
            ; If it's a file, move it to the destination folder
            ; Ensure the directory exists before moving the file
            FileCreateDir, % SubStr(destPath, 1, InStr(destPath, "\", 0, 0) - 1)
            FileMove, % A_LoopFileFullPath, % destPath, 1
        }
    }
}

HttpGet(url) {
    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    http.Open("GET", url, false)
    http.Send()
    return http.ResponseText
}

; Function to extract value from JSON
ExtractJSONValue(json, key1, key2:="", ext:="") {
    value := ""
    json := StrReplace(json, """", "")
    lines := StrSplit(json, ",")

    Loop, % lines.MaxIndex()
    {
        if InStr(lines[A_Index], key1 ":") {
            ; Take everything after the first colon as the value
            value := SubStr(lines[A_Index], InStr(lines[A_Index], ":") + 1)
            if (key2 != "")
            {
                if InStr(lines[A_Index+1], key2 ":") && InStr(lines[A_Index+1], ext)
                    value := SubStr(lines[A_Index+1], InStr(lines[A_Index+1], ":") + 1)
            }
            break
        }
    }
    return Trim(value)
}

FixFormat(text) {
    ; Replace carriage return and newline with an actual line break
    text := StrReplace(text, "\r\n", "`n")  ; Replace \r\n with actual newlines
    text := StrReplace(text, "\n", "`n")    ; Replace \n with newlines

    ; Remove unnecessary backslashes before other characters like "player" and "None"
    text := StrReplace(text, "\player", "player")   ; Example: removing backslashes around words
    text := StrReplace(text, "\None", "None")       ; Remove backslash around "None"
    text := StrReplace(text, "\Welcome", "Welcome") ; Removing \ before "Welcome"

    ; Escape commas by replacing them with %2C (URL encoding)
    text := StrReplace(text, ",", "")

    return text
}

VersionCompare(v1, v2) {
    ; Remove non-numeric characters (like 'alpha', 'beta')
    cleanV1 := RegExReplace(v1, "[^\d.]")
    cleanV2 := RegExReplace(v2, "[^\d.]")

    v1Parts := StrSplit(cleanV1, ".")
    v2Parts := StrSplit(cleanV2, ".")

    Loop, % Max(v1Parts.MaxIndex(), v2Parts.MaxIndex()) {
        num1 := v1Parts[A_Index] ? v1Parts[A_Index] : 0
        num2 := v2Parts[A_Index] ? v2Parts[A_Index] : 0
        if (num1 > num2)
            return 1
        if (num1 < num2)
            return -1
    }

    ; If versions are numerically equal, check if one is an alpha version
    isV1Alpha := InStr(v1, "alpha") || InStr(v1, "beta")
    isV2Alpha := InStr(v2, "alpha") || InStr(v2, "beta")

    if (isV1Alpha && !isV2Alpha)
        return -1 ; Non-alpha version is newer
    if (!isV1Alpha && isV2Alpha)
        return 1 ; Alpha version is older

    return 0 ; Versions are equal
}

DownloadFile(url, filename) {
    url := url
    localPath = %A_ScriptDir%\%filename%

    URLDownloadToFile, %url%, %localPath%
}

ReadFile(filename, numbers := false) {
    FileRead, content, %A_ScriptDir%\%filename%.txt

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

ErrorHandler(exception) {
    ; Display the error message
    errorMessage := "Error in PTCGPB.ahk`n`n" 
                 . "Message: " exception.Message "`n"
                 . "What: " exception.What "`n" 
                 . "Line: " exception.Line "`n`n"
                 . "Click OK to close all related scripts and exit."
                 
    MsgBox, 16, PTCGPB Error, %errorMessage%
    
    ; Kill all related scripts
    KillAllScripts()
    
    ; Exit this script
    ExitApp, 1
    return true  ; Indicate that the error was handled
}

; Add this function to kill all related scripts
KillAllScripts() {
    ; Kill Monitor.ahk if running
    Process, Exist, Monitor.ahk
    if (ErrorLevel) {
        Process, Close, %ErrorLevel%
    }
    
    ; Kill all instance scripts
    Loop, 50 {  ; Assuming you won't have more than 50 instances
        scriptName := A_Index . ".ahk"
        Process, Exist, %scriptName%
        if (ErrorLevel) {
            Process, Close, %ErrorLevel%
        }
        
        ; Also check for Main scripts
        if (A_Index = 1) {
            Process, Exist, Main.ahk
            if (ErrorLevel) {
                Process, Close, %ErrorLevel%
            }
        } else {
            mainScript := "Main" . A_Index . ".ahk"
            Process, Exist, %mainScript%
            if (ErrorLevel) {
                Process, Close, %ErrorLevel%
            }
        }
    }
    
    ; Close any status GUIs that might be open
    Gui, PackStatusGUI:Destroy
}