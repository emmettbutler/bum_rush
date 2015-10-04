package {
    import org.flixel.*;

    import flash.ui.GameInputControl;
    import flash.ui.GameInputDevice;

    public class InstructionState extends GameState {
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;

        private var _cur_map:Number;

        public function InstructionState(map:Number) {
            this._cur_map = map;
        }

        override public function create():void {
            super.create();

            var t:FlxText;
            t = new FlxText(0, ScreenManager.getInstance().screenHeight/3, ScreenManager.getInstance().screenWidth,
                            "A to accelerate.\nB to highlight yourself.\nD-pad to steer.\n\nRam into your friends and collect their dates as you visit the hot spots in town.\nThe more the merrier, after all!");
            t.setFormat("Pixel_Berry_08_84_Ltd.Edition",20,0xffffffff);
            t.alignment = "center";
            add(t);
        }

        override public function update():void {
            super.update();
            if(this.timeAlive/1000 > 5) {
                FlxG.switchState(new PlayState(this._cur_map));
            }
        }
    }
}