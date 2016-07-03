Bum Rush
========

Bum Rush is an eight-player car combat dating sim racing game commissioned
from [Nina Freeman](https://twitter.com/hentaiphd) for the annual No Quarter
games showcase in New York City in 2015. [Diego
Garcia](https://twitter.com/radstronomical) did the visual art, and [Max
Coburn](https://twitter.com/chordslayermaxo) did the audio.

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

Supported Controllers
---------------------



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
