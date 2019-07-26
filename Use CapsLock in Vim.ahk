; Ignore attempts to launch when the script is already-running.
#SingleInstance Ignore

SetStoreCapslockMode Off
CapsLockDownTime := 0
IsKeyCombination := True
HoldingCapsLock := False

*CapsLock::
    if (HoldingCapsLock) {
        return
    }
    SendInput {LCtrl Down}
    HoldingCapsLock := True
    IsKeyCombination := False
    CapsLockDownTime := A_TickCount
    return

*CapsLock Up::
    SendInput {LCtrl Up}
    HoldingCapsLock := False
    if (!IsKeyCombination) {
        if (A_TickCount - CapsLockDownTime <= 250) {
            SendInput {Esc}
        } else {
            SendInput {CapsLock}
        }
    }
    return


~*^a::
~*^b::
~*^c::
~*^d::
~*^e::
~*^f::
~*^g::
~*^h::
~*^i::
~*^j::
~*^k::
~*^l::
~*^m::
~*^n::
~*^o::
~*^p::
~*^q::
~*^r::
~*^s::
~*^t::
~*^u::
~*^v::
~*^w::
~*^x::
~*^y::
~*^z::
~*^1::
~*^2::
~*^3::
~*^4::
~*^5::
~*^6::
~*^7::
~*^8::
~*^9::
~*^0::
~*^Space::
~*^Backspace::
~*^Delete::
~*^Insert::
~*^Home::
~*^End::
~*^PgUp::
~*^PgDn::
~*^Tab::
~*^Return::
~*^,::
~*^.::
~*^/::
~*^;::
~*^'::
~*^[::
~*^]::
~*^\::
~*^-::
~*^=::
~*^`::
~*^F1::
~*^F2::
~*^F3::
~*^F4::
~*^F5::
~*^F6::
~*^F7::
~*^F8::
~*^F9::
~*^F10::
~*^F11::
~*^F12::
    IsKeyCombination := True
    return