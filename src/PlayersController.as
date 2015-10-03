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
        [Embed(source="/../assets/images/characters/driver_emmett_64.png")] private var sprite_1:Class;
        [Embed(source="/../assets/images/characters/driver_nina_64.png")] private var sprite_2:Class;
        [Embed(source="/../assets/images/characters/car_p1_64.png")] private var ImgCar1:Class;
        [Embed(source="/../assets/images/characters/car_p2_64.png")] private var ImgCar2:Class;
        [Embed(source="/../assets/images/characters/temp_car_1.png")] private var ImgCar3:Class;
        [Embed(source="/../assets/images/characters/temp_car_2.png")] private var ImgCar4:Class;
        [Embed(source="/../assets/images/characters/temp_car_3.png")] private var ImgCar5:Class;
        [Embed(source="/../assets/images/characters/temp_car_4.png")] private var ImgCar6:Class;
        [Embed(source="/../assets/images/characters/temp_car_5.png")] private var ImgCar7:Class;
        [Embed(source="/../assets/images/characters/temp_car_6.png")] private var ImgCar8:Class;

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
                "tag": PLAYER_1,
                "sprite": sprite_1,
                "car": ImgCar1,
                "join_prefix": "bernard",
                "starting_passenger": Passenger.TYPE_A,
                "name": "Josh",
                "tint": 0xffe63552,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .43, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .6355, (screenHeight * 2) * .2),
                    new DHPoint((screenWidth * 2) * .385, (screenHeight * 2) * .46),
                    new DHPoint((screenWidth * 2) * .935, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .635, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .334, (screenHeight * 2) * .4)
                ]
            };
            playerConfigs[PLAYER_2] = {
                "tag": PLAYER_2,
                "sprite": sprite_1,
                "car": ImgCar2,
                "join_prefix": "billy",
                "starting_passenger": Passenger.TYPE_B,
                "name": "Jen",
                "tint": 0xff3bc6ff,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .47, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .2),
                    new DHPoint((screenWidth * 2) * .423, (screenHeight * 2) * .46),
                    new DHPoint((screenWidth * 2) * .97, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .372, (screenHeight * 2) * .4)
                ]
            };
            playerConfigs[PLAYER_3] = {
                "tag": PLAYER_3,
                "sprite": sprite_2,
                "car": ImgCar3,
                "join_prefix": "ermit",
                "starting_passenger": Passenger.TYPE_C,
                "name": "Lacey",
                "tint": 0xfff33bff,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .43, (screenHeight * 2) * .3),
                    new DHPoint((screenWidth * 2) * .6355, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .385, (screenHeight * 2) * .51),
                    new DHPoint((screenWidth * 2) * .935, (screenHeight * 2) * .3),
                    new DHPoint((screenWidth * 2) * .635, (screenHeight * 2) * .45),
                    new DHPoint((screenWidth * 2) * .334, (screenHeight * 2) * .45),
                ]
            };
            playerConfigs[PLAYER_4] = {
                "tag": PLAYER_4,
                "sprite": sprite_1,
                "car": ImgCar4,
                "join_prefix": "keiko",
                "starting_passenger": Passenger.TYPE_D,
                "name": "Aaron",
                "tint": 0xffffb43b,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .47, (screenHeight * 2) * .3),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .423, (screenHeight * 2) * .51),
                    new DHPoint((screenWidth * 2) * .97, (screenHeight * 2) * .3),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .45),
                    new DHPoint((screenWidth * 2) * .372, (screenHeight * 2) * .45)
                ]
            };
            playerConfigs[PLAYER_5] = {
                "tag": PLAYER_5,
                "sprite": sprite_1,
                "car": ImgCar5,
                "join_prefix": "laura",
                "starting_passenger": Passenger.TYPE_E,
                "name": "Dan",
                "tint": 0xff225acd,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .43, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .6355, (screenHeight * 2) * .3),
                    new DHPoint((screenWidth * 2) * .385, (screenHeight * 2) * .56),
                    new DHPoint((screenWidth * 2) * .935, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .635, (screenHeight * 2) * .5),
                    new DHPoint((screenWidth * 2) * .334, (screenHeight * 2) * .5)
                ]
            };
            playerConfigs[PLAYER_6] = {
                "tag": PLAYER_6,
                "sprite": sprite_1,
                "car": ImgCar6,
                "join_prefix": "mim",
                "starting_passenger": Passenger.TYPE_F,
                "name": "Toni",
                "tint": 0xffff603b,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .47, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .3),
                    new DHPoint((screenWidth * 2) * .423, (screenHeight * 2) * .56),
                    new DHPoint((screenWidth * 2) * .97, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .5),
                    new DHPoint((screenWidth * 2) * .372, (screenHeight * 2) * .5)
                ]
            };
            playerConfigs[PLAYER_7] = {
                "tag": PLAYER_7,
                "sprite": sprite_2,
                "car": ImgCar7,
                "join_prefix": "nonny",
                "starting_passenger": Passenger.TYPE_G,
                "name": "Nina",
                "tint": 0xffffa7e2,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .43, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .6355, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .385, (screenHeight * 2) * .51),
                    new DHPoint((screenWidth * 2) * .935, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .635, (screenHeight * 2) * .55),
                    new DHPoint((screenWidth * 2) * .334, (screenHeight * 2) * .55)
                ]
            };
            playerConfigs[PLAYER_8] = {
                "tag": PLAYER_8,
                "sprite": sprite_1,
                "car": ImgCar8,
                "join_prefix": "rachel",
                "starting_passenger": Passenger.TYPE_H,
                "name": "Emmett",
                "tint": 0xffb2b2b2,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .47, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .423, (screenHeight * 2) * .51),
                    new DHPoint((screenWidth * 2) * .97, (screenHeight * 2) * .25),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .55),
                    new DHPoint((screenWidth * 2) * .372, (screenHeight * 2) * .55)
                ]
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

                passenger = new Passenger(
                    this.playerConfigs[characterTag]['starting_passenger']
                );
                passenger.addVisibleObjects();
                this.passengers.push(passenger);
                player.addPassenger(passenger, false);

                cur++;
            }

            for (var i:int = 0; i < this.players.length; i++) {
                this.players[i].addMeter();
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
                player.setHudPos(new DHPoint(
                    ((ScreenManager.getInstance().screenWidth / (this.players.length + 1)) * (i + 1)) - 50,
                    ScreenManager.getInstance().screenHeight - 100
                ));
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
