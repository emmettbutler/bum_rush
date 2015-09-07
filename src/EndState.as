package {
    import org.flixel.*;

    import flash.ui.GameInputControl;

    public class EndState extends GameState {
        private var player_list:Array;
        private var list_offset:Number = 100, endTimeBorn:Number = 0, endTimeAlive:Number = 0;
        private var resetText:FlxText;

        override public function create():void {
            super.create();
            var bg:GameObject = new GameObject(new DHPoint(0,0));
            bg.makeGraphic(1280,720,0xff000000);
            FlxG.state.add(bg);

            this.endTimeBorn = new Date().valueOf();
            this.player_list = PlayersController.getInstance().getPlayerList();

            for(var i:Number = 0; i < player_list.length; i++) {
                var t:FlxText;
                if(player_list[i].winner) {
                    t = new FlxText(100, this.list_offset, ScreenManager.getInstance().screenWidth, "Yoooo this is " + player_list[i].driver_name + ". Ya'll mind sleeping at a friends place tonight? I need the room. ;) ;) ;)");
                    t.size = 16;
                    t.color = 0xffd82e5a;
                    t.alignment = "left";
                    FlxG.state.add(t);
                    this.list_offset += 50;
                }
            }

            this.resetText = new FlxText(100, ScreenManager.getInstance().screenHeight - 100, ScreenManager.getInstance().screenWidth, "");
            this.resetText.color = 0xffd82e5a;
            this.resetText.size = 14;
            FlxG.state.add(this.resetText);
        }

        override public function update():void {
            super.update();

            this.endTimeAlive = Math.floor((this.curTime - this.endTimeBorn)/1000);

            this.resetText.text = (6 - this.endTimeAlive) + " seconds until reset.";
            if(this.endTimeAlive == 6) {
                FlxG.switchState(new MenuState());
            }
        }
    }
}