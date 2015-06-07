package {
    import org.flixel.*;

    public class PlayState extends GameState {
        [Embed(source="/../assets/map_1.png")] private var map_1:Class;

        override public function create():void {
            ScreenManager.getInstance().loadSingleTileBG("/../assets/map_1.png");
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
