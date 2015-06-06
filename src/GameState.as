package {
    import org.flixel.*;

    import flash.ui.GameInputControl;

    public class GameState extends FlxState {
        protected var bornTime:Number, timeAlive:Number, curTime:Number;

        override public function create():void {
            this.bornTime = new Date().valueOf();
        }

        override public function update():void {
            super.update();

            this.curTime = new Date().valueOf();
            this.timeAlive = this.curTime - this.bornTime;

            PlayersController.getInstance().update();

            if(FlxG.keys.justPressed("R")) {
                FlxG.switchState(new MenuState());
            }
        }

        public function controllerChanged(control:GameInputControl,
                                          mapping:Object):void
        { }
    }
}
