package {
    import org.flixel.*;
    import flash.ui.GameInput;
    import flash.ui.GameInputDevice;
    import flash.ui.GameInputControl;
    import flash.events.GameInputEvent;
    import flash.events.Event;

    public class PlayersController {
        [Embed(source="/../assets/Char1_32.png")] private var sprite_1:Class;
        [Embed(source="/../assets/Parking.png")] public var Spr1Parking:Class;

        public static const NUM_PLAYERS:Number = 2;
        {
            public static const DRIVER_NAMES:Array = ["Billy", "Wanda"];
            public static const DRIVER_START_POS:Array = [[new DHPoint(543, 603), new DHPoint(543, 653)]];
        }

        public static var instance:PlayersController;

        private var players:FlxGroup, playerColliders:FlxGroup;
        private var registeredPlayers:Object;
        private var gameInput:GameInput;
        public var parking_anims:Array = [Spr1Parking, Spr1Parking];

        private var controllers:Array;
        private var control:GameInputControl;

        public function PlayersController() {
            gameInput = new GameInput();
            gameInput.addEventListener(GameInputEvent.DEVICE_ADDED,
                                       controllerAdded);
            gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED,
                                       controllerRemoved);
            gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE,
                                       controllerUnusable);

            controllers = new Array();
            this.registeredPlayers = new Object();

            if (GameInput.numDevices > 0) {
                this.controllerAdded(null);
            }

            this.players = new FlxGroup();
            this.playerColliders = new FlxGroup();
        }

        public static function reset():void {
            instance = new PlayersController();
        }

        public function getPlayerColliders():FlxGroup {
            if (this.players.length != this.playerColliders.length) {
                for (var i:int = 0; i < this.players.length; i++) {
                    this.playerColliders.add(this.players.members[i].getCollider());
                }
            }
            return this.playerColliders;
        }

        public function registerPlayer(controller:GameInputDevice,
                                       keyboard:Boolean=false):Object {
            var _id:String = controller == null ?
                (Math.random() * 100000) + "" : controller.id;
            if (_id in this.registeredPlayers) {
                return null;
            }
            var tag:Number = ControlResolver.characterTags[this.playersRegistered];
            this.registeredPlayers[_id] = {
                'controller': keyboard ? 'keyboard' : controller,
                'tag': tag
            };
            return PlayersController.getInstance().resolveTag(tag);
        }

        public function resolveTag(tag:Number):Object {
            var ret:Object = {};
            switch(tag) {
                case ControlResolver.characterTags[0]:
                    ret['sprite'] = sprite_1;
                    ret['name'] = DRIVER_NAMES[0];
                break;

                case ControlResolver.characterTags[1]:
                    ret['sprite'] = sprite_1;
                    ret['name'] = DRIVER_NAMES[1];
                break;
            }
            return ret;
        }

        public function get playersRegistered():int {
            var cnt:int = 0;
            for (var s:String in this.registeredPlayers) cnt++;
            return cnt;
        }

        public function getPlayerList():Array {
            return this.players.members;
        }

        public function addRegisteredPlayers(checkpoint_count:Number, active_map_ind:Number):void {
            var controller:GameInputDevice, player:Player, keyboard:Boolean, characterTag:Number;
            var cur:Number = 0;
            for (var kid:Object in this.registeredPlayers) {
                if (this.registeredPlayers[kid]['controller'] == 'keyboard') {
                    controller = null;
                    keyboard = true;
                } else {
                    controller = this.registeredPlayers[kid]['controller'];
                    keyboard = false;
                }
                characterTag = this.registeredPlayers[kid]["tag"];
                player = new Player(PlayersController.DRIVER_START_POS[active_map_ind][cur], controller, keyboard, characterTag, checkpoint_count);
                this.players.add(player);
                player.addVisibleObjects();
                cur++;
            }
        }

        private function addPlayer(controller:GameInputDevice):void {
            var player:Player;
            player = new Player(new DHPoint(40, 40 + Math.random() * 22), controller);
            this.players.add(player);
            player.addVisibleObjects();
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
        }

        private function controllerAdded(gameInputEvent:GameInputEvent):void {
            var device:GameInputDevice;
            this.controllers = new Array();
            for(var k:Number = 0; k < GameInput.numDevices; ++k) {
                device = GameInput.getDeviceAt(k);
                if (device == null) {
                    continue;
                }

                var mapping:Object = ControlResolver.controllerMappings[device.name];
                var usedButtons:Array = new Array();
                for (var kButton:String in mapping) {
                    usedButtons.push(mapping[kButton]);
                }
                //get all the buttons (loop through number of controls) and add the on change listener
                //this indicates if a button pressed, and gets the value...
                for(var i:Number = 0; i < device.numControls; ++i) {
                    control = device.getControlAt(i);
                    if (usedButtons.indexOf(control.id) != -1) {
                        control.addEventListener(Event.CHANGE, controllerChanged);
                    }
                }
                device.enabled = true;

                this.controllers.push(device);
            }
        }

        public function controllerChanged(event:Event):void {
            var control:GameInputControl = event.target as GameInputControl;
            /*
            if(control.value >= control.maxValue){
                trace("control.id=" + control.id + " has been pressed");
                trace("control.value=" + control.value);
            }
            */

            var mapping:Object = ControlResolver.controllerMappings[control.device.name];

            (FlxG.state as GameState).controllerChanged(control, mapping);
            for (var i:int = 0; i < this.players.length; i++) {
                this.players.members[i].controllerChanged(control, mapping);
            }
        }

        private function controllerRemoved( gameInputEvent:GameInputEvent ):void {
            trace( "Controller Removed." );
        }

        private function controllerUnusable( gameInputEvent:GameInputEvent ):void {
            trace( "Controller Unusable." );
        }

        public static function getInstance():PlayersController {
            if (instance == null) {
                instance = new PlayersController();
            }
            return instance;
        }
    }
}
