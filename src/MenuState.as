package {
    import org.flixel.*;

    import flash.ui.GameInputControl;

    public class MenuState extends GameState {
        private var countdownLength:Number = 3, lastRegisterTime:Number = -1;
        private var stateSwitchLock:Boolean = false;

        override public function create():void {
            super.create();

            var t:FlxText;
            t = new FlxText(0,FlxG.height/2-10,FlxG.width,"bootycall");
            t.size = 16;
            t.alignment = "center";
            add(t);
            t = new FlxText(FlxG.width/2-50,FlxG.height-20,100,"join to play");
            t.alignment = "center";
            add(t);
        }

        override public function update():void {
            super.update();

            if (PlayersController.getInstance().playersRegistered >= 2 &&
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
