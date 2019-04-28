{*********************************************************}
{                                                         }
{    Calmira System Library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}


CHANGES in VCL 3.3 release:

- Added CALCOLOR.PAS
- Added SORTHDR.PAS
  This is an unfinished unit; only included so Calmira will compile.


CHANGES in VCL 3.2 release:

- MISCUTIL.PAS:
  Added FreeAndNil procedure
  Moved ReplaceBitmapColors from Settings.pas
- FILES.PAS: Added DOS error constants
- STYLSPED.PAS: Added bsFlat & removed bsBitBtn style
- INTERNET.PAS: Added ReadServiceApplication method
- SCRLTREE.PAS: Added properties
- Included fixed VCL units (see notes):
  - Buttons.dcu
  - Dialogs.dcu
  - Menus.dcu
  - StdCtrls.dcu.


Notes:

The Calmira VCL contains some standard Delphi Compiled Unit (DCU)
files that contain some fixes and changes. You can use these with
other projects, but it is not required, though it is recommended
that they are used when (re)compiling Calmira.

These units are compatible with Delphi 1.0 and 1.01; they have not
been patched in the 1.01 VCL patch. I am not sure about 1.02, since
Borland never released the source code to the 1.02 VCL.

If you have the Calmira VCL directory in your library path, these
units are automatically used in your projects instead of the default
Delphi units.

* Menus.dcu:
  - Fixed memory leak in TMainMenu.
* Buttons.dcu:
  - Modified some color constants in DrawButtonFace,
    bsNew button style appear as real Win95 buttons.
* Dialogs.dcu:
  - Removed fsBold font style.
  - Fixed default button appearence in InputQuery.
* StdCtrls.dcu: fixed two ownerdraw related bugs in TComboBox:
  - DropDownCount is now calculated properly.
  - DrawFocusRect is no longer called if ownerdrawn.


CHANGES in VCL 3.1 release:

- EXTFORM.PAS: Moved all StretchShift related code from CALFORM.PAS
- PROFILE.PAS: Renamed RewriteSectionStrings to WriteNewStrings
- STRINGS.PAS: Renamed StringAsPChar to StrPChar
- PROFILE.PAS: Added DeleteKey and ReadSections methods
- Added TNetDialogs components (netdlgs.pas)
- Added TWin95Pie component (win95pie.pas)
- Added TRegistry object (registry.pas)
- Removed NOTEPAD.PAS


CHANGES in VCL 3.0 Release

* SHUTDOWN: Redesigned the Shut Down dialog
  - changed from bsDialog to bsSingle, used Border3D
  - now shows the ShutDownDialog icon (thus replacable)
  - implemented DARKEN.PAS (DarkenScreen)
    (added SCREENMESH to BITMAPS.RES)
  - Shows optional SHUTDOWN.BMP during shutdown

* STRTPROP: Redesinged Start Menu Properties Dialog
  - Moved toolbar buttons to the top
  - Changed button and outline glyphs
  - Option to fully rebuild start menu by three state checkbox
  - Added option for large menu item height

* TREE, STRTPROP: Optimized tree outline drawing
  - OutlineDrawItem: overhauled:
    + now uses DottedLineTo insted of LineTo
    + added improved focus drawing

* START: Changed Start Menu drawing
  - TStartMenu.DrawItem: overhauled:
    + lost drawing of 3d effects for selected items (flat focus)
    + only draws top and bottom lines when sfTop or sfBottom
    + slightly smaller focus width
  - TSmallMenuItem.GetHeight: minimum height = 20 + fontheight over 16
  - Changed values for icon and text positioning and menu width
  - Added sound event for menu click

* TASK:
  - Improved Taskbar animation in TTaskbar.ShowBar and TTaksbar.HideBar
     + Added full animatation option and speed control
     + Added options in TASKPROP.PAS and in TaskProp in SETTINGS.PAS
  - adjusted start menu popup position to slightly overlap taskbar
  - Changed all MessageBeep(0); to MessageBeep(MB_ICONHAND);
  - Implemented Jiri's applet system menu's
  - Added Christophe Melin's Start menu DDEBuffer check in StartButtonClick,
    so that the Start menu rebuilds after icons are added by a setup program.

* COMPSYS, SPLASH: Improved ShutDown behaviour
  (ALT-F4 now shows the shutdown dialog, OR closes start menu :(
   depending on what is last active. Still working on that)

* MULTIGRD: Moved Font.Color assignments for MultiGrid from
  DIRECTRY and ICONIC to MULTIGRD

* SETTINGS.PAS:
  - Added FullAnimate setting and speed control in TaskProp
    section (Improved Taskbar animation)
  - Added color option for checklist background
    + Assigned color (ccCheckList) in DESKPROP, FILTER, FSYSPROP,
      STRTPROP, SYSPROP and TASKPROP's FormCreate procedures.
  - Added DescriptionFile in File system properties

* MISCUTIL:
  - Improved icon shrinking in MISCUTIL.PAS
  - Added procedure DottedLineTo in MISCUTIL.PAS
  - Added GetButtonState and SetButtonState

* FSYSPROP:
  - Replaced cbDelay scrollbar with TSlider
  - Added description file name edit box

* TASKMAN:
  - Added Hide / Unhide button

* LOGON.PAS: Added
  - fixed a few bugs.
  - replaced UserEdit with UserCombo

* ICONWIN:
  - Added Li-Hsin's toolbar
  - Added sort and create folder buttons

* RESOURCE:
  - now looks first in user's directory for bitmaps

* WASTEBIN:
  - Binned files are immediately saved to INI
  - Moved Empty bin to right click popup menu

* SLIDER:
  - TSlider Added


Bug fixes:
* FILEPROP: filename/folder labels show correctly
* DRIVES: Volume label is now shown correctly
* SETTINGS: Win95 keyboard setting now correctly saved
* SYSPROP: Preflist resize; dirty fix for integral height bug
* TASKMAN: Calmira no longer minimized with 'Minimize all'
* TASK: Calmira no longer minimized with 'Minimize programs'
        Fixed vertical tiling
        TopTaskbar resizes more elegant
* CALFORM: Maximize > minimize > restore bug fixed
* WASTEBIN: fixed resize bug caused by CalForm bugfix :)
