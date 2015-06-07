package {
    import org.flixel.*;

    import flash.ui.GameInputControl;

    public class EndState extends GameState {
        private var player_list:Array;
        private var list_offset:Number = 100, endTimeBorn:Number = 0, endTimeAlive:Number = 0;

        override public function create():void {
            super.create();
            var bg:GameObject = new GameObject(new DHPoint(0,0));
            bg.makeGraphic(1280,720,0xffffffff);
            FlxG.state.add(bg);

            this.endTimeBorn = new Date().valueOf();
            this.player_list = PlayersController.getInstance().getPlayerList();

            for(var i:Number = 0; i < player_list.length; i++) {
                var t:FlxText;
                t = new FlxText(100, this.list_offset, ScreenManager.getInstance().screenWidth, player_list[i].driver_name + " had " + this.player_list[i].laps.toString() + " booty calls!");
                t.size = 16;
                t.color = 0xff000000;
                t.alignment = "left";
                FlxG.state.add(t);
                this.list_offset += 50;
                trace(i);
            }
        }

        override public function update():void {
            super.update();

            this.endTimeAlive = Math.floor((this.curTime - this.endTimeBorn)/1000);

            if(this.endTimeAlive == 6) {
                FlxG.switchState(new MenuState());
            }
        }
    }
}