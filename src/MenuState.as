package {
    import org.flixel.*;

    import flash.ui.GameInputControl;
    import flash.ui.GameInputDevice;

    public class MenuState extends GameState {
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;
        [Embed(source = "../assets/audio/bumrush_select_loop.mp3")] private var SndBGMLoop:Class;
        [Embed(source = "../assets/audio/passenger.mp3")] private var SndJoined:Class;
        [Embed(source = "../assets/audio/bumrush_intro.mp3")] private var SndIntroScene:Class;

        private var countdownLength:Number = 8, lastRegisterTime:Number = -1;
        private var stateSwitchLock:Boolean = false;
        private var registerIndicators:Array;
        private var timerText:FlxText, joinText:FlxText, teamText:FlxText,
                    loadingText:FlxText, skipText:FlxText;
        private var playersToMinimum:Number, secondsRemaining:Number;
        private var bg:FlxExtSprite, toon_text:FlxExtSprite, speech_bubble:FlxExtSprite;
        private var confirmButtonCount:Number = 0, lastConfirmButtonTime:Number = 0;
        private var introStarted:Boolean = false, registeredPlayers:Number = 0;
        private var blackLayer:GameObject;

        private var curIndicator:RegistrationIndicator;

        override public function create():void {
            super.create();

            PlayersController.getInstance().resetInstance();
            ScreenManager.getInstance();

            var pathPrefix:String = "../assets/images/ui/";
            this.bg = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + "bg.png");
            this.blackLayer = new GameObject(new DHPoint(0, 0));
            this.blackLayer.makeGraphic(
                ScreenManager.getInstance().screenWidth,
                ScreenManager.getInstance().screenHeight,
                0xff000000
            );
            this.add(this.blackLayer);
            this.blackLayer.visible = false;
            this.toon_text = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + "text_temp.png");
            this.speech_bubble = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + "speechBubble.png");
            this.speech_bubble.visible = false;

            this.registerIndicators = new Array();
            var indicator:RegistrationIndicator;
            for (var k:Object in PlayersController.getInstance().playerConfigs) {
                indicator = new RegistrationIndicator(PlayersController.getInstance().playerConfigs[k]);
                this.registerIndicators.push(indicator);
                indicator.addVisibleObjects();
            }

            this.loadingText = new FlxText(ScreenManager.getInstance().screenWidth * .05,
                            ScreenManager.getInstance().screenHeight * .8,
                            ScreenManager.getInstance().screenWidth,
                            "Freshening up...");
            this.loadingText.setFormat("Pixel_Berry_08_84_Ltd.Edition",25,0xffffffff,"left");
            FlxG.state.add(this.loadingText);

            this.skipText = new FlxText(0,
                            ScreenManager.getInstance().screenHeight * .94,
                            ScreenManager.getInstance().screenWidth,
                            "All players hold A to skip");
            this.skipText.setFormat("Pixel_Berry_08_84_Ltd.Edition",20,0xccffffff,"right");
            FlxG.state.add(this.skipText);
            this.skipText.visible = false;

            this.joinText = new FlxText(ScreenManager.getInstance().screenWidth * .05,
                            ScreenManager.getInstance().screenHeight * .8,
                            ScreenManager.getInstance().screenWidth,
                            "Bum Rush - Press A to join");
            this.joinText.setFormat("Pixel_Berry_08_84_Ltd.Edition",25,0xffffffff,"left");

            this.teamText = new FlxText(0,
                            ScreenManager.getInstance().screenHeight * .96,
                            ScreenManager.getInstance().screenWidth,
                            "by Nina Freeman, Emmett Butler,\nDiego Garcia and Max Coburn");
            this.teamText.setFormat("Pixel_Berry_08_84_Ltd.Edition",12,0xffffffff,"left");

            this.timerText = new FlxText(ScreenManager.getInstance().screenWidth * .05,
                                         ScreenManager.getInstance().screenHeight * .85,
                                         ScreenManager.getInstance().screenWidth, "");
            this.timerText.setFormat("Pixel_Berry_08_84_Ltd.Edition",20,0xffffffff,"left");

            if (FlxG.music == null) {
                FlxG.playMusic(SndBGMLoop, 1);
            }
            //y pos of background plus a percentage of the height of the bg
            //listener
            var that:MenuState = this;
            FlxG.stage.addEventListener(GameState.EVENT_SINGLETILE_BG_LOADED,
                function(event:DHDataEvent):void {
                    var _bg:FlxExtSprite = event.userData['bg']
                    if (_bg == that.bg) {
                        FlxG.state.add(that.joinText);
                        that.joinText.y = _bg.y + _bg.height * .83;
                        that.joinText.x = _bg.width * .06;

                        FlxG.state.add(that.teamText);
                        that.teamText.y = _bg.y + _bg.height * .935;
                        that.teamText.x = _bg.width * .06;

                        FlxG.state.add(that.timerText);
                        that.timerText.y = _bg.y + _bg.height * .87;
                        that.timerText.x = _bg.width * .06;

                        that.loadingText.visible = false;
                        PlayersController.getInstance().buildControllersMap();

                        FlxG.stage.removeEventListener(
                            GameState.EVENT_SINGLETILE_BG_LOADED,
                            arguments.callee
                        );
                    }
            });
        }

        override public function update():void {
            super.update();

            if (PlayersController.getInstance().playersRegistered >= PlayersController.MIN_PLAYERS) {
                if (((this.curTime - this.lastRegisterTime) / 1000 > this.countdownLength ||
                     this.registeredPlayers == PlayersController.MAX_PLAYERS) &&
                     !this.stateSwitchLock)
                {
                    this.stateSwitchLock = true;
                    this.startIntro();
                }
                secondsRemaining = (this.countdownLength - ((this.curTime - this.lastRegisterTime) / 1000))
                this.timerText.text = "Starting in " + secondsRemaining.toFixed(1) + " seconds!";
            } else {
                playersToMinimum = PlayersController.MIN_PLAYERS - PlayersController.getInstance().playersRegistered;
                this.timerText.text = "Need " + playersToMinimum + " more player" + (playersToMinimum > 1 ? "s" : "");
            }

            if (this.introStarted) {
                if (this.confirmButtonCount == 0) {
                    this.skipText.text = "All players hold A to skip";
                } else if (this.confirmButtonCount < this.registeredPlayers) {
                    this.skipText.text = "All players hold A to skip (" + this.confirmButtonCount + "/" + this.registeredPlayers + ")";
                } else if (this.confirmButtonCount == this.registeredPlayers) {
                    this.skipText.text = "Skipping...";
                }
                if (FlxG.keys.justPressed("B") || this.allPlayersSkipping()) {
                    FlxG.switchState(new MapPickerState());
                }
            }

            // debug
            if (FlxG.keys.justPressed("R")) {
                this.registerPlayer(null, Player.CTRL_KEYBOARD_1);
            } else if (FlxG.keys.justPressed("P")) {
                this.registerPlayer(null, Player.CTRL_KEYBOARD_2);
            }

            for (var i:int = 0; i < this.registerIndicators.length; i++) {
                this.registerIndicators[i].update();
                if (this.registerIndicators[i].state == RegistrationIndicator.STATE_DONE) {
                    FlxG.switchState(new MapPickerState());
                } else if (this.registerIndicators[i].state == RegistrationIndicator.STATE_PHONE) {
                    this.blackLayer.visible = true;
                } else if (this.registerIndicators[i].state == RegistrationIndicator.STATE_HEART) {
                    this.blackLayer.visible = false;
                } else if (this.registerIndicators[i].state == RegistrationIndicator.STATE_ASK) {
                    this.speech_bubble.visible = true;
                } else if (this.registerIndicators[i].state == RegistrationIndicator.STATE_SHOCK) {
                    this.speech_bubble.visible = false;
                }
            }
        }

        public function allPlayersSkipping():Boolean {
            return this.confirmButtonCount == this.registeredPlayers &&
                this.timeAlive - this.lastConfirmButtonTime >= .1 * 1000;
        }

        override public function destroy():void {
            for (var i:int = 0; i < this.registerIndicators.length; i++) {
                this.registerIndicators[i].destroy();
            }
            this.registerIndicators = null;
            this.joinText.destroy();
            this.teamText.destroy();
            this.timerText.destroy();
            this.loadingText.destroy();
            super.destroy();
        }

        override public function controllerChanged(control:Object,
                                                   mapping:Object):void
        {
            super.controllerChanged(control, mapping);
            if (control['id'] == mapping["a"]["button"]){
                if (control['value'] == mapping["a"]["value_on"]) {
                    this.registerPlayer(control, Player.CTRL_PAD);
                    this.confirmButtonCount = Math.min(this.confirmButtonCount + 1, this.registeredPlayers);
                    this.lastConfirmButtonTime = this.timeAlive;
                } else if (control['value'] == mapping["a"]["value_off"]) {
                    this.confirmButtonCount = Math.max(this.confirmButtonCount - 1, 0);
                }
            }
        }

        public function getRegistrationIndicatorByTag(t:Number):RegistrationIndicator {
            for (var i:int = 0; i < this.registerIndicators.length; i++) {
                if (this.registerIndicators[i].tag == t) {
                    return this.registerIndicators[i];
                }
            }
            return null;
        }

        public function registerPlayer(control:Object,
                                       ctrlType:Number=Player.CTRL_PAD):void
        {
            if (this.introStarted) {
                return;
            }
            var device:GameInputDevice;
            if (control == null) {
                device = null;
            } else {
                device = control.device;
            }
            var tagData:Object = PlayersController.getInstance().registerPlayer(
                device, ctrlType);
            if (tagData != null) {
                this.lastRegisterTime = this.curTime;
                this.registeredPlayers += 1;
                FlxG.play(SndJoined, 1);
                var indicator:RegistrationIndicator = this.getRegistrationIndicatorByTag(tagData['tag']);
                indicator.joined = true;
            }
        }

        public function startIntro():void {
            this.toon_text.visible = false;
            this.timerText.visible = false;
            this.joinText.visible = false;
            this.teamText.visible = false;
            this.skipText.visible = true;
            this.introStarted = true;
            var cur:RegistrationIndicator;
            for (var i:int = 0; i < this.registerIndicators.length; i++) {
                cur = this.registerIndicators[i];
                cur.startIntro();
            }
            FlxG.music.stop();
            FlxG.play(SndIntroScene, 1);
        }
    }
}
