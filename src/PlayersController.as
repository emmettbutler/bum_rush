package {
    import org.flixel.*;

    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.Joints.*;

    import flash.ui.GameInput;
    import flash.ui.GameInputDevice;
    import flash.ui.GameInputControl;
    import flash.utils.Dictionary;
    import flash.events.GameInputEvent;
    import flash.events.Event;
    import mx.utils.StringUtil;

    public class PlayersController {
        [Embed(source="/../assets/driver_emmett_64.png")] private var sprite_1:Class;
        [Embed(source="/../assets/Parking.png")] public var Spr1Parking:Class;

        public static const MIN_PLAYERS:Number = 2;
        public static const MAX_PLAYERS:Number = 8;
        public static const PLAYER_1:Number = 0;
        public static const PLAYER_2:Number = 1;
        public static const PLAYER_3:Number = 2;
        public static const PLAYER_4:Number = 3;
        public static const PLAYER_5:Number = 4;
        public static const PLAYER_6:Number = 5;
        public static const PLAYER_7:Number = 6;
        public static const PLAYER_8:Number = 7;

        public static var instance:PlayersController;
        private var players:Array, playerColliders:Array, passengers:Array;
        private var registeredPlayers:Object;
        private var gameInput:GameInput;
        private var controllers:Dictionary;
        private var control:GameInputControl;
        public var playerConfigs:Dictionary;
        public var playerTags:Array;

        public function PlayersController() {
            gameInput = new GameInput();
            gameInput.addEventListener(GameInputEvent.DEVICE_ADDED,
                                       controllerAdded);
            gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED,
                                       controllerRemoved);
            gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE,
                                       controllerUnusable);
            var screenWidth:Number = ScreenManager.getInstance().screenWidth;
            var screenHeight:Number = ScreenManager.getInstance().screenHeight;


            playerConfigs = new Dictionary();
            playerConfigs[PLAYER_1] = {
                "parking_anim": Spr1Parking,
                "sprite": sprite_1,
                "name": "Billy",
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .935, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .6355, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .334, (screenHeight * 2) * .4)
                ],
                "hud_pos": new DHPoint(10, 10)
            };
            playerConfigs[PLAYER_2] = {
                "parking_anim": Spr1Parking,
                "sprite": sprite_1,
                "name": "Wanda",
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .97, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .372, (screenHeight * 2) * .4)
                ],
                "hud_pos": new DHPoint(110, 10)
            };
            playerConfigs[PLAYER_3] = {
                "parking_anim": Spr1Parking,
                "sprite": sprite_1,
                "name": "Aaron",
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .935, (screenHeight * 2) * .3),
                    new DHPoint((screenWidth * 2) * .6355, (screenHeight * 2) * .45),
                    new DHPoint((screenWidth * 2) * .334, (screenHeight * 2) * .45)
                ],
                "hud_pos": new DHPoint(210, 10)
            };
            playerConfigs[PLAYER_4] = {
                "parking_anim": Spr1Parking,
                "sprite": sprite_1,
                "name": "Toni",
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .97, (screenHeight * 2) * .3),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .45),
                    new DHPoint((screenWidth * 2) * .372, (screenHeight * 2) * .45)
                ],
                "hud_pos": new DHPoint(310, 10)
            };
            playerConfigs[PLAYER_5] = {
                "parking_anim": Spr1Parking,
                "sprite": sprite_1,
                "name": "Emmett",
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .935, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .6355, (screenHeight * 2) * .5),
                    new DHPoint((screenWidth * 2) * .334, (screenHeight * 2) * .5)
                ],
                "hud_pos": new DHPoint(410, 10)
            };
            playerConfigs[PLAYER_6] = {
                "parking_anim": Spr1Parking,
                "sprite": sprite_1,
                "name": "Nina",
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .97, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .5),
                    new DHPoint((screenWidth * 2) * .372, (screenHeight * 2) * .5)
                ],
                "hud_pos": new DHPoint(510, 10)
            };
            playerConfigs[PLAYER_7] = {
                "parking_anim": Spr1Parking,
                "sprite": sprite_1,
                "name": "Diego",
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .935, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .6355, (screenHeight * 2) * .55),
                    new DHPoint((screenWidth * 2) * .334, (screenHeight * 2) * .55)
                ],
                "hud_pos": new DHPoint(610, 10)
            };
            playerConfigs[PLAYER_8] = {
                "parking_anim": Spr1Parking,
                "sprite": sprite_1,
                "name": "Michael",
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .97, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .55),
                    new DHPoint((screenWidth * 2) * .372, (screenHeight * 2) * .55)
                ],
                "hud_pos": new DHPoint(710, 10)
            };

            playerTags = new Array();
            for (var _key:Object in this.playerConfigs) {
                playerTags.push(_key);
            }

            controllers = new Dictionary();
            this.registeredPlayers = new Object();

            if (GameInput.numDevices > 0) {
                this.controllerAdded(null);
            }

            this.players = new Array();
            this.passengers = new Array();
            this.playerColliders = new Array();
        }

        public static function reset():void {
            instance = new PlayersController();
        }

        public function getPlayerColliders():Array {
            if (this.players.length != this.playerColliders.length) {
                this.playerColliders = new Array();
                for (var i:int = 0; i < this.players.length; i++) {
                    this.playerColliders.push(this.players[i].getCollider());
                }
            }
            return this.playerColliders;
        }

        public function registerPlayer(controller:GameInputDevice,
                                       ctrlType:Number=Player.CTRL_PAD):Object
        {
            if (this.playersRegistered >= MAX_PLAYERS) {
                return null;
            }
            var _id:String = controller == null ?
                (Math.random() * 100000) + "" : controller.id;
            if (_id in this.registeredPlayers) {
                return null;
            }
            var tag:Number = this.playerTags[this.playersRegistered];
            this.registeredPlayers[_id] = {
                'ctrl_type': ctrlType,
                'controller': ctrlType == Player.CTRL_KEYBOARD_1 ||
                              ctrlType == Player.CTRL_KEYBOARD_2 ?
                              null : controller,
                'tag': tag
            };
            return PlayersController.getInstance().resolveTag(tag);
        }

        public function resolveTag(tag:Number):Object {
            return this.playerConfigs[tag];
        }

        public function get playersRegistered():int {
            var cnt:int = 0;
            for (var s:String in this.registeredPlayers) cnt++;
            return cnt;
        }

        public function getPlayerList():Array {
            return this.players;
        }

        public function addRegisteredPlayers(checkpoint_count:Number,
                                             map_idx:Number,
                                             world:b2World,
                                             groundBody:b2Body,
                                             streetPoints:Array):void
        {
            var controller:GameInputDevice, player:Player, ctrlType:Number,
                characterTag:Number, pos:DHPoint;
            var cur:Number = 0, passenger:Passenger;
            for (var kid:Object in this.registeredPlayers) {
                if (this.registeredPlayers[kid]['ctrl_type'] == Player.CTRL_KEYBOARD_1 ||
                    this.registeredPlayers[kid]['ctrl_type'] == Player.CTRL_KEYBOARD_2)
                {
                    controller = null;
                } else {
                    controller = this.registeredPlayers[kid]['controller'];
                }
                characterTag = this.registeredPlayers[kid]["tag"];
                ctrlType = this.registeredPlayers[kid]['ctrl_type'];
                pos = this.playerConfigs[characterTag]["start_positions"][map_idx];
                player = new Player(
                    pos, controller, world, groundBody, streetPoints, ctrlType,
                    characterTag, checkpoint_count);
                this.players.push(player);
                player.addVisibleObjects();

                passenger = new Passenger();
                passenger.addVisibleObjects();
                this.passengers.push(passenger);
                player.addPassenger(passenger);

                cur++;
            }
        }

        public function addVisibleObjects():void {
            for (var i:int = 0; i < this.players.length; i++) {
                this.players[i].addVisibleObjects();
            }
        }

        public function update():void {
            var i:int, passenger:Passenger, player:Player;
            for (i = 0; i < this.players.length; i++) {
                player = this.players[i];
                player.update();
                for (var k:int = 0; k < this.passengers.length; k++) {
                    passenger = this.passengers[k];
                    if (passenger.isStanding() && player.overlapsPassenger(passenger)) {
                        player.addPassenger(passenger);
                    }
                }
            }
            for (i = 0; i < this.passengers.length; i++) {
                this.passengers[i].update();
            }
        }

        private function controllerAdded(gameInputEvent:GameInputEvent):void {
            var device:GameInputDevice;
            var config:Object = {};
            this.controllers = new Dictionary();
            for(var k:Number = 0; k < GameInput.numDevices; ++k) {
                config = {};
                device = GameInput.getDeviceAt(k);
                trace("got controller: " + device.name);
                if (device == null) {
                    continue;
                }

                var mapping:Object = ControlResolver.controllerMappings[StringUtil.trim(device.name)];
                var usedButtons:Array = new Array();
                var buttonParams:Object, buttonName:String;
                for (var kButton:String in mapping) {
                    buttonParams = mapping[kButton];
                    buttonName = buttonParams["button"]
                    usedButtons.push(buttonName);
                    if (!(buttonName in config)) {
                        config[buttonName] = new Array();
                    }
                    config[buttonName].push(buttonParams["value_on"])
                    config[buttonName].push(buttonParams["value_off"])
                }
                for(var i:Number = 0; i < device.numControls; ++i) {
                    control = device.getControlAt(i);
                    if (usedButtons.indexOf(control.id) != -1) {
                        control.addEventListener(Event.CHANGE, controllerChanged);
                    }
                }
                device.enabled = true;
                this.controllers[device.id] = config;
            }
        }

        public function controllerChanged(event:Event):void {
            var control:GameInputControl = event.target as GameInputControl;
            var normValue:Number = Math.round(control.value);
            var mapping:Object = ControlResolver.controllerMappings[StringUtil.trim(control.device.name)];
            var allowedValues:Array = this.controllers[control.device.id][control.id];

            /*
            trace("control.id=" + control.id + " has been pressed");
            trace("control.value=" + control.value);
            trace("normValue=" + normValue);
            trace("control.minValue=" + control.minValue);
            trace("control.maxValue=" + control.maxValue);
            trace();
            */

            if(allowedValues.indexOf(normValue) != -1){
                var controlParams:Object = {
                    'value': Math.round(control.value),
                    'id': control.id,
                    'device': control.device
                };
                (FlxG.state as GameState).controllerChanged(controlParams, mapping);
                for (var i:int = 0; i < this.players.length; i++) {
                    this.players[i].controllerChanged(controlParams, mapping);
                }
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
