package {
    import org.flixel.*;
    import flash.ui.GameInput;

    [SWF(width="640", height="480", backgroundColor="#000000")]
    [Frame(factoryClass="Preloader")]

    public class bootycall extends FlxGame {
        private static var gameInput:GameInput;

        public function bootycall() {
            gameInput = new GameInput();
            super(320,240,MenuState,1);
        }
    }
}
