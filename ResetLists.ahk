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

; Function to write to log with error handling
WriteLog(message) {
    global logFile
    FormatTime, currentTime,, [MMM d, yyyy HH:mm:ss]
    fullMessage := currentTime . " " . message . "`n"
    
    try {
        FileAppend, %fullMessage%, %logFile%
    } catch e {
        ; If log file write fails, show error and try to create a local log
        MsgBox, Warning: Could not write to log file: %logFile%`nError: %e%`nWill create local log file.
        localLog := A_ScriptDir . "\local_log.txt"
        FileAppend, %fullMessage%, %localLog%
    }
}

; Display debug information about paths
MsgBox, Debug Information:`nScript Directory: %scriptDir%`nSave Directory: %saveDir%`nLogs Directory: %logsDir%`nLog File: %logFile%

; Log start of operation (create file if it doesn't exist)
if (!FileExist(logFile)) {
    FileAppend, , %logFile%
    if (ErrorLevel) {
        MsgBox, Error creating log file: %logFile%
        ; Try alternative local logging
        localLog := A_ScriptDir . "\local_log.txt"
        FileAppend, , %localLog%
        logFile := localLog
    }
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
        MsgBox, ERROR: Directory not found. Please verify the path to Accounts\Saved folder.
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

; Show completion message
MsgBox, Reset complete. Processed %foldersProcessed% folders. Deleted %totalFilesDeleted% list files. New lists will be regenerated on next run with new pack thresholds.