package {
    import org.flixel.*;

    public class PlayState extends GameState {
        override public function create():void {
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

        public function overlapPlayers(player1Collider:GameObject,
                                       player2Collider:GameObject):void
        {
            trace("players touching: " + new Date().valueOf())
            if (player1Collider == null || player2Collider == null) {
                return;
            }
            (player1Collider.parent as Player).collisionCallback(player2Collider.getPos());
            (player2Collider.parent as Player).collisionCallback(player1Collider.getPos());
        }
    }
}
