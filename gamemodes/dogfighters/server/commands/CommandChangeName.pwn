#if !defined COMMAND_CHANGE_NAME
#define COMMAND_CHANGE_NAME

#include "dogfighters\server\serverInfo\serverMain.pwn"
#include "dogfighters\player\localization\PlayerLanguage.pwn"
#include "dogfighters\database\databaseMain.pwn"
#include "dogfighters\server\commands\CommandChangeName.pwn"

forward CommandChangeName(playerid, const params[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);

public CommandChangeName(playerid, const params[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
    new message[MAX_PLAYER_NAME + 75];
    new paramValue[21];
    if (sscanf(params, "s[20]", paramValue))
	{
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            format(message, sizeof(message), "[/changename]: Please enter new name into a dialog box");
        else
            format(message, sizeof(message), "[/changename]: Введите новый ник в диалоговом окне");
        SendClientMessage(playerid, COLOR_SYSTEM_MAIN, message);
        showEnterNewNicknameDialog(playerid, serverPlayers);
        return 1;
	}
    new oldName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, oldName, sizeof(oldName));
    printf("[CommandChangeName]: Player %s (%d) is trying to change name to %s", oldName, playerid, paramValue);
    switch(SetPlayerName(playerid, paramValue))
    {
        case -1:
        {
            if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
                format(message, sizeof(message), "[/changename]: Player with that name is already registered");
            else
                format(message, sizeof(message), "[/changename]: Игрок с таким ником уже зарегистрирован");
            return 1;
        }
        case 0:
        {
            if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
                format(message, sizeof(message), "[/changename]: It's already your nickname");
            else
                format(message, sizeof(message), "[/changename]: У вас уже такой ник");
            return 1;
        }
        case 1:
        {
            printf("Player %s (%d) is trying to change name to %s", oldName, playerid, paramValue);
        }
    }
    if (LoginSystem_OnChangeName(playerid, paramValue, serverPlayers))
    {
        print("Changing player name in df system was approved");
        ChangeDogfighterName(oldName, paramValue);
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            format(message, sizeof(message), "[/changename]: Your nickname has been changed to %s in df system", paramValue);
        else
            format(message, sizeof(message), "[/changename]: Ваш ник изменён на %s в системе", paramValue);
        SendClientMessage(playerid, COLOR_SYSTEM_MAIN, message);
        printf("Name of player %s (%d) was changed to %s", oldName, playerid, paramValue);
    }
    else
    {
        SetPlayerName(playerid, oldName);
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            format(message, sizeof(message), "[/changename]: You cannot change nickname that quick (once per 3 days)");
        else
            format(message, sizeof(message), "[/changename]: Нельзя так часто менять ник (не чаще чем раз в 3 дня)");
        SendClientMessage(playerid, COLOR_SYSTEM_MAIN, message);
        printf("Player %s (%d) is trying to change name too quick", oldName, playerid);
    }
	return 1;
}

#endif