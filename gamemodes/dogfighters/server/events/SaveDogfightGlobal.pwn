#if !defined SAVE_DOGFIGHT_GLOBAL
#define SAVE_DOGFIGHT_GLOBAL
#define DEBUG_MODE_SV_DOGFIGHT true
#include "requests.inc"
#include "dogfighters\server\events\SaveDogfightsSensitive.pwn"
#include "dogfighters\server\serverMain.pwn"

enum DogfightInfo
{
    usedBy,
    player1ID,
    player2ID,
    player1Score,
    player2Score,
    videoPlayer1[128],
    videoPlayer2[128],
    tournamentName[33],
    tournamentStage[33],
    refereeID
}

forward ResetDogfightInfo(dogfightInfo[DogfightInfo]);
forward SaveDogfightPvpData(winnerID, looserID, serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);
forward SaveDogfightData(dogfightInfo[DogfightInfo], serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);

public ResetDogfightInfo(dogfightInfo[DogfightInfo])
{
    dogfightInfo[usedBy] = NOTSET;
    dogfightInfo[player1ID] = NOTSET;
    dogfightInfo[player2ID] = NOTSET;
    dogfightInfo[refereeID] = NOTSET;
    dogfightInfo[player1Score] = 0;
    dogfightInfo[player2Score] = 0;
    format(dogfightInfo[videoPlayer1], 128, "");
    format(dogfightInfo[videoPlayer2], 128, "");
    format(dogfightInfo[tournamentName], 33, "");
    format(dogfightInfo[tournamentStage], 33, "");
}

public SaveDogfightData(dogfightInfo[DogfightInfo], serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
    #if DEBUG_MODE_SV_DOGFIGHT == true
    printf("SaveDogfightData");
    printf("SaveDogfightData: %s (%d) [%d : %d] %s (%d) <ref: (%d)>", 
                                                                    serverPlayers[dogfightInfo[player1ID]][name],
                                                                    dogfightInfo[player1ID],
                                                                    dogfightInfo[player1Score],
                                                                    dogfightInfo[player2Score],
                                                                    serverPlayers[dogfightInfo[player2ID]][name],
                                                                    dogfightInfo[player2ID],
                                                                    dogfightInfo[refereeID]);
    printf("SaveDogfightData1");
    #endif
    if(dogfightInfo[player1ID] == NOTSET || dogfightInfo[player2ID] == NOTSET)
    {
        #if DEBUG_MODE_SV_DOGFIGHT == true
        printf("Cannot create dogfight! Player1 or Player2 id is not set: %d, %d", dogfightInfo[player1ID], dogfightInfo[player2ID]);
        #endif
        return;
    }
    new refereeCertificate[257];
    if (!IsPlayerConnected(dogfightInfo[refereeID]))
        format(refereeCertificate, sizeof(refereeCertificate), API_DF_CERTIFICATE);
    else
    {
        LoginSystem_RefereeGetCert(dogfightInfo[refereeID], refereeCertificate, serverPlayers);
        format(refereeCertificate, sizeof(refereeCertificate), "%s", refereeCertificate);
    }

    #if DEBUG_MODE_SV_DOGFIGHT == true
    printf("SaveDogfightData ref: %s (%d)", refereeCertificate, dogfightInfo[refereeID]);
    #endif

    new req[2048];
	format(req,
		sizeof(req),
		"%s://%s:%s",
		API_DF_PROTOCOL,
		API_DF_HOST,
        API_DF_PORT
	);

    #if DEBUG_MODE_SV_DOGFIGHT == true
    printf("[73]---->Request: %s", req);
    printf("namePlayer1=%s\n\
            namePlayer2=%s\n\
            scorePlayer1=%d\n\
            scorePlayer2=%d\n\
            videoPlayer1=%s\n\
            videoPlayer2=%s\n\
            tournamentName=%s\n\
            tournamentStage=%s\n\
            referee=%s", 
            serverPlayers[dogfightInfo[player1ID]][name],
            serverPlayers[dogfightInfo[player2ID]][name],
            dogfightInfo[player1Score],
            dogfightInfo[player2Score],
            dogfightInfo[videoPlayer1],
            dogfightInfo[videoPlayer2],
            dogfightInfo[tournamentName],
            dogfightInfo[tournamentStage],
            refereeCertificate);
    #endif
    new RequestsClient:https = RequestsClient(req);
    RequestJSON(https,
        API_DF_URL,
        HTTP_METHOD_POST,
        "@OnSaveDogfightResult",
        JsonObject(
            "namePlayer1", JsonString(serverPlayers[dogfightInfo[player1ID]][name]),
            "namePlayer2", JsonString(serverPlayers[dogfightInfo[player2ID]][name]),
            "scorePlayer1", JsonInt(dogfightInfo[player1Score]),
            "scorePlayer2", JsonInt(dogfightInfo[player2Score]),
            "videoPlayer1", JsonString(dogfightInfo[videoPlayer1]),
            "videoPlayer2", JsonString(dogfightInfo[videoPlayer2]),
            "tournamentName", JsonString(dogfightInfo[tournamentName]),
            "tournamentStage", JsonString(dogfightInfo[tournamentStage]),
            "referee", JsonString(refereeCertificate)
        )
    );
    
    #if DEBUG_MODE_SV_DOGFIGHT == true
    printf("SaveDogfightData end");
    #endif
}

public SaveDogfightPvpData(winnerID, looserID, serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
    new dfInfo[DogfightInfo];
    dfInfo[player1ID] = winnerID;
    dfInfo[player2ID] = looserID;
    dfInfo[refereeID] = NOTSET;
    dfInfo[player1Score] = serverPlayers[winnerID][pvpscore];
    dfInfo[player2Score] = serverPlayers[looserID][pvpscore];
    format(dfInfo[videoPlayer1], 128, "");
    format(dfInfo[videoPlayer2], 128, "");
    format(dfInfo[tournamentName], 33, "");
    format(dfInfo[tournamentStage], 33, "");
    SaveDogfightData(dfInfo, serverPlayers);
    new messageEN[100];
    new messageRU[100];
    format(messageEN, sizeof(messageEN), "Dogfight results auto-saved: %s (%d) [%d:%d] (%d) %s",
                                                                                        serverPlayers[dfInfo[player1ID]][name],
                                                                                        dfInfo[player1ID],
                                                                                        dfInfo[player1Score],
                                                                                        dfInfo[player2Score],
                                                                                        dfInfo[player2ID],
                                                                                        serverPlayers[dfInfo[player2ID]][name]);
    format(messageRU, sizeof(messageRU), "Результаты догфайта автоматически сохранены: %s (%d) [%d:%d] (%d) %s",
                                                                                        serverPlayers[dfInfo[player1ID]][name],
                                                                                        dfInfo[player1ID],
                                                                                        dfInfo[player1Score],
                                                                                        dfInfo[player2Score],
                                                                                        dfInfo[player2ID],
                                                                                        serverPlayers[dfInfo[player2ID]][name]);
    sendLocalizedMessage(messageRU, messageEN, COLOR_SYSTEM_DISCORD, serverPlayers);
}

//  When get request result received
/*@OnSaveDogfightResult(Request:id, E_HTTP_STATUS:status, Node:node);
@OnSaveDogfightResult(Request:id, E_HTTP_STATUS:status, Node:node)*/
@OnSaveDogfightResult(Request:id, E_HTTP_STATUS:status, data[], dataLen);
@OnSaveDogfightResult(Request:id, E_HTTP_STATUS:status, data[], dataLen)
{
	if(status == HTTP_STATUS_OK) {
        printf("Successfully added Dogfight!");
    }
}


#endif