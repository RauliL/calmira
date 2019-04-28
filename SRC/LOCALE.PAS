{**************************************************************************}
{                                                                          }
{    Calmira II shell for Microsoft® Windows(TM) 3.1                       }
{    Online! Release 3.3                                                  }
{    Copyright (C) 1998-2002 Calmira Online!                               }
{    Copyright (C) 1997-1998 Li-Hsin Huang                                 }
{                                                                          }
{    This program is free software; you can redistribute it and/or modify  }
{    it under the terms of the GNU General Public License as published by  }
{    the Free Software Foundation; either version 2 of the License, or     }
{    (at your option) any later version.                                   }
{                                                                          }
{    This program is distributed in the hope that it will be useful,       }
{    but WITHOUT ANY WARRANTY; without even the implied warranty of        }
{    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         }
{    GNU General Public License for more details.                          }
{                                                                          }
{    You should have received a copy of the GNU General Public License     }
{    along with this program; if not, write to the Free Software           }
{    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.             }
{                                                                          }
{**************************************************************************}

unit Locale;

interface

{$R LOCALE.RES}

const
  SCannotFindLicense = 1024;
  SCannotRunNotepad = 1025;
  SWelcome = 1026;
  SCannotMoveToBin = 1027;
  SCannotRestoreItem = 1028;
  SCannotRestoreFolderOverFile = 1029;
  SQueryReplaceFile = 1030;
  SDriveRefPrompt = 1031;
  SFolderRefPrompt = 1032;
  SFileRefPrompt = 1033;
  SInternetRefPrompt = 1034;

  SMenuCascadeBrowsers = 1040;
  SMenuArrangeIcons = 1041;
  SMenuLineUpIcons = 1042;
  SMenuCloseBrowsers = 1043;
  SMenuClearDesktop = 1044;
  SMenuProperties = 1045;
  SMenuAbout = 1046;
  SSelectFolder = 1047;
  SAliasProperties = 1048;
  SShortcutProperties = 1049;
  SMenuShortcutProperties = 1050;
  SMenuShortcutOpen = 1051;
  SMenuShortcutRemove = 1052;
  SMenuShortcutMove = 1053;
  SMenuBinEmpty = 1054;

  SCloseUnnamedDialog = 1056;
  SCloseSpecificDialog = 1057;
  SNotifyEndWindows = 1058;
  SQueryQuit = 1059;
  SOpenFolder = 1060;
  SFolderName = 1061;
  SUnknownCommand = 1062;
  SCannotOpenFolder = 1063;
  SQueryReplaceAlias = 1064;
  SCannotOpenTarget = 1065;
  SQueryDeleteShortcut = 1066;

  SFileAlreadyExists = 1072;
  SFolderAlreadyExists = 1073;
  SCannotChangeAttr = 1074;
  SInvalidFilename = 1075;
  SCannotRename = 1076;
  SChangeDescription = 1077;
  SDescribe = 1078;
  SCannotOpenFileWith = 1079;
  SCannotPutFolderOnSelf = 1080;
  SCannotPutFolderInSelf = 1081;
  SCannotPutFolderOverFile = 1082;

  SQueryAffectProtected = 1088;
  SCannotCopyFileToSelf = 1089;
  SCannotMoveFileToSelf = 1090;
  SCannotCreateFolder = 1091;
  SCannotReplaceFile = 1092;
  SCannotMoveFile = 1093;
  SCannotCyclicCopy = 1094;
  SCannotCyclicMove = 1095;
  SCannotDeleteFile = 1096;
  SNoFilesFound = 1097;
  SCannotRunDefViewer = 1098;
  SFileNotAssociated = 1099;
  SCannotRunOrView = 1100;
  SConfirmNewFolder = 1101;

  SNetSuccess = 1104;
  SNetNotSupported = 1105;
  SOutOfMemory = 1106;
  SNetError = 1107;
  SBadPointer = 1108;
  SBadNetworkResource = 1109;
  SBadLocalName = 1110;
  SInvalidPassword = 1111;
  SAccessDenied = 1112;
  SFilesWereOpen = 1113;
  SAlreadyConnected = 1114;
  SNetOperationFailed = 1115;
  SQueryCloseOpenFiles = 1116;

  SQueryBinItems = 1119; { 3.11 }
  SQueryCopyItems = 1120;
  SQueryMoveItems = 1121;
  SQueryDeleteItems = 1122;
  SCannotPutToSelf = 1123;
  SCreateFolder = 1124;
  SNewFolderName =1125;
  SRename = 1126;
  SNewFilename = 1127;
  SCreateAlias = 1128;
  SAliasFilename = 1129;
  SPrintFile = 1130;
  SFilename = 1131;
  SDuplicateFile = 1132;
  SDirectoryOf = 1133;

  SCopy = 1136;
  SMove = 1137;
  SDelete = 1138;
  SCopyFile = 1139;
  SMoveFile = 1140;
  SCopyFolder = 1141;
  SMoveFolder = 1142;
  SDeleteFile = 1143;
  SDeleteFolder = 1144;
  SProgressCopy = 1145;
  SProgressMove = 1146;
  SProgressDelete = 1147;
  SProgressBinning = 1148;
  SProgressRestoring = 1149;
  SProgressEmptying = 1150;

  SAddMenuItem = 1152;
  SInsertMenuItem = 1153;
  SMenuItemProperties = 1154;
  SQueryDeleteMenu = 1155;
  SCannotFindProgman = 1156;
  SCaptionNeedsText = 1157;
  SQuerySaveAdvanced = 1158;
  SAddAdvanced = 1159;
  SIdentValue = 1160;
  SModifyAdvanced = 1161;
  SAddExclusion = 1162;
  SModifyExclusion = 1163;
  SModuleClass = 1164;
  SAddApplet = 1165;
  SModifyApplet = 1166;
  SAppletFormat = 1167;

  SUnknown = 1168;
  SFolderContents = 1169;
  SSelectionContents = 1170;
  STotalContents = 1171;
  SVersion = 1172;
  SAssociation = 1173;
  SAssociateTypeWith = 1174;
  SNoRegCommand = 1175;
  SSpecifyFiles = 1176;
  SStopSearch = 1177;
  SStartSearch = 1178;
  SNoMatchingFiles = 1179;
  SFindListboxFull = 1180;

  SProductName = 1184;
  SLegalCopyright = 1185;
  SDescription = 1186;
  SType = 1187;
  SSubType = 1188;
  SFileOS = 1189;
  SComments = 1190;
  SProductVersion = 1191;
  SFileVersion = 1192;
  SCompany = 1193;
  SLegalTrademarks = 1194;
  SInternalName = 1195;
  SPrivateBuild = 1196;
  SSpecialBuild = 1197;
  SOriginalFilename = 1198;
  SWOWVersion = 1199;

  SQueryTerminate = 1200;
  SCreateNewUser = 1201;
  SUserName = 1202;
  SEnterPassword = 1203;
  SConfirmPassword = 1204;
  SChangePassword = 1205;
  SEnterOldPassword = 1206;
  SEnterNewPassword = 1207;
  SConfirmNewPassword = 1208;
  SInvalidUserName = 1209;
  SPasswordMismatch = 1210;
  SEditEntryCaption = 1211;
  SInvalidOldPassword = 1212;

  SMObjOpen       = 1216;
  SMObjOpenWith   = 1217;
  SMObjInspect    = 1218;
  SMObjCut        = 1219;
  SMObjCopy       = 1220;
  SMObjPaste      = 1221;
  SMObjDelete     = 1222;
  SMObjRename     = 1223;
  SMObjDescribe   = 1224;
  SMObjEditAlias  = 1225;
  SMObjDuplicate  = 1226;
  SMObjProperties = 1227;

  SMWinLargeIcons   = 1232;
  SMWinSmallIcons   = 1233;
  SMWinDetails      = 1234;
  SMWinSortByName   = 1235;
  SMWinSortByType   = 1236;
  SMWinSortBySize   = 1237;
  SMWinSortByDate   = 1238;
  SMWinFileSystem   = 1239;
  SMWinSetFilter    = 1240;
  SMWinCreateFolder = 1241;
  SMWinCreateAlias  = 1242;

  { 3.1 }
  SCorruptEXE  = 1250;
  SFileNotFound = 1251;
  SSharingError = 1252;
  SDLLFailed = 1253;
  SAppOutOfMemory = 1254;
  SIncorrectWinVer = 1255;
  SInvalidEXE = 1256;
  SNonWindowsApp = 1257;
  SRealModeApp = 1258;
  SSecondInstance = 1259;
  SCompressedEXE = 1260;
  SCorruptDLL = 1261;
  SRequiresWin32 = 1262;

  { 3.2 }
  STHintParent = 1270;
  STHintNewFolder = 1271;
  STHintConnect = 1272;
  STHintDisConnect = 1273;
  STHintCut = 1274;
  STHintCopy = 1275;
  STHintPaste = 1276;
  STHintDelete = 1277;
  STHintRename = 1278;
  STHintProperties = 1279;
  STHintLargeIcons = 1280;
  STHintSmallIcons = 1281;
  STHintDetails = 1282;
  STHintSortName = 1283;
  STHintSortType = 1284;
  STHintSortSize = 1285;
  STHintSortDate = 1286;

  SCFilename = 1290;
  SCSize = 1291;
  SCType = 1292;
  SCModified = 1293;
  SCAttributes = 1294;
  SCDescription = 1295;
  SCFile =1296;
  SCFolder = 1297;
  SCAlias = 1298;

implementation

end.

