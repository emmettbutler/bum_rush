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
    import flash.system.Capabilities;
    import mx.utils.StringUtil;

    CONFIG::include_extension {
        import com.iam2bam.ane.nativejoystick.NativeJoystick;
        import com.iam2bam.ane.nativejoystick.event.NativeJoystickEvent;
    }

    public class PlayersController {
        [Embed(source="/../assets/images/characters/driver_emmett_64.png")] private var sprite_emmett:Class;
        [Embed(source="/../assets/images/characters/driver_laura_64.png")] private var sprite_laura:Class;
        [Embed(source="/../assets/images/characters/driver_billy_64.png")] private var sprite_billy:Class;
        [Embed(source="/../assets/images/characters/driver_rachel_64.png")] private var sprite_rachel:Class;
        [Embed(source="/../assets/images/characters/driver_nina_64.png")] private var sprite_nina:Class;
        [Embed(source="/../assets/images/characters/driver_bernard_64.png")] private var sprite_bernard:Class;
        [Embed(source="/../assets/images/characters/driver_keiko_64.png")] private var sprite_keiko:Class;
        [Embed(source="/../assets/images/characters/driver_mim_64.png")] private var sprite_mim:Class;
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
        public var gameInput:GameInput;
        private var controllers:Dictionary, controller_ids:Array;
        private var control:GameInputControl;
        private var keyboardRegisteredPlayers:Number = 0;
        public var playerConfigs:Dictionary;
        public var playerTags:Dictionary, tagsList:Array;
        public var fetchedCaps:Boolean = false;

        public function PlayersController() {
            playerTags = new Dictionary();
            if (ScreenManager.platform == "windows") {
                CONFIG::include_extension {
                    NativeJoystick.manager.pollInterval = 33;
                    NativeJoystick.manager.addEventListener(NativeJoystickEvent.BUTTON_DOWN, onBtnDown);
                    NativeJoystick.manager.addEventListener(NativeJoystickEvent.BUTTON_UP, onBtnUp);
                    NativeJoystick.manager.addEventListener(NativeJoystickEvent.AXIS_MOVE, onAxisMove);
                }
                FlxG.stage.addEventListener(Event.ENTER_FRAME, onFrame);
            } else if (ScreenManager.platform == "mac") {
                gameInput = new GameInput();
                gameInput.addEventListener(GameInputEvent.DEVICE_ADDED,
                                           controllerAdded);
            }

            var screenWidth:Number = ScreenManager.getInstance().screenWidth;
            var screenHeight:Number = ScreenManager.getInstance().screenHeight;

            this.tagsList = [
                PLAYER_1,
                PLAYER_2,
                PLAYER_3,
                PLAYER_4,
                PLAYER_5,
                PLAYER_6,
                PLAYER_7,
                PLAYER_8
            ];

            playerConfigs = new Dictionary();
            playerConfigs[PLAYER_1] = {
                "tag": PLAYER_1,
                "index": 0,
                "sprite": sprite_bernard,
                "car": ImgCar1,
                "join_prefix": "bernard",
                "starting_passenger": Passenger.TYPE_A,
                "name": "Bernard",
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
                "index": 1,
                "sprite": sprite_billy,
                "car": ImgCar2,
                "join_prefix": "billy",
                "starting_passenger": Passenger.TYPE_B,
                "name": "Billy",
                "tint": 0xff00e476,
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
                "index": 2,
                "sprite": sprite_emmett,
                "car": ImgCar3,
                "join_prefix": "ermit",
                "starting_passenger": Passenger.TYPE_C,
                "name": "Emmett",
                "tint": 0xff4646ee,
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
                "index": 3,
                "sprite": sprite_keiko,
                "car": ImgCar4,
                "join_prefix": "keiko",
                "starting_passenger": Passenger.TYPE_D,
                "name": "Keiko",
                "tint": 0xffff8e1f,
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
                "index": 4,
                "sprite": sprite_laura,
                "car": ImgCar5,
                "join_prefix": "laura",
                "starting_passenger": Passenger.TYPE_E,
                "name": "Laura",
                "tint": 0xffac19f0,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .43, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .6355, (screenHeight * 2) * .3),
                    new DHPoint((screenWidth * 2) * .385, (screenHeight * 2) * .56),
                    new DHPoint((screenWidth * 2) * .935, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .635, (screenHeight * 2) * .5),
                    new DHPoint((screenWidth * 2) * .334, (screenHeight * 2) * .5)
                ]
            };
            playerConfigs[PLAYER_6] = {
                "tag": PLAYER_6,
                "index": 5,
                "sprite": sprite_mim,
                "car": ImgCar6,
                "join_prefix": "mim",
                "starting_passenger": Passenger.TYPE_F,
                "name": "Mim",
                "tint": 0xffff69be,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .47, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .3),
                    new DHPoint((screenWidth * 2) * .423, (screenHeight * 2) * .56),
                    new DHPoint((screenWidth * 2) * .97, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .5),
                    new DHPoint((screenWidth * 2) * .372, (screenHeight * 2) * .5)
                ]
            };
            playerConfigs[PLAYER_7] = {
                "tag": PLAYER_7,
                "index": 6,
                "sprite": sprite_nina,
                "car": ImgCar7,
                "join_prefix": "nonny",
                "starting_passenger": Passenger.TYPE_G,
                "name": "Nina",
                "tint": 0xff3cc1ff,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .43, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .6355, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .385, (screenHeight * 2) * .61),
                    new DHPoint((screenWidth * 2) * .935, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .635, (screenHeight * 2) * .55),
                    new DHPoint((screenWidth * 2) * .334, (screenHeight * 2) * .55)
                ]
            };
            playerConfigs[PLAYER_8] = {
                "tag": PLAYER_8,
                "index": 7,
                "sprite": sprite_rachel,
                "car": ImgCar8,
                "join_prefix": "rachel",
                "starting_passenger": Passenger.TYPE_H,
                "name": "Rachel",
                "tint": 0xffffff00,
                "start_positions": [
                    new DHPoint((screenWidth * 2) * .47, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .35),
                    new DHPoint((screenWidth * 2) * .423, (screenHeight * 2) * .61),
                    new DHPoint((screenWidth * 2) * .97, (screenHeight * 2) * .4),
                    new DHPoint((screenWidth * 2) * .67, (screenHeight * 2) * .55),
                    new DHPoint((screenWidth * 2) * .372, (screenHeight * 2) * .55)
                ]
            };

            this.controllers = new Dictionary();
            this.controller_ids = new Array();
            if (ScreenManager.platform == "mac") {
                if (GameInput.numDevices > 0) {
                    this.controllerAdded(null);
                }
            }
        }

        public function resetInstance():void {
            this.registeredPlayers = new Object();
            this.players = new Array();
            this.passengers = new Array();
            this.playerColliders = new Array();
            this.keyboardRegisteredPlayers = 0;
        }

        public function getRegisteredPlayers():Object {
            return this.registeredPlayers;
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

        public function registerPlayer(controllerId:String,
                                       ctrlType:Number=Player.CTRL_PAD):Object
        {
            if (this.playersRegistered >= MAX_PLAYERS) {
                return null;
            }
            if (controllerId == null &&
                this.keyboardRegisteredPlayers >= this.tagsList.length - this.controller_ids.length)
            {
                return null;
            }
            var _id:String = controllerId == null ?
                (Math.random() * 100000) + "" : controllerId;
            if (_id in this.registeredPlayers) {
                return null;
            }
            var _idx:Number = this.tagsList[this.controller_ids.length + this.keyboardRegisteredPlayers];
            if (this.playerTags[controllerId] == undefined) {
                this.playerTags[controllerId] = this.tagsList[this.playersRegistered];
            }
            var tag:Number = this.playerTags[controllerId == null ? _idx : controllerId];
            if (controllerId == null) {
                this.keyboardRegisteredPlayers += 1;
            }
            trace("registered player with settings:\n" +
                "\t'ctrl_type': " + ctrlType +
                "\n\t'controller_id': " + controllerId +
                "\n\t'tag': " + tag +
                "\n\t'config': " + this.resolveTag(tag));
            this.registeredPlayers[_id] = {
                'ctrl_type': ctrlType,
                'controller_id': ctrlType == Player.CTRL_KEYBOARD_1 ||
                              ctrlType == Player.CTRL_KEYBOARD_2 ?
                              null : controllerId,
                'tag': tag,
                'config': this.resolveTag(tag)
            };
            return this.resolveTag(tag);
        }

        public function getTagDataByControllerID(_id:String):Object {
            for (var kid:Object in this.registeredPlayers) {
                if (this.registeredPlayers[kid]['controller_id'] == null) {
                    continue;
                }
                if (_id == this.registeredPlayers[kid]['controller_id']) {
                    return this.registeredPlayers[kid];
                }
            }
            return null;
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

        public function addRegisteredPlayers(checkpoints:Array,
                                             map_idx:Number,
                                             world:b2World,
                                             groundBody:b2Body,
                                             streetPoints:Array):void
        {
            var controllerId:String, player:Player, ctrlType:Number,
                characterTag:Number, pos:DHPoint;
            var cur:Number = 0, passenger:Passenger;
            for (var kid:Object in this.registeredPlayers) {
                if (this.registeredPlayers[kid]['ctrl_type'] == Player.CTRL_KEYBOARD_1 ||
                    this.registeredPlayers[kid]['ctrl_type'] == Player.CTRL_KEYBOARD_2)
                {
                    controllerId = null;
                } else {
                    controllerId = this.registeredPlayers[kid]['controller_id'];
                }
                characterTag = this.registeredPlayers[kid]["tag"];
                ctrlType = this.registeredPlayers[kid]['ctrl_type'];
                pos = this.playerConfigs[characterTag]["start_positions"][map_idx];
                player = new Player(
                    pos, controllerId, world, groundBody, streetPoints, ctrlType,
                    characterTag, checkpoints);
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

        /*
         * Add a controller ID/name pair to the internal controller registry
         * Return an array of the names of buttons used on this controller
         */
        private function registerController(deviceName:String, deviceId:String):Array {
            deviceName = StringUtil.trim(deviceName);
            trace("got controller: " + deviceName + " " + deviceId);
            var os_ver:String = flash.system.Capabilities.os.substr(0, 3);
            var config:Object = {};
            var mapping:Object = ControlResolver.controllerMappings[deviceName][os_ver];
            var usedButtons:Array = new Array();
            var buttonParams:Object, buttonName:String;
            for (var kButton:String in mapping) {
                buttonParams = mapping[kButton];
                buttonName = buttonParams["button"];
                usedButtons.push(buttonName);
                if (!(buttonName in config)) {
                    config[buttonName] = new Array();
                }
                config[buttonName].push(buttonParams["value_on"])
                config[buttonName].push(buttonParams["value_off"])
            }
            if (!this.controllers.hasOwnProperty(deviceId)) {
                this.controllers[deviceId] = config;
                this.controller_ids.push(deviceId);
            }
            return usedButtons;
        }

        /*
         * Normalize control value and dispatch handlers
         */
        private function sendControlSignal(value:int,
                                           cId:String,
                                           deviceName:String,
                                           deviceId:String):void
        {
            var os_ver:String = flash.system.Capabilities.os.substr(0, 3);
            deviceName = StringUtil.trim(deviceName);
            var normValue:Number = Math.round(value);
            trace("Control pressed on controller '" + deviceName + " " + deviceId + "':\n" +
                  "\tControl id:\t\t\t" + cId + "\n" +
                  "\tControl value:\t\t\t" + value + "\n" +
                  "\tNormalized control value:\t" + normValue);
            var mapping:Object = ControlResolver.controllerMappings[deviceName][os_ver];
            var deviceMap:Object = this.controllers[deviceId];
            if (deviceMap == null) {
                return;
            }
            var allowedValues:Array = deviceMap[cId];
            if(allowedValues != null && allowedValues.indexOf(normValue) != -1){
                var controlParams:Object = {
                    'value': Math.round(value),
                    'id': cId,
                    'device_id': deviceId
                };
                (FlxG.state as GameState).controllerChanged(controlParams, mapping);
                for (var i:int = 0; i < this.players.length; i++) {
                    this.players[i].controllerChanged(controlParams, mapping);
                }
            }
        }

        /*
         * Adobe GameInput API handler for controller discovery
         */
        private function controllerAdded(gameInputEvent:GameInputEvent):void {
            if (this.controller_ids.length >= MAX_PLAYERS) {
                return;
            }
            var device:GameInputDevice, usedButtons:Array;
            for(var k:Number = 0; k < GameInput.numDevices; ++k) {
                device = GameInput.getDeviceAt(k);
                usedButtons = this.registerController(device.name, device.id);
                for(var i:Number = 0; i < device.numControls; ++i) {
                    control = device.getControlAt(i);
                    if (usedButtons.indexOf(control.id) != -1) {
                        control.addEventListener(Event.CHANGE, controllerChanged);
                    }
                }
                device.enabled = true;
            }
        }

        /*
         * Adobe GameInput API handler for controller events
         */
        public function controllerChanged(event:Event):void {
            var control:GameInputControl = event.target as GameInputControl;
            this.sendControlSignal(control.value, control.id,
                                   control.device.name, control.device.id);
        }

        CONFIG::include_extension {
            /*
            * NativeJoystick API handler for controller axis events
            */
            private function onAxisMove(ev:NativeJoystickEvent):void {
                var joy:NativeJoystick = new NativeJoystick(ev.index);
                this.sendControlSignal(joy.data.curr.axesRaw[ev.axisIndex],
                                       // differentiate axis indices from button indices
                                       "axis_" + ev.axisIndex.toString(),
                                       joy.data.caps.oemName, ev.index.toString());
            }

            /*
            * NativeJoystick API handler for controller button release events
            */
            private function onBtnUp(ev:NativeJoystickEvent):void {
                var joy:NativeJoystick = new NativeJoystick(ev.index);
                this.sendControlSignal(int(joy.pressed(ev.buttonIndex)),
                                    ev.buttonIndex.toString(),
                                    joy.data.caps.oemName, ev.index.toString());
            }

            /*
            * NativeJoystick API handler for controller button press events
            */
            private function onBtnDown(ev:NativeJoystickEvent):void {
                var joy:NativeJoystick = new NativeJoystick(ev.index);
                this.sendControlSignal(int(joy.pressed(ev.buttonIndex)),
                                    ev.buttonIndex.toString(),
                                    joy.data.caps.oemName, ev.index.toString());
            }
        }

        private function onFrame(ev:Event):void {
            if (this.fetchedCaps) {
                return;
            }
            CONFIG::include_extension {
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
        }

        public static function getInstance():PlayersController {
            if (instance == null) {
                instance = new PlayersController();
            }
            return instance;
        }
    }
}
