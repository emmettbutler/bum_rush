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

        private var curIndicator:RegistrationIndicator;

        override public function create():void {
            super.create();

            PlayersController.reset();
            ScreenManager.getInstance();

            this.registerIndicators = new Array();

            var t:FlxText;
            t = new FlxText(0,
                            ScreenManager.getInstance().screenHeight / 2 - 150,
                            ScreenManager.getInstance().screenWidth,
                            "Bumrush");
            t.setFormat("Pixel_Berry_08_84_Ltd.Edition",25,0xffffffff,"center");
            add(t);
            t = new FlxText(0,
                            ScreenManager.getInstance().screenHeight / 2 - 100,
                            ScreenManager.getInstance().screenWidth,
                            "Press P, SPACE, or A on controller to join");
            t.setFormat("Pixel_Berry_08_84_Ltd.Edition",20,0xffffffff,"center");
            add(t);

            this.timerText = new FlxText(0,
                                         ScreenManager.getInstance().screenHeight / 2,
                                         ScreenManager.getInstance().screenWidth, "");
            this.timerText.setFormat("Pixel_Berry_08_84_Ltd.Edition",20,0xffffffff,"center");
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
            if (FlxG.keys.justPressed("SPACE")) {
                this.registerPlayer(null, Player.CTRL_KEYBOARD_1);
            } else if (FlxG.keys.justPressed("P")) {
                this.registerPlayer(null, Player.CTRL_KEYBOARD_2);
            }

            for (var i:int = 0; i < this.registerIndicators.length; i++) {
                this.curIndicator = this.registerIndicators[i];
                this.curIndicator.setPos(new DHPoint(
                    (ScreenManager.getInstance().screenWidth / (this.registerIndicators.length + 1)) * (i + 1),
                    ScreenManager.getInstance().screenHeight - 200
                ));
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
                var indicator:RegistrationIndicator = new RegistrationIndicator(
                    tagData
                );
                indicator.addVisibleObjects();
                this.registerIndicators.push(indicator);
            }
        }
    }
}
