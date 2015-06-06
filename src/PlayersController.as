package {
    import org.flixel.*;
    import flash.ui.GameInput;
    import flash.ui.GameInputDevice;
    import flash.ui.GameInputControl;
    import flash.events.GameInputEvent;
    import flash.events.Event;

    public class PlayersController {
        public static const NUM_PLAYERS:Number = 2;

        private var players:FlxGroup;
        private var gameInput:GameInput;

        private var controllers:Array;
        private var control:GameInputControl;

        public function PlayersController() {
            gameInput = new GameInput();
            gameInput.addEventListener( GameInputEvent.DEVICE_ADDED, controllerAdded );
            gameInput.addEventListener( GameInputEvent.DEVICE_REMOVED, controllerRemoved );
            gameInput.addEventListener( GameInputEvent.DEVICE_UNUSABLE, controllerUnusable );

            controllers = new Array();

            if (GameInput.numDevices > 0) {
                trace("Controller found! GameInput.numDevices is " + GameInput.numDevices);
                this.controllerAdded(null);
            }

            this.players = new FlxGroup();
            var player:Player;
            for (var i:int = 0; i < NUM_PLAYERS; i++) {
                player = new Player(new DHPoint(40, 40 + i * 22), this.controllers[i]);
                this.players.add(player);
            }
        }

        public function addVisibleObjects():void {
            for (var i:int = 0; i < this.players.length; i++) {
                this.players.members[i].addVisibleObjects();
            }
        }

        public function update():void {
            for (var i:int = 0; i < this.players.length; i++) {
                this.players.members[i].update();
            }
            FlxG.collide(this.players, this.players);
        }

        private function controllerAdded(gameInputEvent:GameInputEvent):void {
            trace("Controller Added! GameInput.numDevices is " + GameInput.numDevices);
            //Controller #1 - lazy test
            var device:GameInputDevice;
            this.controllers = new Array();
            for(var k:Number = 0; k < GameInput.numDevices; ++k) {
                device = GameInput.getDeviceAt(k);
                if (device == null) {
                    continue;
                }
                //get all the buttons (loop through number of controls) and add the on change listener
                //this indicates if a button pressed, and gets the value...
                for(var i:Number = 0; i < device.numControls; ++i) {
                    control = device.getControlAt(i);
                    control.addEventListener(Event.CHANGE, controllerChanged);
                    trace("CONTROLS: " + control.id);
                }
                device.enabled = true;

                this.controllers.push(device);

                trace("device.enabled - " + device.enabled);
                trace("device.id - " + device.id);
                trace("device.name - " + device.name);
                trace("device.numControls - " + device.numControls);
                trace("device.sampleInterval - " + device.sampleInterval);
                trace("device.MAX_BUFFER - " + GameInputDevice.MAX_BUFFER_SIZE);
                trace("device.numControls - " + device.numControls);
            }
        }

        public function controllerChanged(event:Event):void {
            var control:GameInputControl = event.target as GameInputControl;
            //To get the value of the press you can use .value, or minValue and maxValue for on/off
            //var num_val:Number = control.value;
            //
            //constant stream (Axis is very sensitive)
            //trace("control.id=" + control.id);
            //trace("control.value=" + control.value + " (" + control.minValue+" .. " + control.maxValue+")");
            //
            //trace just on/off to see each button
            if(control.value >= control.maxValue){
                trace("control.id=" + control.id + " has been pressed");
            }

            for (var i:int = 0; i < this.players.length; i++) {
                this.players.members[i].controllerChanged(control);
            }
        }

        private function controllerRemoved( gameInputEvent:GameInputEvent ):void {
            trace( "Controller Removed." );
        }

        private function controllerUnusable( gameInputEvent:GameInputEvent ):void {
            trace( "Controller Unusable." );
        }
    }
}
