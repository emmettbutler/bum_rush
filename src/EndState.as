package {
    import org.flixel.*;

    import flash.ui.GameInputControl;

    public class EndState extends GameState {
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;
        [Embed(source = "../assets/audio/bumrush_select_loop.mp3")] private var SndBGMLoop:Class;

        private var player_list:Array;
        private var endTimeBorn:Number = 0, endTimeAlive:Number = 0;
        private var config:Object, passenger_config:Object;
        private var bg:FlxExtSprite, roomTextSprite:FlxExtSprite;
        private var startedRoomText:Boolean = false, showedPassengers:Boolean = false,
                    commentText:FlxText;
        private var winner:Player = null,
                    driver_image:FlxExtSprite, cur_player:Player,
                    passenger_image:FlxExtSprite, passenger:Passenger;
        private var passengers:Array;

        override public function create():void {
            super.create();

            var pathPrefix:String = "../assets/images/ui/";
            this.bg = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + "outtro_bg_9.png", false, true, 169, 95);
            this.bg.addAnimation("run", [0, 1, 2, 3, 4, 5, 6, 7, 8], 13, false);
            this.add(this.bg);

            this.roomTextSprite = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + "outtro_text_roomsUrs.png", false, true, 169, 95);
            this.roomTextSprite.addAnimation("run", [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3], 13, false);
            this.add(this.roomTextSprite);
            this.roomTextSprite.visible = false;

            this.passengers = new Array();

            this.player_list = PlayersController.getInstance().getPlayerList();

            var late_added_passengers:Array = new Array();

            for(var i:Number = 0; i < player_list.length; i++) {
                var t:FlxText;
                config = player_list[i].playerConfig;
                cur_player = player_list[i];
                if(player_list[i].winner && winner == null) {
                    winner = player_list[i];

                    // replace with config['join_prefix']
                    driver_image = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + "outtro_driver_" + "billy" + ".png", false, true, 169, 95);
                    driver_image.addAnimation("run", [0, 1], 7, true);
                    this.add(this.driver_image);
                    driver_image.play("run");

                    var passengers_string:String = winner.driver_name + " brought home ";

                    for (var k:int = 0; k < cur_player.getPassengers().length; k++) {
                        passenger = cur_player.getPassengers()[k];
                        passenger_config = passenger.passengerConfig;

                        passenger_image = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + passenger_config['outtro_sprite'], false, true, 169, 95);
                        passenger_image.addAnimation("run", [0, 1], 7, true);
                        if (passenger_config['outtro_addlate']) {
                            late_added_passengers.push(passenger_image);
                        } else {
                            this.add(passenger_image);
                        }
                        passenger_image.visible = false;
                        this.passengers.push(passenger_image);
                        passenger_image.play("run");

                        passengers_string += passenger_config["name"];
                        if (k == cur_player.getPassengers().length - 2) {
                            passengers_string += " and ";
                        } else if (k < cur_player.getPassengers().length - 1) {
                            passengers_string += ", ";
                        }
                    }
                }
            }

            for (var h:int = 0; h < late_added_passengers.length; h++) {
                this.add(late_added_passengers[h]);
            }

            var commentString:String = "";
            if(winner.getPassengers().length == 1) {
                commentString = passengers_string + ". An intimate evening awaits...";
            } else if(winner.getPassengers().length == 2){
                commentString = passengers_string + ". Not bad, not bad...";
            } else if(winner.getPassengers().length == 3){
                commentString = passengers_string + ". Not too shabby! You must look really cute tonight!";
            } else if(winner.getPassengers().length == 4){
                commentString = passengers_string + ". Impressive! Your sweet smile really did the trick.";
            } else if(winner.getPassengers().length == 5){
                commentString = passengers_string + ". You're a natural born charmer'!";
            } else if(winner.getPassengers().length == 6){
                commentString = passengers_string + ". Do you even have room for that many people in your bed...?!";
            } else if(winner.getPassengers().length == 7){
                commentString = passengers_string + ". WOW! Are you a sex magnet or something?!";
            } else if(winner.getPassengers().length == 8){
                commentString = passengers_string + ". Looks like you'll need to borrow the dorm next door, too!";
            }

            this.commentText = new FlxText(ScreenManager.getInstance().screenWidth * .5, 80,
                ScreenManager.getInstance().screenWidth * .4, commentString);
            this.commentText.setFormat("Pixel_Berry_08_84_Ltd.Edition",24,0xff000000);
            this.commentText.alignment = "center";
            this.commentText.visible = false;
            FlxG.state.add(this.commentText);

            if (FlxG.music != null) {
                FlxG.music.stop();
            }
            FlxG.playMusic(SndBGMLoop, 1);
        }

        override public function update():void {
            super.update();

            if(this.timeAlive / 1000 >= 12) {
                FlxG.switchState(new MenuState());
            } else if (this.timeAlive / 1000 >= 4) {
                if (!this.showedPassengers) {
                    this.showedPassengers = true;
                    this.commentText.visible = true;
                    this.roomTextSprite.visible = false;
                    for (var i:int = 0; i < this.passengers.length; i++) {
                        this.passengers[i].visible = true;
                    }
                }
            } else if (this.timeAlive / 1000 >= 2) {
                if (!this.startedRoomText) {
                    this.startedRoomText = true;
                    this.roomTextSprite.visible = true;
                    this.roomTextSprite.play("run");
                    this.bg.play("run");
                }
            }
        }

        override public function destroy():void {
            for (var i:int = 0; i < this.passengers.length; i++) {
                this.passengers[i].destroy();
            }
            this.passengers = null;
            this.bg.destroy();
            this.roomTextSprite.destroy();
            this.driver_image.destroy();
            super.destroy();
        }
    }
}
