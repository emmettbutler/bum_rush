package {
    import org.flixel.*;

    import flash.ui.GameInputControl;

    public class EndState extends GameState {
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;
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
                ScreenManager.getInstance().screenWidth, "");
            if(cur_player.getPassengers().length == 1) {
                t.text = winner.driver_name +
                " brought home " + cur_player.getPassengers().length + " date! An intimate evening awaits...";
            } else if(cur_player.getPassengers().length == 2){
                t.text = winner.driver_name +
                " brought home " + cur_player.getPassengers().length + " dates! Not bad, not bad...";
            } else if(cur_player.getPassengers().length == 3){
                t.text = winner.driver_name +
                " brought home " + cur_player.getPassengers().length + " dates! Not too shabby! You must look really cute tonight!";
            } else if(cur_player.getPassengers().length == 4){
                t.text = winner.driver_name +
                " brought home " + cur_player.getPassengers().length + " dates! Impressive! Your sweet smile really did the trick.";
            } else if(cur_player.getPassengers().length == 5){
                t.text = winner.driver_name +
                " brought home " + cur_player.getPassengers().length + " dates! You're a natural born charmer'!";
            } else if(cur_player.getPassengers().length == 6){
                t.text = winner.driver_name +
                " brought home " + cur_player.getPassengers().length + " dates! Do you even have room for that many people in your bed...?!";
            } else if(cur_player.getPassengers().length == 7){
                t.text = winner.driver_name +
                " brought home " + cur_player.getPassengers().length + " dates! WOW! Are you a sex magnet or something?!";
            } else if(cur_player.getPassengers().length == 8){
                t.text = winner.driver_name +
                " brought home " + cur_player.getPassengers().length + " dates! Looks like you'll need to borrow the dorm nextdoor, too!";
            }

            t.setFormat("Pixel_Berry_08_84_Ltd.Edition",24,0xffd82e5a);
            t.alignment = "left";
            FlxG.state.add(t);

            this.resetText = new FlxText(100, ScreenManager.getInstance().screenHeight - 100, ScreenManager.getInstance().screenWidth, "");
            this.resetText.setFormat("Pixel_Berry_08_84_Ltd.Edition",14,0xffd82e5a);
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
