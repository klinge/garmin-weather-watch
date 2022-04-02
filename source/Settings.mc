import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.System;

/// Wrapper class for stored properties
///
(:background)
class Settings
{
    //app settings
	static hidden var _lastKnownLocation = "lastKnownLocation";
	static hidden var _etz = "etz";
	static hidden var _isTest = "isTest";
    static hidden var _appVersion = "appVersion";
    static hidden var _deviceName = "device-name";
	//weather settings
	static hidden var _city = "city-v2";
	static hidden var _weather = "weather-v2";
    static hidden var _weatherProvider = "weather-provider";
	static hidden var _weatherRefreshToken = "wr-token";
    //error settings
	static hidden var _conError = "conError";
    static hidden var _conErrorValue = null;

    public static function GetConError()
	{
		if (_conErrorValue == null)
		{
			_conErrorValue = Application.getApp().getProperty(_conError);
		} 
		return _conErrorValue;
	}
	
	public static function SetConError(conError)
	{
		_conErrorValue = conError;
		Application.getApp().setProperty(_conError, conError);	
	}

}

	