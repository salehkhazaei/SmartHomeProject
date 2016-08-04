#ifndef __HEADER
#define __HEADER

#ifndef UNICODE
#define UNICODE
#endif

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0600
#endif

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <windows.h>
#include <http.h>
#include <stdio.h>
#include <string>
#include <sstream>
#include <string>
#include <iostream>
#include <clocale>
#include <locale>
#include <vector>
#include <fstream>
#pragma comment(lib, "httpapi.lib")

//
// Macros.
//
#define INITIALIZE_HTTP_RESPONSE( resp, status, reason )    \
    do                                                      \
		    {                                                       \
        RtlZeroMemory( (resp), sizeof(*(resp)) );           \
        (resp)->StatusCode = (status);                      \
        (resp)->pReason = (reason);                         \
        (resp)->ReasonLength = (USHORT) strlen(reason);     \
		    } while (FALSE)

#define ADD_KNOWN_HEADER(Response, HeaderId, RawValue)               \
    do                                                               \
		    {                                                                \
        (Response).Headers.KnownHeaders[(HeaderId)].pRawValue =      \
                                                          (RawValue);\
        (Response).Headers.KnownHeaders[(HeaderId)].RawValueLength = \
            (USHORT) strlen(RawValue);                               \
		    } while(FALSE)

#define ALLOC_MEM(cb) HeapAlloc(GetProcessHeap(), 0, (cb))

#define FREE_MEM(ptr) HeapFree(GetProcessHeap(), 0, (ptr))

//
// Prototypes.
//
DWORD DoReceiveRequests(HANDLE hReqQueue, HANDLE h2);

DWORD
SendHttpResponse(
IN HANDLE        hReqQueue,
IN PHTTP_REQUEST pRequest,
IN USHORT        StatusCode,
IN PSTR          pReason,
IN PSTR          pEntity,
ULONG size = -1,
char * contentType = "text/html"
);

DWORD
SendHttpPostResponse(
IN HANDLE        hReqQueue,
IN PHTTP_REQUEST pRequest
);

int server_start(
	int argc,
	wchar_t * argv[]
	);

#endif