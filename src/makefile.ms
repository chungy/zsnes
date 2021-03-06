#Copyright (C) 1997-2006 ZSNES Team ( zsKnight, _Demo_, pagefault, Nach )
#
#http://www.zsnes.com
#http://sourceforge.net/projects/zsnes
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#version 2 as published by the Free Software Foundation.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

#Parameters:
#
# PLATFORM=platform_name  Chose target platform and how you're creating it.
#                         Valid options are:
#                         dos, dos-cross, msvc, win32, win32-cross, win32-unix-shell
#
# RELEASEGRADE=yes        for high assembly optimization for releases, will take at least half an hour.
# clean                   cleans object and executable files.
#
# --Not for MSVC--
# DEBUG=yes               for debugging with GDB.
# CPU=cpu-type            optimize for a particular CPU, find a list of cpu types in the GCC manual.


ENV=$(PLATFORM)
ifneq (${ENV},) #end if is at the bottom of the file


CHIPDIR=chips
CPUDIR=cpu
DOSDIR=dos
EFFECTSDIR=effects
GUIDIR=gui
JMADIR=jma
NETDIR=net
VIDEODIR=video
WINDIR=win
ZIPDIR=zip
MMLIBDIR=mmlib

DELETECOMMAND=rm -f
TRUTH=;true
SLASH=/
PSR=parsegen.exe
ASM=nasm
ASMOPT=-O1
ASMFLAGSORIG=
COPT=-O3
CPUOPT=i586
ifneq ($(CPU),)
CPUOPT=$(CPU)
endif
CFLAGSORIG=-march=${CPUOPT} -ffast-math -fomit-frame-pointer -fno-unroll-loops -Wall -Wno-unused -I.
LIBSORIG=-lz -lpng
DRESOBJ=${WINDIR}/zsnes.obj
CROSS=no
STRIP=-Ws -s


ifeq (${ENV},dos)
  CC = gcc
  CPPC = gpp
  OS=__MSDOS__
endif

ifeq (${ENV},win32-unix-shell)
  ENV=win32
  CROSS=yes
endif

ifeq (${ENV},win32)
  CC = gcc
  CPPC = g++
  WINDRES = windres
  OS=__WIN32__
  OBJFIX=objfix.exe
endif

ifeq (${ENV},msvc)
  MSVCLIBS=zlib.lib libpng.lib wsock32.lib user32.lib gdi32.lib shell32.lib winmm.lib dinput8.lib dxguid.lib
  DRESOBJ=${WINDIR}/zsnes.res
  OS=__WIN32__
endif

ifeq (${ENV},dos-cross)
  CC = i386-pc-msdosdjgpp-gcc
  CPPC = i386-pc-msdosdjgpp-g++
  OS=__MSDOS__
  CROSS=yes
endif

ifeq (${ENV},win32-cross)
  CC = i586-mingw32-gcc
  CPPC = i586-mingw32-g++
  WINDRES = i586-mingw32-windres
  OS=__WIN32__
  CROSS=yes
  OBJFIX=objfix
endif

ifeq (${CROSS},no)
  TRUTH=
  DELETECOMMAND=del
  SLASH=\${BLAHBLAHBLAH}
endif

ifeq (${OS},__MSDOS__)
  EXE=zsnes.exe
  FILEFORMAT=coff
  LIBS=${LIBSORIG} -lm
  OE=.do
endif

ifeq (${OS},__WIN32__)
  EXE=zsnesw.exe
  FILEFORMAT=win32
  LIBS=${LIBSORIG} -ldxguid -ldinput8 -lwsock32 -luser32 -lgdi32 -lshell32 -lwinmm -mwindows
  OE=.obj
endif

ifeq (${DEBUG},yes)
  CFLAGSORIG=-fno-omit-frame-pointer -ggdb3 -DDEBUG
  COPT=-O0
  ASMFLAGSORIG=-DDEBUG -g
  EXE=zsnesd.exe
  STRIP=
endif

ifeq (${DEV},yes)
  CFLAGSORIG+=-D__DEVELOPER__
  ASMFLAGSORIG+=-D__DEVELOPER__
endif

ifeq (${RELEASEGRADE},yes)
  ASMOPT=-O9999
endif

CFLAGS=${CFLAGSORIG} -D${OS}
ASMFLAGS=${ASMFLAGSORIG} -f ${FILEFORMAT} -D${OS}


CHIPSOBJ=${CHIPDIR}/dsp1emu${OE} ${CHIPDIR}/fxemu2${OE} ${CHIPDIR}/sfxproc${OE}\
	${CHIPDIR}/fxemu2b${OE} ${CHIPDIR}/fxemu2c${OE} ${CHIPDIR}/fxtable${OE}\
	${CHIPDIR}/sa1proc${OE} ${CHIPDIR}/sa1regs${OE} ${CHIPDIR}/dsp1proc${OE}\
	${CHIPDIR}/st10proc${OE} ${CHIPDIR}/seta10${OE} ${CHIPDIR}/dsp2proc${OE}\
	${CHIPDIR}/sdd1emu${OE} ${CHIPDIR}/c4emu${OE} ${CHIPDIR}/dsp4proc${OE}\
	${CHIPDIR}/dsp4emu${OE} ${CHIPDIR}/dsp3proc${OE} ${CHIPDIR}/dsp3emu${OE}\
	${CHIPDIR}/obc1emu${OE} ${CHIPDIR}/obc1proc${OE}

CPUOBJ=${CPUDIR}/dma${OE} ${CPUDIR}/dsp${OE} ${CPUDIR}/dspproc${OE}\
	${CPUDIR}/execute${OE} ${CPUDIR}/executec${OE} ${CPUDIR}/irq${OE}\
	${CPUDIR}/memory${OE} ${CPUDIR}/memtable${OE} ${CPUDIR}/spc700${OE}\
	${CPUDIR}/stable${OE} ${CPUDIR}/table${OE} ${CPUDIR}/tableb${OE}\
	${CPUDIR}/tablec${OE}

DOSOBJORIG=${DOSDIR}/debug${OE} ${DOSDIR}/joy${OE} ${DOSDIR}/vesa2${OE}

EFFECTSOBJ=${EFFECTSDIR}/burn${OE} ${EFFECTSDIR}/water${OE} ${EFFECTSDIR}/smoke${OE}

GUIOBJ=${GUIDIR}/gui${OE} ${GUIDIR}/guifuncs${OE} ${GUIDIR}/menu${OE}

JMAOBJ=${JMADIR}/7zlzma${OE} ${JMADIR}/crc32${OE} ${JMADIR}/iiostrm${OE}\
	${JMADIR}/inbyte${OE} ${JMADIR}/jma${OE} ${JMADIR}/lzma${OE} ${JMADIR}/lzmadec${OE}\
	${JMADIR}/winout${OE} ${JMADIR}/zsnesjma${OE}

MAINOBJ=cfgload${OE} endmem${OE} init${OE} initc${OE} uic${OE} patch${OE}\
	ui${OE} vcache${OE} version${OE} zmovie${OE} zstate${OE} zloader${OE}\
	cfg${OE} md${OE}

NETOBJ=
#${NETDIR}/ztcp${OE}

VIDEOBJ=${VIDEODIR}/makev16b${OE} ${VIDEODIR}/makev16t${OE} ${VIDEODIR}/makevid${OE}\
	${VIDEODIR}/mode716${OE} ${VIDEODIR}/mode716b${OE} ${VIDEODIR}/mode716d${OE}\
	${VIDEODIR}/mode716e${OE} ${VIDEODIR}/mode716t${OE} ${VIDEODIR}/mode7${OE}\
	${VIDEODIR}/mode7ext${OE} ${VIDEODIR}/mv16tms${OE} ${VIDEODIR}/newg162${OE}\
	${VIDEODIR}/newgfx16${OE} ${VIDEODIR}/newgfx2${OE} ${VIDEODIR}/newgfx${OE}\
	${VIDEODIR}/m716text${OE} ${VIDEODIR}/procvid${OE} ${VIDEODIR}/procvidc${OE}\
	${VIDEODIR}/ntsc${OE}

#only used on Win32
WINOBJ=${WINDIR}/copyvwin${OE} ${DRESOBJ}\
	${WINDIR}/winintrf${OE} ${WINDIR}/winlink${OE} ${WINDIR}/zfilew${OE}\
	${WINDIR}/safelib${OE} ${MMLIBDIR}/mm${OE} ${MMLIBDIR}/windows${OE}

WINVIDOBJ=${VIDEODIR}/sw_draw${OE} ${VIDEODIR}/hq2x16${OE} ${VIDEODIR}/hq2x32${OE}\
	${VIDEODIR}/2xsaiw${OE} ${VIDEODIR}/hq3x16${OE} ${VIDEODIR}/hq3x32${OE}\
	${VIDEODIR}/hq4x16${OE} ${VIDEODIR}/hq4x32${OE}

ZIPOBJ=${ZIPDIR}/unzip${OE} ${ZIPDIR}/zpng${OE}


OBJSORIG=${CHIPSOBJ} ${CPUOBJ} ${GUIOBJ} ${VIDEOBJ} ${MAINOBJ} ${ZIPOBJ} ${EFFECTSOBJ} ${JMAOBJ}

ifeq (${OS},__MSDOS__)
DOSOBJ=${DOSOBJORIG} ${DOSDIR}/dosintrf${OE} ${DOSDIR}/gppro${OE} ${DOSDIR}/initvid${OE}\
	${DOSDIR}/sound${OE} ${DOSDIR}/sw${OE} ${DOSDIR}/vesa12${OE} ${DOSDIR}/zfile${OE}
OBJS=${OBJSORIG} ${DOSOBJ}
DELETEOBJS=${OBJSORIG} ${DOSOBJ}
endif

ifeq (${OS},__WIN32__)
OBJS=${OBJSORIG} ${WINOBJ} ${DOSOBJORIG} ${WINVIDOBJ} ${NETOBJ}
DELETEOBJS=${OBJS}
endif


.SUFFIXES: .c .cpp .asm .psr

ifneq (${ENV},msvc)
%${OE}: %.c
	${CC} ${COPT} ${CFLAGS} -o $@ -c $<

%${OE}: %.cpp
	${CPPC} ${COPT} ${CFLAGS} -o $@ -c $<

%${OE}: %.asm
	${ASM} ${ASMOPT} ${ASMFLAGS} -o $@ $<
ifeq (${OS},__WIN32__)
	objfix $@
endif
else
%.obj : %.c
	cl /nologo /Ox /G6 /c /EHsc /D__WIN32__ /Fo$@ $<

%.obj: %.cpp
	cl /nologo /Ox /G6 /c /EHsc /D__WIN32__ /Fo$@ $<

%.obj: %.asm
	${ASM} ${ASMOPT} -f win32 -D__WIN32__ -o $@ $<
endif

%${OE}: %.psr
	${PSR} -D${OS} -cheader psrhead/$(patsubst %${OE},%.h,$@) -fname $(patsubst %${OE},%,$@) temppsr.c $<
ifneq (${ENV},msvc)
	${CC} -o $@ -c temppsr.c
else
	cl /nologo /Ox /G6 /c /EHsc /D__WIN32__ /Fo$@ temppsr.c
endif
	${DELETECOMMAND} temppsr.c

ALL: zsnes
	${DELETECOMMAND} version${OE}

zsnes: ${PSR} ${OBJFIX} ${OBJS}
ifneq (${ENV},msvc)
	${CPPC} ${STRIP} -o ${EXE} ${OBJS} ${LIBS}
else
	 @echo /Fezsnesw.exe *.obj ${CPUDIR}\*.obj ${VIDEODIR}\*.obj ${CHIPDIR}\*.obj ${EFFECTSDIR}\*.obj ${DOSDIR}\*.obj ${WINDIR}\*.obj ${GUIDIR}\*.obj > link.vc
	 @echo ${ZIPDIR}\*.obj ${JMADIR}\*.obj ${NETDIR}\*.obj ${MMLIBDIR}\*.obj >> link.vc
	 @echo ${MSVCLIBS} >> link.vc
	 cl /nologo @link.vc ${WINDIR}/zsnes.res /link
endif

cfgload${OE}: cfgload.c
cfg${OE}: ${PSR} cfg.psr
endmem${OE}: endmem.asm macros.mac
init${OE}: init.asm macros.mac
initc${OE}: initc.c asm_call.h ${CPUDIR}/memtable.h ${JMADIR}/zsnesjma.h\
	${ZIPDIR}/zunzip.h
patch${OE}: patch.c ${ZIPDIR}/zunzip.h
ui${OE}: ui.asm macros.mac
uic${OE}: uic.c asm_call.h ${MMLIBDIR}/mm.h
vcache${OE}: vcache.asm macros.mac
version${OE}: version.c
zloader${OE}: zloader.c
zmovie${OE}: zmovie.c asm_call.h gblvars.h numconv.h md${OE}
zstate${OE}: zstate.c asm_call.h gblvars.h numconv.h
md${OE}: md.psr ${PSR}

${CHIPDIR}/c4emu${OE}: ${CHIPDIR}/c4emu.c
${CHIPDIR}/dsp1emu${OE}: ${CHIPDIR}/dsp1emu.c
${CHIPDIR}/dsp1proc${OE}: ${CHIPDIR}/dsp1proc.asm macros.mac
${CHIPDIR}/dsp2proc${OE}: ${CHIPDIR}/dsp2proc.asm macros.mac
${CHIPDIR}/dsp3emu${OE}: ${CHIPDIR}/dsp3emu.c
${CHIPDIR}/dsp3proc${OE}: ${CHIPDIR}/dsp3proc.asm macros.mac
${CHIPDIR}/dsp4emu${OE}: ${CHIPDIR}/dsp4emu.c
${CHIPDIR}/dsp4proc${OE}: ${CHIPDIR}/dsp4proc.asm macros.mac
${CHIPDIR}/fxemu2${OE}: ${CHIPDIR}/fxemu2.asm macros.mac ${CHIPDIR}/fxemu2.mac
${CHIPDIR}/fxemu2b${OE}: ${CHIPDIR}/fxemu2b.asm macros.mac ${CHIPDIR}/fxemu2.mac\
	${CHIPDIR}/fxemu2b.mac
${CHIPDIR}/fxemu2c${OE}: ${CHIPDIR}/fxemu2c.asm macros.mac ${CHIPDIR}/fxemu2.mac\
	${CHIPDIR}/fxemu2c.mac
${CHIPDIR}/fxtable${OE}: ${CHIPDIR}/fxtable.asm macros.mac
${CHIPDIR}/obc1emu${OE}: ${CHIPDIR}/obc1emu.c
${CHIPDIR}/obc1proc${OE}: ${CHIPDIR}/obc1proc.asm macros.mac
${CHIPDIR}/sa1proc${OE}: ${CHIPDIR}/sa1proc.asm macros.mac
${CHIPDIR}/sa1regs${OE}: ${CHIPDIR}/sa1regs.asm macros.mac\
	${CPUDIR}/regs.mac ${CPUDIR}/regsw.mac
${CHIPDIR}/sdd1emu${OE}: ${CHIPDIR}/sdd1emu.c
${CHIPDIR}/seta10${OE}: ${CHIPDIR}/seta10.c
${CHIPDIR}/sfxproc${OE}: ${CHIPDIR}/sfxproc.asm macros.mac\
	${CPUDIR}/regs.mac ${CPUDIR}/regsw.mac
${CHIPDIR}/st10proc${OE}: ${CHIPDIR}/st10proc.asm macros.mac

${CPUDIR}/dma${OE}: ${CPUDIR}/dma.asm macros.mac
${CPUDIR}/dsp${OE}: ${CPUDIR}/dsp.asm macros.mac
${CPUDIR}/dspproc${OE}: ${CPUDIR}/dspproc.asm macros.mac ${CPUDIR}/fir_tables.inc
${CPUDIR}/execute${OE}: ${CPUDIR}/execute.asm macros.mac
${CPUDIR}/executec${OE}: ${CPUDIR}/executec.c gblvars.h
${CPUDIR}/irq${OE}: ${CPUDIR}/irq.asm macros.mac
${CPUDIR}/memory${OE}: ${CPUDIR}/memory.asm macros.mac
${CPUDIR}/memtable${OE}: ${CPUDIR}/memtable.c gblvars.h ${CPUDIR}/memtable.h
${CPUDIR}/spc700${OE}: ${CPUDIR}/spc700.asm macros.mac ${CPUDIR}/regsw.mac\
	${CPUDIR}/spcaddr.inc ${CPUDIR}/spcdef.inc
${CPUDIR}/stable${OE}: ${CPUDIR}/stable.asm macros.mac ${CPUDIR}/s65816d.inc\
	${CPUDIR}/saddress.inc ${CPUDIR}/saddrni.inc ${CPUDIR}/se65816.inc
${CPUDIR}/table${OE}: ${CPUDIR}/table.asm macros.mac ${CPUDIR}/65816d.inc\
	${CPUDIR}/address.inc ${CPUDIR}/addrni.inc ${CPUDIR}/e65816.inc\
	${CPUDIR}/regs.inc ${CPUDIR}/regs.mac ${CPUDIR}/regsw.inc ${CPUDIR}/regsw.mac
${CPUDIR}/tableb${OE}: ${CPUDIR}/tableb.asm macros.mac ${CPUDIR}/65816db.inc\
	${CPUDIR}/address.inc ${CPUDIR}/addrni.inc ${CPUDIR}/e65816b.inc
${CPUDIR}/tablec${OE}: ${CPUDIR}/tablec.asm macros.mac ${CPUDIR}/65816dc.inc\
	${CPUDIR}/address.inc ${CPUDIR}/addrni.inc ${CPUDIR}/e65816c.inc

${DOSDIR}/debug${OE}: ${DOSDIR}/debug.asm macros.mac
${DOSDIR}/dosintrf${OE}: ${DOSDIR}/dosintrf.asm macros.mac
${DOSDIR}/gppro${OE}: ${DOSDIR}/gppro.asm macros.mac
${DOSDIR}/initvid${OE}: ${DOSDIR}/initvid.asm macros.mac ${DOSDIR}/vga.inc
${DOSDIR}/joy${OE}: ${DOSDIR}/joy.asm macros.mac
${DOSDIR}/sound${OE}: ${DOSDIR}/sound.asm macros.mac
${DOSDIR}/sw${OE}: ${DOSDIR}/sw.asm macros.mac
${DOSDIR}/vesa12${OE}: ${DOSDIR}/vesa12.asm macros.mac
${DOSDIR}/vesa2${OE}: ${DOSDIR}/vesa2.asm macros.mac
${DOSDIR}/zfile${OE}: ${DOSDIR}/zfile.c

${EFFECTSDIR}/burn${OE}: ${EFFECTSDIR}/burn.c
${EFFECTSDIR}/smoke${OE}: ${EFFECTSDIR}/smoke.c
${EFFECTSDIR}/water${OE}: ${EFFECTSDIR}/water.c ${EFFECTSDIR}/fixsin.h

${GUIDIR}/gui${OE}: ${GUIDIR}/gui.asm macros.mac ${GUIDIR}/guicheat.inc\
	${GUIDIR}/guicombo.inc ${GUIDIR}/guikeys.inc ${GUIDIR}/guiload.inc\
	${GUIDIR}/guimisc.inc ${GUIDIR}/guimouse.inc ${GUIDIR}/guitools.inc\
	${GUIDIR}/guiwindp.inc
${GUIDIR}/guifuncs${OE}: ${GUIDIR}/guifuncs.c md${OE}
${GUIDIR}/menu${OE}: ${GUIDIR}/menu.asm macros.mac

${JMADIR}/7zlzma${OE}: ${JMADIR}/7zlzma.cpp ${JMADIR}/7z.h ${JMADIR}/lzmadec.h
${JMADIR}/crc32${OE}: ${JMADIR}/crc32.cpp
${JMADIR}/iiostrm${OE}: ${JMADIR}/iiostrm.cpp ${JMADIR}/crc32.h ${JMADIR}/iiostrm.h\
	${JMADIR}/portable.h
${JMADIR}/inbyte${OE}: ${JMADIR}/inbyte.cpp ${JMADIR}/inbyte.h
${JMADIR}/jma${OE}: ${JMADIR}/jma.cpp ${JMADIR}/7z.h ${JMADIR}/crc32.h\
	${JMADIR}/jma.h ${JMADIR}/portable.h
${JMADIR}/lzma${OE}: ${JMADIR}/lzma.cpp ${JMADIR}/lzma.h
${JMADIR}/lzmadec${OE}: ${JMADIR}/lzmadec.cpp ${JMADIR}/lzmadec.h\
	${JMADIR}/portable.h
${JMADIR}/winout${OE}: ${JMADIR}/winout.cpp ${JMADIR}/winout.h
${JMADIR}/zsnesjma${OE}: ${JMADIR}/zsnesjma.cpp ${JMADIR}/jma.h\
	${JMADIR}/zsnesjma.h

${VIDEODIR}/2xsaiw${OE}: ${VIDEODIR}/2xsaiw.asm macros.mac
${VIDEODIR}/hq2x16${OE}: ${VIDEODIR}/hq2x16.asm macros.mac
${VIDEODIR}/hq2x32${OE}: ${VIDEODIR}/hq2x32.asm macros.mac
${VIDEODIR}/hq3x16${OE}: ${VIDEODIR}/hq3x16.asm macros.mac
${VIDEODIR}/hq3x32${OE}: ${VIDEODIR}/hq3x32.asm macros.mac
${VIDEODIR}/hq4x16${OE}: ${VIDEODIR}/hq4x16.asm macros.mac
${VIDEODIR}/hq4x32${OE}: ${VIDEODIR}/hq4x32.asm macros.mac
${VIDEODIR}/m716text${OE}: ${VIDEODIR}/m716text.asm macros.mac
${VIDEODIR}/makev16b${OE}: ${VIDEODIR}/makev16b.asm macros.mac\
	${VIDEODIR}/vidmacro.mac
${VIDEODIR}/makev16t${OE}: ${VIDEODIR}/makev16t.asm macros.mac\
	${VIDEODIR}/vidmacro.mac
${VIDEODIR}/makevid${OE}: ${VIDEODIR}/makevid.asm macros.mac\
	${VIDEODIR}/vidmacro.mac
${VIDEODIR}/mode7${OE}: ${VIDEODIR}/mode7.asm macros.mac ${VIDEODIR}/mode7.mac
${VIDEODIR}/mode716${OE}: ${VIDEODIR}/mode716.asm macros.mac ${VIDEODIR}/mode716.mac
${VIDEODIR}/mode716b${OE}: ${VIDEODIR}/mode716b.asm macros.mac ${VIDEODIR}/mode7.mac
${VIDEODIR}/mode716d${OE}: ${VIDEODIR}/mode716d.asm macros.mac ${VIDEODIR}/mode7.mac
${VIDEODIR}/mode716e${OE}: ${VIDEODIR}/mode716e.asm macros.mac
${VIDEODIR}/mode716t${OE}: ${VIDEODIR}/mode716t.asm macros.mac ${VIDEODIR}/mode7.mac
${VIDEODIR}/mode7ext${OE}: ${VIDEODIR}/mode7ext.asm macros.mac ${VIDEODIR}/mode7.mac
${VIDEODIR}/mv16tms${OE}: ${VIDEODIR}/mv16tms.asm macros.mac\
	${VIDEODIR}/vidmacro.mac
${VIDEODIR}/newg162${OE}: ${VIDEODIR}/newg162.asm macros.mac\
	${VIDEODIR}/newg162.mac ${VIDEODIR}/newg16wn.mac ${VIDEODIR}/newgfx16.mac\
	${VIDEODIR}/vidmacro.mac
${VIDEODIR}/newfgx${OE}: ${VIDEODIR}/newfgx.asm macros.mac ${VIDEODIR}/newgfx.mac\
	${VIDEODIR}/newgfx2.mac ${VIDEODIR}/vidmacro.mac
${VIDEODIR}/newgfx16${OE}: ${VIDEODIR}/newgfx16.asm macros.mac\
	${VIDEODIR}/newg162.mac ${VIDEODIR}/newgfx16.mac ${VIDEODIR}/vidmacro.mac
${VIDEODIR}/newgfx2${OE}: ${VIDEODIR}/newgfx2.asm macros.mac ${VIDEODIR}/newgfx.mac\
	${VIDEODIR}/newgfx2.mac ${VIDEODIR}/newgfxwn.mac ${VIDEODIR}/vidmacro.mac
${VIDEODIR}/procvid${OE}: ${VIDEODIR}/procvid.asm macros.mac\
	${VIDEODIR}/2xsaimmx.inc ${VIDEODIR}/copyvid.inc
${VIDEODIR}/procvidc${OE}: ${VIDEODIR}/procvidc.c
${VIDEODIR}/sw_draw${OE}: ${VIDEODIR}/sw_draw.asm macros.mac
${VIDEODIR}/ntsc${OE}: ${VIDEODIR}/ntsc.c

${MMLIBDIR}/mm${OE}: ${MMLIBDIR}/mm.c ${MMLIBDIR}/mm.h
${MMLIBDIR}/windows${OE}: ${MMLIBDIR}/windows.c ${MMLIBDIR}/mm.h

${WINDIR}/copyvwin${OE}: ${WINDIR}/copyvwin.asm macros.mac
${WINDIR}/winintrf${OE}: ${WINDIR}/winintrf.asm macros.mac
${WINDIR}/zfilew${OE}: ${WINDIR}/zfilew.c ${WINDIR}/resource.h
${WINDIR}/safelib${OE}: ${WINDIR}/safelib.c ${WINDIR}/safelib.h argv.h
ifeq (${ENV},msvc)
${WINDIR}/winlink.obj: ${WINDIR}/winlink.cpp ${WINDIR}/resource.h
${WINDIR}/zsnes.res: ${WINDIR}/zsnes.rc ${WINDIR}/afxres.h ${WINDIR}/resource.h
	rc ${WINDIR}/zsnes.rc
else
${WINDIR}/winlink${OE}: ${WINDIR}/winlink.cpp ${WINDIR}/resource.h
	${CPPC} ${COPT} ${CFLAGS} -masm=intel -o $@ -c ${WINDIR}/winlink.cpp
${WINDIR}/zsnes${OE}: ${WINDIR}/zsnes.rc ${WINDIR}/afxres.h ${WINDIR}/resource.h
	${WINDRES} --include-dir ${WINDIR} ${WINDIR}/zsnes.rc -o${WINDIR}/zsnes${OE}
${OBJFIX}: objfix.c
	gcc -O3 -s -o $@ objfix.c
endif
${PSR}: parsegen.cpp
ifeq (${ENV},msvc)
	cl /nologo /EHsc /Fe$@ parsegen.cpp
	${DELETECOMMAND} parsegen.obj
else
ifeq (${ENV},dos)
	gpp -O3 -s -o $@ parsegen.cpp
else
	g++ -O3 -s -o $@ parsegen.cpp
endif
endif

${ZIPDIR}/unzip${OE}: ${ZIPDIR}/unzip.c ${ZIPDIR}/zunzip.h
${ZIPDIR}/zpng${OE}: ${ZIPDIR}/zpng.c ${ZIPDIR}/zpng.h

clean:

	${DELETECOMMAND} ${EXE} ${TRUTH}
	${DELETECOMMAND} ${PSR} ${TRUTH}
	${DELETECOMMAND} *${OE} ${TRUTH}
	${DELETECOMMAND} ${CHIPDIR}${SLASH}*${OE} ${TRUTH}
	${DELETECOMMAND} ${CPUDIR}${SLASH}*${OE} ${TRUTH}
	${DELETECOMMAND} ${DOSDIR}${SLASH}*${OE} ${TRUTH}
	${DELETECOMMAND} ${EFFECTSDIR}${SLASH}*${OE} ${TRUTH}
	${DELETECOMMAND} ${GUIDIR}${SLASH}*${OE} ${TRUTH}
	${DELETECOMMAND} ${JMADIR}${SLASH}*${OE} ${TRUTH}
	${DELETECOMMAND} ${MMLIBDIR}${SLASH}*${OE} ${TRUTH}
	${DELETECOMMAND} ${NETDIR}${SLASH}*${OE} ${TRUTH}
	${DELETECOMMAND} ${VIDEODIR}${SLASH}*${OE} ${TRUTH}
	${DELETECOMMAND} ${WINDIR}${SLASH}*${OE} ${TRUTH}
	${DELETECOMMAND} ${ZIPDIR}${SLASH}*${OE} ${TRUTH}
	${DELETECOMMAND} psrhead${SLASH}*.h

else  #else no ENV specified
help:
	@echo Please specify which platform to compile/clean for with PLATFORM=platform_name
endif #endif on the ENV being empty
