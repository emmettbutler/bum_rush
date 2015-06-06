package {
    import org.flixel.*;

    import flash.ui.GameInputControl;

    public class MenuState extends GameState {
        private var countdownLength:Number = 1, lastRegisterTime:Number = -1;
        private var stateSwitchLock:Boolean = false;

        override public function create():void {
            super.create();

            ScreenManager.getInstance();

            var t:FlxText;
            t = new FlxText(0, 200, ScreenManager.getInstance().screenWidth, "bootycall");
            t.size = 16;
            t.alignment = "left";
            add(t);
            t = new FlxText(0, 250, ScreenManager.getInstance().screenWidth, "join to play");
            t.alignment = "left";
            add(t);
        }

        override public function update():void {
            super.update();

            if (PlayersController.getInstance().playersRegistered >= 1 &&
                (this.curTime - this.lastRegisterTime) / 1000 >
                 this.countdownLength && !this.stateSwitchLock)
            {
                this.stateSwitchLock = true;
                FlxG.switchState(new PlayState());
            }
        }

        override public function controllerChanged(control:GameInputControl,
                                                   mapping:Object):void
        {
            super.controllerChanged(control, mapping);
            if (control.id == mapping["a"] && control.value == 1) {
                PlayersController.getInstance().registerPlayer(control.device);
                this.lastRegisterTime = this.curTime;
            }
        }
    }
}
