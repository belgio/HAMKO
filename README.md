![Logo](http://83.212.115.112/cp/bg5.jpg)


### Requirements
	1. Windows 8.x (x86/64) for client.
	2. Linux based server with nginx.
	3. Aurora API and H5 WebRC installed.
	

### Configuration
To configure H5 we use hconfig utility. Run the following commands replacing %text% with the corresponding values:

	hconfig.exe host %host_address%
	hconfig.exe path %rc_path%
	hconfig.exe auth %token%


### Core commands
	interval - Internal timer loop (value 1 - 1000 ms)
	ping - Time to execute an echo command
	clear - Screen clear
	cache - Cache management
	endsession /F - Terminates session
		



