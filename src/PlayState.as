package {
    import org.flixel.*;

    public class PlayState extends GameState {
        override public function create():void {
            PlayersController.getInstance().addRegisteredPlayers();
        }

        override public function update():void {
            super.update();
        }
    }
}
