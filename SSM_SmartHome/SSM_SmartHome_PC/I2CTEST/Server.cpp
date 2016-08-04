/**
*
* @authors Saleh Khazaei, Shiva Zamani, Mohammad Bagheri
* @email saleh.khazaei@gmail.com
* Copyright:

Copyright (C) Saleh Khazaei

This code is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3, or (at your option)
any later version.

This code is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this code; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

*EndCopyright:
*/

#include "stdafx.h"
#include "Header.h"

/*******************************************************************++

Routine Description:
main routine

Arguments:
argc - # of command line arguments.
argv - Arguments.

Return Value:
Success/Failure

--*******************************************************************/
#include "stdafx.h"
#include "Header.h"

#include <stdlib.h>
#include <windows.h>
#include <conio.h>
#include <windows.h>
#include <strsafe.h>
#include <algorithm>

HANDLE GetSerialPort(char *);

char state[16];
unsigned char sensor[8];
int output[8];

struct job{
	int id;
	int h;
	int m;
	int o;
	int w;
	int r;
};

job jobs[16];
int job_count;

double formul(int sensor, int state)
{
	switch (state)
	{
	case 2:
		return sensor * 2;
	case 1:
		return sensor;
	case 0:
		return sensor;
	}
}

void ErrorExit(LPTSTR lpszFunction)
{
	// Retrieve the system error message for the last-error code

	LPVOID lpMsgBuf;
	LPVOID lpDisplayBuf;
	DWORD dw = GetLastError();

	FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER |
		FORMAT_MESSAGE_FROM_SYSTEM |
		FORMAT_MESSAGE_IGNORE_INSERTS,
		NULL,
		dw,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR)&lpMsgBuf,
		0, NULL);

	// Display the error message and exit the process

	lpDisplayBuf = (LPVOID)LocalAlloc(LMEM_ZEROINIT,
		(lstrlen((LPCTSTR)lpMsgBuf) + lstrlen((LPCTSTR)lpszFunction) + 40) * sizeof(TCHAR));
	StringCchPrintf((LPTSTR)lpDisplayBuf,
		LocalSize(lpDisplayBuf) / sizeof(TCHAR),
		TEXT("%s failed with error %d: %s"),
		lpszFunction, dw, lpMsgBuf);
	MessageBox(NULL, (LPCTSTR)lpDisplayBuf, TEXT("Error"), MB_OK);

	LocalFree(lpMsgBuf);
	LocalFree(lpDisplayBuf);
	ExitProcess(dw);
}

HANDLE GetSerialPort(char * p)
{
	HANDLE hSerial;
	hSerial = CreateFileA(p,
		GENERIC_READ | GENERIC_WRITE,
		0,
		0,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		0);
	if (hSerial == INVALID_HANDLE_VALUE)
	{
		ErrorExit(TEXT("First CreateFile failed"));
		return NULL;
	}

	DCB dcbSerialParams = { 0 };
	dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
	dcbSerialParams.BaudRate = CBR_9600;
	dcbSerialParams.ByteSize = 8;
	dcbSerialParams.StopBits = ONESTOPBIT;
	dcbSerialParams.Parity = NOPARITY;
	SetCommState(hSerial, &dcbSerialParams);
	return hSerial;
}
std::string ws2s(const std::wstring& ws)
{
	std::setlocale(LC_ALL, "");
	
	const std::locale locale("");
	typedef std::codecvt<wchar_t, char, std::mbstate_t> converter_type;
	const converter_type& converter = std::use_facet<converter_type>(locale);
	std::vector<char> to(ws.length() * converter.max_length());
	std::mbstate_t state;
	const wchar_t* from_next;
	char* to_next;
	const converter_type::result result = converter.out(state, ws.data(), ws.data() + ws.length(), from_next, &to[0], &to[0] + to.size(), to_next);
	if (result == converter_type::ok || result == converter_type::noconv) {
		const std::string s(&to[0], to_next);
		return s;
	}
	return std::string();
}
int server_start(
	int argc,
	wchar_t * argv[]
	)
{
	job_count = 0;
	int i, j, idx;
	HANDLE h2;
	char buf[13];
	char tmp[7];
	DWORD byteswritten = 0, bytesread = 0;
	char c1[] = { "\\\\.\\COM13" };

	i = j = 0;
	idx = -1;
	h2 = GetSerialPort(c1);
	if (h2 == NULL)
		printf("Could not open the port");

	printf("SSM Smart Home");
	WriteFile(h2, "?", 1, &byteswritten, NULL);
	ReadFile(h2, buf, 1, &bytesread, NULL);

	printf("System started");

	ULONG           retCode;
	HANDLE          hReqQueue = NULL;
	int             UrlAdded = 0;
	HTTPAPI_VERSION HttpApiVersion = HTTPAPI_VERSION_1;

	if (argc < 2)
	{
		wprintf(L"%ws: <Url1> [Url2] ... \n", argv[0]);
		return -1;
	}

	//
	// Initialize HTTP Server APIs
	//
	retCode = HttpInitialize(
		HttpApiVersion,
		HTTP_INITIALIZE_SERVER,    // Flags
		NULL                       // Reserved
		);

	if (retCode != NO_ERROR)
	{
		wprintf(L"HttpInitialize failed with %lu \n", retCode);
		return retCode;
	}

	//
	// Create a Request Queue Handle
	//
	retCode = HttpCreateHttpHandle(
		&hReqQueue,        // Req Queue
		0                  // Reserved
		);

	if (retCode != NO_ERROR)
	{
		wprintf(L"HttpCreateHttpHandle failed with %lu \n", retCode);
		goto CleanUp;
	}

	//
	// The command line arguments represent URIs that to 
	// listen on. Call HttpAddUrl for each URI.
	//
	// The URI is a fully qualified URI and must include the
	// terminating (/) character.
	//
	for (int i = 1; i < argc; i++)
	{
		wprintf(L"listening for requests on the following url: %s\n", argv[i]);
		retCode = HttpAddUrl(
			hReqQueue,    // Req Queue
			argv[i],      // Fully qualified URL
			NULL          // Reserved
			);

		
		if (retCode != NO_ERROR)
		{
			wprintf(L"HttpAddUrl failed with %lu \n", retCode);
			goto CleanUp;
		}
		else
		{
			//
			// Track the currently added URLs.
			//
			UrlAdded++;
		}
	}

 	DoReceiveRequests(hReqQueue,h2);

CleanUp:

	//
	// Call HttpRemoveUrl for all added URLs.
	//
	for (int i = 1; i <= UrlAdded; i++)
	{
		HttpRemoveUrl(
			hReqQueue,     // Req Queue
			argv[i]        // Fully qualified URL
			);
	}

	//
	// Close the Request Queue handle.
	//
	if (hReqQueue)
	{
		CloseHandle(hReqQueue);
	}

	// 
	// Call HttpTerminate.
	//
	HttpTerminate(HTTP_INITIALIZE_SERVER, NULL);

	CloseHandle(h2);

	return retCode;

}


/*******************************************************************++

Routine Description:
The function to receive a request. This function calls the
corresponding function to handle the response.

Arguments:
hReqQueue - Handle to the request queue

Return Value:
Success/Failure.

--*******************************************************************/
DWORD DoReceiveRequests(
	IN HANDLE hReqQueue,
	HANDLE h2
	)
{
	ULONG              result;
	HTTP_REQUEST_ID    requestId;
	DWORD              bytesRead;
	PHTTP_REQUEST      pRequest;
	PCHAR              pRequestBuffer;
	ULONG              RequestBufferLength;

	//
	// Allocate a 2 KB buffer. This size should work for most 
	// requests. The buffer size can be increased if required. Space
	// is also required for an HTTP_REQUEST structure.
	//
	RequestBufferLength = sizeof(HTTP_REQUEST) + 2048;
	pRequestBuffer = (PCHAR)ALLOC_MEM(RequestBufferLength);

	if (pRequestBuffer == NULL)
	{
		return ERROR_NOT_ENOUGH_MEMORY;
	}

	pRequest = (PHTTP_REQUEST)pRequestBuffer;

	//
	// Wait for a new request. This is indicated by a NULL 
	// request ID.
	//

	HTTP_SET_NULL_ID(&requestId);

	for (;;)
	{
		RtlZeroMemory(pRequest, RequestBufferLength);

		result = HttpReceiveHttpRequest(
			hReqQueue,          // Req Queue
			requestId,          // Req ID
			0,                  // Flags
			pRequest,           // HTTP request buffer
			RequestBufferLength,// req buffer length
			&bytesRead,         // bytes received
			NULL                // LPOVERLAPPED
			);

		if (NO_ERROR == result)
		{
			//
			// Worked! 
			// 
			switch (pRequest->Verb)
			{
			case HttpVerbGET:
			{
				wprintf(L"Got a GET request for %ws \n",
					pRequest->CookedUrl.pFullUrl);

				std::string str1 = ":5223/sensor";
				std::string str2 = ":5223/pullout";
				std::string str3 = ":5223/setout";
				std::string str4 = ":5223/clearout";
				std::string str5 = ":5223/html";
				std::string str6 = ":5223/rooms";
				std::string str7 = ":5223/sets";
				std::string str8 = ":5223/jobs";
				std::string str9 = ":5223/state";


				std::string str = ws2s(pRequest->CookedUrl.pFullUrl);
				std::cout << str << "\n";
				std::string out = "";
				char * contentType = "text/html";

				if (str.find(str1) != std::string::npos) {
					char buf[2];
					DWORD byteswritten = 0, bytesread = 0;

					char * num = new char[3];
					std::stringstream sp;
					sp << "{";

					for (int i = 0; i < 8; i++)
					{
						std::stringstream ss;
						ss << i;
						WriteFile(h2, ss.str().c_str(), 1, &byteswritten, NULL);

						ReadFile(h2, buf, 1, &bytesread, NULL);

						sensor[i] = buf[0];

						itoa((unsigned int)buf[0], num, 10);

						Sleep(50);
						sp << "\"s" << (i + 1) << "\":" << num << (i == 7 ? "" : ",");
					}

					sp << "}\r\n";
					out = sp.str();
				}
				else if (str.find(str2) != std::string::npos) {
					char buf[2];
					DWORD byteswritten = 0, bytesread = 0;

					char * num = new char[3];
					std::stringstream sp;
					sp << "{";

					for (int i = 0; i < 8; i++)
					{
						std::stringstream ss;
						ss << (char)((int)('!') + i);
						WriteFile(h2, ss.str().c_str(), 1, &byteswritten, NULL);

						ReadFile(h2, buf, 1, &bytesread, NULL);

						output[i] = buf[0];

						itoa((unsigned int)buf[0], num, 10);

						Sleep(50);

						sp << "\"o" << i << "\":" << (buf[0] == 102 ? 0 : 1) << (i == 7 ? "" : ",");
					}
					sp << "}\r\n";
					out = sp.str();
				}
				else if (str.find(str3) != std::string::npos) {
					char buf[2];
					DWORD byteswritten = 0, bytesread = 0;

					std::size_t found = str.rfind("?");
					std::cout << found << std::endl;

					if (found != std::string::npos)
					{
						std::cout << str.substr(found+3) << ' ' << static_cast<int>(found) << "\n";
						std::stringstream sq(str.substr(found + 3));
						int i;
						sq >> i;

						std::cout << "c: " << i << ' ' << 20 + i << '\n';

						std::stringstream ss;
						ss << (char)('A' + i);
						WriteFile(h2, ss.str().c_str(), 1, &byteswritten, NULL);

						ReadFile(h2, buf, 1, &bytesread, NULL);
						out = "{\"res\":\"OK\"}\r\n";
					}
				}
				else if (str.find(str4) != std::string::npos) {
					char buf[2];
					DWORD byteswritten = 0, bytesread = 0;

					std::size_t found = str.rfind("?");
					std::cout << found << std::endl;

					if (found != std::string::npos)
					{
						std::cout << str.substr(found + 3) << ' ' << static_cast<int>(found) << "\n";
						std::stringstream sq(str.substr(found + 3));
						int i;
						sq >> i;

						std::cout << "c: " << i << ' ' << 20 + i << '\n';

						std::stringstream ss;
						ss << (char)('a' + i);
						WriteFile(h2, ss.str().c_str(), 1, &byteswritten, NULL);

						ReadFile(h2, buf, 1, &bytesread, NULL);
						out = "{\"res\":\"OK\"}\r\n";
					}
				}
				else if (str.find(str5) != std::string::npos) {
					std::string address = str.substr(10);
					std::size_t found = address.find("/");
					if (found != std::string::npos)
					{
						address = address.substr(found + 1);
					}

					 found = address.find("?");
					if (found != std::string::npos)
					{
						address = address.substr(0,found);
					}


					std::ifstream file(address.c_str());
					if (!file.is_open())
					{
						std::stringstream ss;
						ss << address.c_str() << " Not found!" << std::endl;
						out = ss.str();
					}
					else
					{
						file.seekg(0, std::ios::end);
						out.reserve(file.tellg());
						file.seekg(0, std::ios::beg);

						out.assign((std::istreambuf_iterator<char>(file)),
							std::istreambuf_iterator<char>()); 

						if (address.substr(address.find_last_of(".") + 1) == "html") {
						}
						else if (address.substr(address.find_last_of(".") + 1) == "htm") {
						}
						else if (address.substr(address.find_last_of(".") + 1) == "css") {
							contentType = "text/css";
						}
						else if (address.substr(address.find_last_of(".") + 1) == "js") {
							contentType = "text/javascript";
						}
						else if (address.substr(address.find_last_of(".") + 1) == "woff2") {
							contentType = "application/font-woff2";
						}
						else {
							contentType = "application/octet-stream";
						}
					}
				}
				else if (str.find(str6) != std::string::npos) {
					out = "{\"0\": \"Room0\"}";
				}
				else if (str.find(str7) != std::string::npos) {
					std::stringstream sets;
					sets << "{";
					for (int i = 0; i < 8; i++)
					{
						sets << "\"s" << i << "\":\"" << formul(sensor[i], state[i]) << "\"" << ",";
					}
					for (int i = 0; i < 8; i++)
					{
						sets << "\"o" << i << "\":\"" << output[i] << "\"" << ",";
					}
					sets << "\"j\":{";
					for (int i = 0; i < job_count; i++)
					{
						sets << "\"" << i << "\":{\"h\": \"" << jobs[i].h << "\",\"m\": \"" << jobs[i].m << "\",\"o\": \"" << jobs[i].o << "\",\"w\": \"" << jobs[i].w << "\",\"r\": \"" << jobs[i].r << "\",\"id\": \"" << jobs[i].id << "\"}";
					}
					sets << "}}";
					out = sets.str().c_str();
				}
				else if (str.find(str8) != std::string::npos) {
					if (str.find("&set=") != std::string::npos)
					{
						std::string astr = str.substr(str.find("&set=") + 5);
						std::replace(astr.begin(), astr.end(), ',', ' ');
						std::cout << "********** " << astr << '\n';
						std::stringstream sr(astr);

						if (job_count >= 16)
						{
							job_count = 0;
						}

						sr >> jobs[job_count].h >> jobs[job_count].m >> jobs[job_count].o;
						sr >> jobs[job_count].w >> jobs[job_count].r >> jobs[job_count].id;

						job_count++;
						out = "{\"res\": \"ok\"}";
					}
					else
					{
						out = "{\"res\": \"ok\"}";
					}
				}
				else if (str.find(str9) != std::string::npos) {
					std::cout << "give state\n";
					if (str.find("&set=") != std::string::npos)
					{
						std::cout << "1\n";
						out = "{\"res\": \"ok\"}";
					}
					else
					{
						out = "{\"s0\":\"1\",\"s1\":\"1\",\"s2\":\"1\",\"s3\":\"1\",\"s4\":\"1\",\"s5\":\"1\",\"s6\":\"1\",\"s7\":\"1\",\"o0\":\"1\",\"o1\":\"1\",\"o2\":\"1\",\"o3\":\"1\",\"o4\":\"1\",\"o5\":\"1\",\"o6\":\"1\",\"o7\":\"1\"}";
					}
				}
				else
				{
					out = "{\"res\":\"Bad request\"}\r\n";
				}
				printf("size: %d :| \n", out.size());
				int size = out.size();
				PSTR outp = new CHAR[1000000];
				strcpy(outp, out.c_str());
				outp[size] = 0;

				result = SendHttpResponse(
					hReqQueue,
					pRequest,
					200,
					"OK",
					outp,
					(ULONG) size,
					contentType
					);
			}
				break;

			case HttpVerbPOST:

				wprintf(L"Got a POST request for %ws \n",
					pRequest->CookedUrl.pFullUrl);

				result = SendHttpPostResponse(hReqQueue, pRequest);
				break;

			default:
				wprintf(L"Got a unknown request for %ws \n",
					pRequest->CookedUrl.pFullUrl);

				result = SendHttpResponse(
					hReqQueue,
					pRequest,
					503,
					"Not Implemented",
					NULL
					);
				break;
			}

			if (result != NO_ERROR)
			{
				break;
			}

			//
			// Reset the Request ID to handle the next request.
			//
			HTTP_SET_NULL_ID(&requestId);
		}
		else if (result == ERROR_MORE_DATA)
		{
			//
			// The input buffer was too small to hold the request
			// headers. Increase the buffer size and call the 
			// API again. 
			//
			// When calling the API again, handle the request
			// that failed by passing a RequestID.
			//
			// This RequestID is read from the old buffer.
			//
			requestId = pRequest->RequestId;

			//
			// Free the old buffer and allocate a new buffer.
			//
			RequestBufferLength = bytesRead;
			FREE_MEM(pRequestBuffer);
			pRequestBuffer = (PCHAR)ALLOC_MEM(RequestBufferLength);

			if (pRequestBuffer == NULL)
			{
				result = ERROR_NOT_ENOUGH_MEMORY;
				break;
			}

			pRequest = (PHTTP_REQUEST)pRequestBuffer;

		}
		else if (ERROR_CONNECTION_INVALID == result &&
			!HTTP_IS_NULL_ID(&requestId))
		{
			// The TCP connection was corrupted by the peer when
			// attempting to handle a request with more buffer. 
			// Continue to the next request.

			HTTP_SET_NULL_ID(&requestId);
		}
		else
		{
			break;
		}

	}

	if (pRequestBuffer)
	{
		FREE_MEM(pRequestBuffer);
	}

	return result;
}


/*******************************************************************++

Routine Description:
The routine sends a HTTP response

Arguments:
hReqQueue     - Handle to the request queue
pRequest      - The parsed HTTP request
StatusCode    - Response Status Code
pReason       - Response reason phrase
pEntityString - Response entity body

Return Value:
Success/Failure.
--*******************************************************************/

DWORD SendHttpResponse(
	IN HANDLE        hReqQueue,
	IN PHTTP_REQUEST pRequest,
	IN USHORT        StatusCode,
	IN PSTR          pReason,
	IN PSTR          pEntityString,
	ULONG size,
	char * contentType
	)
{
	HTTP_RESPONSE   response;
	HTTP_DATA_CHUNK dataChunk;
	DWORD           result;
	DWORD           bytesSent;

	//
	// Initialize the HTTP response structure.
	//
	INITIALIZE_HTTP_RESPONSE(&response, StatusCode, pReason);

	//
	// Add a known header.
	//
	ADD_KNOWN_HEADER(response, HttpHeaderContentType, contentType);

	if (pEntityString)
	{
		// 
		// Add an entity chunk.
		//
		dataChunk.DataChunkType = HttpDataChunkFromMemory;
		dataChunk.FromMemory.pBuffer = pEntityString;
		dataChunk.FromMemory.BufferLength =
			(size == -1 ? (ULONG)strlen(pEntityString) : size);

		response.EntityChunkCount = 1;
		response.pEntityChunks = &dataChunk;
	}

	// 
	// Because the entity body is sent in one call, it is not
	// required to specify the Content-Length.
	//

	result = HttpSendHttpResponse(
		hReqQueue,           // ReqQueueHandle
		pRequest->RequestId, // Request ID
		0,                   // Flags
		&response,           // HTTP response
		NULL,                // pReserved1
		&bytesSent,          // bytes sent  (OPTIONAL)
		NULL,                // pReserved2  (must be NULL)
		0,                   // Reserved3   (must be 0)
		NULL,                // LPOVERLAPPED(OPTIONAL)
		NULL                 // pReserved4  (must be NULL)
		);

	if (result != NO_ERROR)
	{
		wprintf(L"HttpSendHttpResponse failed with %lu \n", result);
	}

	return result;
}

#define MAX_ULONG_STR ((ULONG) sizeof("4294967295"))

/*******************************************************************++

Routine Description:
The routine sends a HTTP response after reading the entity body.

Arguments:
hReqQueue     - Handle to the request queue.
pRequest      - The parsed HTTP request.

Return Value:
Success/Failure.
--*******************************************************************/

DWORD SendHttpPostResponse(
	IN HANDLE        hReqQueue,
	IN PHTTP_REQUEST pRequest
	)
{
	HTTP_RESPONSE   response;
	DWORD           result;
	DWORD           bytesSent;
	PUCHAR          pEntityBuffer;
	ULONG           EntityBufferLength;
	ULONG           BytesRead;
	ULONG           TempFileBytesWritten;
	HANDLE          hTempFile;
	TCHAR           szTempName[MAX_PATH + 1];
	CHAR            szContentLength[MAX_ULONG_STR];
	HTTP_DATA_CHUNK dataChunk;
	ULONG           TotalBytesRead = 0;

	BytesRead = 0;
	hTempFile = INVALID_HANDLE_VALUE;

	//
	// Allocate space for an entity buffer. Buffer can be increased 
	// on demand.
	//
	EntityBufferLength = 2048;
	pEntityBuffer = (PUCHAR)ALLOC_MEM(EntityBufferLength);

	if (pEntityBuffer == NULL)
	{
		result = ERROR_NOT_ENOUGH_MEMORY;
		wprintf(L"Insufficient resources \n");
		goto Done;
	}

	//
	// Initialize the HTTP response structure.
	//
	INITIALIZE_HTTP_RESPONSE(&response, 200, "OK");

	//
	// For POST, echo back the entity from the
	// client
	//
	// NOTE: If the HTTP_RECEIVE_REQUEST_FLAG_COPY_BODY flag had been
	//       passed with HttpReceiveHttpRequest(), the entity would 
	//       have been a part of HTTP_REQUEST (using the pEntityChunks
	//       field). Because that flag was not passed, there are no
	//       o entity bodies in HTTP_REQUEST.
	//

	if (pRequest->Flags & HTTP_REQUEST_FLAG_MORE_ENTITY_BODY_EXISTS)
	{
		// The entity body is sent over multiple calls. Collect 
		// these in a file and send back. Create a temporary 
		// file.
		//

		if (GetTempFileName(
			L".",
			L"New",
			0,
			szTempName
			) == 0)
		{
			result = GetLastError();
			wprintf(L"GetTempFileName failed with %lu \n", result);
			goto Done;
		}

		hTempFile = CreateFile(
			szTempName,
			GENERIC_READ | GENERIC_WRITE,
			0,                  // Do not share.
			NULL,               // No security descriptor.
			CREATE_ALWAYS,      // Overrwrite existing.
			FILE_ATTRIBUTE_NORMAL,    // Normal file.
			NULL
			);

		if (hTempFile == INVALID_HANDLE_VALUE)
		{
			result = GetLastError();
			wprintf(L"Cannot create temporary file. Error %lu \n",
				result);
			goto Done;
		}

		do
		{
			//
			// Read the entity chunk from the request.
			//
			BytesRead = 0;
			result = HttpReceiveRequestEntityBody(
				hReqQueue,
				pRequest->RequestId,
				0,
				pEntityBuffer,
				EntityBufferLength,
				&BytesRead,
				NULL
				);

			switch (result)
			{
			case NO_ERROR:

				if (BytesRead != 0)
				{
					TotalBytesRead += BytesRead;
					WriteFile(
						hTempFile,
						pEntityBuffer,
						BytesRead,
						&TempFileBytesWritten,
						NULL
						);
				}
				break;

			case ERROR_HANDLE_EOF:

				//
				// The last request entity body has been read.
				// Send back a response. 
				//
				// To illustrate entity sends via 
				// HttpSendResponseEntityBody, the response will 
				// be sent over multiple calls. To do this,
				// pass the HTTP_SEND_RESPONSE_FLAG_MORE_DATA
				// flag.

				if (BytesRead != 0)
				{
					TotalBytesRead += BytesRead;
					WriteFile(
						hTempFile,
						pEntityBuffer,
						BytesRead,
						&TempFileBytesWritten,
						NULL
						);
				}

				//
				// Because the response is sent over multiple
				// API calls, add a content-length.
				//
				// Alternatively, the response could have been
				// sent using chunked transfer encoding, by  
				// passimg "Transfer-Encoding: Chunked".
				//

				// NOTE: Because the TotalBytesread in a ULONG
				//       are accumulated, this will not work
				//       for entity bodies larger than 4 GB. 
				//       For support of large entity bodies,
				//       use a ULONGLONG.
				// 


				sprintf_s(szContentLength, MAX_ULONG_STR, "%lu", TotalBytesRead);

				ADD_KNOWN_HEADER(
					response,
					HttpHeaderContentLength,
					szContentLength
					);

				result =
					HttpSendHttpResponse(
					hReqQueue,           // ReqQueueHandle
					pRequest->RequestId, // Request ID
					HTTP_SEND_RESPONSE_FLAG_MORE_DATA,
					&response,       // HTTP response
					NULL,            // pReserved1
					&bytesSent,      // bytes sent-optional
					NULL,            // pReserved2
					0,               // Reserved3
					NULL,            // LPOVERLAPPED
					NULL             // pReserved4
					);

				if (result != NO_ERROR)
				{
					wprintf(
						L"HttpSendHttpResponse failed with %lu \n",
						result
						);
					goto Done;
				}

				//
				// Send entity body from a file handle.
				//
				dataChunk.DataChunkType =
					HttpDataChunkFromFileHandle;

				dataChunk.FromFileHandle.
					ByteRange.StartingOffset.QuadPart = 0;

				dataChunk.FromFileHandle.
					ByteRange.Length.QuadPart =
					HTTP_BYTE_RANGE_TO_EOF;

				dataChunk.FromFileHandle.FileHandle = hTempFile;

				result = HttpSendResponseEntityBody(
					hReqQueue,
					pRequest->RequestId,
					0,           // This is the last send.
					1,           // Entity Chunk Count.
					&dataChunk,
					NULL,
					NULL,
					0,
					NULL,
					NULL
					);

				if (result != NO_ERROR)
				{
					wprintf(
						L"HttpSendResponseEntityBody failed %lu\n",
						result
						);
				}

				goto Done;

				break;


			default:
				wprintf(
					L"HttpReceiveRequestEntityBody failed with %lu \n",
					result);
				goto Done;
			}

		} while (TRUE);
	}
	else
	{
		// This request does not have an entity body.
		//

		result = HttpSendHttpResponse(
			hReqQueue,           // ReqQueueHandle
			pRequest->RequestId, // Request ID
			0,
			&response,           // HTTP response
			NULL,                // pReserved1
			&bytesSent,          // bytes sent (optional)
			NULL,                // pReserved2
			0,                   // Reserved3
			NULL,                // LPOVERLAPPED
			NULL                 // pReserved4
			);
		if (result != NO_ERROR)
		{
			wprintf(L"HttpSendHttpResponse failed with %lu \n",
				result);
		}
	}

Done:

	if (pEntityBuffer)
	{
		FREE_MEM(pEntityBuffer);
	}

	if (INVALID_HANDLE_VALUE != hTempFile)
	{
		CloseHandle(hTempFile);
		DeleteFile(szTempName);
	}

	return result;
}
