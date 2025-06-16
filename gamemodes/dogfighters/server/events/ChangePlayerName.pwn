#if !defined CHANGE_NAME_GLOBAL
#define CHANGE_NAME_GLOBAL
#include "requests.inc"
#include "dogfighters\server\events\SaveDogfightsSensitive.pwn"
#include "dogfighters\server\serverMain.pwn"

forward ChangeDogfighterName(userName[], newName[]);

public ChangeDogfighterName(userName[], newName[])
{
    new requestUri[2048];
	format(requestUri,
		sizeof(requestUri),
		"%s://%s:%s/",
		API_DF_PROTOCOL,
		API_DF_HOST,
        API_DF_PORT,
        userName
	);
    new requestHeaders[256];
    format(requestHeaders,
        sizeof(requestHeaders),
        "Content-Type:application/json");
    new requestBody[256];
    format(requestBody,
        sizeof(requestBody),
        "\"newName\": \"%s,\n\"referee\": \"%s\"",
        newName,
        API_DF_CERTIFICATE
    );
    new RequestsClient:https = RequestsClient(requestUri);
    new validation = IsValidRequestsClient(https);
    printf("Is valid requests client: %s", validation ? "true" : "false");
    if (!validation)
        return false;
    new api_player_endpoint[256];
    format(api_player_endpoint, sizeof(api_player_endpoint), "Player/changenamepawn");
    new Request:request = RequestJSON(https,
        api_player_endpoint,
        HTTP_METHOD_POST,
        "@OnChangeDogfighterName",
        JsonObject(
            "oldName", JsonString(userName),
            "newName", JsonString(newName),
            "referee", JsonString(API_DF_CERTIFICATE)
        )
    );
    validation = IsValidRequest(request);
    printf("Is valid request: %s", validation ? "true" : "false");
    if (!validation)
        return false;
    printf("Sending request:\n[url]\n%s%s\n[headers]\n%s\n[body]\n%s", 
        requestUri,
        api_player_endpoint,
        requestHeaders,
        requestBody);
    return true;
}
@OnChangeDogfighterName(Request:id, E_HTTP_STATUS:status, data[], dataLen);
@OnChangeDogfighterName(Request:id, E_HTTP_STATUS:status, data[], dataLen)
{
	if(status == HTTP_STATUS_OK) {
        printf("Successfully changed nickname!");
    }
    else
        printf("Nickname was not changed (Bad response from server)");
}
public OnRequestFailure(Request:id, errorCode, errorMessage[], len)
{
    printf("Request failure. ID: %d Error code:%d, Error message: %s", int:id, errorCode, errorMessage);
}

#endif