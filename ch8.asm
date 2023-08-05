; def main ... end

; a = 1
LD I, #F00 ; MEM[a] => 0xF00 - 0xFFF
LD V0, 10
LD [I], V0

; b = 2
LD I, #E01 ; MEM[b] => 0xE01 - 0xF00
LD V0, 1
LD [I], V0

; print(a+b)
; a + b
; a
LD I, #F00 ; MEM[a] => 0xF00 - 0xFFF
LD V0, [I]
LD V1, V0

; b
LD I, #E01 ; MEM[b] => 0xE01 - 0xF00
LD V0, [I]
LD V2, V0

LD V0, V1
ADD V0, V2

; print(arg)
CLS

; I = arg * 5
LD I, #000
ADD I, V0
ADD I, V0
ADD I, V0
ADD I, V0
ADD I, V0

LD V2, 0
LD V3, 0

DRW V2, V3, #005
