package {
    import org.flixel.*;

    public class PlayerHud {
        [Embed(source="/../assets/HUD_arrow.png")] private var HUDArrow:Class;
        [Embed(source="/../assets/HUD_beer.png")] private var HUDBeer:Class;
        [Embed(source="/../assets/HUD_movie.png")] private var HUDMovie:Class;
        [Embed(source="/../assets/HUD_tree.png")] private var HUDTree:Class;
        [Embed(source="/../assets/HUD_water.png")] private var HUDWater:Class;
        [Embed(source="/../assets/HUD_wiener.png")] private var HUDWiener:Class;

        private var player_icon:FlxText;
        private var Hud_Objects:Array;
        private var player_tag:Number;

        public function PlayerHud(p_tag:Number):void {
            this.player_tag = p_tag;
            var pos_array:Array = new Array();
            switch(this.player_tag) {
                case 1:
                    pos_array.push(new DHPoint(10,10));
                break;
            }

        }

        public function update():void {
            super.update();
        }

    }
}