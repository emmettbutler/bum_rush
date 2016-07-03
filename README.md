Bum Rush
========

Bum Rush is an eight-player car combat dating sim racing game that was made for the annual No Quarter
games showcase in New York City in 2015. [Nina Freeman](https://twitter.com/hentaiphd) received the No Quarter commission and was the designer, working alongside illustrator and animator [Diego
Garcia](https://twitter.com/radstronomical), composer [Max
Coburn](https://twitter.com/chordslayermaxo) and programmer [Emmett Butler](https://twitter.com/sensitiveemmett).

This publicly released version of the game is the same game shown at No Quarter, but with a few additional maps and controller support. The original controllers used to make and play Bum Rush are available on [Amazon](https://www.amazon.com/gp/product/B002YVD3KM/ref=od_aui_detailpages00?ie=UTF8&psc=1). You may notice the lack of joystick support, and that is due to the original game being made for use with retro-style USB controllers.

How to Play
-----------

The goal of Bum Rush is to visit all five date spots and be the first one back
home. To visit a date spot, drive into the parking space in front of the spot
with at least one date in your car with you. Wait for the bar to fill, then
drive to the next spot and repeat. Once you've visited all five spots, head
back to where you started.

If you get hit hard enough, one of your dates will be knocked out of your car.
If you end up with no dates in your car, you won't be able to visit date
spots. To get a new date, slam into someone else who has a date in their car.
Their date will fall out to a random location on the map, at which point you
can drive over them to pick them up. You can have as many dates in your car at
once as there are players in your game.

Note about character selection: each controller is automatically paired with a random character when you start the game. This game was designed for parties, so making the character/map selection process as simple as possible was important to us. If you want to try playing with a different character, just restart the game and a new one will be selected.

Supported Controllers
---------------------

*XBox 360 USB*: A to accelerate, X to highlight, D-pad to steer. On Mac, you
should install [tattiebogle](http://tattiebogle.net/index.php/ProjectRoot/Xbox360Controller/OsxDriver),
a Mac controller driver built specifically for the XBox 360 controller. On Windows,
this controller should work without any additional drivers.

*PS4*: X to accelerate, square to highlight, D-pad to steer. These controllers
are currently unsupported on Mac. On Windows, you'll need to install and configure
[ScpToolkit](https://github.com/nefarius/ScpToolkit).

*PS3*: X to accelerate, square to highlight, D-pad to steer. On Mac, these
controllers should work without the installation of any additional drivers. On
Windows, you'll need to install and configure
[ScpToolkit](https://github.com/nefarius/ScpToolkit).

[*NES USB Controller*](https://www.amazon.com/Classic-USB-NES-Controller-PC/dp/B002YVD3KM?ie=UTF8&*Version*=1&*entries*=0):
A to accelerate, B to highlight, D-pad to steer. On both Mac and Windows,
these controllers should be supported without the installation of any additional
drivers.

Technical Notes
---------------

Bum Rush runs best on screens that are at least 1280x720 pixels in resolution.
It will also not work well on screens that are taller than they are wide.

If you have technical questions or would like support for another type of controller,
please contact Emmett Butler at emmett.butler321@gmail.com.

Compilation
-----------

On both Windows and Mac, the `amxmlc`, `adt`, and `adl` binaries from the
[Adobe AIR SDK](http://www.adobe.com/devnet/air/air-sdk-download.html) must be
on the binary `$PATH`.

On Mac:

    python compile.py -l /path/to/airsdk/frameworks/libs/air/airglobal.swc -v 21.0 -p -t mac

Replace `21.0` with the version of the AIR SDK you're compiling against, which
can be found in the SDK's `air-sdk-description.xml`.

On Windows, simply replace `-t mac` with `-t windows`.

You can also run the app under the ADL debugger by removing the `-p` flag from
the compile command.
