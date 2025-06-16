#if !defined CHANGE_NAME_DIALOG
#define CHANGE_NAME_DIALOG
#include "dogfighters\server\serverInfo\serverMain.pwn"
#include "dogfighters\server\menuDialogs\DialogStyles.pwn"
#include "dogfighters\server\menuDialogs\DialogID.pwn"
#include "dogfighters\player\localization\PlayerLanguage.pwn"

forward showEnterNewNicknameDialog(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);

public showEnterNewNicknameDialog(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{  
    if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
        ShowPlayerDialog(playerid, DIALOG_ID_CHANGENAME, DIALOG_STYLE_INPUT, "Change nickname", "Enter new nickname below:", "Set", "Cancel");
    else
        ShowPlayerDialog(playerid, DIALOG_ID_CHANGENAME, DIALOG_STYLE_INPUT, "—мена ника", "¬ведите новый ник в поле ниже:", "”становить", "ќтмена");
}
#endif