package {
    import org.flixel.*;

    public class PlayState extends GameState {
        [Embed(source="/../assets/instruction_anim.png")] private var InstructionSprite:Class;
        private var checkpoints:FlxGroup;
        private var instructions:GameObject;
        private var timer_text:FlxText;
        private var started_race:Boolean = false;
        private var race_time_left:Number, raceTimeAlive:Number;
        private static const RACE_LENGTH:Number = 60;

        override public function create():void {
            super.create();
            ScreenManager.getInstance().loadSingleTileBG("/../assets/map_1.png");

            this.checkpoints = new FlxGroup();
            var checkpoint:Checkpoint;
            checkpoint = new Checkpoint(
                new DHPoint(0, 0),
                new DHPoint(10, 120)
            );
            this.checkpoints.add(checkpoint);
            checkpoint = new Checkpoint(
                new DHPoint(0, 0),
                new DHPoint(10, 120)
            );
            this.checkpoints.add(checkpoint);
            checkpoint = new Checkpoint(
                new DHPoint(0, 0),
                new DHPoint(120, 10)
            );
            this.checkpoints.add(checkpoint);
            checkpoint = new Checkpoint(
                new DHPoint(0, 0),
                new DHPoint(120, 10),
                Checkpoint.APARTMENT,
                new DHPoint(134, 327)
            );
            this.checkpoints.add(checkpoint);

            var that:PlayState = this;
            FlxG.stage.addEventListener(GameState.EVENT_SINGLETILE_BG_LOADED,
                function(event:DHDataEvent):void {
                    var cur:Checkpoint;

                    cur = that.checkpoints.members[0];
                    cur.setPos(new DHPoint(
                        event.userData['bg'].width * .27,
                        event.userData['bg'].height * .88
                    ));
                    cur.index = 3;

                    cur = that.checkpoints.members[1];
                    cur.setPos(new DHPoint(
                        event.userData['bg'].width * .61,
                        event.userData['bg'].height * .54
                    ));
                    cur.index = 1;

                    cur = that.checkpoints.members[2];
                    cur.setPos(new DHPoint(
                        event.userData['bg'].width * .91,
                        event.userData['bg'].height * .54
                    ));
                    cur.index = 0;

                    cur = that.checkpoints.members[3];
                    cur.setPos(new DHPoint(
                        event.userData['bg'].width * .01,
                        event.userData['bg'].height * .54
                    ));
                    cur.index = 2;

                    FlxG.stage.removeEventListener(
                        GameState.EVENT_SINGLETILE_BG_LOADED,
                        arguments.callee
                    );
                });

            for (var i:int = 0; i < this.checkpoints.length; i++) {
                this.checkpoints.members[i].addVisibleObjects();
            }

            PlayersController.getInstance().addRegisteredPlayers();

            this.timer_text = new FlxText(10,10,1000,"");
            this.timer_text.size = 20;
            FlxG.state.add(this.timer_text);

            this.instructions = new GameObject(new DHPoint(0,0));
            this.instructions.loadGraphic(this.InstructionSprite,true,false,1280,720);
            this.instructions.addAnimation("play",[0,1,2],.5,false);
            FlxG.state.add(this.instructions);
            this.instructions.play("play");
        }

        override public function update():void {
            super.update();

            if(this.instructions.finished) {
                if(!this.started_race) {
                    this.instructions.visible = false;
                    this.started_race = true;
                    this.startRaceTimer();
                }
            }

            if(this.started_race) {
                this.raceTimeAlive = this.curTime - this.raceBornTime;
                this.race_time_left = Math.floor(PlayState.RACE_LENGTH - this.raceTimeAlive/1000);
                this.timer_text.text = this.race_time_left + " seconds left!";
            }

            FlxG.overlap(
                PlayersController.getInstance().getPlayerColliders(),
                PlayersController.getInstance().getPlayerColliders(),
                this.overlapPlayers
            );

            FlxG.overlap(
                PlayersController.getInstance().getPlayerColliders(),
                this.checkpoints,
                this.overlapPlayerCheckpoints
            );
        }

        override public function destroy():void {
            PlayersController.reset();
            super.destroy();
        }

        public function overlapPlayerCheckpoints(player1Collider:GameObject,
                                                 checkpoint:Checkpoint):void
        {
            trace("player touching checkpoint: " + new Date().valueOf())
            var player:Player = player1Collider.parent as Player;
            player.crossCheckpoint(checkpoint, this.checkpoints.length - 1);
        }

        public function overlapPlayers(player1Collider:GameObject,
                                       player2Collider:GameObject):void
        {
            if (player1Collider == null || player2Collider == null) {
                return;
            }
            (player1Collider.parent as Player).collisionCallback(player2Collider.parent as Player);
            (player2Collider.parent as Player).collisionCallback(player1Collider.parent as Player);
        }
    }
}
