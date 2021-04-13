# cranix-radius
FreeRadius configuration for the CRANIX server

Installing this package a radius server will be installed and configured for the CRANIX server:

 * SSL certificate will be created based on the CRANIX server settings.
 * rewrite_calling_station_id policy will be activated to rewrite the calling station id in MAC-address style with ":"
 * 4 modules will be installed into mods-available: eap, mschap, preprocess, set_logged_on
 * The module set_logged_on takes care about registering new devices and setting the logged on flag on the device

