#if !defined COMMAND_ADM_KICK
#define COMMAND_ADM_KICK

#include "dogfighters\server\serverInfo\serverMain.pwn"
#include "dogfighters\player\localization\PlayerLanguage.pwn"
#include "dogfighters\database\databaseMain.pwn"

forward CommandKickAdm(playerid, const params[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);

public CommandKickAdm(playerid, const params[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
    new playerLevel = LoginSystem_GetAccessLevel(playerid, serverPlayers);
    if (playerLevel < 3)
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] Not enough access rights for this command");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] ������������ ���� ��� ������������� ���� �������");
        return 1;
    }
    if (isnull(params))
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] Syntax: /kick [ID]");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] ���������: /kick [ID]");
	    return 1;
    }
    new targetid, reason[32];
    if (sscanf(params, "ds[32]", targetid, reason))
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] Syntax: /kick [ID] [Reason]");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] ���������: /kick [ID] [�������]");
	    return 1;
    }
    if (!IsPlayerConnected(targetid))
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] Player is not connected");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] ����� � ����� ID �� ��������� � �������");
	    return 1;
    }
    if (targetid == playerid)
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] You cannot kick yourself");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] �����������, �� ������ ������� ������ ����");
	    return 1;
    }
    new targetLevel = LoginSystem_GetAccessLevel(targetid, serverPlayers);
    if (targetLevel >= playerLevel)
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] Not enough access rights to kick this player");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/kick] ������������ ���� ����� ������� ����� ������");
	    return 1;
    }
    new messageRU[128];
    new messageEN[128];
    format(messageRU, sizeof(messageRU), "������������� %s (%d) ������ ������ %s (%d) [�������: %s]",
                                                                                                    serverPlayers[playerid][name],
                                                                                                    playerid,
                                                                                                    serverPlayers[targetid][name],
                                                                                                    targetid,
                                                                                                    reason);
    format(messageEN, sizeof(messageEN), "Administrator %s (%d) has kicked player %s (%d) [reason: %s]",
                                                                                                    serverPlayers[playerid][name],
                                                                                                    playerid,
                                                                                                    serverPlayers[targetid][name],
                                                                                                    targetid,
                                                                                                    reason);
    sendLocalizedMessage(messageRU, messageEN, COLOR_SYSTEM_DISCORD, serverPlayers);
    Kick(targetid);
    return 1;
}

#endif