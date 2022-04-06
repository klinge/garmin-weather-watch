import Toybox.Background;
import Toybox.System;
import Toybox.Communications;
import Toybox.Application;

(:background)
class BackgroundService extends System.ServiceDelegate {
	
    hidden var result = {};

	(:background_method)
	function initialize() {
		System.ServiceDelegate.initialize();
	}

	// Read pending web requests, and call appropriate web request function.
	// This function determines priority of web requests, if multiple are pending.
	// Pending web request flag will be cleared only once the background data has been successfully received.
	(:background_method)
	function onTemporalEvent() {

		System.println("Started onTemporalEvent..");
		try
    	{
			//getWeather(); 
			getSLDepartures();
		}
		catch(ex)
		{
			var errorMessage = ex.getErrorMessage();
			System.println("onTemporalEvent error: " + errorMessage);
			result.put("temporalEventError", errorMessage);
			Background.exit(result); 
		}		
	}

	(:background_method)
	function getWeather() {
		//get apikey
		var api_key = Application.getApp().getProperty("OwmApi");
		if (api_key.length() != 32) {
			api_key = "9eb325d7d772cdd21ce90111853d5549"; // default apikey
		}
		System.println("OWM Key: " + api_key);
		//get station for weather
		var owm_station = Application.getApp().getProperty("OwmStation");
		//depending on if a station number or 
		if(owm_station != 0){
			getWeatherForStation(owm_station, api_key);
		}
		else {
			getWeatherForCoords(api_key);
		}
	}

	(:background_method)
	function getSLDepartures() {
		System.println("In getSLDepartures()");
		var station = "9509";
		var apiKey = "43db3f9f91e541a68ffbb1f35784c813";
		var timeDuration = "20";
		
		makeWebRequest(
			"https://api.sl.se/api2/realtimedeparturesV4.json",
			{
				"siteid" => station,
				"timewindow" => timeDuration,
				"key" => apiKey,
				"bus" => "false"
			},
			method(:onReceiveSLData)
		);
	}

	(:background_method)
	function getWeatherForStation(owm_station, api_key) {
		System.println("Getting data for station: " + owm_station);
		makeWebRequest(
			"https://api.openweathermap.org/data/2.5/weather",
			{
				"id" => owm_station,
				"appid" => api_key,
				"units" => "metric" // Celcius.
			},
			method(:onReceiveOpenWeatherMapCurrent)
		);
	}

	(:background_method)
	function getWeatherForCoords(api_key) {
		System.println("Getting data for last known coordinates");
		makeWebRequest(
			"https://api.openweathermap.org/data/2.5/weather",
			{
				"lat" => Application.getApp().getProperty("LastLocationLat"),
				"lon" => Application.getApp().getProperty("LastLocationLng"),
				"appid" => api_key,
				"units" => "metric" // Celcius.
			},
			method(:onReceiveOpenWeatherMapCurrent)
		);
	}

	(:background_method)
	function onReceiveOpenWeatherMapCurrent(responseCode, data) {
		
		System.println("Starting callback onReceiveOpenWeatherMapCurrent()");
		
		// Useful data only available if result was successful.
		// Filter and flatten data response for data that we actually need.
		// Reduces runtime memory spike in main app.
		if (responseCode == 200) {
			result = {
				"lat" => data["coord"]["lat"],
				"lon" => data["coord"]["lon"],
				"dt" => data["dt"],
				"temp" => data["main"]["temp"],
				"tempFeelsLike" => data["main"]["feels_like"],
				"tempMin" => data["main"]["temp_min"],
				"tempMax" => data["main"]["temp_max"],
				"humidity" => data["main"]["humidity"],
				"windSpeed" => data["wind"]["speed"],
				"windDirect" => data["wind"]["deg"],
				"icon" => data["weather"][0]["icon"],
				"des" => data["weather"][0]["main"],
				"name" => data["name"],
				"sunrise" => data["sys"]["sunrise"],
				"sunset" => data["sys"]["sunset"]
			};

		// HTTP error
		} else {
			result = {
				"httpError" => responseCode,
				"message" => data["message"]
			};
		}
		Background.exit( 
			{ "OpenWeatherMapCurrent" => result } 
		);
	}

	(:background_method)
	function onReceiveSLData(responseCode, data) {
		System.println("Starting callback onReceiveSLData()");
		System.println("In onReceiveSLData() callback. Response code was: " + responseCode);
		System.println("In onReceiveSLData() callback. Result is: " + data);

		// Useful data only available if result was successful.
		// Filter and flatten data response for data that we actually need.
		if (responseCode == 200) {
			result = {
				"allDepartures" => data["Departure"]
			};
		} 
		else {  //HTTP error
			var errorMessage = "";
			if(data != null) {
				errorMessage = data["StatusCode"];
			}
			result = {
				"httpError" => responseCode,
				"message" => errorMessage
			};
		}
		Background.exit( 
			{ "SLDepartures" => result } 
		);
	
	}

	(:background_method)
	function makeWebRequest(url, params, callback) {
		System.println("In makeWebRequest(). URL is: " + url);
		System.println("In makeWebRequest(). params is: " + params);
        var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET,
			:headers => {
				"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
			},
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
		};

		Communications.makeWebRequest(url, params, options, callback);
	}
}