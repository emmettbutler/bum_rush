Bum Rush
========

Bum Rush is an eight-player car combat dating sim racing game commissioned
from [Nina Freeman](https://twitter.com/hentaiphd) for the annual No Quarter
games showcase in New York City in 2015. [Diego
Garcia](https://twitter.com/radstronomical) did the visual art, and [Max
Coburn](https://twitter.com/chordslayermaxo) did the audio.

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
