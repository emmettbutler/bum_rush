Adobe AIR's [GameInput API](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/GameInput.html)
is extremely buggy. That's been my primary takeaway from developing Bum Rush, a "car
combat dating sim racing game" I worked on with [Nina Freeman](https://twitter.com/hentaiphd).
The game is meant to be played by up to eight players simultaneously in the same
physical space, each using a USB controller. It was originally commissioned from Nina
by the No Quarter games exhibition in New York in October 2015, and we showed it there
to great success. However, we've been blocked on releasing it publicly for months due
to a bug in the GameInput API.

The bug we encountered (on Windows only) was
[this one](http://forum.starling-framework.org/topic/multiple-game-input-controllers):
with multiple controllers connected, a signal from a single controller would cause
the driver to send the matching signal from every other connected controller
simultaneously. In Bum Rush, this meant that a single player pressing A to register
their character would cause all connected controllers to register their characters
simultaneously, effectively binding all characters to the same controller. This bug only
appeared on Windows, not Mac, interestingly enough, but it still made it completely
impossible to run the game on Windows.

At this point I essentially gave up hope that we could get AIR's APIs to behave. I tested
the issue in every configuration I could think of, with every type of controller we had
available, and on many different versions of the AIR runtime, yet it persisted across
all setups. We were actually considering porting the game to a completely different
language, since our original choice of Actionscript seemed not to be working out.
Every once in a while I'd come back to the issue and try something else out,
but the bug never changed. This went on for a while until an acquaintance from the
independent games community gave me some advice about an open-source alternative to
Adobe's broken driver.

The [NativeJoystick](http://2bam.com/2014/08/25/nativejoystick-air-ane-extension-to-support-all-joysticks-that-windows-can/)
API, written by a person going by "2bam", is a native extension (ANE) library for Adobe AIR
that provides game controller inputs to Actionscript code using the native Windows
drivers. When I came across it, I didn't know the first thing about how to use native
extensions, and it took a good chunk of trial and error to figure out how all of the
pieces fit together. The goal of this post is to provide an incomplete guide for anyone
who wants to integrate the NativeJoystick extension into their Windows AIR game.

All of the code I'm referencing here is available on the
[Bum Rush GitHub repository](https://github.com/emmett9001/bum_rush).

*Caveats: These instructions are from my personal experience using the Flex 21.0 SDK
without FlashDevelop and have not been tested outside of the context of this project.*

## Compiling and Debugging with NativeJoystick

First, a note about how NativeJoystick (and apparently other ANEs) is set up. The
[repository](https://github.com/2bam/NativeJoystick) includes two compiled versions of
the extension: [ane](https://github.com/2bam/NativeJoystick/tree/master/extension/ane)
and [ane_unzipped](https://github.com/2bam/NativeJoystick/tree/master/extension/ane_unzipped/NativeJoystick.ane).
The former is for use with ADT, and the latter is for use with ADL.

The steps for including a native extension in a compiled SWF and running it under ADL
are surprisingly simple. I started by including the `ane` and `ane_unzipped` directories
in an `extensions` directory at the root of my project, compiling with the
`-external-library-path` flag:

    amxmlc
        src/main.as
        -compiler.include-libraries \opt\AIRSDK_Compiler\frameworks\libs\air\airglobal.swc
        -external-library-path+=extensions\\ane\NativeJoystick.swc

Note the `-compiler.include-libraries` argument here. One of my sticking points was that
I had been passing the Flex SDK's `playerglobal.swc` to this flag instead of
`airglobal.swc`. Apparently these two libraries have different rules around including
native extensions, and I couldn't get NativeJoystick to load properly without pointing
`amxmlc` to specifically `airglobal.swc`.

Also note that the `-external-library-path` flag is pointing to the zipped version of the
extension.

Once I had successfully compiled a swf, I was able to run the app with this command:

    adl -extdir extensions\ane_unzipped -profile extendedDesktop main.xml

The `-extdir` flag here points to the `ane_unzipped` directory, and the `-profile` flag
indicates the AIR "profile" under which this project should run. `extendedDesktop` is
required for a desktop app that uses a native extension. My `main.xml` looks like this:

    <application xmlns="http://ns.adobe.com/air/application/21.0">
        <id>com.emmettbutler.BumRush</id>
        <versionNumber>1.0</versionNumber>
        <filename>BumRush-2016.05.27.15.38.12</filename>
        <initialWindow>
            <content>src/main.swf</content>
            <visible>true</visible>
            <width>640</width>
            <height>480</height>
            <maximizable>false</maximizable>
            <resizable>false</resizable>
        </initialWindow>
        <supportedProfiles>extendedDesktop</supportedProfiles>
        <extensions>
            <extensionID>com.iam2bam.ane.nativejoystick</extensionID>
        </extensions>
    </application>

Note the `supportedProfiles` and `extensions` tags - these are what I needed to add to
get ADL to run the app.

## Using the NativeJoystick API

The `NativeJoystick` extension's Actionscript API was a bit finicky, but after working
through the few strange behaviors I found, it became much nicer to use than Adobe's
`GameInput`. Following the [example](https://github.com/2bam/NativeJoystick/blob/master/src/Main.as#L46)
given on the `NativeJoystick` github page, the first thing I did was to import the API
and set up some event handlers:

    NativeJoystick.manager.pollInterval = 33;
    NativeJoystick.manager.addEventListener(NativeJoystickEvent.BUTTON_DOWN, onBtnDown);
    NativeJoystick.manager.addEventListener(NativeJoystickEvent.BUTTON_UP, onBtnUp);
    NativeJoystick.manager.addEventListener(NativeJoystickEvent.AXIS_MOVE, onAxisMove);
    FlxG.stage.addEventListener(Event.ENTER_FRAME, onFrame);

As it turns out, accessing `NativeJoystick.manager` instantiates a singleton
`NativeJoystickMgr` instance, and setting its `pollInterval` to a positive integer
causes that instance to start repeatedly making native Windows joystick calls once
every `pollInterval` milliseconds. In the above example, I've started the library's
automatic joystick polling and added handlers for buttons being pressed and released, and
for axis controls moving.

I've also set up a function `onFrame` to be called every frame. The `NativeJoystick`
example code suggests doing this instead of setting `pollInterval` and calling the
library's polling functions yourself. I found that automatic polling was fine for my
needs, so I'm not performing any manual polling in `onFrame`. However, take a look
at a simplified version of that function:

    private function onFrame(ev:Event):void {
        if (this.fetchedCaps) {
            return;
        }
        for (var i:int = 0; i < NativeJoystick.maxJoysticks; i++) {
            if (NativeJoystick.isPlugged(i)) {
                var joy:NativeJoystick = new NativeJoystick(i);
                if (joy.data.caps.numButtons == 0) {
                    // workaround for a bug in NativeJoystick
                    NativeJoystick.manager.getCapabilities(i, joy.data.caps);
                } else {
                    this.registerController(joy.data.caps.oemName, i.toString());
                    this.fetchedCaps = true;
                }
            }
        }
    }

I ran into a bug (or at least a strange behavior) in `NativeJoystick` that caused
controllers plugged in when the app launches not to have their "capabilities" retrieved.
The `caps` are contained in an object `NativeJoystick.data.caps` that includes information
about the various inputs provided by a given controller. In my case, this object was
only being populated when I'd plug in a controller after the app had started, and
any controllres connected at startup would have their `caps` left empty. Since this
object is necessary for some checks I wanted to do, I used the above workaround.

This function simply fetches the capabilities of all connected controllers on the first
frame of game code execution, then locks to make sure it's not doing extra work
thereafter. This is necessary simply because `NativeJoystick` fails to do this step
reliably itself.

Beyond this issue, the rest of the implementation was pretty straightforward. Here's
an example of one of the event handlers (they're all very similar):

    private function onAxisMove(ev:NativeJoystickEvent):void {
        var joy:NativeJoystick = new NativeJoystick(ev.index);
        this.sendControlSignal(joy.data.curr.axesRaw[ev.axisIndex],
                               // differentiate axis indices from button indices
                               "axis_" + ev.axisIndex.toString(),
                               joy.data.caps.oemName, ev.index.toString());
    }

Note that I use `joy.data.curr.axesRaw[ev.axisIndex]` instead of `ev.axisValue`. I found
that for XBox 360 wired USB controllers, `axisValue` was sending ambiguous signals
for the D-pad. Pressing right or down on the pad would cause `axisValue` to populate with
`0` both when the direction was pressed and when it was released, making it impossible
to differentiate the two events. Luckily, I found that `axesRaw` didn't share this issue.

I'm also appending an identifying `axis_` string to the `axisIndex` to identify it to my
lower-level control handling code. This is necessary because `NativeJoystick` doesn't
provide unique identifiers for buttons and axes apart from their index in its internal
array of controls. I'm also passing the name and index of the controller for event
disambiguation at lower levels.

You can find the complete integration of `NativeJoystick` in BumRush
[here](https://github.com/emmett9001/bum_rush/blob/master/src/PlayersController.as).

## Windows and Mac

The `NativeJoystick` extension is only for Windows, since it uses
[native calls](https://msdn.microsoft.com/en-us/library/windows/desktop/dd757105(v=vs.85).aspx)
in its DLL implementation. Since we wanted BumRush to work on Windows and Mac, I needed
to use Actionscrit's conditional compilation feature. I set up the app to compile against
the Adobe `GameInput` API on Mac and against `NativeJoystick` on windows.

This meant that the `extdir` and `external-library-path` CLI arguments mentioned above
needed only to be used on Windows. For this, I used a Python
[compile script](https://github.com/emmett9001/bum_rush/blob/master/compile.py) that set
up the necessary commands and configuration files for the specified platform. I ended
up with a lot of logic that looks like this:

        extlib = ""
        if platform == "windows":
            extlib = "-external-library-path+=extensions\\ane\NativeJoystick.swc"
        command = [
            "amxmlc", "src/{entry_point_class}.as".format(entry_point_class=entry_point_class), "-o",
            swfpath,
            "-compiler.include-libraries", libpath,
            extlib,
            "-use-network=false", "-verbose-stacktraces={}".format(stacktraces),
            "-debug={}".format(debug),
            "{}".format("-advanced-telemetry" if debug else ""),
            "-omit-trace-statements={}".format(omit_trace),
            "-define=CONFIG::debug,{}".format(debug_flag),
            "-define=CONFIG::test,{}".format(test_flag),
            "-define=CONFIG::include_extension,{}".format(str(platform == "windows").lower()),
            '-define=CONFIG::platform,"{}"'.format(platform),
        ]

Also note the `CONFIG::include_extension` compiler argument here. This results in a
flag that looks like `-define=CONFIG::include_extension,true`. In the game code itself,
I wrapped all uses of the `NativeJoystick` API in a compile-time condition so they wouldn't
be included unless compiling on Windows:

    CONFIG::include_extension {
        private function onAxisMove(ev:NativeJoystickEvent):void {
            var joy:NativeJoystick = new NativeJoystick(ev.index);
            this.sendControlSignal(joy.data.curr.axesRaw[ev.axisIndex],
                                    // differentiate axis indices from button indices
                                    "axis_" + ev.axisIndex.toString(),
                                    joy.data.caps.oemName, ev.index.toString());
        }
        ...
    }
