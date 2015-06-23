package {
    import org.flixel.*;

    public class PlayerHud extends GameObject {
        [Embed(source="/../assets/HUD_arrow.png")] private var HUDArrow:Class;
        [Embed(source="/../assets/HUD_beer.png")] private var HUDBeer:Class;
        [Embed(source="/../assets/HUD_movie.png")] private var HUDMovie:Class;
        [Embed(source="/../assets/HUD_tree.png")] private var HUDTree:Class;
        [Embed(source="/../assets/HUD_water.png")] private var HUDWater:Class;
        [Embed(source="/../assets/HUD_weiner.png")] private var HUDWeiner:Class;

        private var player_icon:FlxText;
        private var player_tag:Number;

        public static const HUD_BEER:String = "my beer";
        public static const HUD_MOVIE:String = "my movie";
        public static const HUD_TREE:String = "my tree";
        public static const HUD_WATER:String = "my water";
        public static const HUD_WEINER:String = "my weiner";

        public static const HUD_NAMES:Array = [PlayerHud.HUD_BEER, PlayerHud.HUD_MOVIE, PlayerHud.HUD_TREE, PlayerHud.HUD_WATER, PlayerHud.HUD_WEINER];

        public static const HUD_IMAGES:Object = {
            PlayerHud.HUD_BEER: HUDBeer,
            PlayerHud.HUD_MOVIE: HUDMovie,
            PlayerHud.HUD_TREE: HUDTree,
            PlayerHud.HUD_WATER: HUDWater,
            PlayerHud.HUD_WEINER: HUDWeiner
        };

        public static const HUD_OBJECT_POSITIONS:Object = {
                                        1: {
                                            PlayerHud.HUD_BEER: new DHPoint(10,10),
                                            PlayerHud.HUD_MOVIE: new DHPoint(40,10),
                                            PlayerHud.HUD_TREE: new DHPoint(70,10),
                                            PlayerHud.HUD_WATER: new DHPoint(10,40),
                                            PlayerHud.HUD_WEINER: new DHPoint(10,70)
                                        },
                                        2: {
                                            PlayerHud.HUD_BEER: new DHPoint(10,10),
                                            PlayerHud.HUD_MOVIE: new DHPoint(40,10),
                                            PlayerHud.HUD_TREE: new DHPoint(70,10),
                                            PlayerHud.HUD_WATER: new DHPoint(10,40),
                                            PlayerHud.HUD_WEINER: new DHPoint(10,70)
                                        }
                                    };

        private var player_hud_pos_list:Object;
        private var hud_objects:Object;
        private var base_pos_list:Array;

        public function PlayerHud(p_tag:Number):void {
            super(new DHPoint(0,0));
            this.player_tag = p_tag;
            this.player_hud_pos_list = PlayerHud.HUD_OBJECT_POSITIONS[this.player_tag];

            /*for(var i:Number = 0; i < PlayerHud.HUD_NAMES.length; i++) {
                var cur_obj:String = PlayerHud.HUD_NAMES[i];
                var hud_piece = new GameObject(this.player_hud_pos_list[cur_obj]);
                hud_piece.loadGraphic(PlayerHud.HUD_IMAGES[cur_obj],false,false,32,32);
                FlxG.state.add(hud_piece);
                this.hud_objects[cur_obj] = hud_piece;
            }*/
        }

        override public function update():void {
            super.update();
        }

    }
}