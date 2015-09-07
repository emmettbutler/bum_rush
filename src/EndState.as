package {
    import org.flixel.*;

    import flash.ui.GameInputControl;

    public class EndState extends GameState {
        private var player_list:Array;
        private var endTimeBorn:Number = 0, endTimeAlive:Number = 0;
        private var resetText:FlxText;
        private var config:Object, passenger_config:Object;
        private var winner:Player = null, car_image:GameObject,
                    driver_image:GameObject, cur_player:Player,
                    passenger_image:GameObject, passenger:Passenger;

        override public function create():void {
            super.create();
            var bg:GameObject = new GameObject(new DHPoint(0,0));
            bg.makeGraphic(1280,720,0xff000000);
            FlxG.state.add(bg);

            this.endTimeBorn = new Date().valueOf();
            this.player_list = PlayersController.getInstance().getPlayerList();

            for(var i:Number = 0; i < player_list.length; i++) {
                var t:FlxText;
                config = player_list[i].playerConfig;
                cur_player = player_list[i];
                if(player_list[i].winner && winner == null) {
                    winner = player_list[i];

                    car_image = new GameObject(new DHPoint(
                        ScreenManager.getInstance().screenWidth / 2,
                        ScreenManager.getInstance().screenHeight / 2
                    ));
                    car_image.loadGraphic(config['car'], false, false, 64, 64);
                    car_image.addAnimation("drive_down", [8,9,10,11], 12, true);
                    FlxG.state.add(car_image);
                    car_image.play("drive_down");

                    driver_image = new GameObject(car_image.getPos());
                    driver_image.loadGraphic(config['sprite'], false, false, 64, 64);
                    driver_image.addAnimation("drive_down", [8,9,10,11], 12, true);
                    FlxG.state.add(driver_image);
                    driver_image.play("drive_down");

                    for (var k:int = 0; k < cur_player.getPassengers().length; k++) {
                        passenger = cur_player.getPassengers()[k];
                        passenger_config = passenger.passengerConfig;
                        passenger_image = new GameObject(car_image.getPos().sub(
                            new DHPoint(0, Passenger.STACK_INTERVAL * passenger.idx)));
                        passenger_image.loadGraphic(passenger_config['riding_sprite'],
                                                    true, false, 64, 64);
                        passenger_image.addAnimation("ride_down", [8,9,10,11], 12, true);
                        FlxG.state.add(passenger_image);
                        passenger_image.play("ride_down");
                    }
                }
            }

            t = new FlxText(100, 100,
                ScreenManager.getInstance().screenWidth,
                "Yoooo this is " +
                winner.driver_name +
                ". Ya'll mind sleeping at a friends place tonight? I need the room. ;) ;) ;)");
            t.size = 16;
            t.color = 0xffd82e5a;
            t.alignment = "left";
            FlxG.state.add(t);

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
