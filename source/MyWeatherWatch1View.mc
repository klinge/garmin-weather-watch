import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MyWeatherWatch1View extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);

        // Update the time
        var time = View.findDrawableById("TimeDisplay") as Text;
        time.setColor(getApp().getProperty("ForegroundColor") as Number);
        time.setText(timeString);

        //Update weather
        //get saved values from background
        var weather = Application.getApp().getProperty("OpenWeatherMapCurrent");
        
        //initialize weather variables
        var tempValue = "-";
        var placeValue = "-";
        var descValue = "-";
        var windSpeedValue = "-";
        var windDirValue = "-";
        var windDirAbbr = "";
        var windString = "-";

        //update them with actual values if we have them
        if( weather != null ) {
            tempValue = weather["temp"].format("%.1f").toString();
            placeValue = weather["name"];
            descValue = weather["des"];
            windSpeedValue = weather["windSpeed"].format("%.1f");
            //windDirValue = weather["windDirect"].format("%03i");
            windDirAbbr = weather["windDirectAbbr"];
            windString = windSpeedValue + " m/s (" + windDirAbbr + ")";
        }

        //update watchface
        var temp = View.findDrawableById("TempDisplay") as Text;
        temp.setText(tempValue);
        var desc = View.findDrawableById("WeatherDescDisplay") as Text;
        desc.setText(descValue);
        var wind = View.findDrawableById("WindDisplay") as Text;
        wind.setText(windString);
        var place = View.findDrawableById("PlaceDisplay") as Text;
        place.setText(placeValue);
        


        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
