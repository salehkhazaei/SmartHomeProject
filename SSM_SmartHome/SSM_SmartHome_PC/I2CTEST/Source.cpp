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

#include <stdlib.h>
#include <windows.h>
#include <conio.h>
#include <windows.h>
#include <strsafe.h>


int main(void)
{
	wchar_t * arr[5];
	arr[0] = L"Server";
	arr[1] = L"http://*:5223/sensor";
	arr[2] = L"http://*:5223/pullout";
	arr[3] = L"http://*:5223/setout";
	arr[4] = L"http://*:5223/clearout";
	arr[5] = L"http://*:5223/html";

	// web settings
	arr[6] = L"http://*:5223/rooms";
	arr[7] = L"http://*:5223/sets";
	arr[8] = L"http://*:5223/jobs";

	arr[9] = L"http://localhost:5223/sensor";
	arr[10] = L"http://localhost:5223/pullout";
	arr[11] = L"http://localhost:5223/setout";
	arr[12] = L"http://localhost:5223/clearout";
	arr[13] = L"http://localhost:5223/html";

	// web settings
	arr[14] = L"http://localhost:5223/rooms";
	arr[15] = L"http://localhost:5223/sets";
	arr[16] = L"http://localhost:5223/jobs";

	arr[17] = L"http://*:5223/state";
	arr[18] = L"http://localhost:5223/state";

	server_start(19, arr);
	getch();
}
