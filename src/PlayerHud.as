package {
    import org.flixel.*;

    import flash.utils.Dictionary;

    public class PlayerHud extends GameObject {
        [Embed(source="/../assets/images/ui/HUD_arrow.png")] private static var HUDCheckmark:Class;
        [Embed(source="/../assets/images/ui/HUD_beer.png")] private static var HUDBeer:Class;
        [Embed(source="/../assets/images/ui/HUD_movie.png")] private static var HUDMovie:Class;
        [Embed(source="/../assets/images/ui/HUD_tree.png")] private static var HUDTree:Class;
        [Embed(source="/../assets/images/ui/HUD_water.png")] private static var HUDWater:Class;
        [Embed(source="/../assets/images/ui/HUD_weiner.png")] private static var HUDWeiner:Class;
        [Embed(source="/../assets/images/ui/HUD_nightClub.png")] private static var HUDClub:Class;
        [Embed(source="/../assets/images/ui/text_back.png")] private static var ImgTextBack:Class;

        private var player_icon:FlxText;
        private var player_tag:Number;
        private static var _classData:Dictionary;

        public static const HUD_ARROW:String = "my arrow";
        public static const HUD_NAME:String = "my number";
        private var hud_objects:Dictionary;
        private var hud_finished_objects:Dictionary;
        private var base_pos:DHPoint;
        private var hud_numbers:Array;
        private var hud_name:FlxText;
        private var hud_name_back:GameObject;

        public function PlayerHud(p_tag:Number) {
            super(new DHPoint(0,0));
            this.player_tag = p_tag;
            this.hud_objects = new Dictionary();
            this.hud_finished_objects = new Dictionary();
            this.base_pos = new DHPoint(0, 0);
        }

        public function buildHud():void {
            var curImg:Object, hud_piece:GameObject, checkmark:GameObject;
            PlayerHud._classData = PlayerHud.buildHudData();
            var playerConfig:Object = PlayersController.getInstance().playerConfigs[this.player_tag];
            for(var _key:Object in PlayerHud._classData['image_map']) {
                curImg = PlayerHud._classData['image_map'][_key];

                if (_key == PlayerHud.HUD_NAME) {
                    hud_name_back = new GameObject(new DHPoint(0, 0));
                    hud_name_back.loadGraphic(ImgTextBack, false, false, 90, 20);
                    FlxG.state.add(hud_name_back);

                    hud_name = new FlxText(
                        0, 0, 90, playerConfig['name']);
                    hud_name.setFormat("Pixel_Berry_08_84_Ltd.Edition",12, 0xff000000, "center");
                    hud_name.color = playerConfig['tint'];
                    FlxG.state.add(hud_name);
                } else {
                    hud_piece = new GameObject(new DHPoint(0, 0));
                    hud_piece.loadGraphic(curImg["sprite"], false, false, 32, 32);
                    this.hud_objects[_key] = hud_piece;
                    FlxG.state.add(hud_piece);

                    checkmark = new GameObject(new DHPoint(0, 0));
                    checkmark.loadGraphic(HUDCheckmark, false, false, 32, 32);
                    checkmark.visible = false;
                    this.hud_finished_objects[_key] = checkmark;
                    FlxG.state.add(checkmark);
                }
            }
        }

        override public function setPos(pos:DHPoint):void {
            if (this.base_pos.x == pos.x && this.base_pos.y == pos.y) {
                return;
            }
            this.base_pos = pos;
            var curData:Object;
            for (var kTag:Object in this.hud_finished_objects) {
                curData = PlayerHud._classData['image_map'][kTag];
                this.hud_objects[kTag].setPos(this.base_pos.add(curData['pos']))
                this.hud_finished_objects[kTag].setPos(this.base_pos.add(curData['pos']))
            }
            curData = PlayerHud._classData['image_map'][PlayerHud.HUD_NAME];
            var textPos:DHPoint = this.base_pos.add(curData['pos']);
            this.hud_name.x = textPos.x;
            this.hud_name.y = textPos.y;
            this.hud_name_back.setPos(textPos.add(new DHPoint(0, 3)));
        }

        public function posOf(tag:String):DHPoint {
            return this.hud_objects[tag].getPos();
        }

        public function markCheckpoint(cp:String):void {
            if (this.hud_finished_objects[cp] != null) {
                this.hud_finished_objects[cp].visible = true;
            }
        }

        public static function buildHudData():Dictionary {
            var struc:Dictionary = new Dictionary();
            var screenWidth:Number = ScreenManager.getInstance().screenWidth;
            var screenHeight:Number = ScreenManager.getInstance().screenHeight;

            struc['image_map'] = new Dictionary();
            struc['image_map'][Checkpoint.BOOZE] = {
                "sprite": PlayerHud.HUDBeer,
                "pos": new DHPoint(0, 0)
            };
            struc['image_map'][Checkpoint.MOVIES] = {
                "sprite": PlayerHud.HUDMovie,
                "pos": new DHPoint(36, 0)
            };
            struc['image_map'][Checkpoint.PARK] = {
                "sprite": PlayerHud.HUDTree,
                "pos": new DHPoint(72, 0)
            };
            struc['image_map'][Checkpoint.CLUB] = {
                "sprite": PlayerHud.HUDClub,
                "pos": new DHPoint(15, 35)
            };
            struc['image_map'][Checkpoint.DINNER] = {
                "sprite": PlayerHud.HUDWeiner,
                "pos": new DHPoint(58, 35)
            };
            struc['image_map'][PlayerHud.HUD_NAME] = {
                "pos": new DHPoint(0, 65)
            };
            return struc;
        }

        override public function update():void {
            super.update();
        }
    }
}
