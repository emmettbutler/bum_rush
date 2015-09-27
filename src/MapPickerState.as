package {
    import org.flixel.*;

    import flash.ui.GameInputControl;
    import flash.ui.GameInputDevice;

    public class MapPickerState extends GameState {
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;
        [Embed(source="/../assets/images/worlds/maps/map_3_thumb.png")] private var ImgMapThumb3:Class;
        [Embed(source="/../assets/images/worlds/maps/map_4_thumb.png")] private var ImgMapThumb4:Class;
        [Embed(source="/../assets/images/worlds/maps/map_5_thumb.png")] private var ImgMapThumb5:Class;
        [Embed(source="/../assets/images/worlds/maps/map_6_thumb.png")] private var ImgMapThumb6:Class;
        [Embed(source="/../assets/images/worlds/maps/map_7_thumb.png")] private var ImgMapThumb7:Class;
        [Embed(source="/../assets/images/worlds/maps/map_8_thumb.png")] private var ImgMapThumb8:Class;

        private var _maps:Array;
        private var _picker:FlxSprite;
        private var _cur_map:Number;
        private var _picker_lock:Boolean = false;
        private var _players:Array;
        private var _basic_label:FlxText;
        private var _advanced_label:FlxText;
        private var highlight_dim:DHPoint;
        private var row_count:Number;
        private var i:Number;

        override public function create():void {
            super.create();
            this._players = PlayersController.getInstance().getPlayerList();

            var thumb_dim:DHPoint = new DHPoint(300, 169);
            this.highlight_dim = new DHPoint(9, 9);
            this.row_count = 3;

            ScreenManager.getInstance();
            this._maps = new Array();
            this._cur_map = 0;

            var t:FlxText;
            t = new FlxText(0, 50, ScreenManager.getInstance().screenWidth,
                            "Where do you want to go?");
            t.setFormat("Pixel_Berry_08_84_Ltd.Edition",20,0xffd82e5a);
            t.alignment = "center";
            add(t);

            this._picker = new FlxSprite(0, 0);
            this._picker.makeGraphic(thumb_dim.x + this.highlight_dim.x * 2,
                                     thumb_dim.y + this.highlight_dim.y * 2,
                                     0xffffffff);
            add(this._picker);

            var rowY:Number = ScreenManager.getInstance().screenHeight * .3;
            var colSpacing:Number = 100;

            _basic_label = new FlxText(
                0, rowY - 50,
                ScreenManager.getInstance().screenWidth, "Basic Maps");
            _basic_label.setFormat("Pixel_Berry_08_84_Ltd.Edition",16,0xffd82e5a);
            _basic_label.alignment = "center";
            add(_basic_label);

            var thumb_:FlxSprite = new FlxSprite(
                ScreenManager.getInstance().screenWidth * .5 - thumb_dim.x / 2 - colSpacing - thumb_dim.x,
                rowY
            );
            thumb_.loadGraphic(ImgMapThumb6, false, false, thumb_dim.x, thumb_dim.y);
            add(thumb_);
            this._maps.push(thumb_);

            thumb_ = new FlxSprite(
                ScreenManager.getInstance().screenWidth * .5 - thumb_dim.x / 2,
                rowY
            );
            thumb_.loadGraphic(ImgMapThumb7, false, false, thumb_dim.x, thumb_dim.y);
            add(thumb_);
            this._maps.push(thumb_);

            thumb_ = new FlxSprite(
                ScreenManager.getInstance().screenWidth * .5 + thumb_dim.x / 2 + colSpacing,
                rowY
            );
            thumb_.loadGraphic(ImgMapThumb8, false, false, thumb_dim.x, thumb_dim.y);
            add(thumb_);
            this._maps.push(thumb_);

            rowY += ScreenManager.getInstance().screenHeight * .4;

            _advanced_label = new FlxText(
                0, rowY - 50,
                ScreenManager.getInstance().screenWidth, "Advanced Maps");
            _advanced_label.setFormat("Pixel_Berry_08_84_Ltd.Edition",16,0xffd82e5a);
            _advanced_label.alignment = "center";
            add(_advanced_label);

            thumb_ = new FlxSprite(
                ScreenManager.getInstance().screenWidth * .5 - thumb_dim.x / 2 - colSpacing - thumb_dim.x,
                rowY
            );
            thumb_.loadGraphic(ImgMapThumb3, false, false, thumb_dim.x, thumb_dim.y);
            add(thumb_);
            this._maps.push(thumb_);

            thumb_ = new FlxSprite(
                ScreenManager.getInstance().screenWidth * .5 - thumb_dim.x / 2,
                rowY
            );
            thumb_.loadGraphic(ImgMapThumb4, false, false, thumb_dim.x, thumb_dim.y);
            add(thumb_);
            this._maps.push(thumb_);

            thumb_ = new FlxSprite(
                ScreenManager.getInstance().screenWidth * .5 + thumb_dim.x / 2 + colSpacing,
                rowY
            );
            thumb_.loadGraphic(ImgMapThumb5, false, false, thumb_dim.x, thumb_dim.y);
            add(thumb_);
            this._maps.push(thumb_);
        }

        override public function controllerChanged(control:Object,
                                                   mapping:Object):void
        {
            super.controllerChanged(control, mapping);
            if (control['id'] == mapping["a"]["button"] && control['value'] == mapping["a"]["value_on"]) {
                this.startRace();
            }

            if(control['id'] == mapping["up"]["button"] && control['value'] == mapping["up"]["value_on"]) {
                this._cur_map -= this.row_count;
            } else if (control['id'] == mapping["down"]["button"] && control['value'] == mapping["down"]["value_on"]) {
                this._cur_map += this.row_count;
            } else if (control['id'] == mapping["right"]["button"] && control['value'] == mapping["right"]["value_on"]) {
                this._cur_map += 1;
            } else if (control['id'] == mapping["left"]["button"] && control['value'] == mapping["left"]["value_on"]) {
                this._cur_map -= 1;
            }
        }

        public function startRace():void {
            FlxG.switchState(new PlayState(this._cur_map));
        }

        override public function update():void {
            super.update();

            if(!this._picker_lock) {
                if(FlxG.keys.justPressed("DOWN")) {
                    this._picker_lock = true;
                    this._cur_map += row_count;
                }
                if(FlxG.keys.justPressed("UP")) {
                    this._picker_lock = true;
                    this._cur_map -= row_count;
                }
                if(FlxG.keys.justPressed("LEFT")) {
                    this._picker_lock = true;
                    this._cur_map -= 1;
                }
                if(FlxG.keys.justPressed("RIGHT")) {
                    this._picker_lock = true;
                    this._cur_map += 1;
                }
                if(FlxG.keys.justPressed("SPACE")) {
                    this.startRace();
                }
            } else {
                if(FlxG.keys.justReleased("DOWN") ||
                   FlxG.keys.justReleased("UP") ||
                   FlxG.keys.justReleased("RIGHT") ||
                   FlxG.keys.justReleased("LEFT")
                ) {
                    this._picker_lock = false;
                }
            }

            if(this._cur_map >= this._maps.length) {
                this._cur_map = this._cur_map % 3;
            } else if(this._cur_map < 0) {
                this._cur_map = this._maps.length + this._cur_map;
            }

            this._picker.x = this._maps[this._cur_map].x - this.highlight_dim.x;
            this._picker.y = this._maps[this._cur_map].y - this.highlight_dim.y;
        }
    }
}
