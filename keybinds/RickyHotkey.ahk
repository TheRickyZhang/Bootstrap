#Requires AutoHotkey v2.0
#SingleInstance Force

CapsLock::Ctrl
LCtrl::z
$*Space::
{
    if GetKeyState("RShift", "P")
        SendInput "{Backspace}"
    else
        SendInput " "
}


; Colemak DH remapping
e::f
r::p
t::b
y::j
u::l
i::u
o::y
p::;

; Home row
s::r
d::s
f::t
h::m
j::n
k::e
l::i
`;::o

z::x
x::c
c::d
b::Esc
n::k
m::h

; Opening, running, quiting RickyHotkey
^!o:: {
    Run('"C:\Users\ricky\AppData\Local\Programs\Microsoft VS Code\Code.exe" "C:\Users\ricky\ConfigEfficiency\RickyHotkey.ahk"')
}
^!r:: {
    Run "C:\Users\ricky\ConfigEfficiency\RickyHotkey.ahk"
}
^!q:: {
    Suspend(1)
    ToolTip("Hotkeys suspended!")
    Sleep(500)
    ToolTip("")
}