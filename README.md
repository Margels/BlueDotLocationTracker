# BlueDotLocationTracker
This app tracks the user's precise location. It also keeps track of the user's movements and records an event every 10 meters or so.



## How to run the project:

Download the zip folder and open on XCode.

## Implementation decisions and trade-offs I made:

I implemented a table view with a list of significant move events and the time passed from that event. Every 10 meters or so, the app will display a message and a new event will appear on the table view. I added buttons to the map so the user can zoom in and out. The application is intended to work mostly in the foreground.
I did mention method ``startMonitoringSignificantLocationChanges()`` in ``viewDidLoad()`` both for background location tracking and also for more power-friendly activities. However, since I suspect it would not track movements as short as 10 meters, I mostly relied on ``didUpdateLocations`` instead. I did set ``pausesLocationUpdatesAutomatically`` to ``true`` to save battery life when the user is unlikely to move.


## Any architectural considerations and reasonings:

I considered that 10 meters is a very short distance for users who run or drive, therefore sending ``UIAlerts`` for every event could stack up a lot of alerts. I decided to display messages that disappear on their own after 5 seconds so to not overwhelm the user with alerts. 


## Areas of focus:

Location tracking precision, user's experience, bug fixing, code precision.


## Any copied code, references and 3rd party libraries:

I used UIKit, MapKit and CoreLocation. I referred to Apple's documents, my own material which I originally got by reference to StackOverflow, and new StackOverflow research. Here are the ones I referred to today:

• significant-change location service: https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/using_the_significant-change_location_service

• reverse geocode location: https://stackoverflow.com/questions/51905877/converting-cllocationcoordinate2d-to-street-address-with-swift

• ``relativeDateTimeFormatter()``: https://stackoverflow.com/questions/44086555/swift-display-time-ago-from-date-nsdate


## How long you worked on the app for:

I worked on the code for a total of 4-5 hours and spent an additional 2-3 hours reviewing my code, testing (unit and device) and fixing my code to make it more readable.

## Any additional information:

It wasn't clear whether the app was supposed to work in the background, so I focused on foreground work.
