import Toybox.Application;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Background;
import Toybox.Time;

// In-memory current location.
// Current location retrieved/saved in getPosition()
// Persistence allows weather and sunrise/sunset features to be used after watch face restart, even if watch no longer has current
// location available.
var gLocationLat = null;
var gLocationLng = null;

(:background)
class MyWeatherWatch1App extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        InitBackgroundEvents();
        return [ new MyWeatherWatch1View() ] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        InitBackgroundEvents();
        WatchUi.requestUpdate();
    }

    (:background_method)
	function getServiceDelegate() {
		return [new BackgroundService()];
	}
	
	// Handle data received from BackgroundService.
	// data is Dictionary with single key that indicates the data type received.
	(:background_method)
	function onBackgroundData(data) {
		System.println("onBackgroundData() called");
        var type = data.keys()[0];
        var receivedData = data[type];

		// No value in showing any HTTP error to the user, so no need to modify stored data.
		// Leave pendingWebRequests flag set, and simply return early.
		if (receivedData["httpError"]) {
			System.println("httpError: " + receivedData);
            return;
		}

        System.println("Type of result: " + type);
        System.println("Received data: " + receivedData);
        setProperty(type, receivedData);
        //if we have no location set it to the last coordinates from openweathermap.. 
        if (getProperty("LastLocationLat") == null) {
            setProperty("LastLocationLat",receivedData["lat"].toFloat());
            setProperty("LastLocationLng",receivedData["lon"].toFloat());
        }
        WatchUi.requestUpdate();
    }
	

    // Register for temporal events.. 
    function InitBackgroundEvents()
    {
        getLocation();
        if(Toybox.System has :ServiceDelegate) {
            var FIVE_MINUTES = new Toybox.Time.Duration(5 * 60);
            var lastTime = Background.getLastTemporalEventTime();

            if (lastTime != null) 
            {
                var nextTime = lastTime.add(FIVE_MINUTES);
                Background.registerForTemporalEvent(nextTime);
            } 
            else 
            {
                Background.registerForTemporalEvent(Time.now());
            }
        } else {
            System.println("****background not available on this device****");
        }
    }

    // Attempt to update current location, to be used by Sunrise/Sunset, and Weather.
	// If current location available from current activity, save it in case it goes "stale" and can not longer be retrieved.
    function getLocation() {
		var location = Activity.getActivityInfo().currentLocation;
		if (location) {
			System.println("Found location from activity..");
			location = location.toDegrees(); // Array of Doubles.
			gLocationLat = location[0].toFloat();
			gLocationLng = location[1].toFloat();

			Application.getApp().setProperty("LastLocationLat", gLocationLat);
			Application.getApp().setProperty("LastLocationLng", gLocationLng);
		// If current location is not available, read stored value from Object Store, being careful not to overwrite a valid
		// in-memory value with an invalid stored one.
		} else {
			var lat = Application.getApp().getProperty("LastLocationLat");
			if (lat != null) {
				gLocationLat = lat;
			}

			var lng = Application.getApp().getProperty("LastLocationLng");
			if (lng != null) {
				gLocationLng = lng;
			}
		}
		System.println("getLocation() lat, long: " + gLocationLat + ", " + gLocationLng);
    }

}

function getApp() as MyWeatherWatch1App {
    return Application.getApp() as MyWeatherWatch1App;
}