package {
    import org.flixel.*;
    import org.flixel.plugin.photonstorm.FlxCollision;

    public class PlayState extends GameState {
        [Embed(source="/../assets/instruction_anim.png")] private var InstructionSprite:Class;
        [Embed(source="/../assets/readysetgo.png")] private var StartSprite:Class;
        [Embed(source="/../assets/timeout.png")] private var TimeOutSprite:Class;

        private var checkpoints:FlxGroup;
        private var instructions:GameObject, start_sprite:GameObject, time_out_sprite:GameObject;
        private var timer_text:FlxText;
        private var started_race:Boolean = false, shown_start_anim:Boolean = false, finished:Boolean = false;
        private var race_time_left:Number, raceTimeAlive:Number, raceEndedAt:Number;
        private var collider:FlxExtSprite;
        private static const RACE_LENGTH:Number = 60;

        override public function create():void {
            super.create();
            this.collider = ScreenManager.getInstance().loadSingleTileBG("assets/map_1_collider.png");
            ScreenManager.getInstance().loadSingleTileBG("assets/map_1.png");
            this.gameActive = true;

            this.checkpoints = new FlxGroup();
            var checkpoint:Checkpoint;
            checkpoint = new Checkpoint(
                new DHPoint(0, 0),
                new DHPoint(10, 120),
                Checkpoint.HOME
            );
            this.checkpoints.add(checkpoint);
            checkpoint = new Checkpoint(
                new DHPoint(0, 0),
                new DHPoint(10, 120),
                Checkpoint.BOOZE
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
                Checkpoint.APARTMENT
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
                    cur.setImgPos(new DHPoint(
                        event.userData['bg'].width * .27,
                        event.userData['bg'].height * .62
                    ));
                    cur.index = 3;

                    cur = that.checkpoints.members[1];
                    cur.setPos(new DHPoint(
                        event.userData['bg'].width * .61,
                        event.userData['bg'].height * .54
                    ));
                    cur.setImgPos(new DHPoint(
                        event.userData['bg'].width * .67,
                        event.userData['bg'].height * .43
                    )); //errand
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
                    cur.setImgPos(new DHPoint(
                        event.userData['bg'].width * .11,
                        event.userData['bg'].height * .45
                    )); //booty call
                    cur.index = 2;

                    FlxG.stage.removeEventListener(
                        GameState.EVENT_SINGLETILE_BG_LOADED,
                        arguments.callee
                    );
                });

            for (var i:int = 0; i < this.checkpoints.length; i++) {
                this.checkpoints.members[i].addVisibleObjects();
            }

            PlayersController.getInstance().addRegisteredPlayers(this.checkpoints.length);

            this.timer_text = new FlxText(10,10,1000,"");
            this.timer_text.size = 20;
            FlxG.state.add(this.timer_text);

            this.start_sprite = new GameObject(new DHPoint(0,0));
            this.start_sprite.loadGraphic(this.StartSprite, true, false, 1280, 720);
            this.start_sprite.addAnimation("play", [0,1,2], .5, false);
            FlxG.state.add(this.start_sprite);

            this.time_out_sprite = new GameObject(new DHPoint(0,0));
            this.time_out_sprite.loadGraphic(this.TimeOutSprite, false, false, 1280, 720);
            FlxG.state.add(this.time_out_sprite);
            this.time_out_sprite.visible = false;

            /*this.instructions = new GameObject(new DHPoint(0,0));
            this.instructions.loadGraphic(this.InstructionSprite,true,false,1280,720);
            this.instructions.addAnimation("play",[0,1,2],.5,false);
            FlxG.state.add(this.instructions);
            this.instructions.play("play");*/
        }

        override public function update():void {
            super.update();

            //if(this.instructions.finished) {
                if(!this.started_race) {
                    if(!this.shown_start_anim) {
                        //this.instructions.visible = false;
                        this.start_sprite.play("play");
                        this.shown_start_anim = true;
                    }

                    if(this.start_sprite.finished) {
                        this.start_sprite.visible = false;
                        this.started_race = true;
                        this.startRaceTimer();
                    }
                }
            //}

            if(this.started_race) {
                this.raceTimeAlive = this.curTime - this.raceBornTime;
                this.race_time_left = Math.floor(PlayState.RACE_LENGTH - this.raceTimeAlive/1000);
                this.timer_text.text = this.race_time_left + " seconds left!";
            }

            if(this.race_time_left <= 0) {
                if(!this.finished) {
                    this.endRace();
                }
            }
            if(this.finished) {
                if(this.race_time_left <= this.raceEndedAt - 5) {
                    FlxG.switchState(new EndState());
                }
            }

            var colliders:Array = PlayersController.getInstance().getPlayerColliders().members,
                checkpoint:Checkpoint, curPlayer:Player, curCollider:GameObject,
                k:int, curCompareCollider:GameObject, curComparePlayer:Player;
            for (var i:int = 0; i < colliders.length; i++) {
                curCollider = colliders[i];
                curPlayer = curCollider.parent as Player;
                for (k = 0; k < this.checkpoints.members.length; k++) {
                    checkpoint = this.checkpoints.members[k];
                    if (curCollider._getRect().overlaps(checkpoint._getRect())) {
                        this.overlapPlayerCheckpoints(curPlayer, checkpoint);
                    }
                }

                for (k = 0; k < colliders.length; k++) {
                    curCompareCollider = colliders[i];
                    curComparePlayer = curCollider.parent as Player;
                    if (curCollider._getRect().overlaps(curCompareCollider._getRect())) {
                        this.overlapPlayers(curPlayer, curComparePlayer);
                    }
                }

                var collisionData:Array = FlxCollision.pixelPerfectCheck(
                    curCollider, this.collider, 255, null, curPlayer.collisionDirection);
                curPlayer.colliding = collisionData[0];
            }
        }

        override public function destroy():void {
            super.destroy();
        }

        public function endRace():void {
            this.raceEndedAt = this.race_time_left;
            this.finished = true;
            this.time_out_sprite.visible = true;
            this.timer_text.visible = false;
            this.gameActive = false;
        }

        public function overlapPlayerCheckpoints(player:Player,
                                                 checkpoint:Checkpoint):void
        {
            player.crossCheckpoint(checkpoint);
            if(!this.finished) {
                if(player.winner) {
                    this.endRace();
                }
            }
        }

        public function overlapPlayers(player1:Player, player2:Player):void
        {
            player1.collisionCallback(player2);
            player2.collisionCallback(player1);
        }

    }
}
