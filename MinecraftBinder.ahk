#Persistent
#SingleInstance force

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
            Sleep, 100
			SendEvent, {T}
			Sleep, 150
            SendEvent, %command%{Enter}
        }
    }
}

return

#IfWinActive