package {
    import org.flixel.*;

    public class PlayState extends GameState {
        private var checkpoints:FlxGroup;

        override public function create():void {
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
                new DHPoint(120, 10)
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
        }

        override public function update():void {
            super.update();

            FlxG.overlap(
                PlayersController.getInstance().getPlayerColliders(),
                PlayersController.getInstance().getPlayerColliders(),
                this.overlapPlayers
            );
        }

        override public function destroy():void {
            PlayersController.reset();
            super.destroy();
        }

        public function overlapPlayers(player1Collider:GameObject,
                                       player2Collider:GameObject):void
        {
            trace("players touching: " + new Date().valueOf())
            if (player1Collider == null || player2Collider == null) {
                return;
            }
            (player1Collider.parent as Player).collisionCallback(player2Collider.parent as Player);
            (player2Collider.parent as Player).collisionCallback(player1Collider.parent as Player);
        }
    }
}
