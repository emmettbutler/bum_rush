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

        private var player_icon:FlxText;
        private var player_tag:Number;

        public static const HUD_ARROW:String = "my arrow";
        public static const HUD_NUMBER:String = "my number";
        private var hud_objects:Dictionary;
        private var hud_finished_objects:Dictionary;
        private var base_pos_list:Array;
        private var hud_numbers:Array;

        public function PlayerHud(p_tag:Number) {
            super(new DHPoint(0,0));
            this.player_tag = p_tag;
            this.hud_objects = new Dictionary();
            this.hud_finished_objects = new Dictionary();
        }

        public function buildHud():void {
            var curImg:Object, hud_piece:GameObject, checkmark:GameObject,
                hud_num:FlxText, namePos:DHPoint;
            var _classData:Dictionary = PlayerHud.buildHudData();
            var playerConfig:Object = PlayersController.getInstance().playerConfigs[this.player_tag];
            for(var _key:Object in _classData['image_map']) {
                curImg = _classData['image_map'][_key];

                if (_key == PlayerHud.HUD_NUMBER) {
                    namePos = playerConfig['hud_pos'].add(curImg['pos']);
                    hud_num = new FlxText(
                        namePos.x, namePos.y, 100, playerConfig['name']);
                    hud_num.size = 12;
                    hud_num.color = playerConfig['font_color'];
                    FlxG.state.add(hud_num);
                } else {
                    hud_piece = new GameObject(playerConfig['hud_pos'].add(curImg['pos']));
                    hud_piece.loadGraphic(curImg["sprite"], false, false, 32, 32);
                    this.hud_objects[_key] = hud_piece;
                    FlxG.state.add(hud_piece);

                    checkmark = new GameObject(playerConfig['hud_pos'].add(curImg['pos']));
                    checkmark.loadGraphic(HUDCheckmark, false, false, 32, 32);
                    checkmark.visible = false;
                    this.hud_finished_objects[_key] = checkmark;
                    FlxG.state.add(checkmark);
                }
            }
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
                "pos": new DHPoint(screenWidth * .19, screenHeight - 45)
            };
            struc['image_map'][Checkpoint.MOVIES] = {
                "sprite": PlayerHud.HUDMovie,
                "pos": new DHPoint(screenWidth * .215, screenHeight - 45)
            };
            struc['image_map'][Checkpoint.PARK] = {
                "sprite": PlayerHud.HUDTree,
                "pos": new DHPoint(screenWidth * .24, screenHeight - 45)
            };
            struc['image_map'][Checkpoint.CLUB] = {
                "sprite": PlayerHud.HUDClub,
                "pos": new DHPoint(screenWidth * .2, screenHeight - 80)
            };
            struc['image_map'][Checkpoint.DINNER] = {
                "sprite": PlayerHud.HUDWeiner,
                "pos": new DHPoint(screenWidth * .23, screenHeight - 80)
            };
            struc['image_map'][PlayerHud.HUD_NUMBER] = {
                "pos": new DHPoint(screenWidth * .215, screenHeight - 100)
            };
            return struc;
        }

        override public function update():void {
            super.update();
        }
    }
}
