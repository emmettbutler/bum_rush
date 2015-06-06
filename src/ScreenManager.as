package {
    import org.flixel.*;

    import flash.display.StageDisplayState;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.geom.Rectangle;
    import flash.events.*;
    import flash.ui.Keyboard;
    import flash.utils.Timer;

    public class ScreenManager {
        public static const DEFAULT_ASPECT:Number = 640/360;
        public var screenWidth:Number, screenHeight:Number;

        private var fullscreen:Boolean = false;

        public static var _instance:ScreenManager = null;

        public function ScreenManager() {
            FlxG.stage.frameRate = 60;

            if (!this.fullscreen) {
                this.setupWindowedMode();
            } else {
                this.setupFullscreenMode();
            }

            var that:ScreenManager = this;
            FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,
                function(e:KeyboardEvent):void {
                    if (e.keyCode == Keyboard.ESCAPE) {
                        e.preventDefault();
                    } else if (e.keyCode == Keyboard.F) {
                        that.toggleFullscreen();
                    }
                });

            trace("SCREEN DIMENSIONS: " + screenWidth + "x" + screenHeight);
        }

        private function toggleFullscreen():void {
            if (this.fullscreen) {
                this.fullscreen = false;
                this.setupWindowedMode();
            } else {
                this.fullscreen = true;
                this.setupFullscreenMode();
            }
        }

        private function setupFullscreenMode():void {
            screenWidth = FlxG.stage.fullScreenWidth;
            screenHeight = FlxG.stage.fullScreenHeight;
            FlxG.width = screenWidth;
            FlxG.height = screenHeight;
            FlxG.stage.fullScreenSourceRect = new Rectangle(0, 0, screenWidth,
                                                            screenHeight);
            FlxG.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
            this.setupCamera(null);
        }

        private function setupWindowedMode():void {
            FlxG.stage.displayState = StageDisplayState.NORMAL;
            FlxG.stage.nativeWindow.width = FlxG.stage.fullScreenWidth;
            FlxG.stage.nativeWindow.height = FlxG.stage.fullScreenHeight - 100;
            FlxG.stage.nativeWindow.x = 0;
            FlxG.stage.nativeWindow.y = 0;
            screenWidth = FlxG.stage.nativeWindow.width;
            screenHeight = FlxG.stage.nativeWindow.height;
            FlxG.width = screenWidth;
            FlxG.height = screenHeight;
            this.setupCamera(null);
        }

        public function calcFullscreenDimensions(aspect:Number=DEFAULT_ASPECT):DHPoint {
            return new DHPoint(screenHeight * aspect, screenWidth / aspect);
        }

        public function calcFullscreenDimensionsAlt(dim:DHPoint):DHPoint {
            var aspect:Number = dim.x / dim.y;
            if (dim.x > dim.y) {
                return new DHPoint(screenWidth, screenWidth / aspect);
            } else {
                return new DHPoint(screenHeight * aspect, screenHeight);
            }
        }

        public function calcFullscreenScale(dim:DHPoint):Number {
            var factor:Number;
            if (dim.x > dim.y) {
                factor = screenWidth / dim.x;
            } else {
                factor = screenHeight / dim.y;
            }
            return factor;
        }

        public function calcFullscreenOrigin(dim:DHPoint):DHPoint {
            return new DHPoint((screenWidth - dim.x) / 2, (screenHeight - dim.y) / 2);
        }

        public function setupCamera(playerCamera:GameObject, zoomFactor:Number=1.2):void {
            var cam:FlxCamera = new FlxCamera(0, 0, screenWidth, screenHeight);
            FlxG.resetCameras(cam);
        }

        public static function getInstance():ScreenManager {
            if (_instance == null) {
                _instance = new ScreenManager();
            }
            return _instance;
        }
    }
}
