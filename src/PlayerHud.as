package {
    import org.flixel.*;

    import flash.utils.Dictionary;

    public class PlayerHud extends GameObject {
        [Embed(source="/../assets/HUD_arrow.png")] private static var HUDArrow:Class;
        [Embed(source="/../assets/HUD_beer.png")] private static var HUDBeer:Class;
        [Embed(source="/../assets/HUD_movie.png")] private static var HUDMovie:Class;
        [Embed(source="/../assets/HUD_tree.png")] private static var HUDTree:Class;
        [Embed(source="/../assets/HUD_water.png")] private static var HUDWater:Class;
        [Embed(source="/../assets/HUD_weiner.png")] private static var HUDWeiner:Class;

        private var player_icon:FlxText;
        private var player_tag:Number;
        private static var _classData:Dictionary;

        public static const HUD_BOOZE:String = "my beer";
        public static const HUD_MOVIES:String = "my movie";
        public static const HUD_PARK:String = "my tree";
        public static const HUD_BEACH:String = "my water";
        public static const HUD_DINNER:String = "my weiner";
        public static const HUD_ARROW:String = "my arrow";
        private var hud_objects:Dictionary;
        private var hud_finished_objects:Dictionary;
        private var base_pos_list:Array;

        public function PlayerHud(p_tag:Number) {
            super(new DHPoint(0,0));
            this.player_tag = p_tag;
            this.hud_objects = new Dictionary();
            this.hud_finished_objects = new Dictionary();
        }

        public function buildHud():void {
            var curImg:Class;
            var _classData:Dictionary = PlayerHud.buildHudData();
            for(var key:Object in _classData['image_map']) {
                curImg = _classData['image_map'][key];
                var hud_piece:GameObject = new GameObject(_classData['instances'][this.player_tag][key]['pos']);
                var arrow_hud_piece:GameObject = new GameObject(_classData['instances'][this.player_tag][key]['pos']);
                hud_piece.loadGraphic(_classData['image_map'][key],false,false,32,32);
                arrow_hud_piece.loadGraphic(HUDArrow,false,false,32,32);
                FlxG.state.add(hud_piece);
                FlxG.state.add(arrow_hud_piece);
                arrow_hud_piece.visible = false;
                this.hud_objects[key] = hud_piece;
                this.hud_finished_objects[key] = arrow_hud_piece;
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
                this.hud_finished_objects[PlayerHud.HUD_BEACH].visible = true;
            } else if (cp == Checkpoint.DINNER) {
                this.hud_finished_objects[PlayerHud.HUD_DINNER].visible = true;
            }
        }

        public static function buildHudData():Dictionary {
            var struc:Dictionary = new Dictionary();

            struc['image_map'] = new Dictionary();
            struc['image_map'][PlayerHud.HUD_BOOZE] = PlayerHud.HUDBeer;
            struc['image_map'][PlayerHud.HUD_MOVIES] = PlayerHud.HUDMovie;
            struc['image_map'][PlayerHud.HUD_PARK] = PlayerHud.HUDTree;
            struc['image_map'][PlayerHud.HUD_BEACH] = PlayerHud.HUDWater;
            struc['image_map'][PlayerHud.HUD_DINNER] = PlayerHud.HUDWeiner;

            struc['instances'] = {};
            struc['instances'][0] = new Dictionary();
            struc['instances'][0][PlayerHud.HUD_BOOZE] = {
                'pos': new DHPoint(10,10)
            };
            struc['instances'][0][PlayerHud.HUD_MOVIES] = {
                'pos': new DHPoint(40,10)
            };
            struc['instances'][0][PlayerHud.HUD_PARK] = {
                'pos': new DHPoint(70,10)
            };
            struc['instances'][0][PlayerHud.HUD_BEACH] = {
                'pos': new DHPoint(20,40)
            };
            struc['instances'][0][PlayerHud.HUD_DINNER] = {
                'pos': new DHPoint(60,40)
            };

            struc['instances'][1] = new Dictionary();
            struc['instances'][1][PlayerHud.HUD_BOOZE] = {
                'pos': new DHPoint(110,10)
            };
            struc['instances'][1][PlayerHud.HUD_MOVIES] = {
                'pos': new DHPoint(140,10)
            };
            struc['instances'][1][PlayerHud.HUD_PARK] = {
                'pos': new DHPoint(170,10)
            };
            struc['instances'][1][PlayerHud.HUD_BEACH] = {
                'pos': new DHPoint(120,40)
            };
            struc['instances'][1][PlayerHud.HUD_DINNER] = {
                'pos': new DHPoint(160,40)
            };
            PlayerHud._classData = struc;
            return struc;
        }

        override public function update():void {
            super.update();
        }

    }
}