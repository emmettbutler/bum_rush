package {
    import org.flixel.*;

    import flash.ui.GameInputControl;
    import flash.ui.GameInputDevice;

    public class MapPickerState extends GameState {
        private var _maps:Array;
        private var _picker:FlxSprite;
        private var _cur_map:Number;
        private var _picker_lock:Boolean = false;
        private var _players:Array;
        private var i:Number;

        override public function create():void {
            super.create();
            this._players = PlayersController.getInstance().getPlayerList();

            ScreenManager.getInstance();
            this._maps = new Array();
            this._cur_map = 0;

            var t:FlxText;
            t = new FlxText(0, 100, ScreenManager.getInstance().screenWidth, "Up/Down and then A (or space) to select map.");
            t.size = 16;
            t.alignment = "left";
            add(t);

            var t:FlxText;
            t = new FlxText(0, 200, ScreenManager.getInstance().screenWidth, "Map A");
            t.size = 16;
            t.alignment = "left";
            add(t);
            this._maps.push(t);

            t = new FlxText(0, 250, ScreenManager.getInstance().screenWidth, "Map B");
            t.alignment = "left";
            t.size = 16;
            add(t);
            this._maps.push(t);

            t = new FlxText(0, 300, ScreenManager.getInstance().screenWidth, "Map C");
            t.alignment = "left";
            t.size = 16;
            add(t);
            this._maps.push(t);

            this._picker = new FlxSprite(this._maps[0].x + 100, this._maps[0].y);
            this._picker.makeGraphic(20, 20, 0xffffffff);
            add(this._picker);

        }

        override public function controllerChanged(control:Object,
                                                   mapping:Object):void
        {
            super.controllerChanged(control, mapping);
            if (control['id'] == mapping["a"]["button"] && control['value'] == mapping["a"]["value_on"]) {
                FlxG.switchState(new PlayState(this._cur_map));
            }

            if(control['id'] == mapping["down"]["button"] && control['value'] == mapping["down"]["value_on"]) { //down
                this._cur_map += 1;
                if(this._cur_map > (this._maps.length - 1)) {
                    this._cur_map = 0;
                }
                this._picker.x = this._maps[this._cur_map].x + 100;
                this._picker.y = this._maps[this._cur_map].y;
            } else if (control['id'] == mapping["up"]["button"] && control['value'] == mapping["up"]["value_on"]) { //up
                this._cur_map -= 1;
                if(this._cur_map < 0) {
                    this._cur_map = this._maps.length - 1;
                }
                this._picker.x = this._maps[this._cur_map].x + 100;
                this._picker.y = this._maps[this._cur_map].y;
            }
        }

        override public function update():void {
            super.update();

            if(!this._picker_lock) {
                if(FlxG.keys.justPressed("DOWN")) {
                    this._picker_lock = true;
                    this._cur_map += 1;
                    if(this._cur_map >= this._maps.length) {
                        this._cur_map = 0;
                    }
                    this._picker.x = this._maps[this._cur_map].x + 100;
                    this._picker.y = this._maps[this._cur_map].y;
                }
                if(FlxG.keys.justPressed("UP")) {
                    this._picker_lock = true;
                    this._cur_map -= 1;
                    if(this._cur_map < 0) {
                        this._cur_map = this._maps.length - 1;
                    }
                    this._picker.x = this._maps[this._cur_map].x + 100;
                    this._picker.y = this._maps[this._cur_map].y;
                }
                if(FlxG.keys.justPressed("SPACE")) {
                    FlxG.switchState(new PlayState(this._cur_map));
                }
            } else {
                if(FlxG.keys.justReleased("DOWN") || FlxG.keys.justReleased("UP")) {
                    this._picker_lock = false;
                }
            }
        }
    }
}
