package {
    import org.flixel.*;

    import flash.ui.GameInputControl;
    import flash.ui.GameInputDevice;

    public class MenuState extends GameState {
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;
        [Embed(source = "../assets/audio/bumrush_select_loop.mp3")] private var SndBGMLoop:Class;
        [Embed(source = "../assets/audio/bumrush_intro.mp3")] private var SndIntroScene:Class;

        private var countdownLength:Number = 5, lastRegisterTime:Number = -1;
        private var stateSwitchLock:Boolean = false;
        private var registerIndicators:Array;
        private var timerText:FlxText, joinText:FlxText, teamText:FlxText,
                    loadingText:FlxText;
        private var playersToMinimum:Number, secondsRemaining:Number;
        private var bg:FlxExtSprite, toon_text:FlxExtSprite, speech_bubble:FlxExtSprite;

        private var curIndicator:RegistrationIndicator;

        override public function create():void {
            super.create();

            PlayersController.reset();
            ScreenManager.getInstance();

            var pathPrefix:String = "../assets/images/ui/";
            this.bg = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + "bg.png");
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

            if (FlxG.music != null) {
                FlxG.music.stop();
            }
            FlxG.playMusic(SndBGMLoop, 1);
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
                if ((this.curTime - this.lastRegisterTime) / 1000 > this.countdownLength && !this.stateSwitchLock)
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
                } else if (this.registerIndicators[i].state == RegistrationIndicator.STATE_ASK) {
                    this.speech_bubble.visible = true;
                } else if (this.registerIndicators[i].state == RegistrationIndicator.STATE_SHOCK) {
                    this.speech_bubble.visible = false;
                }
            }
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
            if (control['id'] == mapping["a"]["button"] && control['value'] == mapping["a"]["value_on"]) {
                this.registerPlayer(control, Player.CTRL_PAD);
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
                var indicator:RegistrationIndicator = this.getRegistrationIndicatorByTag(tagData['tag']);
                indicator.joined = true;
            }
        }

        public function startIntro():void {
            this.toon_text.visible = false;
            this.timerText.visible = false;
            this.joinText.visible = false;
            this.teamText.visible = false;
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
