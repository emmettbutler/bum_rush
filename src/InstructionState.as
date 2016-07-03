package {
    import org.flixel.*;

    import flash.ui.GameInputControl;
    import flash.ui.GameInputDevice;

    public class InstructionState extends GameState {
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;

        private var _cur_map:Number;
        private var bg:FlxExtSprite

        public function InstructionState(map:Number) {
            this._cur_map = map;
        }

        override public function create():void {
            super.create();

            ScreenManager.getInstance();
            var pathPrefix:String = "../assets/images/ui/";
            this.bg = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + "instructions_bg.png");
            this.addQuitElements();
        }

        override public function update():void {
            super.update();
            if(this.timeAlive/1000 > 8) {
                FlxG.switchState(new PlayState(this._cur_map));
            }
        }
    }
}
