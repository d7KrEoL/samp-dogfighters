#if !defined ADD_DOGFIGHT_DIALOG
#define ADD_DOGFIGHT_DIALOG

#define DEBUG_MODE_DF_MENU true
#define DF_MENU_ERROR_ID -2

#include "dogfighters\server\serverInfo\serverMain.pwn"
#include "dogfighters\server\menuDialogs\DialogStyles.pwn"
#include "dogfighters\server\menuDialogs\DialogID.pwn"
#include "dogfighters\server\events\SaveDogfightGlobal.pwn"



forward showAddDFDialog_Player1(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward showAddDFDialog_Player2(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward showAddDFDialog_Score1(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward showAddDFDialog_Score2(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward showAddDFDialog_YouTube1(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward showAddDFDialog_YouTube2(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward showAddDFDialog_Referee(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward showAddDFDialog_Summary(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);

forward processPlayer1Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward processPlayer2Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward processScore1Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward processScore2Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward processYouTube1Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward processYouTube2Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward processRefereeDialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);
forward processSummaryDialog(playerid, response, listitem, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo]);

public showAddDFDialog_Player1(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (dfInfo[usedBy] != NOTSET && dfInfo[usedBy] != playerid)
    {
        if (IsPlayerConnected(dfInfo[usedBy]) && serverPlayers[dfInfo[usedBy]][isLoggedIn])
        {
            printf("Player %s (%d) was trying to use /savedf when it was used by %d", 
                                                                                        serverPlayers[playerid][name], 
                                                                                        playerid,
                                                                                        serverPlayers[usedBy]);
            if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
                SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Dogfight adding panel is beasy at this moment. Try again later.");
            else
                SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������ ���������� ��������� ������ ������ ������ �������. ��������� �����.");
            return;
        }
    }
    dfInfo[usedBy] = playerid;
    if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_PL1, DIALOG_STYLE_INPUT, "Dogfight - Player1 ID", "Enter player 1 ID below:", "Set", "Reset");
    else
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_PL1, DIALOG_STYLE_INPUT, "Dogfight - ����� 1", "������� ID ������ 1 � ���� ����", "��", "�����");
}
public showAddDFDialog_Player2(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (isDFPanelBeasy(playerid, serverPlayers, dfInfo))
        return;
    if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_PL2, DIALOG_STYLE_INPUT, "Dogfight - Player2 ID", "Enter player 2 ID below:", "Set", "Back");
    else
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_PL2, DIALOG_STYLE_INPUT, "Dogfight - ����� 2", "������� ID ������ 2 � ���� ����", "��", "�����");
}
public showAddDFDialog_Score1(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (isDFPanelBeasy(playerid, serverPlayers, dfInfo))
        return;
    if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_SC1, DIALOG_STYLE_INPUT, "Dogfight - Player 1 score", "Enter player 1 score below:", "Set", "Back");
    else
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_SC1, DIALOG_STYLE_INPUT, "Dogfight - ���� ����� 1", "������� ���� ������ 1 � ���� ����", "��", "�����");
}
public showAddDFDialog_Score2(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (isDFPanelBeasy(playerid, serverPlayers, dfInfo))
        return;
    if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_SC2, DIALOG_STYLE_INPUT, "Dogfight - Player 2 score", "Enter player 2 score below:", "Set", "Back");
    else
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_SC2, DIALOG_STYLE_INPUT, "Dogfight - ���� ����� 2", "������� ���� ������ 2 � ���� ����", "��", "�����");
}
public showAddDFDialog_YouTube1(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (isDFPanelBeasy(playerid, serverPlayers, dfInfo))
        return;
    if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_YT1, DIALOG_STYLE_INPUT, "Dogfight - Video player 1", "Enter player 1 YouTube video URL below:", "Set", "Back");
    else
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_YT1, DIALOG_STYLE_INPUT, "Dogfight - ����� ����� 1", "������� ������ �� ����� �� ������ 1 � ���� ����", "��", "�����");
}
public showAddDFDialog_YouTube2(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (isDFPanelBeasy(playerid, serverPlayers, dfInfo))
        return;
    if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_YT2, DIALOG_STYLE_INPUT, "Dogfight - Video player 2", "Enter player 2 YouTube video URL below:", "Set", "Back");
    else
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_YT2, DIALOG_STYLE_INPUT, "Dogfight - ����� ����� 2", "������� ������ �� ����� �� ������ 2 � ���� ����", "��", "�����");
}
public showAddDFDialog_Referee(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (isDFPanelBeasy(playerid, serverPlayers, dfInfo))
        return;
    if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_REF, DIALOG_STYLE_INPUT, "Dogfight - Referee", "Enter referee player ID or -1 if it was\n\"no-referee\" match:", "Set", "Back");
    else
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_REF, DIALOG_STYLE_INPUT, "Dogfight - ���������", "������� ID ������, ���� -1 (���� ������ ��� ������)\n� ���� ����:", "��", "�����");
}

public showAddDFDialog_Summary(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    #if DEBUG_MODE_DF_MENU == true
    printf("showAddDFDialog_Summary %d %d", playerid, isDFPanelBeasy(playerid, serverPlayers, dfInfo));
    #endif

    if (isDFPanelBeasy(playerid, serverPlayers, dfInfo))
        return;
    new message[512];
    #if DEBUG_MODE_DF_MENU == true
    printf("[121] showAddDFDialog_Summary");
    #endif
        
    if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH) 
    {                                  
        SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Fields starting with '>' are neccessary, with '*' - optional");                   
        format(message, sizeof(message), ">Player1: %d\n\
                                        >Score player1: %d\n\
                                        >Player 2: %d\n\
                                        >Score player 2: %d\n\
                                        *Video link 1: %s\n\
                                        *Video link 2: %s\n\
                                        *Referee: %d\
                                        {00FF00}Save dogfight results",
                                                        dfInfo[player1ID],
                                                        dfInfo[player1Score],
                                                        dfInfo[player2ID],
                                                        dfInfo[player2Score],
                                                        dfInfo[videoPlayer1],
                                                        dfInfo[videoPlayer2],
                                                        dfInfo[refereeID]);                        
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_APPROVE, DIALOG_STYLE_LIST, "Dogfight - Summary", message, "Change", "Exit");
    }
    else
    { 
        SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "����, ������������ � '>' - ������������, � '*' - ������������");
        format(message, sizeof(message), "{FFAA00}>����� 1:{FFFFFF}ID:%d\n\
                                        {FF9900}>���� ������ 1:{FFFFFF}%d\n\
                                        {FF9900}>����� 2:{FFFFFF}ID:%d\n\
                                        {FF9900}>���� ������ 2:{FFFFFF}%d\n\
                                        {FFFF00}*������ �� ����� 1:{FFFFFF}%s\n\
                                        {FFFF00}*������ �� ����� 2:{FFFFFF}%s\n\
                                        {FFFF00}*�����:{FFFFFF}ID:%d\n\
                                        {00FF00}��������� ���������� ��������",
                                                        dfInfo[player1ID],
                                                        dfInfo[player1Score],
                                                        dfInfo[player2ID],
                                                        dfInfo[player2Score],
                                                        dfInfo[videoPlayer1],
                                                        dfInfo[videoPlayer2],
                                                        dfInfo[refereeID]);
        ShowPlayerDialog(playerid, DIALOG_ADD_DF_APPROVE, DIALOG_STYLE_LIST, "Dogfight - ����� ��������", message, "��������", "�����");
    }
    #if DEBUG_MODE_DF_MENU == true
    printf("[167] showAddDFDialog_Summary");
    #endif
}


public processPlayer1Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    #if DEBUG_MODE_DF_MENU == true
    printf("ProcessPlayer1Dialog");
    #endif
    if (!response)
    {
        dfInfo[usedBy] = NOTSET;
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Dogfight info adding cancelled");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "���������� ���������� � �������� ��������");
        return 1;
    }
    new value = validateNumberInput(playerid, inputtext);
    if (value == DF_MENU_ERROR_ID || value == NOTSET)
    {
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Error: bad input");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������: ������������ ����");
        showAddDFDialog_Player1(playerid, serverPlayers, dfInfo);
        return 1;
    }
    if (!IsPlayerConnected(value))
    {
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Error: player is not connected");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������: ����� � ����� ID �� ��������� � �������");
        showAddDFDialog_Player1(playerid, serverPlayers, dfInfo);
        return 1;
    }
    if (value == dfInfo[player2ID])
    {
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Error: both players cannot be the same");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������: ����� ����� ������ ������ ����?");
        showAddDFDialog_Player1(playerid, serverPlayers, dfInfo);
        return 1;
    }
    dfInfo[player1ID] = value;
    showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);

    #if DEBUG_MODE_DF_MENU == true
    printf("showAddDFDialog_Player2(%d)", playerid);
    #endif
    return 1;
}
public processPlayer2Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (!response)
    {
        showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
        return 1;
    }
    new value = validateNumberInput(playerid, inputtext);
    if (value == DF_MENU_ERROR_ID)
    {
        showAddDFDialog_Player2(playerid, serverPlayers, dfInfo);
        return 1;
    }
    if (!IsPlayerConnected(value))
    {
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Error: player is not connected");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������: ����� � ����� ID �� ��������� � �������");
        showAddDFDialog_Player2(playerid, serverPlayers, dfInfo);
        return 1;
    }
    if (value == dfInfo[player1ID])
    {
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Error: both players cannot be the same");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������: ����� ����� ������ ������ ����?");
        showAddDFDialog_Player2(playerid, serverPlayers, dfInfo);
        return 1;
    }
    dfInfo[player2ID] = value;
    showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
    return 1;
}
public processScore1Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (!response)
    {
        showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
        return 1;
    }
    new value = validateNumberInput(playerid, inputtext);
    if (value == DF_MENU_ERROR_ID)
    {
        showAddDFDialog_Score1(playerid, serverPlayers, dfInfo);
        return 1;
    }
    if (value < 0 || value > 10)
    {
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Error: score value can be only between 0 and 10");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������: ���� ����� ���� ������ � �������� �� 0 �� 10");
        showAddDFDialog_Score1(playerid, serverPlayers, dfInfo);
        return 1;
    }
    dfInfo[player1Score] = value;
    showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
    return 1;
}
public processScore2Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (!response)
    {
        showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
        return 1;
    }
    new value = validateNumberInput(playerid, inputtext);
    if (value == DF_MENU_ERROR_ID)
    {
        showAddDFDialog_Score2(playerid, serverPlayers, dfInfo);
        return 1;
    }
    if (value < 0 || value > 10)
    {
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Error: score value can be only between 0 and 10");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������: ���� ����� ���� ������ � �������� �� 0 �� 10");
        showAddDFDialog_Score2(playerid, serverPlayers, dfInfo);
        return 1;
    }
    dfInfo[player2Score] = value;
    showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
    return 1;
}
public processYouTube1Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (!response)
    {
        showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
        return 1;
    }
    sscanf(inputtext, "s[127]", dfInfo[videoPlayer1]);
    showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
    return 1;
}
public processYouTube2Dialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    if (!response)
    {
        showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
        return 1;
    }
    sscanf(inputtext, "s[127]", dfInfo[videoPlayer2]);
    showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
    return 1;
}
public processRefereeDialog(playerid, response, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    #if DEBUG_MODE_DF_MENU == true
    printf("processRefereeDialog: %d (%s)", playerid, inputtext);
    #endif
    if (!response)
    {
        showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
        return 1;
    }
    new value = strval(inputtext);
    if (value < -1 || value > MODE_MAX_PLAYERS)
    {
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Error: wrong input");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������: �������� ����");
        showAddDFDialog_Referee(playerid, serverPlayers, dfInfo);
        return 1;
    }
    if (!IsPlayerConnected(value) && value != NOTSET)
    {
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Error: player is not connected!");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������: ������ � ����� ID ��� �� �������");
        showAddDFDialog_Referee(playerid, serverPlayers, dfInfo);
        return 1;
    }
    dfInfo[refereeID] = value;
    #if DEBUG_MODE_DF_MENU == true
    printf("referee value set to: %d (value: %d)", dfInfo[refereeID], value);
    #endif
    showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
    return 1;
}

public processSummaryDialog(playerid, response, listitem, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    /*Player1:%s (%d)\nScore player1:%d\nPlayer 2:%s (%d)\nScore player 2:%d\nReferee: id%d*/
    if (!response)
    {
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Dogfight saving cancelled");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������������ ������ � �������� ��������");
        ResetDogfightInfo(dfInfo);
        return 1;
    }
    switch (listitem)
    {
        case 0:
        {
            showAddDFDialog_Player1(playerid, serverPlayers, dfInfo);
        }
        case 1:
        {
            showAddDFDialog_Score1(playerid, serverPlayers, dfInfo);
        }
        case 2:
        {
            showAddDFDialog_Player2(playerid, serverPlayers, dfInfo);
        }
        case 3:
        {
            showAddDFDialog_Score2(playerid, serverPlayers, dfInfo);
        }
        case 4:
        {
            showAddDFDialog_YouTube1(playerid, serverPlayers, dfInfo);
        }
        case 5:
        {
            showAddDFDialog_YouTube2(playerid, serverPlayers, dfInfo);
        }
        case 6:
        {
            showAddDFDialog_Referee(playerid, serverPlayers, dfInfo);
        }
        case 7:
        {
            if (dfInfo[player1ID] == NOTSET || 
            dfInfo[player2ID] == NOTSET || 
            dfInfo[player1Score] == NOTSET ||
            dfInfo[player2Score] == NOTSET)
            {
                if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
                    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Not all neccessary fields are filled");
                else
                    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "��������� �� ��� ������������ ����!");
                showAddDFDialog_Summary(playerid, serverPlayers, dfInfo);
                return 1;
            }
            SaveDogfightData(dfInfo, serverPlayers);
            ResetDogfightInfo(dfInfo);
            new messageEN[256];
            new messageRU[256];
            format(messageEN, sizeof(messageEN), "[ADM]: %s (%d) saved df: %s (%d) [%d:%d] (%d) %s",
                                                                                                serverPlayers[playerid][name],
                                                                                                playerid,
                                                                                                serverPlayers[dfInfo[player1ID]][name],
                                                                                                dfInfo[player1ID],
                                                                                                dfInfo[player1Score],
                                                                                                dfInfo[player2Score],
                                                                                                dfInfo[player2ID],
                                                                                                serverPlayers[dfInfo[player2ID]][name]);
            format(messageRU, sizeof(messageRU), "[ADM]: %s (%d) �������� ��: %s (%d) [%d:%d] (%d) %s",
                                                                                                serverPlayers[playerid][name],
                                                                                                playerid,
                                                                                                serverPlayers[dfInfo[player1ID]][name],
                                                                                                dfInfo[player1ID],
                                                                                                dfInfo[player1Score],
                                                                                                dfInfo[player2Score],
                                                                                                dfInfo[player2ID],
                                                                                                serverPlayers[dfInfo[player2ID]][name]);
            sendLocalizedMessage(messageRU, messageEN, COLOR_SYSTEM_DISCORD, serverPlayers);
        }
    }
    return 1;
}

/*
#define DIALOG_ADD_DF_PL1 41
#define DIALOG_ADD_DF_PL2 42
#define DIALOG_ADD_DF_SC1 43
#define DIALOG_ADD_DF_SC2 44
#define DIALOG_ADD_DF_YT1 45
#define DIALOG_ADD_DF_YT2 46
#define DIALOG_ADD_DF_REF 47
#define DIALOG_ADD_DF_APPROVE 48
*/

stock validateNumberInput(playerid, inputtext[])
{
    new value = strval(inputtext);
    if (value == NOTSET)    //  !another check needed!
    {
        //if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
        SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Wrong input!");
        /*else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "�������� ����");*/
        return DF_MENU_ERROR_ID;
    }
    return value;
}

stock isDFPanelBeasy(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer], dfInfo[DogfightInfo])
{
    #if DEBUG_MODE_DF_MENU == true
    printf("isDFPanelBeasy %d, [usedBy: %d]", playerid, dfInfo[usedBy]);
    #endif
    if (dfInfo[usedBy] != NOTSET && dfInfo[usedBy] != playerid)
    {
        printf("Player %s (%d) was trying to use /savedf [stage 1+] (he has no rights, current user: (%d))", 
                                                                                        serverPlayers[playerid][name], 
                                                                                        playerid,
                                                                                        serverPlayers[usedBy]);
        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Dogfight adding panel is beasy at this moment. Try again later.");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "������ ���������� ��������� ������ ������ ������ �������. ��������� �����.");
        return true;
    }
    return false;
}

#endif