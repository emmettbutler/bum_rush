package {
    import org.flixel.*;

    import flash.ui.GameInputControl;

    public class GameState extends FlxState {
        protected var bornTime:Number, timeAlive:Number, curTime:Number, raceBornTime:Number;
        public var gameActive:Boolean = false;

        public static const EVENT_SINGLETILE_BG_LOADED:String = "bg_loaded";

        override public function create():void {
            this.bornTime = new Date().valueOf();
        }

        override public function update():void {
            super.update();

            this.curTime = new Date().valueOf();
            this.timeAlive = this.curTime - this.bornTime;

            if(this.gameActive) {
                PlayersController.getInstance().update();
            }

            if(FlxG.keys.justPressed("R")) {
                FlxG.switchState(new MenuState());
            }
        }

        public function startRaceTimer():void {
            this.raceBornTime = new Date().valueOf();
        }

        public function controllerChanged(control:Object,
                                          mapping:Object):void
        { }
    }
}
