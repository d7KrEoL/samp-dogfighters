#if !defined COMMAND_SET_CERT
#define COMMAND_SET_CERT

#include "dogfighters\server\serverInfo\serverMain.pwn"
#include "dogfighters\player\localization\PlayerLanguage.pwn"
#include "dogfighters\database\databaseMain.pwn"

forward CommandSetCertificate(playerid, const params[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);

public CommandSetCertificate(playerid, const params[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
    if (isnull(params))
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/changecert] Syntax:[/changecert [Certificate]");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/changecert] Синтаксис:[/changecert [Сертификат]");
	    return 1;
    }
	new certificate[257];
	if (sscanf(params, "s[256]", certificate))
	{
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/changecert] Syntax:[/changecert [Certificate]");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/changecert] Синтаксис:[/changecert [Сертификат]");
	    return 1;
	}
    if (!LoginSystem_RefereeSetCert(playerid, certificate, serverPlayers))
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/changecert] Error changing access certificate. Please contact server administrator to fix this.");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/changecert] Не получилось изменить ваш сертификат. Обратитесь к администрации сервера.");
	    return 1;
    }
    else
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/changecert] Your referee access certificate was successfully changed!");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/changecert] Ваш сертификат судьи был успешно изменён!");
    }
    return 1;
}

#endif