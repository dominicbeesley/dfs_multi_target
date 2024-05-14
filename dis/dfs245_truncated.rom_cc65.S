; Target assembler: cc65 v2.18.0 [--target none -C dfs245_truncated.rom_cc65.cfg]
; 6502bench SourceGen v1.8.5
                .setcpu "65C02"
FSCV            =       $021e                   ;FSCV vector
TubeCode        =       $0406
intnmi          =       $0d00
swrom_wksp_tab  =       $0df0
WKSP261_TransAddr =     $c261
WKSP281_TubeClaimed =   $c281
WKSP2D6_TubePresentIf0 = $c2d6
fdccmd          =       $fe28
fdcsec          =       $fe2a
fdcdat          =       $fe2b
sheila_TUBE_R3_data =   $fee5
GSREAD          =       $ffc5

                .org    $8000
                brk

                .byte   $00
                .byte   $00

                jmp     serv

                .byte   $82
                .byte   $11
                .byte   $95
                .byte   $44
                .byte   $46
                .byte   $53
                .byte   $00
                .byte   "2.45"
                .byte   $00
                .byte   "(C)1985 Acorn"
                .byte   $00

jmpIndFSCV:     jmp     (FSCV)

brk_with_prefix_disc:
                jsr     estrng
                brk

                .byte   "Disc "

                bcc     L804F
brk_with_prefix_bad:
                jsr     estrng
                brk

                .byte   "Bad "

                bcc     L804F
estrng:         lda     $c2dd
                bne     @L8040
                jsr     L98E3
@L8040:         lda     #$ff
                sta     $c282
                sta     $c2dd
do_following_brk:
                ldx     #$02
                lda     #$00
                sta     $0100
L804F:          sta     $b3
                pla
                sta     $ae
                pla
                sta     $af
                lda     $b3
                ldy     #$00
                jsr     L83E4
                lda     ($ae),Y
                sta     $0101
                dex
@L8064:         jsr     L83E4
                inx
                lda     ($ae),Y
                sta     $0100,X
                bmi     L8097
                bne     @L8064
                jsr     L8F9E
                bit     $c2a6
                bmi     @L807C
                jsr     L9877
@L807C:         jmp     $0100

vstrng:         sta     $b3
                pla
                sta     $ae
                pla
                sta     $af
                lda     $b3
                pha
@vstrnglp:      jsr     L83E4
                lda     ($ae)
                bmi     @vstrngx
                jsr     pchr
                bra     @vstrnglp

@vstrngx:       pla
L8097:          clc
                jmp     ($00ae)

L809B:          jsr     L80C3
pdot:           lda     #'.'
pchr:           jsr     savita
                pha
                lda     #$ec
                jsr     LA5D9
                txa
                pha
                ora     #$10
                jsr     LA5C7
                plx
                pla
                jsr     $ffe3
                jmp     LA5C8

                jsr     L841D
L80BB:          pha
                jsr     L81BE
                jsr     L80C3
                pla
L80C3:          jsr     L80C8
                bne     pchr
L80C8:          and     #$0f
                cmp     #$0a
                bcc     @L80D0
                adc     #$06
@L80D0:         adc     #$30
                rts

L80D3:          jsr     L80E3
                dex
                dex
                jsr     @L80DB
@L80DB:         lda     ($b0),Y
                sta     $c272,X
                inx
                iny
                rts

L80E3:          jsr     @L80E6
@L80E6:         lda     ($b0),Y
                sta     $ba,X
                inx
                iny
                rts

L80ED:          jsr     L8B52
                jmp     L8103

L80F3:          jsr     L8B52
L80F6:          lda     $ba
                sta     $f2
                lda     $bb
                sta     $f3
                ldy     #$00
                jsr     L8703
L8103:          ldx     #$20
                jsr     L8149
                bcs     brkBadName
                sta     $c200
                cmp     #$2e
                bne     L8115
L8111:          stx     $cc
                beq     L8103

L8115:          cmp     #$3a
                bne     L812E
                jsr     L8B62
                jsr     L8149
                bcs     brkBadName
                cmp     #$2e
                beq     L8103
brkBadName:     jsr     brk_with_prefix_bad
                .byte   $cc
                .asciiz "name"
L812E:          tax
                jsr     L8149
                bcs     L815D
                cmp     #$2e
                beq     L8111
                ldx     #$01
@L813A:         sta     $c200,X
                inx
                jsr     L8149
                bcs     L815F
                cpx     #$07
                bne     @L813A
                beq     brkBadName

L8149:          jsr     GSREAD
                php
                and     #$7f
                cmp     #$0d
                beq     @L815B
                cmp     #$20
                bcc     brkBadName
                cmp     #$7f
                beq     brkBadName
@L815B:         plp
                rts

L815D:          ldx     #$01
L815F:          lda     #$20
@L8161:         sta     $c200,X
                inx
                cpx     #$40
                bne     @L8161
                ldx     #$06
@L816B:         lda     $c200,X
                sta     $c5,X
                dex
                bpl     @L816B
                rts

prtnam:         jsr     savita
                lda     $c00f,Y
                php
                and     #$7f
                bne     @L8184
                jsr     LADCF
                beq     @L818A
@L8184:         jsr     pchr
                jsr     pdot
@L818A:         ldx     #$06
ptnam0:         lda     $c008,Y
                and     #$7f
                jsr     pchr
                iny
                dex
                bpl     ptnam0
                jsr     LADCF
                lda     #$20
                plp
                bpl     ptnam1
                lda     #$4c
ptnam1:         jsr     pchr
                ldy     #$01
yspace:         jsr     LADD2
                dey
                bne     yspace
                rts

isoexe:         lsr     A
                lsr     A
L81B0:          jsr     L81BE
                and     #$03
                rts

L81B6:          and     #$08
                beq     @L81BC
                lda     #$03
@L81BC:         rts

L81BD:          lsr     A
L81BE:          lsr     A
L81BF:          lsr     A
                lsr     A
                lsr     A
                rts

L81C3:          asl     A
L81C4:          asl     A
                asl     A
                asl     A
                asl     A
                rts

L81C9:          lda     #$05
                sta     $c295
                lda     $cd
                sta     $c290
                lda     #$0a
                sta     $b0
                lda     $bc
                sta     $c291
                lda     $bd
                sta     $c292
                lda     $c274
                sta     $c293
                lda     $c275
                sta     $c294
                lda     #$ff
                sta     $c297
                lda     $c2
                jsr     L81B0
                sta     $c29a
                lda     $c0
                sta     $c29b
                lda     $c1
                sta     $c299
                lda     $c2
                and     #$03
                tax
                lda     $c3
@L820B:         sec
@L820C:         inc     $c297
                sbc     $b0
                bcs     @L820C
                dex
                bpl     @L820B
                adc     $b0
                sta     $c298
rts821B:        rts

L821C:          jsr     L80ED
                bmi     L8224
L8221:          jsr     L80F3
L8224:          jsr     lookup
                bcs     rts821B
brkNotFound:    jsr     do_following_brk
                .byte   $d6
                .asciiz "Not found"
                jsr     L86FC
                jsr     L8B52
                jsr     L8703
                beq     @L8245
                jsr     L8961
@L8245:         lda     #$2a
                sta     $c200
                jsr     L815D
                jsr     LA4A7
                jsr     L8224
                jmp     @L8264

                jsr     L86FC
                jsr     LA4A7
                jsr     L8703
                beq     jbrkBadName
                jsr     L821C
@L8264:         jsr     L8342
                jsr     L828A
                bcs     @L8264
                rts

jbrkBadName:    jmp     brkBadName

L8270:          jsr     L943E
                lda     #$00
                bra     L8295

L8277:          ldx     #$06
@L8279:         lda     $c5,X
                sta     $c258,X
                dex
                bpl     @L8279
                lda     #$20
                sta     $c25f
                lda     #$58
                bne     L8290

L828A:          ldx     #$00
                bra     L8298

lookup:         lda     #$00
L8290:          pha
                jsr     L9442
                pla
L8295:          tax
                stz     $b6
L8298:          ldy     #$00
                lda     #$c0
                sta     $b7
                lda     $b6
                cmp     $c105
                bcs     L82EE
                adc     #$08
                sta     $b6
                jsr     L82C3
                bcc     L8298
                lda     $cc
                ldy     #$07
                jsr     L82F0
                bne     L8298
                ldy     $b6
                sec
L82BA:          dey
                dey
                dey
                dey
                dey
                dey
                dey
                dey
                rts

L82C3:          jsr     savita
@L82C6:         lda     $c200,X
                cmp     $c2ce
                bne     @L82E1
                inx
@L82CF:         jsr     L82C3
                bcs     rts82EF
                iny
                cpy     #$07
                bcc     @L82CF
@L82D9:         lda     $c200,X
                cmp     #$20
                bne     L82EE
                rts

@L82E1:         cpy     #$07
                bcs     @L82D9
                jsr     L82F0
                bne     L82EE
                inx
                iny
                bne     @L82C6
L82EE:          clc
rts82EF:        rts

L82F0:          cmp     $c2ce
                beq     rts8305
                cmp     $c2cd
                beq     rts8305
                jsr     L832F
                eor     ($b6),Y
                bcs     @L8303
                and     #$5f
@L8303:         and     #$7f
rts8305:        rts

L8306:          php
                jsr     L832F
                bcs     @L830E
                and     #$5f
@L830E:         and     #$7f
                plp
                rts

L8312:          jsr     LA55B
@L8315:         lda     $c010,Y
                sta     $c008,Y
                lda     $c110,Y
                sta     $c108,Y
                iny
                cpy     $c105
                bcc     @L8315
                tya
                sbc     #$08
                sta     $c105
                clc
rts832E:        rts

L832F:          pha
                and     #$5f
                cmp     #$41
                bcc     @L833A
                cmp     #$5b
                bcc     @L833B
@L833A:         sec
@L833B:         pla
                rts

L833D:          bit     $c2c6
                bmi     rts832E
L8342:          jsr     savita
                jsr     prtnam
                tya
                pha
                lda     #$60
                sta     $b0
                lda     #$c2
                sta     $b1
                jsr     L838E
                ldy     #$02
                jsr     LADD2
                jsr     @L8376
                jsr     @L8376
                jsr     @L8376
                pla
                tay
                lda     $c10e,Y
                and     #$03
                jsr     L80C3
                lda     $c10f,Y
                jsr     L80BB
                jmp     LA7DD

@L8376:         ldx     #$03
@L8378:         lda     WKSP261_TransAddr+1,Y
                jsr     L80BB
                dey
                dex
                bne     @L8378
                jsr     iny7
                jmp     LADD2

L8388:          jsr     savita
                jmp     L9451

L838E:          jsr     savita
                tya
                pha
                tax
                ldy     #$12
                lda     #$00
@L8398:         dey
                sta     ($b0),Y
                cpy     #$02
                bne     @L8398
@L839F:         jsr     @L83D9
                iny
                iny
                cpy     #$0e
                bne     @L839F
                pla
                tax
                lda     $c00f,X
                bpl     @L83B3
                lda     #$08
                sta     ($b0),Y
@L83B3:         lda     $c10e,X
                ldy     #$04
                jsr     @L83C7
                ldy     #$0c
                lsr     A
                lsr     A
                pha
                and     #$03
                sta     ($b0),Y
                pla
                ldy     #$08
@L83C7:         lsr     A
                lsr     A
                pha
                and     #$03
                cmp     #$03
                bne     @L83D5
                lda     #$ff
                sta     ($b0),Y
                iny
@L83D5:         sta     ($b0),Y
                pla
                rts

@L83D9:         jsr     @L83DC
@L83DC:         lda     $c108,X
                sta     ($b0),Y
                inx
                iny
                rts

L83E4:          inc     $ae
                bne     rts83EA
                inc     $af
rts83EA:        rts

savita:         pha
                phx
                phy
                lda     #$84
                pha
                lda     #$0b
                pha
L83F4:          ldy     #$05
@L83F6:         tsx
                lda     $0107,X
                pha
                dey
                bne     @L83F6
                ldy     #$0a
@L8400:         lda     $0109,X
                sta     $010b,X
                dex
                dey
                bne     @L8400
                pla
                pla
L840C:          ply
                plx
                pla
                rts

savit:          pha
                phx
                phy
                jsr     L83F4
                tsx
                sta     $0103,X
                jmp     L840C                   ;TODO: OPT: BRA

L841D:          jsr     savit
                tay
                beq     rts842D
                clc
                sed
                lda     #$00
@L8427:         adc     #$01
                dey
                bne     @L8427
                cld
rts842D:        rts

                and     #$7f
                cmp     #$7f
                beq     @L8438
                cmp     #$20
                bcs     @L843A
@L8438:         lda     #$2e
@L843A:         rts

L843B:          sec
                sbc     #$30
                bcc     @L8456
                cmp     #$0a
                rts

                jsr     L8306
                jsr     L843B
                bcc     @L8455
                sbc     #$07
                bcc     @L8456
                cmp     #$0a
                bcc     @L8456
                cmp     #$10
@L8455:         rts

@L8456:         sec
                rts

L8458:          jsr     L8703
                sec
                beq     @L8482
                php
                stz     $b9
                bra     @L8477

@L8463:         jsr     L843B
                bcs     @L8481
                sta     $b8
                lda     $b9
                asl     A
                sta     $b9
                asl     A
                asl     A
                adc     $b9
                adc     $b8
                sta     $b9
@L8477:         jsr     GSREAD
                bcc     @L8463
                lda     $b9
                plp
                clc
                rts

@L8481:         plp
@L8482:         rts

                jsr     L86FC
                jsr     L8B5D
                jsr     L9451
                ldy     #$ff
                sty     $a8
                iny
                sty     $aa
@L8493:         lda     $c000,Y
                cpy     #$08
                bcc     @L849D
                lda     $c0f8,Y
@L849D:         jsr     pchr
                iny
                cpy     #$0c
                bne     @L8493
                jsr     vstrng
                .byte   " ("
                lda     $c104
                jsr     L80BB
                jsr     vstrng
                .byte   ") FM",$0d,"Drive "
                lda     $cd
                jsr     L80C3
                ldy     #$0d
                jsr     yspace
                jsr     vstrng
                .byte   "Option "

                lda     $c106
                jsr     L81BE
                pha
                jsr     L80C3
                jsr     vstrng
                .byte   " ("
                ldy     #$03
                pla
                asl     A
                asl     A
                tax
@L84E7:         lda     aoff,X
                jsr     pchr
                inx
                dey
                bpl     @L84E7
                jsr     vstrng
                .byte   ")",$0d,"Dir. :"
                lda     $c2ca
                jsr     L809B
                lda     $c2c9
                jsr     pchr
                ldy     #$0b
                jsr     yspace
                jsr     vstrng
                .byte   "Lib. :"
                lda     $c2cc
                jsr     L809B
                lda     $c2cb
                jsr     pchr
                jsr     LA7DD
                ldy     #$00
@L8527:         cpy     $c105
                bcs     L8543
                lda     $c00f,Y
                eor     $c2c9
                and     #$5f
                bne     @L853E
                lda     $c00f,Y
                and     #$80
                sta     $c00f,Y
@L853E:         jsr     iny8
                bcc     @L8527
L8543:          ldy     #$00
                jsr     L8555
                bcc     L8560
                lda     #$ff
                sta     $c282
                jmp     LA7DD

L8552:          jsr     iny8
L8555:          cpy     $c105
                bcs     rts855F
                lda     $c008,Y
                bmi     L8552
rts855F:        rts

L8560:          sty     $ab
                ldx     #$00
@L8564:         lda     $c008,Y
                jsr     L8306
                sta     WKSP261_TransAddr-1,X
                iny
                inx
                cpx     #$08
                bne     @L8564
@L8573:         jsr     L8555
                bcs     @L859B
                sec
                ldx     #$06
@L857B:         lda     $c00e,Y
                jsr     L8306
                sbc     WKSP261_TransAddr-1,X
                dey
                dex
                bpl     @L857B
                jsr     iny7
                lda     $c00f,Y
                jsr     L8306
                sbc     $c267
                bcc     L8560
                jsr     iny8
                bcs     @L8573
@L859B:         ldy     $ab
                lda     $c008,Y
                ora     #$80
                sta     $c008,Y
                lda     $c267
                cmp     $aa
                beq     @L85BC
                ldx     $aa
                sta     $aa
                bne     @L85BC
                jsr     LA7DD
@L85B5:         jsr     LA7DD
                ldy     #$ff
                bne     @L85C5

@L85BC:         ldy     $a8
                bne     @L85B5
                ldy     #$05
                jsr     yspace
@L85C5:         iny
                sty     $a8
                ldy     $ab
                jsr     LADCF
                jsr     prtnam
                jmp     L8543

aoff:           .asciiz "off"
aLOADRUNEXEC:   .asciiz "LOADRUN"
                .byte   "EXEC"

L85E3:          lda     $c10e,Y
                jsr     L81B0
                sta     $c2
                clc
                lda     #$ff
                adc     $c10c,Y
                lda     $c10f,Y
                adc     $c10d,Y
                sta     $c3
                lda     $c10e,Y
                and     #$03
                adc     $c2
                sta     $c2
L8602:          sec
                lda     $c107,Y
                sbc     $c3
                pha
                lda     $c106,Y
                and     #$03
                sbc     $c2
                tax
                lda     #$00
                cmp     $c0
                pla
                sbc     $c1
                txa
                sbc     $c4
ServNul:        rts

comTab:         .byte   "ACCESS"
                .dbyt   cmd_access-1
                .byte   $32
                .byte   "BACKUP"
                .dbyt   cmd_backup-1
                .byte   $04
                .byte   "COMPACT"
                .dbyt   cmd_compact-1
                .byte   $07
                .byte   "COPY"
                .dbyt   cmd_copy-1
                .byte   $24
                .byte   "DESTROY"
                .dbyt   cmd_destroy-1
                .byte   $02
                .byte   "DIR"
                .dbyt   cmd_dir-1
                .byte   $06
                .byte   "DRIVE"
                .dbyt   cmd_drive-1
                .byte   $09
                .byte   "ENABLE"
                .dbyt   cmd_enable-1
                .byte   $00
                .byte   "FORM"
                .dbyt   cmd_form-1
                .byte   $ba
                .byte   "FREE"
                .dbyt   cmd_free-1
                .byte   $07
                .byte   "LIB"
                .dbyt   cmd_lib-1
                .byte   $06
                .byte   "MAP"
                .dbyt   cmd_map-1
                .byte   $07
                .byte   "RENAME"
                .dbyt   cmd_rename-1
                .byte   $05
                .byte   "TITLE"
                .dbyt   cmd_title-1
                .byte   $08
                .byte   "VERIFY"
                .dbyt   cmd_verify-1
                .byte   $0b
                .byte   "WIPE"
                .dbyt   cmd_wipe-1
                .byte   $02
                .dbyt   cmd_run-1
                .byte   "DISC"
                .dbyt   cmd_disk-1
                .byte   $00
                .byte   "DISK"
                .dbyt   cmd_disk-1
                .byte   $00
                .dbyt   ServNul-1
                .byte   "DFS"
                .dbyt   cmd_dfs-1
                .byte   $00
                .dbyt   cmd_q-1

                jsr     L86FC
                ldx     #$fd
L86BA:          tya
                pha
@L86BC:         inx
                inx
                pla
                pha
                tay
                jsr     L8703
                inx
                lda     comTab,X
                bmi     @L86F2
                dex
                dey
                stx     $bf
@L86CE:         inx
                iny
                lda     comTab,X
                bmi     @L86EB
                eor     ($f2),Y
                and     #$5f
                beq     @L86CE
                dex
@L86DC:         inx
                lda     comTab,X
                bpl     @L86DC
                lda     ($f2),Y
                cmp     #$2e
                bne     @L86BC
                iny
                bcs     @L86F2
@L86EB:         lda     ($f2),Y
                jsr     L832F
                bcc     @L86BC
@L86F2:         pla
                lda     comTab,X
                pha
                lda     comTab+1,X
                pha
                rts

L86FC:          stx     $f2
                sty     $f3
                ldy     #$00
                rts

L8703:          clc
                jmp     $ffc2

cmd_wipe:       jsr     LA4A7
                jsr     L9F15
                jsr     L821C
@L8710:         lda     $c00f,Y
                bmi     @L8733
                jsr     prtnam
                jsr     LA7E5
                bne     @L8730
                ldx     $b6
                jsr     L9638
                stx     $b6
                jsr     L879A
                sty     $ab
                jsr     L942B
                lda     $ab
                sta     $b6
@L8730:         jsr     LA7DD
@L8733:         jsr     L828A
                bcs     @L8710
                rts

                jsr     LA49E
                jsr     L9F15
                jsr     L821C
                jsr     L833D
                jsr     L8312
                jmp     L942B

cmd_destroy:    jsr     LA719
                jsr     LA4A7
                jsr     L9F15
                jsr     L821C
@L8757:         lda     $c00f,Y
                bmi     @L8762
                jsr     prtnam
                jsr     LA7DD
@L8762:         jsr     L828A
                bcs     @L8757
                jsr     LA7ED
                beq     @L876F
                jmp     LA7DD

@L876F:         jsr     L9638
                jsr     lookup
@L8775:         lda     $c00f,Y
                bmi     @L877D
                jsr     L879A
@L877D:         jsr     L828A
                bcs     @L8775
                jsr     L942B
                jsr     vstrng
                ora     $6544
                jmp     ($7465)

                .byte   $65
                .byte   $64
                .byte   $0d

iny8:           iny
iny7:           iny
                iny
                iny
                iny
                iny
                iny
                iny
                rts

L879A:          jsr     L8312
                ldy     $b6
                jsr     L82BA
                sty     $b6
                rts

cmd_drive:      jsr     L9F15
                jsr     L8B62
                sta     $c2ca
                jsr     L8458
                beq     @L87CC
                cmp     #$28
                beq     @L87BF
                cmp     #$50
                clc
                beq     @L87BF
                jmp     L9F1A

@L87BF:         php
                ldx     $c2ca
                lda     $c2de,X
                rol     A
                plp
                ror     A
                sta     $c2de,X
@L87CC:         rts

L87CD:          and     #$03
                sta     $cd
                rts

                jsr     L8221
                jsr     LA57D
                jsr     L838E
                lda     #$80
L87DD:          sta     $c296
                sty     $ba
                ldx     #$00
                lda     $be
                bne     @L87EE
                iny
                iny
                ldx     #$02
                bne     @L87F6

@L87EE:         lda     $c10e,Y
                sta     $c2
                jsr     L8B24
@L87F6:         lda     $c108,Y
                sta     $bc,X
                iny
                inx
                cpx     #$08
                bne     @L87F6
                jsr     L8B3B
                ldy     $ba
                jsr     L833D
                jmp     L881E

L880C:          lda     #$80
                bne     L881B

                jsr     L8A4E
                jsr     LA57D
                jsr     L838E
L8819:          lda     #$a0
L881B:          sta     $c296
L881E:          stz     $b2
L8820:          jsr     L81C9
                jsr     L948C
                lda     #$01
                rts

                jsr     L86FC
cmd_run:        jsr     @L884B
                bcs     @L887F
                lda     #$0b
                jmp     jmpIndFSCV

                jsr     L86FC
                jsr     @L884B
                bcs     @L887F
                jsr     brk_with_prefix_bad
                inc     $6f63,X
                adc     $616d
                ror     $2064
                brk

@L884B:         jsr     @L890B
                sty     $c2da
                jsr     L80F3
                sty     $c2d9
                jsr     L8270
                bcs     @L887E
                ldy     $c2da
                lda     $c2cb
                sta     $cc
                lda     $c2cc
                jsr     L87CD
                jsr     L80F6
                jsr     L8270
                bcs     @L887E
                lda     $f2
                adc     $c2da
                tax
                ldy     $f3
                bcc     @L887D
                iny
@L887D:         clc
@L887E:         rts

@L887F:         lda     $c10e,Y
                jsr     isoexe
                cmp     #$03
                bne     @L88CD
                lda     $c10a,Y
                and     $c10b,Y
                cmp     #$ff
                bne     @L88CD
                ldx     #$06
@L8895:         lda     $c200,X
                sta     $c207,X
                dex
                bpl     @L8895
                lda     #$0d
                sta     $c20e
                lda     #$45
                sta     $c200
                lda     #$2e
                sta     $c201
                lda     #$3a
                sta     $c202
                lda     $cd
                ora     #$30
                sta     $c203
                lda     #$2e
                sta     $c204
                sta     $c206
                lda     $cc
                sta     $c205
                ldx     #$00
                ldy     #$c2
                jmp     $fff7

@L88CD:         lda     #$81
                jsr     L87DD
                clc
                lda     $c2d9
                tay
                adc     $f2
                sta     $c2d9
                lda     $f3
                adc     #$00
                sta     $c2da
                lda     $c276
                and     $c277
                ora     WKSP2D6_TubePresentIf0
                cmp     #$ff
                beq     @L8906
                lda     $be
                sta     $c274
                lda     $bf
                sta     $c275
                jsr     TUBE_CLAIM
                ldx     #$74
                ldy     #$c2
                lda     #$04
                jmp     TubeCode

@L8906:         lda     #$01
                jmp     ($00be)

@L890B:         lda     #$ff
                sta     $be
                lda     $f2
                sta     $ba
                lda     $f3
                sta     $bb
                rts

cmd_dir:        ldx     #$00
                beq     L891E

cmd_lib:        ldx     #$02
L891E:          jsr     L8950
                sta     $c2ca,X
                lda     $cc
                sta     $c2c9,X
                rts

L892A:          jsr     savita
                lda     $b0
                pha
                lda     $b1
                pha
                jsr     LA5AE
                ldy     #$00
@L8938:         cpy     #$c0
                bcc     @L8941
                lda     $c200,Y
                bcs     @L8944

@L8941:         lda     $c300,Y
@L8944:         sta     ($b0),Y
                iny
                bne     @L8938
                pla
                sta     $b1
                pla
                sta     $b0
                rts

L8950:          lda     $c2c9
                sta     $cc
                jsr     L8703
                bne     L8961
                lda     #$00
                jsr     L87CD
                beq     L898B
L8961:          lda     $c2ca
                jsr     L87CD
@L8967:         jsr     L8149
                bcs     @L897C
                cmp     #$3a
                bne     @L8984
                jsr     L8B62
                jsr     L8149
                bcs     L898B
                cmp     #$2e
                beq     @L8967
@L897C:         jsr     brk_with_prefix_bad
                dec     $6964
                adc     ($00)
@L8984:         sta     $cc
                jsr     L8149
                bcc     @L897C
L898B:          lda     $cd
                rts

cmd_title:      jsr     L9F15
                jsr     L8B52
                jsr     L8388
                ldx     #$0b
                lda     #$00
@L899B:         jsr     L89B1
                dex
                .byte   $10
                plx
@L89A1:         inx
                jsr     L8149
                bcs     L89AE
                jsr     L89B1
                cpx     #$0b
                bcc     @L89A1
L89AE:          jmp     L942B

L89B1:          cpx     #$08
                bcc     @L89B9
                sta     $c0f8,X
                rts

@L89B9:         sta     $c000,X
                rts

cmd_access:     jsr     LA4A7
                jsr     L9F15
                jsr     L80ED
                ldx     #$00
                jsr     L8703
                bne     @L89F0
@L89CD:         stx     $aa
                jsr     lookup
                bcs     @L89D7
                jmp     brkNotFound

@L89D7:         jsr     LA55E
                lda     $c00f,Y
                and     #$7f
                ora     $aa
                sta     $c00f,Y
                jsr     L833D
                jsr     L828A
                bcs     @L89D7
                bcc     L89AE

@L89EE:         ldx     #$80
@L89F0:         jsr     L8149
                bcs     @L89CD
                and     #$5f
                cmp     #$4c
                beq     @L89EE
                jsr     brk_with_prefix_bad
                .byte   $cf
                .asciiz "attribute"
                jsr     savita
                txa
                cmp     #$04
                beq     @L8A2B
                cmp     #$02
                bcc     @L8A20
                jsr     brk_with_prefix_bad
                .byte   $cb
                .byte   "option"
                .byte   $00

@L8A20:         ldx     #$ff
                tya
                beq     @L8A27
                ldx     #$00
@L8A27:         stx     $c2c6
                rts

@L8A2B:         tya
                pha
                jsr     L8B52
                jsr     L9451
                pla
                jsr     L81C4
                eor     $c106
                and     #$30
                eor     $c106
                sta     $c106
                jmp     L942B

L8A45:          jsr     brk_with_prefix_disc
                dec     $66
                adc     $6c,X
                .byte   $6c,$00

L8A4E:          jsr     L80F3
                jsr     lookup
                bcc     @L8A59
                jsr     L8312
@L8A59:         lda     $c0
                pha
                lda     $c1
                pha
                sec
                lda     $c2
                sbc     $c0
                sta     $c0
                lda     $c3
                sbc     $c1
                sta     $c1
                lda     $c27a
                sbc     $c278
                sta     $c4
                jsr     L8A8A
                lda     $c279
                sta     $c275
                lda     $c278
                sta     $c274
                pla
                sta     $bd
                pla
                sta     $bc
                rts

L8A8A:          lda     #$00
                sta     $c2
                lda     #$02
                sta     $c3
                ldy     $c105
                cpy     #$f8
                bcs     @L8AEF
                jsr     L8602
                jmp     @L8AA7

@L8A9F:         beq     L8A45
                jsr     L82BA
                jsr     L85E3
@L8AA7:         tya
                bcc     @L8A9F
                sty     $b0
                ldy     $c105
@L8AAF:         cpy     $b0
                beq     @L8AC2
                lda     $c007,Y
                sta     $c00f,Y
                lda     $c107,Y
                sta     $c10f,Y
                dey
                bcs     @L8AAF
@L8AC2:         ldx     #$00
                jsr     @L8AFC
@L8AC7:         lda     $c5,X
                sta     $c008,Y
                iny
                inx
                cpx     #$08
                bne     @L8AC7
@L8AD2:         lda     $bb,X
                dey
                sta     $c108,Y
                dex
                bne     @L8AD2
                jsr     L833D
                tya
                pha
                ldy     $c105
                jsr     iny8
                sty     $c105
                jsr     L942B
                pla
                tay
                rts

@L8AEF:         jsr     estrng
                ldx     $6143,Y
                stz     $20,X
                ror     $75
                jmp     ($006c)

@L8AFC:         lda     $c276
                and     #$03
                asl     A
                asl     A
                eor     $c4
                and     #$fc
                eor     $c4
                asl     A
                asl     A
                eor     $c274
                and     #$fc
                eor     $c274
                asl     A
                asl     A
                eor     $c2
                and     #$fc
                eor     $c2
                sta     $c2
                rts

cmd_enable:     lda     #$01
                sta     $c2c7
                rts

L8B24:          lda     #$00
                sta     $c275
                lda     $c2
                jsr     L81B6
                cmp     #$03
                bne     @L8B37
                lda     #$ff
                sta     $c275
@L8B37:         sta     $c274
                rts

L8B3B:          lda     #$00
                sta     $c277
                lda     $c2
                jsr     isoexe
                cmp     #$03
                bne     @L8B4E
                lda     #$ff
                sta     $c277
@L8B4E:         sta     $c276
                rts

L8B52:          lda     $c2c9
                sta     $cc
L8B57:          lda     $c2ca
                jmp     L87CD

L8B5D:          jsr     L8703
                beq     L8B57
L8B62:          jsr     L8149
                bcs     L8B79
                cmp     #$3a
                beq     L8B62
                sec
                sbc     #$30
                bcc     L8B79
                cmp     #$04
                bcs     L8B79
                jsr     L87CD
                clc
                rts

L8B79:          jsr     brk_with_prefix_bad
                cmp     $7264
                adc     #$76
                adc     $00
cmd_rename:     jsr     LA49E
                jsr     L9F15
                jsr     L80ED
                tya
                pha
                jsr     L8224
                jsr     LA55B
                sty     $c4
                pla
                tay
                jsr     L9F15
                lda     $cd
                pha
                jsr     L80ED
                pla
                cmp     $cd
                bne     L8B79
                jsr     lookup
                bcc     @L8BBA
                cpy     $c4
                beq     @L8BBA
                jsr     estrng
                cpy     $45
                sei
                adc     #$73
                stz     $73,X
                brk

@L8BBA:         ldy     $c4
                jsr     iny8
                ldx     #$07
@L8BC1:         lda     $c5,X
                sta     $c007,Y
                dey
                dex
                bpl     @L8BC1
                jmp     L942B

L8BCD:          lda     #$01
                sta     $b2
L8BD1:          cli
                stx     $b0
                sty     $b1
                cld
                jsr     @L8C3A
                lda     $a2
                bne     @L8BE7
                ldy     #$05
                lda     ($b0),Y
                beq     @L8BE7
                jsr     @L8CE9
@L8BE7:         ldy     #$05
                lda     ($b0),Y
                clc
                adc     #$07
                tay
                lda     $a2
                jsr     @L8C2B
                sta     ($b0),Y
                ldx     $a7
                cpx     #$80
                bne     @L8C03
                lda     fdccmd
                and     #$20
                ora     ($b0),Y
@L8C03:         pha
                and     #$df
                cmp     #$18
                bne     @L8C0F
                lda     #$ff
                sta     $c287
@L8C0F:         lda     $cd
                and     #$01
                tay
                lda     $ce
                sta     $c288,Y
                jsr     @L8F42
                bit     $a1
                bpl     @L8C23
                jsr     L8FA3
@L8C23:         jsr     L8F87
                lda     fdcdat
                pla
                rts

@L8C2B:         ldx     #$05
@L8C2D:         cmp     L917E,X
                beq     @L8C36
                dex
                bpl     @L8C2D
                rts

@L8C36:         lda     L9184,X
                rts

@L8C3A:         jsr     L8F67
                jsr     L8FAB
                stz     $a1
                ldy     #$09
@L8C44:         lda     ($b0),Y
                sta     $00aa,Y
                iny
                cpy     #$0c
                bne     @L8C44
                ldy     #$06
                lda     ($b0),Y
                and     #$f0
                cmp     #$a0
                beq     @L8C5A
                cmp     #$f0
@L8C5A:         ror     $a1
                ldy     #$03
                lda     ($b0),Y
                iny
                and     ($b0),Y
                cmp     #$ff
                clc
                beq     @L8C85
                jsr     L8F57
                clc
                bmi     @L8C85
                jsr     TUBE_CLAIM
                lda     $a1
                rol     A
                rol     A
                and     #$01
                eor     #$01
                ldx     $b0
                ldy     $b1
                inx
                bne     @L8C81
                iny
@L8C81:         jsr     TubeCode
                sec
@L8C85:         ror     $a1
                jsr     L8FB8
                lda     ($b0)
                bmi     @L8C92
                and     #$0f
                sta     $cd
@L8C92:         lda     $cd
                and     #$03
                tax
                lda     $c2de,X
                sta     $c28a
                lda     $cd
                ldy     #$0a
                and     #$08
                beq     @L8CA7
                ldy     #$10
@L8CA7:         sty     $a3
                eor     tblDrvCtlQ,X
                sta     $fe24
                lsr     A
                ldx     $c288
                bcs     @L8CB8
                ldx     $c289
@L8CB8:         stz     $a2
                lda     $c287
                bit     $c287
                bcc     @L8CCB
                bpl     @L8CDC
                stz     $c288
                and     #$7f
                bpl     @L8CD2

@L8CCB:         bvc     @L8CDC
                stz     $c289
                and     #$bf
@L8CD2:         sta     $c287
                lda     #$00
                jsr     @L8DE0
                ldx     #$00
@L8CDC:         txa
                sta     $ce
                jsr     @L8F42
@L8CE2:         rts

@L8CE3:         jmp     @L8EC7

@L8CE6:         jmp     @L8DE0

@L8CE9:         jsr     @L8F17
                bne     @L8CE2
                ldy     #$06
                lda     ($b0),Y
                cmp     #$10
                beq     @L8CE2
                cmp     #$c0
                beq     @L8CE3
                cmp     #$e0
                bcs     @L8CE6
                ldy     #$08
                lda     ($b0),Y
                lsr     $b2
                bcs     @L8D62
                ldx     $b5
                beq     @L8D10
                inc     $b3
                bne     @L8D10
                inc     $b4
@L8D10:         jsr     L913E
                sta     $cf
                sbc     $a3
                eor     #$ff
                inc     A
                sta     $a5
                lda     $b4
                bne     @L8D44
                lda     $b3
                beq     @L8D61
                cmp     $a5
                beq     @L8D2A
                bcs     @L8D44
@L8D2A:         sta     $a5
                ldx     $b5
                beq     @L8D44
                stx     $a6
                ror     $a1
                sec
                rol     $a1
                cmp     #$01
                bne     @L8D44
                lda     intnmi+34
                ldx     intnmi+36
                sta     intnmi,X
@L8D44:         lda     $b3
                sec
                sbc     $a5
                sta     $b3
                lda     $b4
                sbc     #$00
                sta     $b4
                jsr     @L8DDC
                bne     @L8D61
                lda     $b3
                ora     $b4
                beq     @L8D61
                jsr     @L8EE4
                beq     @L8D10
@L8D61:         rts

@L8D62:         jsr     L913E
                sta     $cf
                ldy     #$09
                lda     ($b0),Y
                and     #$1f
                beq     @L8D61
                sta     $a5
                bit     $a1
                bvs     @L8DDC
                bit     $c28a
                bvc     @L8DDC
                ldx     #$33
@L8D7C:         lda     intnmi+96,X
                sta     $c200,X
                dex
                bpl     @L8D7C
                jsr     @L8D96
                ldx     #$33
@L8D8A:         lda     $c200,X
                sta     intnmi+96,X
                dex
                bpl     @L8D8A
                lda     $a2
                rts

@L8D96:         stz     $b4
                lda     ($b0),Y
                and     #$e0
                bne     @L8DA0
                lda     #$10
@L8DA0:         asl     A
                rol     $b4
                asl     A
                rol     $b4
                asl     A
                rol     $b4
                sta     $b3
                tax
                beq     @L8DB0
                inc     $b4
@L8DB0:         jsr     L9081
                lda     #$14
                sta     $b7
@L8DB7:         lda     #$e0
                sta     $a2
                sta     fdccmd
@L8DBE:         lda     $a2
                bmi     @L8DBE
                bne     @L8DDB
                lda     $a5
                beq     @L8DD1
                dec     $b7
                bne     @L8DB7
                lda     #$10
                sta     $a2
                rts

@L8DD1:         lda     $b6
                eor     #$fb
                beq     @L8DDB
                lda     #$20
                sta     $a2
@L8DDB:         rts

@L8DDC:         ldy     #$06
                lda     ($b0),Y
@L8DE0:         tay
                pha
                lda     $a4
                lsr     A
                beq     @L8E1F
                bcs     @L8E1F
                pla
                pha
                cmp     #$20
                bcs     @L8E1F
                cmp     #$10
                bcc     @L8E09
                lda     fdcdat
                pha
@L8DF7:         pla
                cmp     fdcsec-1
                beq     @L8E1F
                pha
                lda     #$50
                bcs     @L8E04
                lda     #$70
@L8E04:         jsr     @L8DE0
                bra     @L8DF7

@L8E09:         lda     fdcsec-1
                sta     fdcdat
                lda     #$10
                bra     @L8E15

@L8E13:         lda     #$60
@L8E15:         jsr     @L8DE0
                lda     fdccmd
                bit     #$04
                beq     @L8E13
@L8E1F:         pla
                ldy     #$ff
@L8E22:         iny
                cmp     tblErrTransQ,Y
                bne     @L8E22
                pha
                lda     L9171,Y
                sta     intnmi+5
                ror     $a2
                pla
                bpl     @L8E8A
                sta     $a7
                ldy     #$01
                cmp     #$c0
                beq     @L8E55
                ora     #$04
                bcs     @L8E55
                ldy     $a5
                cmp     #$85
                beq     @L8E4F
                cmp     #$87
                bne     @L8E55
                lda     #$14
                sta     intnmi+67
@L8E4F:         lda     #$80
                sta     $a7
                lda     #$84
@L8E55:         sty     $a5
                sta     fdccmd
                cmp     #$f0
                bcc     @L8E66
                jsr     @L8EB7
                and     #$5c
                sta     $a2
                rts

@L8E66:         lda     $a2
                bmi     @L8E66
                cmp     #$20
                bne     @L8E71
                jsr     @L8EBD
@L8E71:         lda     $a7
                bmi     @L8E87
                cmp     #$20
                bcc     @L8E87
                and     #$03
                cmp     #$02
                bne     @L8E87
                ldy     #$30
@L8E81:         dec     A
                bne     @L8E81
                dey
                bne     @L8E81
@L8E87:         lda     $a2
                rts

@L8E8A:         ldy     #$01
                sty     $a5
                ora     $a4
                sta     $a7
                sta     fdccmd
                tay
                lda     $b2
                lsr     A
                bcs     @L8E66
                cpy     #$20
                bcs     @L8E66
@L8E9F:         lda     $a2
                bpl     @L8EB6
                lda     $ff
                bpl     @L8E9F
                lda     #$40
                sta     intnmi
                stz     $fe24
                lda     $ff
                sta     $c282
                sta     $a2
@L8EB6:         rts

@L8EB7:         lda     fdccmd
                ror     A
                bcc     @L8EB7
@L8EBD:         lda     fdccmd
                ror     A
                bcs     @L8EBD
                lda     fdccmd
                rts

@L8EC7:         lda     #$14
                sta     intnmi+84
                ldx     intnmi+67
@L8ECF:         sbc     #$01
                bne     @L8ECF
                stx     intnmi+67
                lda     #$04
                sta     $a6
                jsr     @L8DDC
                bne     @L8EE3
                dec     $b3
                bne     @L8ECF
@L8EE3:         rts

@L8EE4:         jsr     @L8F04
                bne     @L8F03
                lda     $cd
                and     #$01
                asl     A
                tay
                lda     $ce
                bit     $c28a
                bpl     @L8EF7
                lsr     A
@L8EF7:         cmp     $c28b,Y
                beq     @L8EE4
                cmp     $c28c,Y
                beq     @L8EE4
                lda     #$00
@L8F03:         rts

@L8F04:         bit     $c28a
                bpl     @L8F10
                lda     #$40
                jsr     @L8F12
                bne     @L8F03
@L8F10:         lda     #$50
@L8F12:         inc     $ce
                jmp     @L8DE0

@L8F17:         lda     $cd
                and     #$01
                asl     A
                tax
                ldy     #$07
                lda     ($b0),Y
                jsr     @L8F4B
                bit     $c28a
                bpl     @L8F2A
                asl     A
@L8F2A:         sta     $ce
                tay
                beq     @L8F39
@L8F2F:         sta     fdcdat
                cmp     fdcdat
                bne     @L8F2F
                lda     #$10
@L8F39:         jsr     @L8DE0
                bne     @L8F56
                ldy     #$07
                lda     ($b0),Y
@L8F42:         sta     fdcsec-1
                cmp     fdcsec-1
                bne     @L8F42
                rts

@L8F4B:         jsr     @L8F4F
                inx
@L8F4F:         cmp     $c28b,X
                bcc     @L8F56
                adc     #$00
@L8F56:         rts

L8F57:          lda     #$ea
                ldx     #$00
                ldy     #$ff
                jsr     $fff4
                txa
                eor     #$ff
                sta     WKSP2D6_TubePresentIf0
                rts

L8F67:          ldx     #$02
@L8F69:         lda     $b0,X
                pha
                dex
                bpl     @L8F69
                lda     #$8f
                ldx     #$0c
                ldy     #$ff
                jsr     $fff4
                pla
                sta     $b0
                pla
                sta     $b1
                pla
                sta     $b2
                sty     $a0
                inc     $c2d3
                rts

L8F87:          ldy     $a0
                lda     #$8f
                ldx     #$0b
                jsr     $fff4
                dec     $c2d3
                rts

TUBE_CLAIM:     pha
@tclloop:       lda     #$c1
                jsr     TubeCode
                bcc     @tclloop
                pla
                rts

L8F9E:          jsr     L8F57
                bmi     L8FAA
L8FA3:          pha
                lda     #$81
                jsr     TubeCode
                pla
L8FAA:          rts

L8FAB:          lda     #$a1
                ldx     #$0b
                jsr     $fff4
                tya
                and     #$03
                sta     $a4
                rts

L8FB8:          ldx     #$59
@L8FBA:         lda     @L9011,X
                sta     intnmi,X
                dex
                bpl     @L8FBA
                ldx     #$0b
                bit     $a1
                bvc     @L8FE7
                lda     #$3d
                sta     intnmi+86
                lda     #$06
                bit     $b2
                bmi     @L8FD7
                sta     intnmi+84
@L8FD7:         stz     intnmi+34
                ldx     #$16
@L8FDC:         lda     @L906A,X
                sta     intnmi+56,X
                dex
                bne     @L8FDC
                bra     @L8FF4

@L8FE7:         bit     $b2
                bvc     @L8FF4
                ldy     $c2c2
                lda     $c313,Y
                sta     intnmi+62
@L8FF4:         bit     $a1
                bmi     @L9006
                ldy     #$01
                lda     ($b0),Y
                sta     intnmi+58,X
                iny
                lda     ($b0),Y
                sta     intnmi+59,X
                rts

@L9006:         lda     #$80
                sta     intnmi+71
                lda     #$06
                sta     intnmi+72
                rts

@L9011:         pha
                lda     fdccmd
                and     #$18
                cmp     #$03
                beq     @L904A
                and     #$fc
                bne     @L9023
                dec     $a5
                bne     @L9027
@L9023:         sta     $a2
                pla
                rti

@L9027:         lda     $a5
                cmp     #$01
                bne     @L9037
                lda     $a1
                ror     A
                bcc     @L9037
                lda     #$14
                sta     intnmi+84
@L9037:         inc     $cf
                lda     $cf
@L903B:         sta     fdcsec
                cmp     fdcsec
                bne     @L903B
                lda     $a7
                sta     fdccmd
                pla
                rti

@L904A:         lda     fdcdat
                sta     $ff00
                inc     intnmi+61
                bra     @L9055

@L9055:         sta     sheila_TUBE_R3_data
                inc     intnmi+69
                bne     @L9060
                inc     intnmi+70
@L9060:         dec     $a6
                bne     @L9069
                lda     #$00
                sta     intnmi+67
@L9069:         pla
@L906A:         rti

                lda     sheila_TUBE_R3_data
                bra     @L9076

                stz     fdcdat
                pla
                rti

                .byte   $ea

@L9076:         sta     fdcdat
                inc     intnmi+58
                bne     L9081
                inc     intnmi+59
L9081:          ldx     intnmi+69
                lda     intnmi+70
                pha
                ldy     #$94
L908A:          lda     nmiQ1-1,Y
L908D:          sta     intnmi-1,Y
                dey
                bne     L908A
                pla
                bit     $a1
                bpl     @L90A3
                lda     #$b0
                sta     intnmi+24
                lda     #$06
                sta     intnmi+25
                rts

@L90A3:         stx     intnmi+22
                sta     intnmi+23
                rts

nmiQ1:          pha
                lda     fdccmd
                and     #$1b
                cmp     #$03
                bne     @L90B9
                lda     fdcdat
                bcs     @L90DF
@L90B9:         and     #$fc
                sta     $a2
                pla
                rti

                sta     sheila_TUBE_R3_data
                inc     intnmi+22
                bne     @L90CA
                inc     intnmi+23
@L90CA:         dec     $a6
                bne     @L90DD
                dec     $a7
                bne     @L90DD
                lda     #$77
                dec     $a5
                bne     @L90DA
                lda     #$24
@L90DA:         sta     intnmi+14
@L90DD:         pla
                rti

@L90DF:         cmp     #$fe
                beq     @L90E7
                cmp     #$ce
                bne     @L90DD
@L90E7:         lda     #$32
                bne     @L90DA

                sbc     fdcdat
                sta     $b5
                lda     #$3b
                bne     @L90DA

                lda     #$3f
                bne     @L90DA

                sbc     $cf
                ora     $b5
                sta     $b5
                lda     #$49
                bne     @L90DA

                lda     #$4d
                bne     @L90DA

                lda     $b3
                sta     $a6
                lda     #$55
                bne     @L90DA

                lda     $b4
                sta     $a7
                lda     #$5d
                bne     @L90DA

                cmp     #$fb
                beq     @L911E
                cmp     #$f8
                bne     @L90DD
@L911E:         sta     $b6
                lda     $b5
                bne     @L912A
                inc     $cf
                lda     #$06
                bne     @L90DA

@L912A:         inc     $a5
                lda     #$11
                bne     @L90DA

                lda     #$7b
                bne     @L90DA

                lda     #$7f
                bne     @L90DA

                bne     @L90DD
                lda     #$26
                bne     @L90DA

L913E:          sta     fdcsec
                cmp     fdcsec
                bne     L913E
                rts

                ldx     #$00
                lda     #$5a
@L914B:         sta     fdcsec-1
                cmp     fdcsec-1
                beq     @L9158
                dex
                bne     @L914B
@L9156:         clc
                rts

@L9158:         lda     $fe24
                and     #$03
                beq     @L9156
                rts

tblDrvCtlQ:     .byte   $25
                .byte   $26
                .byte   $35
                .byte   $36
tblErrTransQ:   .byte   $00
                .byte   $10
                .byte   $40
                .byte   $50
                .byte   $70
                .byte   $80
                .byte   $81
                .byte   $83
.macro          HiAscii Arg
                .repeat .strlen(Arg), I
                .byte   .strat(Arg, I) | $80
                .endrep
.endmacro
                HiAscii " !@`p"
L9171:          .res    5,$18
                .byte   $3f
                .byte   $1f
                .byte   $1f
                .byte   $5f
                .byte   $5f
                .byte   $17
                .byte   $1b
                .byte   $5f
L917E:          .byte   $08
                .byte   $10
                .byte   $18
                .byte   $20
                .byte   $40
                .byte   $00
L9184:          .byte   $0e
                .byte   $18
                .byte   $0c
                .byte   $20
                .byte   $12
                .byte   $00
L918A:          .byte   $b2
L918B:          .byte   $91
                .byte   $8e
                .byte   $91
                .byte   $3c
                .byte   $0c
                .byte   $03
                .res    6,$01
                .byte   $16
                .byte   $0c
                .byte   $03
                .byte   $01
                .byte   $ff
                .byte   $01
                .byte   $01
                .byte   $18
                .byte   $04
                .byte   $4e
                .byte   $00
                .byte   $f5
                .byte   $fe
                .byte   $00
                .byte   $00
                .byte   $00
                .byte   $00
                .byte   $f7
                .byte   $4e
                .byte   $00
                .byte   $f5
                .byte   $fb
                .byte   $5a
                .byte   $5a
                .byte   $f7
                .byte   $4e
                .byte   $4e
                .byte   $10
                .byte   $06
                .byte   $00
                .res    6,$01
                .byte   $0b
                .byte   $06
                .byte   $00
                .byte   $01
                .byte   $ff
                .byte   $01
                .byte   $01
                .byte   $13
                .byte   $03
                .byte   $ff
                .byte   $00
                .byte   $00
                .byte   $fe
                .byte   $00
                .byte   $00
                .byte   $00
                .byte   $00
                .byte   $f7
                .byte   $ff
                .byte   $00
                .byte   $00
                HiAscii "{eew"
                .byte   $ff
                .byte   $ff
L91D6:          .byte   $0a
                .byte   $0b
                .byte   $0e
                .byte   $0f
                .byte   $12
                .byte   $13
                .byte   $16
                .byte   $17
                .byte   $1b
                .byte   $1e
                .byte   $1f
                .byte   "#) 0"
L91E5:          HiAscii "  !!"
                .byte   $80
                .byte   $80
                .byte   $81
                .byte   $81
                .byte   $c0
                .byte   $83
                .byte   $83
                .byte   $f0
                .byte   $10
                .byte   $e0
                .byte   $f0

L91F4:          lda     #$ff
                sta     $c282
                stx     $c7
                sty     $c8
                ldy     #$0c
@L91FF:         lda     ($c7),Y
                sta     $00ba,Y
                dey
                bpl     @L91FF
                ldx     #$0c
                lda     $bf
                cmp     #$0a
                bne     @L9211
                ldx     #$0e
@L9211:         lda     $c0
                and     #$3f
                cmp     #$3a
                beq     @L9264
                cmp     #$3d
                beq     @L9284
                cmp     #$35
                bne     @L9224
                jmp     @L929F

@L9224:         cmp     L91D6,X
                beq     @L9230
                dex
                bpl     @L9224
@L922C:         lda     #$fe
                bmi     @L9259

@L9230:         cmp     #$23
                beq     @L9238
                cpx     #$04
                bcs     @L9246
@L9238:         lda     $ba
                bpl     @L923E
                lda     $cd
@L923E:         and     #$03
                tay
                lda     $c2de,Y
                bmi     @L922C
@L9246:         ldy     L91E5,X
                sty     $c0
                cpy     #$f0
                bne     @L9252
                jsr     @L92E2
@L9252:         ldx     #$ba
                ldy     #$00
                jsr     L8BCD
@L9259:         pha
                lda     $bf
                clc
                adc     #$07
                tay
                pla
                sta     ($c7),Y
                rts

@L9264:         jsr     @L92CF
                bcs     @L9270
                lda     $c2
                sta     $c28b,X
                bcc     @L9280

@L9270:         jsr     @L92BE
                bcc     @L929C
                lda     $c2
                ldy     $c2de,X
                bpl     @L927D
                asl     A
@L927D:         sta     $c288,X
@L9280:         lda     #$00
                beq     @L929C

@L9284:         jsr     @L92CF
                bcs     @L928E
                lda     $c28b,X
                bcc     @L929C

@L928E:         jsr     @L92BE
                bcc     @L929C
                lda     $c288,X
                ldy     $c2de,X
                bpl     @L929C
                lsr     A
@L929C:         jmp     @L9259

@L929F:         lda     #$ff
                ldx     #$00
                ldy     $c1
                cpy     #$10
                beq     @L92AF
                cpy     #$18
                bne     @L92BB
                inx
                inx
@L92AF:         lda     $c2
                sta     $c28b,X
                lda     $c3
                sta     $c28c,X
                lda     #$00
@L92BB:         jmp     @L9259

@L92BE:         ldx     #$00
                lda     $c1
                cmp     #$12
                beq     @L92CE
                inx
                cmp     #$1a
                beq     @L92CE
                lda     #$fe
                clc
@L92CE:         rts

@L92CF:         lda     $c1
                and     #$f6
                cmp     #$10
                sec
                bne     @L92E1
                lda     $c1
                lsr     A
                lsr     A
                ora     $c1
                and     #$03
                tax
@L92E1:         rts

@L92E2:         jsr     LA588
                lda     $bb
                sta     $b0
                sta     $b4
                clc
                adc     #$80
                sta     $b2
                lda     $bc
                sta     $b1
                php
                jsr     L8F57
                bmi     @L9302
                lda     $bd
                ora     $be
                cmp     #$ff
                bne     @L9309
@L9302:         lda     $b1
                cmp     $c2cf
                bcs     @L930C
@L9309:         lda     $c2cf
@L930C:         plp
                sta     $b5
                adc     #$00
                sta     $b3
                inc     $b5
                lda     $ba
                bpl     @L931B
                lda     #$00
@L931B:         rol     A
                rol     A
                rol     A
                sta     $c28a
                ldx     #$02
                rol     A
                bmi     @L9328
                ldx     #$00
@L9328:         lda     L918A,X
                sta     $b6
                lda     L918B,X
                sta     $b7
                ldy     #$23
@L9334:         lda     ($b6),Y
                sta     ($b2),Y
                dey
                bpl     @L9334
                iny
                sty     $b6
                lda     $c3
                pha
                and     #$e0
                bne     @L9347
                lda     #$10
@L9347:         asl     A
                rol     $b6
                asl     A
                rol     $b6
                asl     A
                rol     $b6
                ldy     #$0d
                sta     ($b2),Y
                lda     $b6
                iny
                sta     ($b2),Y
                pla
                and     #$1f
                sta     $b9
                lda     $c2
                ldy     #$10
                sta     ($b2),Y
                lda     $c5
                ldy     #$00
                sta     ($b2),Y
                tya
                sta     $b8
                jsr     @L9418
                jsr     L8F57
                bmi     @L93AC
                lda     $bd
                and     $be
                cmp     #$ff
                beq     @L93AC
                lda     #$ff
                sta     $bd
                sta     $be
                jsr     TUBE_CLAIM
                ldx     #$bb
                ldy     #$00
                tya
                jsr     TubeCode
                ldx     $b5
                dex
                stx     $b1
                lda     $b9
                asl     A
                asl     A
                tax
                ldy     #$00
@L939A:         lda     #$07
@L939C:         sbc     #$01
                bne     @L939C
                lda     sheila_TUBE_R3_data
                sta     ($b0),Y
                iny
                dex
                bpl     @L939A
                jsr     L8FA3
@L93AC:         lda     $b5
                sta     $bc
@L93B0:         ldy     #$16
                ldx     #$00
@L93B4:         lda     ($b0,X)
                sta     ($b2),Y
                inc     $b0
                bne     @L93BE
                inc     $b1
@L93BE:         iny
                cpy     #$1a
                bne     @L93B4
                lda     #$01
                sta     $b6
@L93C7:         lda     $b6
                cmp     #$0e
                bne     @L93D2
                jsr     @L93F9
                beq     @L93D5
@L93D2:         jsr     @L9418
@L93D5:         inc     $b6
                lda     $b6
                cmp     #$11
                bne     @L93C7
                inc     $b8
                dec     $b9
                bne     @L93B0
                tay
                lda     #$0e
                bit     $c28a
                bvc     @L93ED
                lda     #$1a
@L93ED:         clc
                adc     $bc
                sbc     $b5
                bcs     @L93F6
                lda     #$01
@L93F6:         sta     ($b2),Y
                tya
@L93F9:         jsr     @L940A
                beq     @L9409
                stx     $b7
                ldx     #$00
@L9402:         jsr     @L941D
                dec     $b7
                bne     @L9402
@L9409:         rts

@L940A:         tay
                lda     ($b2),Y
                tax
                tya
                clc
                adc     #$12
                tay
                lda     ($b2),Y
                cpx     #$00
                rts

@L9418:         jsr     @L940A
                beq     @L942A
@L941D:         ldy     #$00
@L941F:         sta     ($b4),Y
                inc     $b4
                bne     @L9427
                inc     $b5
@L9427:         dex
                bne     @L941F
@L942A:         rts

L942B:          lda     $c104
                clc
                sed
                adc     #$01
                sta     $c104
                cld
                ldy     #$a0
                bne     L9453

L943A:          ldy     #$81
                bne     L9453

L943E:          ldy     #$81
                bne     L9444

L9442:          ldy     #$80
L9444:          bit     fdccmd
                bpl     L9453
                lda     $c282
                cmp     $cd
                bne     L9453
                rts

L9451:          ldy     #$80
L9453:          jsr     L957D
                sty     $c296
                lda     $cd
                sta     $c290
                lda     #$02
                sta     $c299
                lda     #$c0
                sta     $c292
                dec     $c293
                dec     $c294
                jsr     L948A
                lda     $cd
                sta     $c282
                rts

L9477:          bit     $ff
                bpl     L9489
L947B:          jsr     LA5CC
                jsr     do_following_brk
                ora     ($45),Y
                .byte   "scape"
                .byte   $00

L9489:          rts

L948A:          stz     $b2
L948C:          jsr     @L955D
                lda     #$06
                sta     $c29e
                jsr     L9477
@L9497:         lda     $c297
                ldx     $c290
                ldy     $c2de,X
                bpl     @L94A3
                asl     A
@L94A3:         ldy     #$18
                cmp     #$50
                bcs     @L9508
                ldx     #$90
                ldy     #$c2
                jsr     L8BD1
                tay
                beq     L9489
                bmi     L947B
                cmp     #$12
                beq     @L950D
                cmp     #$20
                bne     @L94D4
                lda     $c296
                ror     A
                bcs     L9489
                jsr     do_following_brk
                .byte   $bc
                .asciiz "Execute only"
@L94D4:         cmp     #$18
                bne     @L9503
                lda     $c28a
                cmp     #$04
                bne     @L94F0
                ldx     $c296
                cpx     #$81
                bne     @L94F0
                lda     #$ff
                eor     $c28b
                sta     $c28b
                bcs     @L9503
@L94F0:         ldx     $ce
                beq     @L9503
                rol     A
                and     #$80
                ldx     $c290
                eor     $c2de,X
                sta     $c2de,X
                jsr     @L955D
@L9503:         dec     $c29e
                bne     @L9497
@L9508:         tya
                cmp     #$12
                bne     @L951B
@L950D:         jsr     brk_with_prefix_disc
                .byte   $c9
                .asciiz "read only"
@L951B:         pha
                jsr     brk_with_prefix_disc
                .byte   $00
                nop
                jsr     L804F
                .byte   $c7
                .byte   "fault "

                nop
                pla
                jsr     @L956D
                jsr     L804F
                brk

                .byte   " at :"

                lda     $cd
                jsr     @L9575
                jsr     L804F
                brk

                .byte   $20

                lda     $ce
                bit     $c28a
                bpl     @L954B
                lsr     A
@L954B:         jsr     @L956D
                jsr     L804F
                brk

                .byte   '/'

                lda     $cf
                jsr     @L956D
                jsr     L804F
                .byte   $c7
                .byte   $00

@L955D:         lda     $c296
                cmp     #$a0
                bcc     @L957C
                ldx     $c290
                lda     $c2de,X
                bmi     @L950D
                rts

@L956D:         pha
                jsr     L81BE
                jsr     @L9575
                pla
@L9575:         jsr     L80C8
                sta     $0100,X
                inx
@L957C:         rts

L957D:          ldx     #$0d
                lda     #$00
@L9581:         sta     $c28f,X
                dex
                bne     @L9581
                lda     #$05
                sta     $c295
                rts

                ldx     #$11
                ldy     #$15
L9591:          rts

                jsr     savita
                lda     #$77
                jsr     $fff4
                jmp     Serv10

                lda     #$20
                sta     $c286
L95A2:          lda     #$77
                jsr     $fff4
L95A7:          lda     #$00
@L95A9:         clc
                adc     #$20
                beq     L9591
                tay
                jsr     L95BF
                bne     @L95A9
L95B4:          lda     #$20
                sta     $c286
                tya
                beq     L95A2
                jsr     L9927
L95BF:          pha
                jsr     L98A7
                bcs     @L960B
                lda     $c31b,Y
                eor     #$ff
                and     $c2c0
                sta     $c2c0
                lda     $c317,Y
                and     #$60
                beq     @L960B
                jsr     L9610
                lda     $c317,Y
                and     $c286
                beq     @L9608
                ldx     $c2c3
                lda     $c314,Y
                sta     $c10c,X
                lda     $c315,Y
                sta     $c10d,X
                lda     $c316,Y
                jsr     L81C4
                eor     $c10e,X
                and     #$30
                eor     $c10e,X
                sta     $c10e,X
                jsr     L942B
                ldy     $c2c2
@L9608:         jsr     L99C1
@L960B:         ldx     $c2c5
                pla
                rts

L9610:          jsr     L962B
L9613:          ldx     #$06
@L9615:         lda     $c30c,Y
                sta     $c5,X
                dey
                dey
                dex
                bpl     @L9615
                jsr     L8277
                bcc     L9646
                sty     $c2c3
                ldy     $c2c2
L962A:          rts

L962B:          lda     $c30e,Y
                and     #$7f
                sta     $cc
                lda     $c317,Y
                jmp     L87CD

L9638:          jsr     savita
                lda     $c104
                jsr     L8388
                cmp     $c104
                beq     L962A
L9646:          jsr     brk_with_prefix_disc
                iny
                .asciiz "changed"

my_FINDV:       and     #$c0
                bne     @L965C
                jsr     savita
                jmp     L95B4

@L965C:         jsr     savit
                stx     $ba
                sty     $bb
                sta     $b4
                bit     $b4
                php
                jsr     L80F3
                jsr     LA49E
                jsr     lookup
                bcs     @L9697
                plp
                bvc     @L9679
                lda     #$00
                rts

@L9679:         php
                lda     #$00
                ldx     #$07
@L967E:         sta     $bc,X
                sta     $c274,X
                dex
                bpl     @L967E
                dec     $be
                dec     $bf
                dec     $c276
                dec     $c277
                lda     #$40
                sta     $c3
                jsr     L8A4E
@L9697:         plp
                php
                bvs     @L969E
                jsr     LA54B
@L969E:         jsr     L9764
                bcc     @L96B1
@L96A3:         lda     $c30c,Y
                bpl     L96C8
                plp
                php
                bmi     L96C8
                jsr     L975F
                bcs     @L96A3
@L96B1:         ldy     $c2c2
                bne     L96D1
                jsr     estrng
                .byte   $c0
                .asciiz "Too many open"
L96C8:          jsr     estrng
                .byte   $c2
                .asciiz "Open"

L96D1:          lda     #$08
                sta     $c2c4
@L96D6:         lda     $c008,X
                sta     $c300,Y
                iny
                lda     $c108,X
                sta     $c300,Y
                iny
                inx
                dec     $c2c4
                bne     @L96D6
                ldx     #$10
                lda     #$00
@L96EE:         sta     $c300,Y
                iny
                dex
                bne     @L96EE
                lda     $c2c2
                tay
                jsr     L81BD
                adc     #$c3
                sta     $c313,Y
                lda     $c2c1
                sta     $c31b,Y
                ora     $c2c0
                sta     $c2c0
                lda     $c309,Y
                adc     #$ff
                lda     $c30b,Y
                adc     #$00
                sta     $c319,Y
                lda     $c30d,Y
                ora     #$0f
                adc     #$00
                jsr     L81B0
                sta     $c31a,Y
                plp
                bvc     @L9758
                bmi     @L9734
                lda     #$80
                ora     $c30c,Y
                sta     $c30c,Y
@L9734:         lda     $c309,Y
                sta     $c314,Y
                lda     $c30b,Y
                sta     $c315,Y
                lda     $c30d,Y
                jsr     L81B0
                sta     $c316,Y
@L9749:         lda     $cd
                ora     $c317,Y
                sta     $c317,Y
                tya
                jsr     L81BD
                ora     #$10
                rts

@L9758:         lda     #$20
                sta     $c317,Y
                bne     @L9749

L975F:          txa
                pha
                jmp     L97A3

L9764:          lda     #$00
                sta     $c2c2
                lda     #$08
                sta     $b5
                tya
                tax
                ldy     #$a0
L9771:          sty     $b3
                txa
                pha
                lda     #$08
                sta     $b2
                lda     $b5
                bit     $c2c0
                beq     @L979D
                lda     $c317,Y
                eor     $cd
                and     #$03
                bne     L97A3
@L9789:         lda     $c008,X
                eor     $c300,Y
                and     #$7f
                bne     L97A3
                inx
                iny
                iny
                dec     $b2
                bne     @L9789
                sec
                bcs     L97AD

@L979D:         sty     $c2c2
                sta     $c2c1
L97A3:          sec
                lda     $b3
                sbc     #$20
                sta     $b3
                asl     $b5
                clc
L97AD:          pla
                tax
                ldy     $b3
                lda     $b5
                bcs     @L97B7
                bne     L9771
@L97B7:         rts

L97B8:          jsr     returnWithA0
L97BB:          lda     $c2c0
                pha
                lda     #$00
                sta     $c286
                tya
                bne     @L97CC
                jsr     L95A7
                beq     @L97CF
@L97CC:         jsr     L95B4
@L97CF:         pla
                sta     $c2c0
                rts

returnWithA0:   pha
                txa
                pha
                lda     #$00
                tsx
                sta     $0109,X
                pla
                tax
                pla
                rts

my_ARGSV:       jsr     savita
                cmp     #$ff
                beq     L97B8
                cpy     #$00
                beq     @L9801
                cmp     #$04
                bcs     @L981A
                jsr     returnWithA0
                cmp     #$03
                beq     @L9841
                cmp     #$01
                bne     @L9822
                jsr     L9927
                jmp     L9AC7

@L9801:         cmp     #$02
                bcs     @L981A
                jsr     returnWithA0
                beq     @L981B
                lda     #$ff
                sta     $02,X
                sta     $03,X
                lda     $c2d9
                sta     $00,X
                lda     $c2da
                sta     $01,X
@L981A:         rts

@L981B:         lda     #$04
                tsx
                sta     $0105,X
                rts

@L9822:         jsr     L9927
                sty     $c2c2
                asl     A
                adc     $c2c2
                tay
                lda     $c310,Y
                sta     $00,X
                lda     $c311,Y
                sta     $01,X
                lda     $c312,Y
                sta     $02,X
                lda     #$00
                sta     $03,X
                rts

@L9841:         jsr     L9927
                jsr     gbpb_putbytes
                lda     #$20
                jsr     L99B2
                ldy     $c2c2
                lda     $c314,Y
                cmp     $00,X
                lda     $c315,Y
                sbc     $01,X
                lda     $c316,Y
                sbc     $02,X
                lda     #$00
                sbc     $03,X
                bcs     L988F
                phx
                phy
                ldx     #$fd
@L9868:         lda     $c310,Y
                sta     $c1a7,X
                iny
                inx
                bne     @L9868
                ply
                plx
                jsr     L9AC7
L9877:          ldy     $c2c2
                phy
                ldx     #$fd
@L987D:         lda     $c1a7,X
                sta     $c310,Y
                iny
                inx
                bne     @L987D
                dex
                stx     $c2a6
                ply
                jmp     L9C29

L988F:          lda     $00,X
                sta     $c314,Y
                lda     $01,X
                sta     $c315,Y
                lda     $02,X
                sta     $c316,Y
                jsr     L9AAE
                bcc     @L98A6
                jsr     L9C1B
@L98A6:         rts

L98A7:          pha
                stx     $c2c5
                tya
                and     #$e0
                sta     $c2c2
                beq     @L98C6
                jsr     L81BD
                tay
                lda     #$00
                sec
@L98BA:         ror     A
                dey
                bne     @L98BA
                ldy     $c2c2
                bit     $c2c0
                bne     @L98C9
@L98C6:         pla
                sec
                rts

@L98C9:         pla
                clc
                rts

                pha
                txa
                jmp     L98D3

L98D1:          pha
                tya
L98D3:          cmp     #$10
                bcc     @L98DB
                cmp     #$18
                bcc     @L98DD
@L98DB:         lda     #$08
@L98DD:         jsr     L81C3
                tay
                pla
                rts

L98E3:          lda     #$c6
                jsr     LA5D9
                txa
                beq     @L98F4
                jsr     @L9907
                bne     @L98F4
                lda     #$c6
                bne     @L9900

@L98F4:         lda     #$c7
                jsr     LA5D9
                jsr     @L9907
                bne     @L990F
                lda     #$c7
@L9900:         ldx     #$00
                ldy     #$00
                jmp     $fff4

@L9907:         txa
                tay
                jsr     L98D1
                cpy     $c2c2
@L990F:         rts

                pha
                tya
                pha
                txa
                tay
                jsr     L9927
                jsr     L9AAE
                bne     @L9921
                ldx     #$ff
                bne     @L9923

@L9921:         ldx     #$00
@L9923:         pla
                tay
                pla
L9926:          rts

L9927:          jsr     L98D1
                jsr     L98A7
                bcc     L9926
                jsr     L98E3
                jsr     estrng
                .byte   $de
                .asciiz "Channel"
L993E:          jsr     estrng
                .byte   $df
                .asciiz "EOF"

my_BGETV:       jsr     savit
                jsr     L9927
                jsr     L9AAE
                bne     @L9964
                lda     $c317,Y
                and     #$10
                bne     L993E
                lda     #$10
                jsr     L99B2
                ldx     $c2c5
                lda     #$fe
                sec
                rts

@L9964:         lda     $c317,Y
                bmi     @L9973
                jsr     L962B
                jsr     L99C1
                sec
                jsr     L99C9
@L9973:         lda     $c310,Y
                sta     $ba
                lda     $c313,Y
                sta     $bb
                ldy     #$00
                lda     ($ba),Y
                pha
                ldy     $c2c2
                ldx     $ba
                inx
                txa
                sta     $c310,Y
                bne     @L99A2
                clc
                lda     $c311,Y
                adc     #$01
                sta     $c311,Y
                lda     $c312,Y
                adc     #$00
                sta     $c312,Y
                jsr     L99B7
@L99A2:         clc
                pla
                rts

L99A5:          jsr     L9EBD
                sta     $c31d,Y
                lda     $c3
                sta     $c31c,Y
L99B0:          lda     #$80
L99B2:          ora     $c317,Y
                bne     L99BC
L99B7:          lda     #$7f
L99B9:          and     $c317,Y
L99BC:          sta     $c317,Y
                clc
                rts

L99C1:          lda     $c317,Y
                and     #$40
                beq     L99F8
                clc
L99C9:          php
                inc     $c2dd
                ldy     $c2c2
                lda     #$01
                sta     $c1
                jsr     L9C64
                plp
                bcs     @L99EC
                lda     $c31d,Y
                sta     $c2
                jsr     L8819
                ldy     $c2c2
                lda     #$bf
                jsr     L99B9
                bcc     @L99F2
@L99EC:         jsr     L99A5
                jsr     L880C
@L99F2:         dec     $c2dd
                ldy     $c2c2
L99F8:          rts

gbpb_putbytes:  lda     $c30c,Y
                bmi     @L9A06
                lda     $c30e,Y
                bpl     L99F8
                jmp     LA550

@L9A06:         jsr     estrng
                .byte   $c1
                .asciiz "Read only"
                jsr     savita
                jmp     L9A20

my_BPUTV:       jsr     savita
                jsr     L9927
L9A20:          pha
                jsr     gbpb_putbytes
                jsr     L962B
                tya
                clc
                adc     #$04
                jsr     L9AAF
                bne     L9A96
                jsr     L9613
                ldx     $c2c3
                sec
                lda     $c107,X
                sbc     $c10f,X
                pha
                lda     $c106,X
                sbc     $c10e,X
                and     #$03
                cmp     $c31a,Y
                bne     L9A6A
                pla
                cmp     $c319,Y
                bne     L9A85
                sty     $b4
                sty     $c2c2
L9A56:          jsr     L98E3
                jsr     estrng
                .byte   $bf
                .byte   "Can't extend"
                .byte   $00

L9A6A:          lda     $c31a,Y
                clc
                adc     #$01
                sta     $c31a,Y
                asl     A
                asl     A
                asl     A
                asl     A
                eor     $c10e,X
                and     #$30
                eor     $c10e,X
                sta     $c10e,X
                pla
                lda     #$00
L9A85:          sta     $c10d,X
                sta     $c319,Y
                lda     #$00
                sta     $c10c,X
                jsr     L942B
                ldy     $c2c2
L9A96:          jsr     L9C4B
                lda     $c310,Y
                sta     $ba
                lda     $c313,Y
                sta     $bb
                pla
                ldy     #$00
                sta     ($ba),Y
                ldy     $c2c2
                jmp     L9E58

L9AAE:          tya
L9AAF:          tax
                lda     $c312,Y
                cmp     $c316,X
                bne     @L9AC6
                lda     $c311,Y
                cmp     $c315,X
                bne     @L9AC6
                lda     $c310,Y
                cmp     $c314,X
@L9AC6:         rts

L9AC7:          ldy     #$fc
@L9AC9:         lda     $00,X
                sta     $c1a4,Y
                inx
                iny
                bne     @L9AC9
                lda     #$01
L9AD4:          pha
                ldy     $c2c2
                jsr     L962B
                lda     $c2a3
                beq     @L9AE6
                stz     $c2a3
                sty     $c2a2
@L9AE6:         jsr     L9BEE
                bcs     @L9B63
                jsr     gbpb_putbytes
                jsr     @L9BDB
                bcs     @L9B63
                jsr     L9610
                ldx     $c2c3
                lda     $c107,X
                sec
                sbc     $c10f,X
                sta     $c319,Y
                lda     $c106,X
                sbc     $c10e,X
                and     #$03
                sta     $c31a,Y
                lda     #$00
                sta     $c318,Y
                jsr     @L9BDB
                php
                bcs     @L9B2A
                stz     $c2a0
                lda     $c319,Y
                sta     $c2a1
                lda     $c31a,Y
                sta     $c2a2
                bra     @L9B46

@L9B2A:         clc
                lda     $c2a0
                ora     $c2a1
                beq     @L9B3B
                lda     $c31a,Y
                cmp     $c2a2
                beq     @L9B46
@L9B3B:         lda     #$00
                sta     $c319,Y
                adc     $c2a2
                sta     $c31a,Y
@L9B46:         jsr     L81C4
                eor     $c10e,X
                and     #$30
                eor     $c10e,X
                sta     $c10e,X
                lda     $c319,Y
                sta     $c10d,X
                stz     $c10c,X
                phy
                jsr     L942B
                ply
                plp
@L9B63:         pla
                beq     @L9BDA
                php
                jsr     L9BEE
                bcs     @L9BCE
                jsr     L9C1B
                jsr     L9C4B
                lda     $c310,Y
                jsr     L9C7B
                lda     #$40
                jsr     L99B2
                sec
                lda     $c2a1
                sbc     $c315,Y
                sta     $c1
                lda     $c2a2
                sbc     $c316,Y
                tax
                ora     $c1
                beq     @L9BC0
                txa
                jsr     L81C4
                ora     $c31d,Y
                sta     $c2
                jsr     L9C64
                lda     $c2a0
                beq     @L9BA4
                dec     $c0
@L9BA4:         lda     #$80
                sta     $b2
                lda     #$a0
                sta     $c296
                jsr     L9E9A
                lda     #$00
                jsr     L9C7B
                jsr     L9C0C
                jsr     L99A5
                lda     #$bf
                jsr     L99B9
@L9BC0:         phy
                iny
                iny
                iny
                iny
                jsr     L9C0C
                ply
                lda     #$20
                jsr     L99B2
@L9BCE:         jsr     L9C0C
                jsr     L9C29
                plp
                bcs     @L9BDA
                jmp     L9A56

@L9BDA:         rts

@L9BDB:         lda     $c318,Y
                cmp     $c2a0
                lda     $c319,Y
                sbc     $c2a1
                lda     $c31a,Y
                sbc     $c2a2
                rts

L9BEE:          lda     #$00
                cmp     $c2a3
                bne     @L9C0B
                lda     $c316,Y
                cmp     $c2a2
                bne     @L9C0B
                lda     $c315,Y
                cmp     $c2a1
                bne     @L9C0B
                lda     $c314,Y
                cmp     $c2a0
@L9C0B:         rts

L9C0C:          phy
                ldx     #$fd
@L9C0F:         lda     $c1a3,X
                sta     $c310,Y
                iny
                inx
                bne     @L9C0F
                ply
L9C1A:          rts

L9C1B:          ldx     #$02
                phy
@L9C1E:         lda     $c314,Y
                sta     $c310,Y
                iny
                dex
                bpl     @L9C1E
                ply
L9C29:          lda     #$6f
                jsr     L99B9
                lda     $c30f,Y
                adc     $c311,Y
                tax
                lda     $c30d,Y
                and     #$03
                adc     $c312,Y
                cmp     $c31d,Y
                bne     L9C1A
                txa
                cmp     $c31c,Y
                bne     L9C1A
                jmp     L99B0

L9C4B:          lda     $c317,Y
                bmi     L9C1A
                jsr     L99C1
                lda     $c314,Y
                bne     @L9C60
                jsr     L9AAE
                bne     @L9C60
                jmp     L99A5

@L9C60:         sec
                jmp     L99C9

L9C64:          stz     $bc
                lda     $c313,Y
                sta     $bd
                lda     #$ff
                sta     $c274
                sta     $c275
                stz     $c0
                lda     $c31c,Y
                sta     $c3
                rts

L9C7B:          sta     $ba
                lda     $c313,Y
                sta     $bb
                lda     #$00
@L9C84:         sta     ($ba)
                inc     $ba
                bne     @L9C84
                rts

gbpb_rw_seqptr: jsr     TUBE_RELEASE_QQQ
                ldx     #$03
gbpb_seqptr_loop1:
                lda     $c269,X
                sta     $c2a0,X
                dex
                bpl     gbpb_seqptr_loop1
                ldy     WKSP261_TransAddr-1
                jsr     L9927
                jsr     L962B
                plp
                bcs     @L9CAA
                lda     #$01
                jsr     L9AD4
@L9CAA:         ldx     #$fc
                phy
                clc
@L9CAE:         lda     $c310,Y
                inx
                bne     @L9CB6
                lda     #$00
@L9CB6:         dex
                sta     $c16d,X
                adc     $c169,X
                sta     $c1a4,X
                iny
                inx
                bne     @L9CAE
                ply
                bcc     @L9CCA
                sty     $c2a3
@L9CCA:         sec
                jsr     gbpb_jmpsub
                php
                txa
                jsr     L9AD4
                php
                ldx     #$7c
                sec
@L9CD7:         lda     $c224,X
                pha
                sbc     $c1ed,X
                sta     $48,X
                pla
                sta     $c1ed,X
                lda     $c1e5,X
                sta     $4c,X
                inx
                bpl     @L9CD7
                ldx     #$7c
                sec
@L9CEF:         lda     $c1e9,X
                sbc     $48,X
                sta     $c1e9,X
                inx
                bpl     @L9CEF
                lda     $c310,Y
                beq     @L9D02
                jsr     @L9DD1
@L9D02:         lda     $c5
                ora     $c6
                bne     @L9D0B
                jmp     @L9D9C

@L9D0B:         jsr     L99C1
                jsr     L99B7
                lda     #$00
                sta     $c31c,Y
                sta     $c31d,Y
                pha
                ldx     $c27f
                lda     @L9DCF,X
                sta     $c296
                txa
                bne     @L9D34
                jsr     L9BEE
                bcc     @L9D33
                beq     @L9D33
                pla
                lda     $c4
                pha
                stz     $c4
@L9D33:         inx
@L9D34:         lda     $c4,X
                sta     $c0,X
                lda     $c8,X
                sta     $bc,X
                lda     $ca,X
                sta     $c274,X
                dex
                bpl     @L9D34
                jsr     L9EBD
                lda     #$40
                sta     $b2
                lda     $c6
                jsr     L81C4
                tsb     $c2
                jsr     L9E9A
                phy
                ldx     #$7d
                clc
@L9D59:         lda     $c310,Y
                adc     $47,X
                sta     $c310,Y
                iny
                inx
                bpl     @L9D59
                ply
                jsr     L9E71
                phy
                ldx     #$7c
                clc
@L9D6D:         lda     $4c,X
                adc     $48,X
                stz     $48,X
                sta     $4c,X
                sta     $c1e5,X
                inx
                bpl     @L9D6D
                ply
                lda     $c27f
                beq     @L9D99
                jsr     L99A5
                lda     $c310,Y
                bne     @L9D99
                jsr     L99B7
                tya
                tax
                lda     $c31c,X
                bne     @L9D96
                dec     $c31d,X
@L9D96:         dec     $c31c,X
@L9D99:         pla
                sta     $c4
@L9D9C:         lda     $c4
                beq     @L9DA3
                jsr     @L9DD1
@L9DA3:         plp
                bcs     @L9DA9
                jmp     L9A56

@L9DA9:         ldx     #$fc
                phy
@L9DAC:         lda     $ffcc,X
                sta     $c165,X
                inx
                bne     @L9DAC
                jsr     gbpb_wordB4_word107D
                ldy     #$0c
@L9DBA:         lda     WKSP261_TransAddr-1,Y
                sta     ($b4),Y
                dey
                bpl     @L9DBA
                ply
                plp
                bcs     @L9DCD
                lda     #$10
                jsr     L99B2
                sec
                rts

@L9DCD:         clc
                rts

@L9DCF:         ldy     #$80
@L9DD1:         jsr     L9C4B
                lda     $c313,Y
                sta     $bb
                lda     $c310,Y
                sta     $ba
                phy
                jsr     checkAddrAndClaimTube
                ply
@L9DE3:         ldx     #$00
@L9DE5:         lda     $c4,X
                bne     @L9DF0
                inx
                cpx     #$04
                bcc     @L9DE5
                bra     @L9E2A

@L9DF0:         dec     $c4,X
                dex
                bpl     @L9DF0
                bit     WKSP281_TubeClaimed
                lda     $c27f
                bvs     @L9E09
                bne     @L9E03
                lda     ($c8)
                bra     @L9E0E

@L9E03:         lda     ($ba)
                sta     ($c8)
                bra     @L9E17

@L9E09:         bne     @L9E12
                lda     sheila_TUBE_R3_data
@L9E0E:         sta     ($ba)
                bra     @L9E17

@L9E12:         lda     ($ba)
                sta     sheila_TUBE_R3_data
@L9E17:         ldx     #$7c
@L9E19:         inc     $c1e5,X
                inc     $4c,X
                bne     @L9E23
                inx
                bpl     @L9E19
@L9E23:         jsr     L9E53
                lda     $ba
                bne     @L9DE3
@L9E2A:         phy
                jsr     TUBE_RELEASE_QQQ
                ply
                rts

checkAddrAndClaimTube:
                stz     WKSP281_TubeClaimed
                lda     WKSP261_TransAddr+2
                and     WKSP261_TransAddr+3
                ora     WKSP2D6_TubePresentIf0
                inc     A
                beq     rts9E52
                dec     WKSP281_TubeClaimed
                jsr     TUBE_CLAIM
                lda     $c27f
                ldx     #<WKSP261_TransAddr
                ldy     #>WKSP261_TransAddr
                jsr     TubeCode
                jsr     rts9E52
rts9E52:        rts

L9E53:          lda     $c27f
                bne     L9E5D
L9E58:          lda     #$40
                jsr     L99B2
L9E5D:          tya
                tax
                inc     $ba
                inc     $c310,X
                bne     L9E71
                jsr     L99B7
                inc     $c311,X
                bne     L9E71
                inc     $c312,X
L9E71:          jsr     L9AAE
                bcc     @L9E8B
                beq     @L9E8B
                lda     #$20
                jsr     L99B2
                ldx     #$02
                phy
@L9E80:         lda     $c310,Y
                sta     $c314,Y
                iny
                dex
                bpl     @L9E80
                ply
@L9E8B:         rts

TUBE_RELEASE_QQQ:
                bit     WKSP281_TubeClaimed
                bpl     @L9E99
                phy
                jsr     L8FA3
                stz     WKSP281_TubeClaimed
                ply
@L9E99:         rts

L9E9A:          phy
                inc     $c2dd
                jsr     L8820
                dec     $c2dd
                ply
                rts

gbpb_getbyteSAVEBYTE:
                jsr     L9BEE
                bcs     @L9EBC
                phy
                ldx     #$fd
@L9EAE:         lda     $c314,Y
                sta     $c1a3,X
                iny
                inx
                bne     @L9EAE
                stz     $c2a3
                ply
@L9EBC:         rts

L9EBD:          clc
                lda     $c30f,Y
                adc     $c311,Y
                sta     $c3
                lda     $c30d,Y
                and     #$03
                adc     $c312,Y
                sta     $c2
                rts

cmd_dfs:        tya
                ldx     #$ff
                ldy     #$10
L9ED6:          pha
                jsr     vstrng
                .byte   $0d,"DFS 2.45",$0d
                stx     $bf
                sty     $b7
@L9EE8:         lda     #$00
                sta     $b9
                ldy     #$02
                jsr     L9F91
                jsr     L9F33
                jsr     LA7DD
                dec     $b7
                bne     @L9EE8
                pla
                tay
L9EFD:          ldx     #$8e
                jmp     L86BA

                tya
                ldx     #$80
                ldy     #$01
                bne     L9ED6

cmd_q:          jsr     L8703
                beq     L9F8B
@L9F0E:         jsr     L8149
                bcc     @L9F0E
                bcs     L9EFD

L9F15:          jsr     L8703
                bne     L9F8B
L9F1A:          jsr     do_following_brk
                .byte   $dc
                .byte   "Syntax: "

                stx     $b9
                jsr     L9F33
                lda     #$00
                jsr     L9F7F
                jmp     $0100

L9F33:          ldx     $bf
                lda     #$09
                sta     $b8
@L9F39:         inx
                lda     comTab,X
                bmi     @L9F45
                jsr     L9F7F
                jmp     @L9F39

@L9F45:         ldy     $b8
                cpy     #$0c
                beq     @L9F4E
                jsr     L9F91
@L9F4E:         inx
                inx
                stx     $bf
                lda     comTab,X
                jsr     @L9F5B
                jsr     L81BE
@L9F5B:         jsr     savita
                and     #$0f
                beq     L9F8B
                tay
                lda     #$20
                jsr     L9F7F
                ldx     #$ff
@L9F6A:         inx
                lda     tblHelpTokens,X
                bpl     @L9F6A
                dey
                bne     @L9F6A
                and     #$7f
@L9F75:         jsr     L9F7F
                inx
                lda     tblHelpTokens,X
                bpl     @L9F75
                rts

L9F7F:          jsr     savita
                ldx     $b9
                beq     L9F8C
                inc     $b9
                sta     $0100,X
L9F8B:          rts

L9F8C:          dec     $b8
                jmp     pchr

L9F91:          lda     $b9
                bne     @L9F9D
                lda     #$20
@L9F97:         jsr     L9F7F
                dey
                bne     @L9F97
@L9F9D:         rts

tblHelpTokens:  .byte   $bc
                .byte   "fsp>"
                .byte   $bc
                .byte   "afsp>"
                .byte   $a8
                .byte   "L)"
                .byte   $bc
                .byte   "source> <dest.>"
                .byte   $bc
                .byte   "old fsp> <new fsp>"
                .byte   $a8
                .byte   "<dir>)"
                .byte   $a8
                .byte   "<drive>)"
                .byte   $bc
                .byte   "title>"
                .byte   $bc
                .byte   "drive> (40)(80)"
                .byte   $b4
                .byte   "0/80"
                .byte   $a8
                .byte   "<drive>)..."
                .byte   $a8
                .byte   "<rom>)"
                .byte   $ff
                .byte   "L.!BOOT",$0d,"E.!BOOT",$0d

serv:           bit     swrom_wksp_tab,X
                bpl     @LA027
                bvs     @LA029
                rts

@LA027:         bvs     ret
@LA029:         cmp     #$12
                beq     Serv18
                cmp     #$0b
                bcc     @lt0B
                cmp     #$28
                bcs     ret
                cmp     #$21
                bcc     ret
                sbc     #$16
@lt0B:          asl     A
                tax
                lda     tblServ+1,X
                pha
                lda     tblServ,X
                pha
                txa
                ldx     $f4
                lsr     A
                cmp     #$0b
                bcc     ret
                adc     #$15
ret:            rts

tblServ:        .word   ServNul-1               ;0
                .word   ServNul-1               ;1
                .word   Serv2-1                 ;2
                .word   Serv3-1                 ;3
                .word   Serv4-1                 ;4
                .word   ServNul-1               ;5
                .word   ServNul-1               ;6
                .word   ServNul-1               ;7
                .word   Serv8-1                 ;8
                .word   Serv9-1                 ;9
                .word   Serv10-1                ;10
                .word   Serv21-1                ;21
                .word   Serv22-1                ;22
                .word   ServNul-1               ;23
                .word   Serv24-1                ;24
                .word   Serv25-1                ;25
                .word   Serv26-1                ;26
                .word   Serv27-1                ;27

Serv18:         jsr     savita
                cpy     #$04
                beq     cmd_disk
                rts

Serv3:          jsr     savita
                sty     $b3
                lda     #$7a
                jsr     $fff4
                txa
                bmi     @LA099
                cmp     #$32
                beq     @LA094
                cmp     #$61
                bne     ret
                jsr     LADDB
@LA094:         lda     #$78
                jsr     $fff4
@LA099:         lda     $b3
                jsr     vstrng
                .byte   "Acorn 1770 DFS",$0d,$0d
                bra     LA0B2

cmd_disk:       lda     #$ff
LA0B2:          jsr     returnWithA0
LA0B5:          pha
                lda     #$06
                jsr     jmpIndFSCV
                ldx     #$0d
@LA0BD:         lda     vtabb,X
                sta     $0212,X
                dex
                bpl     @LA0BD
                lda     #$a8
                jsr     LA5D9
                stx     $b0
                sty     $b1
                ldx     #$07
                ldy     #$1b
@LA0D3:         lda     LA5D3,Y
                sta     ($b0),Y
                iny
                lda     LA5D3,Y
                sta     ($b0),Y
                iny
                lda     $f4
                sta     ($b0),Y
                iny
                dex
                bne     @LA0D3
                sty     $c282
                sty     $c283
                stx     $cd
                lda     #$ff
                sta     $c287
                ldy     #$03
@LA0F6:         sta     $c28b,Y
                dey
                bpl     @LA0F6
                ldx     #$0f
                jsr     LA5D3
                jsr     LA5AE
                ldy     #$d3
                lda     ($b0),Y
                bpl     @LA13D
                pla
                pha
                beq     @LA13D
                ldy     #$d4
                lda     ($b0),Y
                bmi     @LA16B
                jsr     LA59E
                ldy     #$00
@LA119:         lda     ($b0),Y
                cpy     #$c0
                bcc     @LA124
                sta     $c200,Y
                bcs     @LA127

@LA124:         sta     $c300,Y
@LA127:         dey
                bne     @LA119
                lda     #$a0
@LA12C:         tay
                pha
                lda     #$3f
                jsr     L99B9
                pla
                sta     $c31d,Y
                sbc     #$1f
                bne     @LA12C
                beq     @LA16B

@LA13D:         jsr     LA59E
                lda     #$24
                sta     $c2c9
                sta     $c2cb
                ldy     #$00
                sty     $c2ca
                sty     $c2cc
                ldy     #$00
                sty     $c2c0
                ldx     #$03
                tya
@LA158:         sta     $c2de,X
                dex
                bne     @LA158
                dey
                sty     $c2c7
                sty     $c2c6
                sty     $c2dd
                sty     $c2a6
@LA16B:         jsr     L8F57
                pla
                bne     @LA18C
                lda     #$04
                ora     $c2de
                sta     $c2de
                jsr     L943A
                lda     #$fb
                and     $c2de
                sta     $c2de
                lda     $c106
                jsr     L81BE
                bne     @LA18D
@LA18C:         rts

@LA18D:         ldy     #$a0
                ldx     #$0f
                cmp     #$02
                bcc     @LA19D
                beq     @LA19B
                ldx     #$17
                bne     @LA19D

@LA19B:         ldx     #$19
@LA19D:         jmp     $fff7

Serv2:          lda     swrom_wksp_tab,X
                cmp     #$dc
                bcc     @LA1AB
                tya
                sta     swrom_wksp_tab,X
@LA1AB:         phy
                sta     $b1
                stz     $b0
                lda     #$fd
                jsr     LA5D9
                dex
                txa
                ldy     #$d3
                and     ($b0),Y
                sta     ($b0),Y
                php
                iny
                plp
                bpl     @LA1C9
                lda     ($b0),Y
                bpl     @LA1C9
                jsr     L892A
@LA1C9:         lda     #$00
                sta     ($b0),Y
                lda     #$02
                ldx     $f4
                ply
                bit     swrom_wksp_tab,X
                bmi     @LA1D8
                iny
@LA1D8:         rts

Serv4:          jsr     savita
                ldx     #$7e
LA1DE:          jmp     L86BA

Serv9:          jsr     savita
                lda     ($f2),Y
                ldx     #$8e
                cmp     #$0d
                bne     LA1DE
                tya
                inx
                inx
                ldy     #$01
                jmp     L9ED6

Serv10:         jsr     LA5AE
                ldy     #$00
                jsr     L97BB
                jsr     L892A
                jsr     LA5AE
                ldy     #$d4
                lda     #$00
                sta     ($b0),Y
                rts

                .byte   $a9
                .byte   $0a

LA20B:          tsx
                sta     $0105,X
                rts

Serv8:          jsr     savita
                jsr     returnWithA0
                ldy     $ef
                bmi     LA20B
                cpy     #$7d
                bcc     LA20B
                tax
                jsr     LA5AE
                ldy     #$d4
                lda     ($b0),Y
                pha
                phx
                pla
                plx
                bpl     LA20B
                ldx     $f0
                stx     $c7
                ldx     $f1
                stx     $c8
                iny
                bpl     @LA23E
                ldx     $c7
                ldy     $c8
                jmp     L91F4

@LA23E:         jsr     L8B52
                jsr     L8388
                iny
                bmi     @LA24F
                ldy     #$00
                lda     $c104
                sta     ($c7),Y
                rts

@LA24F:         lda     #$00
                tay
                sta     ($c7),Y
                iny
                lda     $c107
                sta     ($c7),Y
                iny
                lda     $c106
                and     #$03
                sta     ($c7),Y
                iny
                lda     #$00
                sta     ($c7),Y
                rts

Serv27:         jsr     savita
                jsr     LA5AE
                ldy     #$d4
                lda     ($b0),Y
                bpl     @LA277
                sta     $c282
@LA277:         rts

Serv21:         cpy     #$ca
                bcs     @LA27E
                ldy     #$ca
@LA27E:         rts

Serv22:         tya
                sta     swrom_wksp_tab,X
                lda     #$22
                iny
                rts

Serv24:         dey
                dey
                rts

Serv25:         ldx     #$15
@LA28C:         lda     @LA29A,X
                sta     ($f2),Y
                iny
                dex
                bpl     @LA28C
                lda     #$25
                ldx     $f4
                rts

@LA29A:         .byte   $04
                .byte   $15
                .byte   $11
                .byte   "    CSID"
                .byte   $04
                .byte   $15
                .byte   $11
                .byte   "    KSID"

Serv26:         phy
                jsr     LA5AE
                ldx     $c2c0
                ldy     #$d4
                lda     ($b0),Y
                bmi     @LA2CA
                ldy     #$c0
                lda     ($b0),Y
                and     #$f8
                beq     @LA2CF
                lda     #$ff
                jsr     LA0B5
@LA2CA:         ldy     #$00
                jsr     L95B4
@LA2CF:         ply
                ldx     $f4
                lda     #$26
                rts

myFILEV:        jsr     savit
                pha
                jsr     LA49E
                stx     $b0
                stx     $c2db
                sty     $b1
                sty     $c2dc
                ldx     #$00
                ldy     #$00
                jsr     L80E3
@LA2ED:         jsr     L80D3
                cpy     #$12
                bne     @LA2ED
                pla
                tax
                inx
                cpx     #$09
                bcs     LA303
                lda     LA624,X
                pha
                lda     LA61B,X
                pha
LA303:          lda     #$00
                rts

my_FSCV:        cmp     #$0c
                bcs     LA303
                stx     $b5
                tax
                lda     LA60F,X
                pha
                lda     LA603,X
                pha
                txa
                ldx     $b5
rtsA318:        rts

my_GBPBV:       cmp     #$09                    ;check reason code 
                bcs     rtsA318                 ;if >= 9 exit 
                jsr     savita
                jsr     returnWithA0
                stx     $c27d
                sty     $c27e
                tay
                jsr     gbpb_gosub
                php
                jsr     TUBE_RELEASE_QQQ
                plp
                rts

gbpb_gosub:     lda     gbpbv_table1,Y
                sta     $c2d7
                lda     gbpbv_table2,Y
                sta     $c2d8
                lda     gbpbv_table3,Y          ;3 bit flags: bit 2=tube op
                lsr     A
                php                             ;Save bit 0 (0=write new seq ptr)
                lsr     A
                php                             ;Save bit 1 (1=read/write seq ptr)
                sta     $c27f                   ;save Tube operation
                jsr     gbpb_wordB4_word107D    ;(B4) -> param blk
                ldy     #$0c                    ;MMFSDIF: set in fn above TODO: opt?
gbpb_ctlblk_loop:
                lda     ($b4),Y
                sta     WKSP261_TransAddr-1,Y
                dey
                bpl     gbpb_ctlblk_loop
                jsr     checkAddrAndClaimTube
                plp
                bcs     jgbpb_rw_seqptr
                plp
gbpb_jmpsub:    jmp     ($c2d7)

jgbpb_rw_seqptr:
                jmp     gbpb_rw_seqptr

LA363:          jsr     LA456
                bmi     @LA375
@LA368:         ldy     WKSP261_TransAddr-1
                jsr     gbpb_jmpsub
                bcs     @LA37D
                ldx     #$09
                jsr     LA44A
@LA375:         ldx     #$05
                jsr     LA44A
                bne     @LA368
                clc
@LA37D:         php
                jsr     LA456
                ldx     #$05
                jsr     LA44A
                ldy     #$0c
                jsr     gbpb_wordB4_word107D
@LA38B:         lda     WKSP261_TransAddr-1,Y
                sta     ($b4),Y
                dey
                bpl     @LA38B
                plp
                rts

gbpb_rdfiles_curdir:
                jsr     L8B52
                jsr     L9442
                lda     #$a7
                sta     $c2d7
                lda     #$a3
                sta     $c2d8
                bne     LA363

                ldy     $c269
@LA3AA:         cpy     $c105
                bcs     @LA3D7
                lda     $c00f,Y
                jsr     L832F
                eor     $cc
                bcs     @LA3BB
                and     #$df
@LA3BB:         and     #$7f
                beq     @LA3C4
                jsr     iny8
                bne     @LA3AA
@LA3C4:         lda     #$07
                jsr     LA471
                sta     $b0
@LA3CB:         lda     $c008,Y
                jsr     LA471
                iny
                dec     $b0
                bne     @LA3CB
                clc
@LA3D7:         sty     $c269
                lda     $c104
                sta     WKSP261_TransAddr-1
                rts

gbpb_getmediatitle:
                jsr     L8B52
                jsr     L9442
                lda     #$0c
                jsr     LA471
                ldy     #$00
@LA3EE:         cpy     #$08
                bcs     @LA3F7
                lda     $c000,Y
                bcc     @LA3FA

@LA3F7:         lda     $c0f8,Y
@LA3FA:         jsr     LA471
                iny
                cpy     #$0c
                bne     @LA3EE
                lda     $c106
                jsr     L81BE
                jsr     LA471
                lda     $cd
                jmp     LA471

gbpb_rdcurdirdevice:
                jsr     LA46F
                lda     $c2ca
                ora     #$30
                jsr     LA471
                jsr     LA46F
                lda     $c2c9
                bne     LA471
gbpb_rdcurlibdevice:
                jsr     LA46F
                lda     $c2cc
                ora     #$30
                jsr     LA471
                jsr     LA46F
                lda     $c2cb
                bne     LA471
LA436:          pha
                lda     WKSP261_TransAddr
                sta     $b8
                lda     WKSP261_TransAddr+1
                sta     $b9
                ldx     #$00
                pla
                rts

LA445:          jsr     savita
                ldx     #$01
LA44A:          ldy     #$04
@LA44C:         inc     WKSP261_TransAddr-1,X
                bne     @LA455
                inx
                dey
                bne     @LA44C
@LA455:         rts

LA456:          ldx     #$03
@LA458:         lda     #$ff
                eor     $c265,X
                sta     $c265,X
                dex
                bpl     @LA458
                rts

gbpb_wordB4_word107D:
                lda     $c27d
                sta     $b4
                lda     $c27e
                sta     $b5
                rts

LA46F:          lda     #$01
LA471:          bit     WKSP281_TubeClaimed
                bpl     @LA47B
                sta     sheila_TUBE_R3_data
                bmi     LA445

@LA47B:         jsr     LA436
                sta     ($b8,X)
                jmp     LA445

                bit     WKSP281_TubeClaimed
                bpl     @LA48E
                lda     sheila_TUBE_R3_data
                jmp     LA445

@LA48E:         jsr     LA436
                lda     ($b8,X)
                jmp     LA445

                bit     $c2c7
                bmi     LA49E
                dec     $c2c7
LA49E:          lda     #$ff
                sta     $c2ce
LA4A3:          sta     $c2cd
                rts

LA4A7:          lda     #$2a
                sta     $c2ce
                lda     #$23
                bne     LA4A3

                jsr     LA569
                jsr     L838E
                lda     #$01
                rts

                jsr     LA546
                jsr     L838E
                jsr     L8312
                bcc     @LA4E8
                jsr     LA569
                jsr     @LA4EE
                jsr     @LA50A
                bvc     @LA4E5
                jsr     LA569
                jsr     @LA50A
                bvc     @LA4E8
                jsr     LA569
                jsr     @LA4EE
                bvc     @LA4E8
                jsr     LA569
                jsr     LA55E
@LA4E5:         jsr     LA52D
@LA4E8:         jsr     L89AE
                lda     #$01
                rts

@LA4EE:         jsr     savita
                ldy     #$02
                lda     ($b0),Y
                sta     $c108,X
                iny
                lda     ($b0),Y
                sta     $c109,X
                iny
                lda     ($b0),Y
                asl     A
                asl     A
                eor     $c10e,X
                and     #$0c
                bpl     LA525

@LA50A:         jsr     savita
                ldy     #$06
                lda     ($b0),Y
                sta     $c10a,X
                iny
                lda     ($b0),Y
                sta     $c10b,X
                iny
                lda     ($b0),Y
                ror     A
                ror     A
                ror     A
LA520:          eor     $c10e,X
                and     #$c0
LA525:          eor     $c10e,X
                sta     $c10e,X
                clv
                rts

LA52D:          jsr     savita
                ldy     #$0e
                lda     ($b0),Y
                and     #$0a
                beq     @LA53A
                lda     #$80
@LA53A:         eor     $c00f,X
                and     #$80
                eor     $c00f,X
                sta     $c00f,X
                rts

LA546:          jsr     LA573
                bcc     LA56E
LA54B:          lda     $c00f,Y
                bpl     LA572
LA550:          jsr     estrng
                .byte   $c3
                .byte   "Locked"
                .byte   $00

LA55B:          jsr     LA54B
LA55E:          jsr     savita
                jsr     L9764
                bcc     LA587
                jmp     L96C8

LA569:          jsr     LA573
                bcs     LA587
LA56E:          pla
                pla
                lda     #$00
LA572:          rts

LA573:          jsr     L80F3
                jsr     lookup
                bcc     LA587
                tya
                tax
LA57D:          lda     $c2db
                sta     $b0
                lda     $c2dc
                sta     $b1
LA587:          rts

LA588:          lda     #$83
                jsr     $fff4
                sty     $c2cf
                lda     #$84
                jsr     $fff4
                tya
                sec
                sbc     $c2cf
                sta     $c2d0
                rts

LA59E:          jsr     LA5AE
                ldy     #$d3
                lda     #$ff
                sta     ($b0),Y
                sta     $c2d3
                iny
                sta     ($b0),Y
                rts

LA5AE:          pha
                lda     #$00
                sta     $b0
                ldx     $f4
                lda     swrom_wksp_tab,X
                sta     $b1
                pla
                rts

LA5BC:          jsr     savita
                lda     #$0f
                ldx     #$01
                ldy     #$00
                beq     LA5DD

LA5C7:          tax
LA5C8:          lda     #$03
                bne     LA5DD

LA5CC:          jsr     savita
                lda     #$7e
                bne     LA5DD

LA5D3:          lda     #$8f
                bne     LA5DD

                .byte   $a9
                .byte   $ff

LA5D9:          ldx     #$00
                ldy     #$ff
LA5DD:          jmp     $fff4

vtabb:          .word   $ff1b
                .word   $ff1e
                .word   $ff21
                .word   $ff24
                .word   $ff27
                .word   $ff2a
                .word   $ff2d
vtabf:          .word   myFILEV
                .byte   $00
                .word   my_ARGSV
                .byte   $00
                .word   my_BGETV
                .byte   $00
                .word   my_BPUTV
                .byte   $00
                .word   my_GBPBV
                .byte   $00
                .word   my_FINDV
                .byte   $00
                .word   my_FSCV
                .byte   $00
LA603:          .byte   $08
                .byte   $0f
                .byte   $28
                .byte   $b4
                .byte   $28
                .byte   $82
                .byte   $91
                .byte   $8c
                .byte   $95
                .byte   $36
                .byte   $55
                .byte   $35
LA60F:          .byte   $8a
                .byte   $99
                .byte   $88
                .byte   $86
                .byte   $88
                .byte   $84
                .byte   $95
                .byte   $95
                .byte   $a4
                .byte   $82
                .byte   $82
                .byte   $88
LA61B:          .byte   $d1
                .byte   $0f
                HiAscii "CVN^/8"
                .byte   $4d
LA624:          .byte   $87
                .byte   $88
                .byte   $a4,$a4,$a4,$a4,$a4,$a4,$8a
gbpbv_table1:   .byte   <ServNul
                .byte   <gbpb_putbytes
                .byte   <gbpb_putbytes
                .byte   <gbpb_getbyteSAVEBYTE
                .byte   <gbpb_getbyteSAVEBYTE
                .byte   <gbpb_getmediatitle
                .byte   <gbpb_rdcurdirdevice
                .byte   <gbpb_rdcurlibdevice
                .byte   <gbpb_rdfiles_curdir
gbpbv_table2:   .byte   >ServNul
                .byte   >gbpb_putbytes
                .byte   >gbpb_putbytes
                .byte   >gbpb_getbyteSAVEBYTE
                .byte   >gbpb_getbyteSAVEBYTE
                .byte   >gbpb_getmediatitle
                .byte   >gbpb_rdcurdirdevice
                .byte   >gbpb_rdcurlibdevice
                .byte   >gbpb_rdfiles_curdir
; following table:
; bit     descr
; 3       "flags"
; 2       Tube operation
; 1       read/write seq ptr
; 0       write new seq ptr after
gbpbv_table3:   .byte   $04
                .byte   $02
                .byte   $03
                .byte   $06
                .byte   $07
                .byte   $04
                .byte   $04
                .byte   $04
                .byte   $04

cmd_compact:    jsr     L8B5D
                jsr     vstrng
                .byte   "Compacting :"

                sta     $c2d1
                sta     $c2d2
                jsr     L80C3
                jsr     LA7DD
LA666:          ldy     #$00
                jsr     L95BF
                jsr     LA588
                jsr     L8388
                ldy     $c105
                sty     $ca
                lda     #$02
                sta     $c8
                lda     #$00
                sta     $c9
@LA67E:         ldy     $ca
                jsr     L82BA
                cpy     #$f8
                bne     @LA6AF
                lda     $c107
                sec
                sbc     $c8
                pha
                lda     $c106
                and     #$03
                sbc     $c9
                jsr     L80C3
                pla
                jsr     L80BB
                jsr     vstrng
                jsr     $7266
                adc     $65
                jsr     $6573
                .byte   "ctors",$0d
                .byte   $ea
                .byte   $60

@LA6AF:         sty     $ca
                jsr     L833D
                ldy     $ca
                lda     $c10c,Y
                cmp     #$01
                lda     #$00
                sta     $bc
                sta     $c0
                adc     $c10d,Y
                sta     $c4
                lda     $c10e,Y
                php
                jsr     L81B0
                plp
                adc     #$00
                sta     $c5
                lda     $c10f,Y
                sta     $c6
                lda     $c10e,Y
                and     #$03
                sta     $c7
                cmp     $c9
                bne     @LA6F6
                lda     $c6
                cmp     $c8
                bne     @LA6F6
                clc
                adc     $c4
                sta     $c8
                lda     $c9
                adc     $c5
                sta     $c9
                jmp     @LA711

@LA6F6:         lda     $c8
                sta     $c10f,Y
                lda     $c10e,Y
                and     #$fc
                ora     $c9
                sta     $c10e,Y
                lda     #$00
                sta     $a8
                sta     $a9
                jsr     LA931
                jsr     L942B
@LA711:         ldy     $ca
                jsr     L8342
                jmp     @LA67E

LA719:          bit     $c2c7
                bpl     LA779
                jsr     LA7ED
                beq     @LA725
                pla
                pla
@LA725:         jmp     LA7DD

LA728:          jsr     L9F15
                jsr     L8B62
                sta     $c2d1
                jsr     L9F15
                jsr     L8B62
                sta     $c2d2
                phy
                stz     $a9
                lda     $c2d2
                cmp     $c2d1
                bne     @LA74B
                lda     #$ff
                sta     $a9
                sta     $aa
@LA74B:         jsr     LA588
                jsr     vstrng
                .byte   "Copying from :"
                .byte   $ad
                .byte   $d1
                .byte   $c2
                .byte   $20
                .byte   $c3
                .byte   $80
                .byte   $20
                .byte   $7f
                .byte   $80
                .byte   " to :"
                .byte   $ad
                .byte   $d2
                .byte   $c2
                .byte   $20
                .byte   $c3
                .byte   $80
                .byte   $20
                .byte   $dd
                .byte   $a7
                .byte   $68
                .byte   $a8
                .byte   $18

LA779:          rts

LA77A:          jsr     savita
                bit     $a9
                bpl     LA78C
                lda     #$00
                bra     LA78F

LA785:          jsr     savita
                bit     $a9
                bmi     LA78D
LA78C:          rts

LA78D:          lda     #$80
LA78F:          cmp     $aa
                beq     LA78C
                sta     $aa
                jsr     vstrng
                eor     #$6e
                .byte   "sert "
                .byte   $ea
                .byte   $24
                .byte   $aa
                .byte   $30
                .byte   $0b
                .byte   $20
                .byte   $7f
                .byte   $80
                .byte   "source"
                .byte   $90
                .byte   $0f
                .byte   $20
                .byte   $7f
                .byte   $80
                .byte   "destination"
                .byte   $ea
                .byte   $20
                .byte   $7f
                .byte   $80
                .byte   " disc and hit a key"
                .byte   $ea
                .byte   $20
                .byte   $bc
                .byte   $a5
                .byte   $20
                .byte   $e0
                .byte   $ff
                .byte   $b0
                .byte   $35

LA7DD:          pha
                lda     #$0d
                jsr     pchr
                pla
                rts

LA7E5:          jsr     vstrng
                jsr     $203a
                bcc     LA7FC
LA7ED:          jsr     vstrng
                .byte   "Go (Y/N) ? "
                .byte   $ea

LA7FC:          jsr     LA5BC
                jsr     $ffe0
                bcs     @LA812
                and     #$5f
                cmp     #$59
                php
                beq     @LA80D
                lda     #$4e
@LA80D:         jsr     pchr
                plp
                rts

@LA812:         jmp     L947B

LA815:          .byte   $4c,$45

TA817:          txa
cmd_backup:     jsr     LA728
                jsr     LA719
                lda     #$00
                sta     $c7
                sta     $c9
                sta     $c8
                sta     $c6
                sta     $a8
                jsr     LA77A
                lda     $c2d1
                sta     $cd
                jsr     L9451
                lda     $c107
                sta     $c4
                lda     $c106
                and     #$03
                sta     $c5
                jsr     LA785
                lda     $c2d2
                sta     $cd
                jsr     L9451
                lda     $c106
                and     #$03
                cmp     $c5
                bcc     LA815
                bne     @LA85E
                lda     $c107
                cmp     $c4
                bcc     LA815
@LA85E:         jsr     LA931
                jmp     L9451

cmd_copy:       jsr     LA4A7
                jsr     LA728
                jsr     L9F15
                jsr     L80ED
                jsr     LA77A
                lda     $c2d1
                jsr     L87CD
                jsr     L8224
@LA87C:         lda     $cc
                pha
                lda     $b6
                sta     $ab
                jsr     L8342
                ldx     #$00
@LA888:         lda     $c008,Y
                sta     $c5,X
                sta     $c250,X
                lda     $c108,Y
                sta     $bb,X
                sta     $c247,X
                inx
                iny
                cpx     #$08
                bne     @LA888
                lda     $c1
                jsr     L81B0
                sta     $c3
                lda     $bf
                clc
                adc     #$ff
                lda     $c0
                adc     #$00
                sta     $c4
                lda     $c3
                adc     #$00
                sta     $c5
                lda     $c24e
                sta     $c6
                lda     $c24d
                and     #$03
                sta     $c7
                lda     #$ff
                sta     $a8
                jsr     LA931
                jsr     LA77A
                lda     $c2d1
                jsr     L87CD
                jsr     L8388
                lda     $ab
                sta     $b6
                pla
                sta     $cc
                jsr     L828A
                bcs     @LA87C
                rts

LA8E2:          jsr     @LA920
                jsr     LA785
                lda     $c2d2
                sta     $cd
                lda     $cc
                pha
                jsr     L8388
                jsr     L8277
                bcc     @LA8FB
                jsr     L8312
@LA8FB:         pla
                sta     $cc
                jsr     L8B24
                jsr     L8B3B
                lda     $c2
                jsr     L81B0
                sta     $c4
                jsr     L8A8A
                lda     $c2
                and     #$03
                pha
                lda     $c3
                pha
                jsr     @LA920
                pla
                sta     $c8
                pla
                sta     $c9
                rts

@LA920:         ldx     #$11
@LA922:         lda     $c245,X
                ldy     $ba,X
                sta     $ba,X
                tya
                sta     $c245,X
                dex
                bpl     @LA922
                rts

LA931:          stz     $bc
                stz     $c0
                bra     @LA9AA

@LA937:         lda     $c4
                tay
                cmp     $c2d0
                lda     $c5
                sbc     #$00
                bcc     @LA946
                ldy     $c2d0
@LA946:         sty     $c1
                lda     $c6
                sta     $c3
                lda     $c7
                sta     $c2
                lda     $c2cf
                sta     $bd
                lda     $c2d1
                sta     $cd
                jsr     LA77A
                jsr     @LA9B1
                jsr     L880C
                lda     $c2d2
                sta     $cd
                bit     $a8
                bpl     @LA973
                jsr     LA8E2
                lda     #$00
                sta     $a8
@LA973:         lda     $c8
                sta     $c3
                lda     $c9
                sta     $c2
                lda     $c2cf
                sta     $bd
                jsr     LA785
                jsr     @LA9B1
                jsr     L8819
                lda     $c1
                clc
                adc     $c8
                sta     $c8
                bcc     @LA994
                inc     $c9
@LA994:         lda     $c1
                clc
                adc     $c6
                sta     $c6
                bcc     @LA99F
                inc     $c7
@LA99F:         sec
                lda     $c4
                sbc     $c1
                sta     $c4
                bcs     @LA9AA
                dec     $c5
@LA9AA:         lda     $c4
                ora     $c5
                bne     @LA937
                rts

@LA9B1:         lda     #$ff
                sta     $c274
                sta     $c275
                rts

cmd_verify:     lda     #$00
                beq     LA9C3

cmd_form:       lda     #$ff
                sta     $c282
LA9C3:          sta     $c9
                sta     $c290
                bpl     @LA9E4
                jsr     L9F15
                jsr     L8458
                sta     $c29f
                bcs     @LA9E1
                cmp     #$23
                beq     @LA9E4
                cmp     #$28
                beq     @LA9E4
                cmp     #$50
                beq     @LA9E4
@LA9E1:         jmp     L9F1A

@LA9E4:         jsr     L8703
                sty     $ca
                bne     @LAA36
                bit     $c9
                bmi     @LA9FA
                jsr     vstrng
                lsr     $65,X
                adc     ($69)
                ror     $79
                bcc     @LAA04
@LA9FA:         jsr     vstrng
                lsr     $6f
                adc     ($6d)
                adc     ($74,X)
                nop
@LAA04:         jsr     vstrng
                jsr     $6877
                adc     #$63
                pla
                jsr     $7264
                adc     #$76
                adc     $20
                .byte   $3f
                .byte   $20
                .byte   $ea
                .byte   $20
                .byte   $e0
                .byte   $ff
                .byte   $b0
                .byte   $40
                .byte   $c9
                .byte   $20
                .byte   $90
                .byte   $3f
                .byte   $20
                .byte   $a0
                .byte   $80
                .byte   $38
                .byte   $e9
                .byte   $30
                .byte   $90
                .byte   $37
                .byte   $c9
                .byte   $04
                .byte   $b0
                .byte   $33
                .byte   $85
                .byte   $cd
                .byte   $20
                HiAscii "]'$J"
                .byte   $4c
                .byte   $39
                .byte   $aa

@LAA36:         jsr     L8B62
                sty     $ca
                bit     $c9
                bpl     @LAA46
                ldx     $cd
                lda     #$00
                sta     $c2de,X
@LAA46:         bit     $c290
                bpl     @LAA51
                jsr     LA719
                jsr     LA588
@LAA51:         jsr     @LAA62
                ldy     $ca
                jsr     L8703
                bne     @LAA36
                rts

                .byte   $4c
                .byte   $7b
                .byte   $94
                .byte   $4c
                .byte   $79
                .byte   $8b

@LAA62:         bit     $c9
                bmi     @LAA74
                jsr     vstrng
                lsr     $65,X
                adc     ($69)
                ror     $79
                adc     #$6e
                .byte   $67
                .byte   $90
                .byte   $15

@LAA74:         jsr     @LAB6B
                jsr     vstrng
                lsr     $6f
                adc     ($6d)
                adc     ($74,X)
                stz     $69,X
                ror     LA666+1
                cmp     L908D+1
                .byte   $c2
                .byte   $20
                .byte   $7f
                .byte   $80
                .byte   " drive "
                .byte   $a5
                .byte   $cd
                .byte   $20
                .byte   $c3
                .byte   $80
                .byte   $20
                .byte   $7f
                .byte   $80
                .byte   " track   "
                .byte   $ea
                .byte   $24
                .byte   $c9
                .byte   $30
                .byte   $0c
                .byte   $20
                .byte   $cd,$ab,$8a,$d0
                .byte   $03
                .byte   $4c
                .byte   $dd
                .byte   $a7
                .byte   $8d
                .byte   $9f
                .byte   $c2
                .byte   $a9
                .byte   $00
                .byte   $8d
                .byte   $97
                .byte   $c2
                .byte   $a9
                .byte   $08
                .byte   $20
                .byte   $a0
                .byte   $80
                .byte   $20
                .byte   $a0
                .byte   $80
                .byte   $ad
                .byte   $97
                .byte   $c2
                .byte   $20
                .byte   $bb
                .byte   $80
                .byte   $a9
                .byte   $06
                .byte   $8d
                .byte   $9d
                .byte   $c2
                .byte   $20
                .byte   $3c
                .byte   $ab
                .byte   $24
                .byte   $c9
                .byte   $10
                .byte   $0d
                .byte   $20
                .byte   $87
                .byte   $ab
                .byte   $a2
                .byte   $90
                .byte   $a0
                .byte   $c2
                .byte   $20
                .byte   $f4
                .byte   $91
                .byte   $aa
                .byte   $d0
                .byte   $28
                .byte   $a9
                .byte   $00
                .byte   $8d
                .byte   $98
                .byte   $c2
                .byte   $ad
                .byte   $99
                .byte   $c2
                .byte   $29
                .byte   $1f
                .byte   $8d
                .byte   $99
                .byte   $c2
                .byte   $a9
                .byte   $03
                .byte   $8d
                .byte   $95
                .byte   $c2
                .byte   $a9
                .byte   $5f
                .byte   $8d
                .byte   $96
                .byte   $c2
                .byte   $20
                .byte   $77
                .byte   $94
                .byte   $a2
                .byte   $90
                .byte   $a0
                .byte   $c2
                .byte   $20
                .byte   $f4
                .byte   $91
                .byte   $f0
                .byte   $0d
                .byte   $ce
                .byte   $9d
                .byte   $c2
                .byte   $d0
                .byte   $c4
                .byte   $20
                .byte   $7f
                .byte   $80
                .byte   $3f
                .byte   $ea
                .byte   $4c
                .byte   $09
                .byte   $95
                .byte   $ad
                .byte   $9d
                .byte   $c2
                .byte   $c9
                .byte   $06
                .byte   $f0
                .byte   $08
                .byte   $20
                .byte   $7f
                .byte   $80
                .byte   "?   "
                .byte   $ea
                .byte   $24
                .byte   $c9
                .byte   $10
                .byte   $03
                .byte   $20
                .byte   $78
                .byte   $ab
                .byte   $ee
                .byte   $97
                .byte   $c2
                .byte   $ad
                .byte   $97
                .byte   $c2
                .byte   $cd
                .byte   $9f
                .byte   $c2
                .byte   $d0
                .byte   $88
                .byte   $24
                .byte   $c9
                .byte   $10
                .byte   $03
                .byte   $20
                .byte   $36
                .byte   $94
                .byte   $4c
                .byte   $dd
                .byte   $a7
                .byte   $a2
                .byte   $00
                .byte   $8e
                .byte   $91
                .byte   $c2
                .byte   $8e
                .byte   $9a
                .byte   $c2
                .byte   $ca
                .byte   $8e
                .byte   $93
                .byte   $c2
                .byte   $8e
                .byte   $94
                .byte   $c2,$ad,$cf,$c2,$8d
                .byte   $92
                .byte   $c2
                .byte   $a9
                .byte   $05
                .byte   $8d
                .byte   $95
                .byte   $c2
                .byte   $a9
                .byte   $63
                .byte   $8d
                .byte   $96
                .byte   $c2
                .byte   $a9
                .byte   $2a
                .byte   $8d
                .byte   $99
                .byte   $c2
                .byte   $a2
                .byte   $10
                .byte   $a0
                .byte   $13
                .byte   $8e
                .byte   $9b
                .byte   $c2
                .byte   $8c
                .byte   $98
                .byte   $c2
                .byte   $60

@LAB6B:         lda     #$00
                tay
@LAB6E:         sta     $c000,Y
                sta     $c100,Y
                iny
                bne     @LAB6E
                rts

                .byte   $a9
                .byte   $0a
                .byte   $18
                .byte   $6d
                .byte   $07
                .byte   $c1
                .byte   $8d
                .byte   $07
                .byte   $c1
                .byte   $90
                .byte   $03
                .byte   $ee
                .byte   $06
                .byte   $c1
                .byte   $60
                .byte   $a9
                .byte   $00
                .byte   $85
                HiAscii "0-OB"
                .byte   $85
                .byte   $b1
                .byte   $a9
                .byte   $0a
                .byte   $85
                .byte   $b2
                .byte   $ad
                .byte   $97
                .byte   $c2
                .byte   $f0
                .byte   $0a
                .byte   $a0
                .byte   $02
                .byte   $b1
                .byte   $b0
                .byte   $18
                .byte   $69
                .byte   $07
                .byte   $20
                HiAscii "D+* "
                .byte   $00
                .byte   $ad
                .byte   $97
                .byte   $c2
                .byte   $91
                .byte   $b0
                .byte   $c8
                .byte   $a9
                .byte   $00
                .byte   $91
                .byte   $b0
                .byte   $c8
                .byte   $8a
                .byte   $91
                .byte   $b0
                .byte   $c8
                .byte   $a9
                .byte   $01
                .byte   $91
                .byte   $b0
                .byte   $c8
                .byte   $e8
                .byte   $20
                HiAscii "C+F2Pd"
                .byte   $60
                .byte   $8a
                .byte   $38
                .byte   $e9
                .byte   $0a
                .byte   $b0
                .byte   $fc
                .byte   $69
                .byte   $0a
                .byte   $aa
                .byte   $60
                .byte   $20
                .byte   $3a
                .byte   $94
                .byte   $ad
                .byte   $06
                .byte   $c1
                .byte   $29
                .byte   $03
                .byte   $aa
                .byte   $ad
                .byte   $07
                .byte   $c1
                .byte   $a0
                .byte   $0a
                .byte   $84
                .byte   $b0
                .byte   $a0
                .byte   $ff
                .byte   $38
                HiAscii "He00{J"
                .byte   $10
                .byte   $f7
                .byte   $65
                .byte   $b0
                .byte   $48
                .byte   $98
                .byte   $aa
                .byte   $68
                .byte   $f0
                .byte   $01
                .byte   $e8
                .byte   $60

cmd_free:       sec
                bcs     LABF6

cmd_map:        clc
LABF6:          ror     $c6
                jsr     L8B5D
                jsr     L8388
                bit     $c6
                bmi     @LAC17
                jsr     @LAD9B
                eor     ($64,X)
                stz     $72
                adc     $73
                .byte   "s :  Length",$0d

@LAC17:         lda     $c106
                and     #$03
                sta     $c5
                sta     $c2
                lda     $c107
                sta     $c4
                sec
                sbc     #$02
                sta     $c1
                bcs     @LAC2E
                dec     $c2
@LAC2E:         lda     #$02
                sta     $bb
                lda     #$00
                sta     $bc
                sta     $bf
                sta     $c0
                lda     $c105
                and     #$f8
                tay
                beq     @LAC6A
                bne     @LAC55

@LAC44:         jsr     @LACE1
                jsr     L82BA
                lda     $c4
                sec
                sbc     $bb
                lda     $c5
                sbc     $bc
                bcc     @LAC6A
@LAC55:         lda     $c107,Y
                sec
                sbc     $bb
                sta     $c1
                php
                lda     $c106,Y
                and     #$03
                plp
                sbc     $bc
                sta     $c2
                bcc     @LAC44
@LAC6A:         sty     $bd
                bit     $c6
                bmi     @LAC79
                lda     $c1
                ora     $c2
                beq     @LAC79
                jsr     @LACBD
@LAC79:         lda     $c1
                clc
                adc     $bf
                sta     $bf
                lda     $c2
                adc     $c0
                sta     $c0
                ldy     $bd
                bne     @LAC44
                bit     $c6
                bpl     @LACBC
                tay
                ldx     $bf
                lda     #$f8
                sec
                sbc     $c105
                jsr     @LAD0C
                jsr     @LAD9B
                lsr     $72
                adc     $65
                ora     $c4a5
                sec
                sbc     $bf
                tax
                lda     $c5
                sbc     $c0
                tay
                lda     $c105
                jsr     @LAD0C
                jsr     @LAD9B
                eor     $73,X
                adc     $64
                .byte   $0d,$ea
@LACBC:         rts

@LACBD:         lda     $bc
                jsr     @LADC9
                lda     $bb
                jsr     @LADC1
                jsr     @LAD9B
                jsr     $2020
                jsr     $3a20
                jsr     LA520
                .byte   $c2
                .byte   $20
                HiAscii "I-%A"
                .byte   $20
                .byte   $c1
                .byte   $ad
                .byte   $a9
                .byte   $0d
                .byte   $20
                .byte   $e3
                .byte   $ff

@LACE1:         lda     $c106,Y
                pha
                jsr     L81B0
                sta     $bc
                pla
                and     #$03
                clc
                adc     $bc
                sta     $bc
                lda     $c104,Y
                beq     @LACF9
                lda     #$01
@LACF9:         clc
                adc     $c105,Y
                bcc     @LAD01
                inc     $bc
@LAD01:         clc
                adc     $c107,Y
                sta     $bb
                bcc     @LAD0B
                inc     $bc
@LAD0B:         rts

@LAD0C:         jsr     L81BF
                jsr     @LADBE
                jsr     @LAD9B
                jsr     $6946
                jmp     ($7365)

                .byte   $20
                .byte   $86
                .byte   $bc
                .byte   $84
                .byte   $bd
                .byte   $98
                .byte   $20
                .byte   $c9
                .byte   $ad
                .byte   $8a
                .byte   $20
                .byte   $c1
                .byte   $ad
                .byte   $20
                .byte   $9b
                .byte   $ad
                .byte   " Sectors "
                .byte   $a9
                .byte   $00
                .byte   $85
                .byte   $bb
                .byte   $85
                .byte   $be
                .byte   $a2
                .byte   $1f
                .byte   $86
                .byte   $c1
                .byte   $a2
                .byte   $09
                .byte   $9d
                .byte   $00
                .byte   $c2
                .byte   $ca
                .byte   $10
                .byte   $fa
                .byte   $06
                .byte   $bb
                .byte   $26
                .byte   $bc
                .byte   $26
                .byte   $bd
                .byte   $26
                .byte   $be
                .byte   $a2
                .byte   $00
                .byte   $a0
                .byte   $09
                .byte   $bd
                .byte   $00
                .byte   $c2
                .byte   $2a
                .byte   $c9
                .byte   $0a
                .byte   $90
                .byte   $02
                .byte   $e9
                .byte   $0a
                .byte   $9d
                .byte   $00
                .byte   $c2
                .byte   $e8
                .byte   $88
                .byte   $10
                .byte   $ef
                .byte   $c6
                .byte   $c1
                .byte   $10
                .byte   $df
                .byte   $a0
                .byte   $20
                .byte   $a2
                .byte   $05
                .byte   $d0
                .byte   $02
                .byte   $a0
                .byte   $2c
                .byte   $bd
                .byte   $00
                .byte   $c2
                .byte   $d0
                .byte   $08
                .byte   $c0
                .byte   $2c
                .byte   $f0
                .byte   $04
                .byte   $a9
                .byte   $20
                .byte   $d0
                .byte   $05
                .byte   $a0
                .byte   $2c
                .byte   $18
                .byte   $69
                .byte   $30
                .byte   $20
                .byte   $e3
                .byte   $ff
                .byte   $e0
                .byte   $03
                .byte   $d0
                .byte   $04
                .byte   $98
                .byte   $20
                .byte   $e3
                .byte   $ff
                .byte   $ca
                .byte   $10
                .byte   $dc
                .byte   $20
                .byte   $9b
                .byte   $ad
                .byte   " Bytes "
                .byte   $ea
                .byte   $60

@LAD9B:         sta     $b3
                pla
                sta     $ae
                pla
                sta     $af
                lda     $b3
                pha
                tya
                pha
                ldy     #$00
@LADAA:         jsr     L83E4
                lda     ($ae),Y
                bmi     @LADB7
                jsr     $ffe3
                jmp     @LADAA

@LADB7:         pla
                tay
                pla
                clc
                jmp     ($00ae)

@LADBE:         jsr     L841D
@LADC1:         pha
                jsr     L81BE
                jsr     @LADC9
                pla
@LADC9:         jsr     L80C8
                jmp     $ffe3

LADCF:          jsr     LADD2
LADD2:          pha
                lda     #$20
                jsr     $ffe3
                pla
                clc
                rts

LADDB:          jsr     savita
                lda     #$40
                sta     $c2de
                lda     #$a8
                jsr     LA5D9
                stx     $b0
                sty     $b1
                ldy     #$0f
                lda     #$4c
                sta     $c2e2
                lda     $020a
                sta     $c2e3
                lda     $020b
                sta     $c2e4
                php
                sei
                lda     #$0f
                sta     $020a
                lda     #$ff
                sta     $020b
                lda     #$1b
                sta     ($b0),Y
                iny
                lda     #$ae
                sta     ($b0),Y
                iny
                lda     $f4
                sta     ($b0),Y
                plp
                rts

                .byte   $c9
                .byte   $00
                .byte   $f0
                .byte   $11
                .byte   $c9
                .byte   $81
                .byte   $d0
                .byte   $0a
                .byte   $c0
                .byte   $ff
                .byte   $d0
                .byte   $06
                .byte   $e0
                .byte   $00
                .byte   $d0
                .byte   $02
                .byte   $ca
                .byte   $60
                .byte   $4c
                .byte   $e2
                .byte   $c2
                .byte   $08
                .byte   $78
                .byte   $ad,$e3,$c2,$8d
                .byte   $0a
                .byte   $02
                .byte   $ad,$e4,$c2,$8d
                .byte   $0b
                .byte   $02
                .byte   $a9
                .byte   $00
                .byte   $a2
                .byte   $01
                .byte   $28
                .byte   $60
                .res    188,$ff
