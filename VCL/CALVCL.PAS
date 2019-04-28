{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit CalVCL;

interface

procedure Register;

implementation

uses Classes, ApHolder, SysMenu, LabelSel, DropServ, DropClnt,
  StylSped, PicBtn, ChkList, PathCmbo, ScrTree, MultiGrd, Internet,
  BarGauge, Win95Pie, TabPanel, Slider, SortHdr, IconDlg, NetDlgs;

procedure Register;
begin
  RegisterComponents('Calmira', [TAppHolder, TSystemMenu,
    TLabelSelect, TPathComboBox, TScrollTree, TMultiGrid, TCheckList,
    TBrowserLink, TDropServer, TDropClient, TPicBtn, TStyleSpeed,
    TBarGauge, TWin95Gauge, TWin95PieChart, TTabPanel, TSlider,
    TSortHeader]);
  RegisterComponents('Dialogs', [TIconDialog,
    TNetConnectDialog, TNetDisconnectDialog,
    TNetShareAsDialog, TNetStopShareDialog]);
end;

end.
