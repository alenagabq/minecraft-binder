; Version = 1.0.2

#Persistent
#SingleInstance force

; URL файла на GitHub
GitHubURL := "https://raw.githubusercontent.com/alenagabq/minecraft-binder/main/MinecraftBinder.ahk"
GitHubSoundListURL := "https://raw.githubusercontent.com/alenagabq/minecraft-binder/main/sound_files_list.txt"
LocalScriptPath := A_ScriptFullPath

; Функция для загрузки файла из GitHub
DownloadFile(url, savePath) {
    UrlDownloadToFile, %url%, %savePath%
}

; Функция для получения версии скрипта (например, из комментария или строки в файле)
GetVersion(path) {
    FileRead, content, %path%
    RegExMatch(content, "Version\s*=\s*(\d+\.\d+\.\d+)", version)
    return version1
}

; Функция для проверки и обновления файлов в папке sound
UpdateSoundFiles() {
    global GitHubSoundListURL, SoundFolderPath
    TempSoundListPath := A_Temp "\sound_files_list.txt"
    DownloadFile(GitHubSoundListURL, TempSoundListPath)
    
    FileRead, fileList, %TempSoundListPath%
    Loop, Parse, fileList, `n, `r
    {
        fileName := A_LoopField
        if (fileName != "") {
            remoteFileURL := "https://raw.githubusercontent.com/alenagabq/minecraft-binder/main/sound/" . fileName
            localFilePath := SoundFolderPath . "\" . fileName
            TempFilePath := A_Temp "\" . fileName

            DownloadFile(remoteFileURL, TempFilePath)
            if (!FileExist(localFilePath) || !FileCompare(localFilePath, TempFilePath)) {
                FileMove, %TempFilePath%, %localFilePath%, 1  ; Перемещение с заменой
            } else {
                FileDelete, %TempFilePath%  ; Удаление временного файла, если не требуется обновление
            }
        }
    }
    FileDelete, %TempSoundListPath%
}

; Функция для сравнения двух файлов
FileCompare(file1, file2) {
    FileGetSize, size1, %file1%
    FileGetSize, size2, %file2%
    if (size1 != size2)
        return false

    FileRead, content1, %file1%
    FileRead, content2, %file2%
    return (content1 == content2)
}

; Скачивание удаленного файла во временное место
RemoteScriptPath := A_Temp "\MinecraftBinder.ahk"
DownloadFile(GitHubScriptURL, RemoteScriptPath)

; Получение версий скриптов
localVersion := GetVersion(LocalScriptPath)
remoteVersion := GetVersion(RemoteScriptPath)

; Если версии отличаются, обновляем скрипт
if (remoteVersion != "" && localVersion != remoteVersion) {
    FileMove, %RemoteScriptPath%, %LocalScriptPath%, 1  ; Перемещение с заменой
    MsgBox, 64, - MinecraftBinder -, Скрипт обновлен до версии %remoteVersion%. Перезагрузка...
    Reload  ; Перезагрузка скрипта
} else {
    FileDelete, %RemoteScriptPath%  ; Удаление временного файла, если не было обновления
}

; Обновление файлов в папке sound
UpdateSoundFiles()

PlayStartSound() {
    SoundFilePath := A_ScriptDir "\sound\start.wav"
    SoundPlay, %SoundFilePath%
}

PlayStartSound()
MsgBox, 64, - MinecraftBinder -, Скрипт успешно запущен, приятной игры!                       Авторство: xDarkGabRG, VK/TG: @alenagabq

^r::Reload

#IfWinActive Minecraft | ahk_class ApplicationFrameWindow

configFile := "config.ini"

if (!FileExist(configFile)) {
    FileAppend, 
    (
    [Bindings]
    Numpad1=/gamemode 1
    Numpad0=/gamemode 0
    Numpad2=/vanish
    Numpad3=/fly
    Numpad4=/console
    Numpad7=/time day
    Numpad8=/time night
    Numpad9=/spawn
    ), %configFile%
}

bindings := {}
IniRead, keys, %configFile%, Bindings
Loop, Parse, keys, `n
{
    StringSplit, keyCommand, A_LoopField, =
    if (keyCommand1 && keyCommand2)
    {
        bindings[keyCommand1] := keyCommand2
    }
}

for key, command in bindings
{
    func := Func("SendCommand").Bind(command)
    Hotkey, %key%, % func
}

SendCommand(command) {
    global LastSent
    if WinActive("ahk_class ApplicationFrameWindow") {
        if (A_TickCount - LastSent > 3000 || LastSent = "") {
            LastSent := A_TickCount
            Sleep, 150
			SendEvent, {T}
			Sleep, 150
            SendEvent, %command%{Enter}
        }
    }
}

return

#IfWinActive