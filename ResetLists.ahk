#SingleInstance, force

; Define the primary paths
scriptDir := A_ScriptDir
saveDir := scriptDir . "\..\Accounts\Saved"
saveDir := RegExReplace(saveDir, "\\{2,}", "\")

; Create Logs directory if it doesn't exist
logsDir := scriptDir . "\..\Logs"
logsDir := RegExReplace(logsDir, "\\{2,}", "\")
if (!InStr(FileExist(logsDir), "D")) {
    FileCreateDir, %logsDir%
}
logFile := logsDir . "\Log_PTCGPB.txt"

; Function to write to log with error handling (silent - no popups)
WriteLog(message) {
    global logFile
    FormatTime, currentTime,, [MMM d, yyyy HH:mm:ss]
    fullMessage := currentTime . " " . message . "`n"
    
    try {
        FileAppend, %fullMessage%, %logFile%
    } catch e {
        ; Fail silently - no popups
        localLog := A_ScriptDir . "\local_log.txt"
        FileAppend, %fullMessage%, %localLog%
    }
}

; Log start of operation (create file if it doesn't exist)
if (!FileExist(logFile)) {
    FileAppend, , %logFile%
    ; No error message if this fails
}

WriteLog(" Resetting all account lists to apply latest pack threshold settings...")
WriteLog(" Script running from: " . scriptDir)
WriteLog(" Using save directory: " . saveDir)
WriteLog(" Using logs directory: " . logsDir)

; Verify the directory exists
if (!InStr(FileExist(saveDir), "D")) {
    WriteLog(" ERROR: Directory not found: " . saveDir)
    
    ; Try an alternative approach - go directly to the path without the relative part
    alternativePath := scriptDir . "\Accounts\Saved"
    alternativePath := RegExReplace(alternativePath, "\\{2,}", "\")
    
    if (InStr(FileExist(alternativePath), "D")) {
        WriteLog(" Using alternative path: " . alternativePath)
        saveDir := alternativePath
    } else {
        WriteLog(" ERROR: Could not find Accounts\Saved directory in any expected location")
        ; No popup, just exit
        ExitApp
    }
}

; Initialize counters
totalFilesDeleted := 0
foldersProcessed := 0

; Process each folder
Loop, %saveDir%\*, 2  ; Loop through folders
{
    folderName := A_LoopFileName
    folder := A_LoopFileFullPath
    foldersProcessed++
    
    ; Log the folder being processed
    WriteLog(" Processing folder: " . folderName)
    
    ; Define the file paths
    listFile := folder . "\list.txt"
    listCurrentFile := folder . "\list_current.txt"
    lastGenFile := folder . "\list_last_generated.txt"
    
    ; Delete list.txt if it exists
    if (FileExist(listFile)) {
        FileDelete, %listFile%
        if (!ErrorLevel) {
            totalFilesDeleted++
            WriteLog(" Deleted: " . listFile)
        } else {
            WriteLog(" ERROR: Failed to delete: " . listFile)
        }
    }
    
    ; Delete list_current.txt if it exists
    if (FileExist(listCurrentFile)) {
        FileDelete, %listCurrentFile%
        if (!ErrorLevel) {
            totalFilesDeleted++
            WriteLog(" Deleted: " . listCurrentFile)
        } else {
            WriteLog(" ERROR: Failed to delete: " . listCurrentFile)
        }
    }
    
    ; Delete list_last_generated.txt if it exists
    if (FileExist(lastGenFile)) {
        FileDelete, %lastGenFile%
        if (!ErrorLevel) {
            totalFilesDeleted++
            WriteLog(" Deleted: " . lastGenFile)
        } else {
            WriteLog(" ERROR: Failed to delete: " . lastGenFile)
        }
    }
}

; Log completion and summary
WriteLog(" Reset complete. Processed " . foldersProcessed . " folders. Deleted " . totalFilesDeleted . " list files. New lists will be generated on next injection.")

; No completion message dialog
ExitApp