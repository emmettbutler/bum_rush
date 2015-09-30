package {
    import org.flixel.*;

    import flash.ui.GameInputControl;
    import flash.ui.GameInputDevice;

    public class MenuState extends GameState {
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;

        private var countdownLength:Number = 5, lastRegisterTime:Number = -1;
        private var stateSwitchLock:Boolean = false;
        private var registerIndicators:Array;
        private var timerText:FlxText;
        private var playersToMinimum:Number, secondsRemaining:Number;
        private var bg:FlxExtSprite, toon_text:FlxExtSprite;

        private var curIndicator:RegistrationIndicator;

        override public function create():void {
            super.create();

            PlayersController.reset();
            ScreenManager.getInstance();

            var pathPrefix:String = "../assets/images/ui/";
            this.bg = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + "bg.png");
            this.toon_text = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + "text_temp.png");

            this.registerIndicators = new Array();
            var indicator:RegistrationIndicator;
            for (var k:Object in PlayersController.getInstance().playerConfigs) {
                indicator = new RegistrationIndicator(PlayersController.getInstance().playerConfigs[k]);
                this.registerIndicators.push(indicator);
                indicator.addVisibleObjects();
            }

            var t:FlxText;
            t = new FlxText(ScreenManager.getInstance().screenWidth * .05,
                            ScreenManager.getInstance().screenHeight * .8,
                            ScreenManager.getInstance().screenWidth,
                            "Press A to join");
            t.setFormat("Pixel_Berry_08_84_Ltd.Edition",25,0xffffffff,"left");
            add(t);

            t = new FlxText(0,
                            ScreenManager.getInstance().screenHeight * .96,
                            ScreenManager.getInstance().screenWidth,
                            "Bum Rush - by Nina Freeman, Emmett Butler, Diego Garcia and Max Coburn");
            t.setFormat("Pixel_Berry_08_84_Ltd.Edition",20,0xffffffff,"center");
            add(t);

            this.timerText = new FlxText(ScreenManager.getInstance().screenWidth * .05,
                                         ScreenManager.getInstance().screenHeight * .85,
                                         ScreenManager.getInstance().screenWidth, "");
            this.timerText.setFormat("Pixel_Berry_08_84_Ltd.Edition",20,0xffffffff,"left");
            FlxG.state.add(this.timerText);

            if (FlxG.music != null) {
                FlxG.music.stop();
            }
        }

        override public function update():void {
            super.update();

            if (PlayersController.getInstance().playersRegistered >= PlayersController.MIN_PLAYERS) {
                if ((this.curTime - this.lastRegisterTime) / 1000 > this.countdownLength && !this.stateSwitchLock)
                {
                    this.stateSwitchLock = true;
                    FlxG.switchState(new MapPickerState());
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
            }
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
    }
}
