package {
    import org.flixel.*;

    public class PlayState extends FlxState {
        private var playersController:PlayersController;

        override public function create():void {
            this.playersController = new PlayersController();
        }

        override public function update():void {
            super.update();

            this.playersController.update();
        }
    }
}
