package {
    import org.flixel.*;

    public class PlayState extends GameState {
        [Embed(source="/../assets/map_1.png")] private var map_1:Class;
        private var mapSprite:GameObject;

        override public function create():void {
            this.mapSprite = new GameObject(new DHPoint(0,0));
            this.mapSprite.loadGraphic(map_1,false,false,1280,720);
            FlxG.state.add(this.mapSprite);
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
            (player1Collider.parent as Player).collisionCallback(player2Collider.getPos());
            (player2Collider.parent as Player).collisionCallback(player1Collider.getPos());
        }
    }
}
