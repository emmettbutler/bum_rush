package {
    import org.flixel.*;

    import flash.utils.Dictionary;

    public class PlayerHud extends GameObject {
        [Embed(source="/../assets/HUD_arrow.png")] private static var HUDCheckmark:Class;
        [Embed(source="/../assets/HUD_beer.png")] private static var HUDBeer:Class;
        [Embed(source="/../assets/HUD_movie.png")] private static var HUDMovie:Class;
        [Embed(source="/../assets/HUD_tree.png")] private static var HUDTree:Class;
        [Embed(source="/../assets/HUD_water.png")] private static var HUDWater:Class;
        [Embed(source="/../assets/HUD_weiner.png")] private static var HUDWeiner:Class;
        [Embed(source="/../assets/HUD_nightClub.png")] private static var HUDClub:Class;

        private var player_icon:FlxText;
        private var player_tag:Number;

        public static const HUD_BOOZE:String = "my beer";
        public static const HUD_MOVIES:String = "my movie";
        public static const HUD_PARK:String = "my tree";
        public static const HUD_BEACH:String = "my water";
        public static const HUD_DINNER:String = "my weiner";
        public static const HUD_ARROW:String = "my arrow";
        public static const HUD_NUMBER:String = "my number";
        public static const HUD_CLUB:String = "my club";
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
                    hud_num.color = 0xff1f3446;
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

        public function finishedCheckpoint(cp:String):void {
            if(cp == Checkpoint.HOME) {
            } else if (cp == Checkpoint.BOOZE) {
                this.hud_finished_objects[PlayerHud.HUD_BOOZE].visible = true;
            } else if (cp == Checkpoint.APARTMENT) {
            } else if (cp == Checkpoint.PARK) {
                this.hud_finished_objects[PlayerHud.HUD_PARK].visible = true;
            } else if (cp == Checkpoint.MOVIES) {
                this.hud_finished_objects[PlayerHud.HUD_MOVIES].visible = true;
            } else if (cp == Checkpoint.BEACH) {
                if (this.hud_finished_objects[PlayerHud.HUD_BEACH] != null) {
                    this.hud_finished_objects[PlayerHud.HUD_BEACH].visible = true;
                }
            } else if (cp == Checkpoint.DINNER) {
                this.hud_finished_objects[PlayerHud.HUD_DINNER].visible = true;
            } else if (cp == Checkpoint.CLUB) {
                this.hud_finished_objects[PlayerHud.HUD_CLUB].visible = true;
            }
        }

        public static function buildHudData():Dictionary {
            var struc:Dictionary = new Dictionary();

            struc['image_map'] = new Dictionary();
            struc['image_map'][PlayerHud.HUD_BOOZE] = {
                "sprite": PlayerHud.HUDBeer,
                "pos": new DHPoint(0, 0)
            };
            struc['image_map'][PlayerHud.HUD_MOVIES] = {
                "sprite": PlayerHud.HUDMovie,
                "pos": new DHPoint(30, 0)
            };
            struc['image_map'][PlayerHud.HUD_PARK] = {
                "sprite": PlayerHud.HUDTree,
                "pos": new DHPoint(60, 0)
            };
            struc['image_map'][PlayerHud.HUD_CLUB] = {
                "sprite": PlayerHud.HUDClub,
                "pos": new DHPoint(10, 30)
            };
            struc['image_map'][PlayerHud.HUD_DINNER] = {
                "sprite": PlayerHud.HUDWeiner,
                "pos": new DHPoint(50, 30)
            };
            struc['image_map'][PlayerHud.HUD_NUMBER] = {
                "pos": new DHPoint(8, 59)
            };
            return struc;
        }

        override public function update():void {
            super.update();
        }
    }
}
