#if !defined COMMAND_CHANGE_PASSWORD
#define COMMAND_CHANGE_PASSWORD

#include "dogfighters\server\serverInfo\serverMain.pwn"
#include "dogfighters\player\localization\PlayerLanguage.pwn"
#include "dogfighters\database\databaseMain.pwn"
#include "dogfighters\server\commands\CommandChangePassword.pwn"

forward CommandChangePassword(playerid, const params[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);

public CommandChangePassword(playerid, const params[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
    new message[MAX_PLAYER_NAME + 75];
    new paramValue[33];
    if (sscanf(params, "s[32]", paramValue))
	{
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            format(message, sizeof(message), "[/password]: Please enter new password into a dialog box");
        else
            format(message, sizeof(message), "[/password]: ������� ����� ������ � ���������� ����");
        SendClientMessage(playerid, COLOR_SYSTEM_MAIN, message);
        showEnterNewPasswordDialog(playerid, serverPlayers);
        return 1;
	}
    LoginSystem_OnChangePassword(playerid, paramValue, serverPlayers);
	return 1;
}

#endif