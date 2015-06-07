package {
    import org.flixel.*;

    import flash.display.StageDisplayState;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.geom.Rectangle;
    import flash.events.*;
    import flash.ui.Keyboard;
    import flash.utils.Timer;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.PixelSnapping;
    import flash.display.Loader;
    import flash.geom.Matrix;
    import flash.net.URLRequest;

    public class ScreenManager {
        public static const DEFAULT_ASPECT:Number = 640/360;
        public var screenWidth:Number, screenHeight:Number;

        private var fullscreen:Boolean = true;

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

        public function loadSingleTileBG(path:String):FlxExtSprite {
            var _screen:ScreenManager = ScreenManager.getInstance();
            var bg:FlxExtSprite = new FlxExtSprite(0, 0);
            bg.scrollFactor = new FlxPoint(0, 0);
            FlxG.state.add(bg);
            var receivingMachine:Loader = new Loader();
            receivingMachine.contentLoaderInfo.addEventListener(Event.COMPLETE,
                function (event_load:Event):void {
                    var bmp:Bitmap = new Bitmap(event_load.target.content.bitmapData);
                    var imgDim:DHPoint = new DHPoint(bmp.width, bmp.height);
                    var dim:DHPoint = _screen.calcFullscreenDimensionsAlt(imgDim);
                    var origin:DHPoint = _screen.calcFullscreenOrigin(dim);
                    var bgScale:Number = _screen.calcFullscreenScale(imgDim);
                    var matrix:Matrix = new Matrix();
                    matrix.scale(bgScale, bgScale);
                    var scaledBMD:BitmapData = new BitmapData(bmp.width * bgScale,
                                                            bmp.height * bgScale,
                                                            true, 0x000000);
                    scaledBMD.draw(bmp, matrix, null, null, null, true);
                    bmp = new Bitmap(scaledBMD, PixelSnapping.NEVER, true);
                    bg.loadExtGraphic(bmp, false, false, bmp.width, bmp.height, true);
                    bg.x = origin.x;
                    bg.y = origin.y;
                    FlxG.stage.dispatchEvent(
                        new DataEvent(GameState.EVENT_SINGLETILE_BG_LOADED,
                                      {'bg_scale': bgScale, 'bg': bg}));
                }
            );
            receivingMachine.load(new URLRequest(path));
            return bg;
        }

        public static function getInstance():ScreenManager {
            if (_instance == null) {
                _instance = new ScreenManager();
            }
            return _instance;
        }
    }
}
