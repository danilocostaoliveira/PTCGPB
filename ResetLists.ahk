#SingleInstance, force

; Define the primary paths
scriptDir := A_ScriptDir
saveDir := scriptDir . "\..\Accounts\Saved"
saveDir := RegExReplace(saveDir, "\\{2,}", "\")

; Verify the directory exists
if (!InStr(FileExist(saveDir), "D")) {
    ; Try an alternative approach - go directly to the path without the relative part
    alternativePath := scriptDir . "\Accounts\Saved"
    alternativePath := RegExReplace(alternativePath, "\\{2,}", "\")
    
    if (InStr(FileExist(alternativePath), "D")) {
        saveDir := alternativePath
    } else {
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
    
    ; Define the file paths
    listFile := folder . "\list.txt"
    listCurrentFile := folder . "\list_current.txt"
    lastGenFile := folder . "\list_last_generated.txt"
    
    ; Delete list.txt if it exists
    if (FileExist(listFile)) {
        FileDelete, %listFile%
        if (!ErrorLevel) {
            totalFilesDeleted++
        }
    }
    
    ; Delete list_current.txt if it exists
    if (FileExist(listCurrentFile)) {
        FileDelete, %listCurrentFile%
        if (!ErrorLevel) {
            totalFilesDeleted++
        }
    }
    
    ; Delete list_last_generated.txt if it exists
    if (FileExist(lastGenFile)) {
        FileDelete, %lastGenFile%
        if (!ErrorLevel) {
            totalFilesDeleted++
        }
    }
}

ExitApp