package org.flixel
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    /**
     * ...
     * @author William Hawthorne
     */
    public class FlxExtSprite extends FlxSprite
    {
        public var hasLoaded:Boolean = false;
        public var hasStartedLoad:Boolean = false;

        public function FlxExtSprite(X:Number, Y:Number, SimpleGraphic:Class=null):void
        {
            super(X, Y, SimpleGraphic);
            this.makeGraphic(10, 10, 0x00000000);
        }

        override public function update():void {
            super.update();
        }

        public function loadExtGraphic(Graphic:Bitmap,Animated:Boolean=false,Reverse:Boolean=false,Width:uint=0,Height:uint=0,Unique:Boolean=false):FlxSprite
        {
            _bakedRotation = 0;

            if (Reverse)
            {
                _pixels = FlxG.createBitmap(Graphic.width << 1, Graphic.height, 0x00FFFFFF, Unique);
                _pixels.draw(Graphic);
                var mtx:Matrix = new Matrix();
                mtx.scale( -1, 1);
                mtx.translate(Graphic.width << 1, 0);
                _pixels.draw(Graphic, mtx);
                _flipped = _pixels.width >> 1;
            } else {
                _pixels = FlxG.createBitmap(Graphic.width, Graphic.height, 0x00FFFFFF, Unique);
                _pixels.draw(Graphic);
                _flipped = 0;
            }
            if(Width == 0)
            {
                if(Animated)
                    Width = _pixels.height;
                else if(_flipped > 0)
                    Width = _pixels.width/2;
                else
                    Width = _pixels.width;
            }
            width = frameWidth = Width;
            if(Height == 0)
            {
                if(Animated)
                    Height = width;
                else
                    Height = _pixels.height;
            }
            height = frameHeight = Height;
            resetHelpers();
            return this;
        }
    }
}
