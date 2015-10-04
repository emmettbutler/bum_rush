/**
 * FlxCollision
 * -- Part of the Flixel Power Tools set
 *
 * v1.6 Fixed bug in pixelPerfectCheck that stopped non-square rotated objects from colliding properly (thanks to joon on the flixel forums for spotting)
 * v1.5 Added createCameraWall
 * v1.4 Added pixelPerfectPointCheck()
 * v1.3 Update fixes bug where it wouldn't accurately perform collision on AutoBuffered rotated sprites, or sprites with offsets
 * v1.2 Updated for the Flixel 2.5 Plugin system
 *
 * @version 1.6 - October 8th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm
{
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.PixelSnapping;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.display.BlendMode;
    import flash.utils.setTimeout;
    import flash.utils.clearTimeout;

    import org.flixel.*;

    public class FlxCollision
    {
        public static var CAMERA_WALL_OUTSIDE:uint = 0;
        public static var CAMERA_WALL_INSIDE:uint = 1;

        {
            private static var edgeRect:Rectangle = new Rectangle(0, 0, 1, 1);
        }

        public function FlxCollision()
        {
        }

        /**
         * A Pixel Perfect Collision check between two FlxSprites.
         * It will do a bounds check first, and if that passes it will run a pixel perfect match on the intersecting area.
         * Works with rotated, scaled and animated sprites.
         *
         * @param    contact            The first FlxSprite to test against
         * @param    target            The second FlxSprite to test again, sprite order is irrelevant
         * @param    alphaTolerance    The tolerance value above which alpha pixels are included. Default to 255 (must be fully opaque for collision).
         * @param    camera            If the collision is taking place in a camera other than FlxG.camera (the default/current) then pass it here
         *
         * @return    Boolean True if the sprites collide, false if not
         */
        public static function pixelPerfectCheck(contact:FlxSprite,
                                                 target:FlxSprite,
                                                 alphaTolerance:int=255,
                                                 camera:FlxCamera=null,
                                                 collideData:Array=null,
                                                 showCollider:Boolean=false,
                                                 threshold_:Number=-1,
                                                 rotationOrigin:DHPoint=null):Array
        {
            var pointA:Point = new Point;
            var pointB:Point = new Point;

            var cam:FlxCamera = camera;
            if (cam == null) {
                cam = FlxG.camera;
            }

            var contactPixels:BitmapData = contact.framePixels;
            var contactPos:DHPoint = new DHPoint(contact.x, contact.y);

            // get the origin point of each colliding object
            pointA.x = contactPos.x - int(cam.scroll.x * contact.scrollFactor.x) - contact.offset.x;
            pointA.y = contactPos.y - int(cam.scroll.y * contact.scrollFactor.y) - contact.offset.y;
            pointB.x = target.x - int(cam.scroll.x * target.scrollFactor.x) - target.offset.x;
            pointB.y = target.y - int(cam.scroll.y * target.scrollFactor.y) - target.offset.y;

            // build a bounding box for each object involved in collision
            var boundsA:Rectangle = new Rectangle(pointA.x, pointA.y, contactPixels.width, contactPixels.height);
            var boundsB:Rectangle = new Rectangle(pointB.x, pointB.y, target.framePixels.width, target.framePixels.height);

            // figure out the bounds of the intersection between the two bounding boxes
            var intersect:Rectangle = boundsA.intersection(boundsB);

            if (intersect.isEmpty() || intersect.width == 0 || intersect.height == 0) {
                return [false, null];
            }

            // Normalise the values or it'll break the BitmapData creation below
            intersect.x = Math.floor(intersect.x);
            intersect.y = Math.floor(intersect.y);
            intersect.width = Math.ceil(intersect.width);
            intersect.height = Math.ceil(intersect.height);

            if (intersect.isEmpty()) {
                return [false, null];
            }

            // generate translation matrices. these are used to position the bitmaps
            // of the colliding objects in the same way the objects themselves
            // are positioned.
            var matrixA:Matrix = new Matrix;
            matrixA.translate(intersect.x - boundsA.x, intersect.y - boundsA.y);
            var matrixB:Matrix = new Matrix;
            matrixB.translate(-(intersect.x - boundsB.x), -(intersect.y - boundsB.y));

            var testA:BitmapData = contactPixels;
            var testB:BitmapData = target.framePixels;

            // draw the overlap in an invisible bitmap
            var overlapArea:BitmapData = new BitmapData(contactPixels.width, contactPixels.height, true, 0x00000000);
            overlapArea.draw(testA, matrixA, new ColorTransform(1, 1, 1, 1, 255, -255, -255, alphaTolerance), BlendMode.NORMAL);
            overlapArea.draw(testB, matrixB, new ColorTransform(1, 1, 1, 1, 255, 255, 255, alphaTolerance), BlendMode.DIFFERENCE);

            //    Developers: If you'd like to see how this works, display it in your game somewhere. Or you can comment it out to save a tiny bit of performance
            if (showCollider) {
                var spr:FlxExtSprite = new FlxExtSprite(contactPos.x, contactPos.y);
                var bmp:Bitmap = new Bitmap(overlapArea, PixelSnapping.NEVER, true);
                spr.loadExtGraphic(bmp, false, false, bmp.width, bmp.height, true);
                spr.active = false;
                FlxG.state.add(spr);
                var tid:Number;
                tid = setTimeout(function():void {
                    FlxG.state.remove(spr);
                    spr.kill();
                    spr = null;
                    clearTimeout(tid);
                }, 500);
            }

            var leftEdge:BitmapData = new BitmapData(2, Math.floor(boundsA.height));
            edgeRect.x = 0;
            edgeRect.y = 0;
            edgeRect.width = leftEdge.width;
            edgeRect.height = leftEdge.height;
            leftEdge.copyPixels(overlapArea, edgeRect, new Point(0, 0));
            var leftEdgeCollisionBounds:Rectangle = leftEdge.getColorBoundsRect(0xffffffff, 0xff00ffff);
            var collidingLeft:Boolean = leftEdgeCollisionBounds.width >= leftEdge.width - 1 &&
                leftEdgeCollisionBounds.height >= (threshold_ == -1 ? leftEdge.height - 1 : threshold_);

            var rightEdge:BitmapData = new BitmapData(2, Math.floor(boundsA.height));
            edgeRect.x = boundsA.width - rightEdge.width;
            edgeRect.y = 0;
            edgeRect.width = rightEdge.width;
            edgeRect.height = rightEdge.height;
            rightEdge.copyPixels(overlapArea, edgeRect, new Point(0, 0));
            var rightEdgeCollisionBounds:Rectangle = rightEdge.getColorBoundsRect(0xffffffff, 0xff00ffff);
            var collidingRight:Boolean = rightEdgeCollisionBounds.width >= rightEdge.width - 1 &&
                rightEdgeCollisionBounds.height >= (threshold_ == -1 ? rightEdge.height - 1 : threshold_);

            var topEdge:BitmapData = new BitmapData(Math.floor(boundsA.width), 2);
            edgeRect.x = 0;
            edgeRect.y = 0;
            edgeRect.width = topEdge.width;
            edgeRect.height = topEdge.height;
            topEdge.copyPixels(overlapArea, edgeRect, new Point(0, 0));
            var topEdgeCollisionBounds:Rectangle = topEdge.getColorBoundsRect(0xffffffff, 0xff00ffff);
            var collidingTop:Boolean = topEdgeCollisionBounds.height >= topEdge.height - 1 &&
                topEdgeCollisionBounds.width >= (threshold_ == -1 ? topEdge.width - 1 : threshold_);

            var bottomEdge:BitmapData = new BitmapData(Math.floor(boundsA.width), 2);
            edgeRect.x = 0;
            edgeRect.y = boundsA.height - bottomEdge.height;
            edgeRect.width = bottomEdge.width;
            edgeRect.height = bottomEdge.height;
            bottomEdge.copyPixels(overlapArea, edgeRect, new Point(0, 0));
            var bottomEdgeCollisionBounds:Rectangle = bottomEdge.getColorBoundsRect(0xffffffff, 0xff00ffff);
            var collidingBottom:Boolean = bottomEdgeCollisionBounds.height >= bottomEdge.height - 1 &&
                bottomEdgeCollisionBounds.width >= (threshold_ == -1 ? bottomEdge.width - 1 : threshold_);

            var overlap:Rectangle = overlapArea.getColorBoundsRect(0xffffffff, 0xff00ffff);
            overlap.offset(intersect.x, intersect.y);

            overlapArea.dispose();
            overlapArea = null;
            rightEdge.dispose();
            rightEdge = null;
            leftEdge.dispose();
            leftEdge = null;
            topEdge.dispose();
            topEdge = null;
            bottomEdge.dispose();
            bottomEdge = null;

            if (overlap.isEmpty()) {
                return [false, null];
            }
            else {
                // added to include information about the direction of the collision
                // with respect to contact
                if (collideData == null) {
                    collideData = new Array(0, 0, 0, 0);  // left, right, up, down
                }
                collideData[0] = collidingLeft || collideData[0] ? 1 : 0;
                collideData[1] = collidingRight || collideData[1] ? 1 : 0;
                collideData[2] = collidingTop || collideData[2] ? 1 : 0;
                collideData[3] = collidingBottom || collideData[3] ? 1 : 0;
                return [true, collideData];
            }
        }

        /**
         * A Pixel Perfect Collision check between a given x/y coordinate and an FlxSprite<br>
         *
         * @param    pointX            The x coordinate of the point given in local space (relative to the FlxSprite, not game world coordinates)
         * @param    pointY            The y coordinate of the point given in local space (relative to the FlxSprite, not game world coordinates)
         * @param    target            The FlxSprite to check the point against
         * @param    alphaTolerance    The alpha tolerance level above which pixels are counted as colliding. Default to 255 (must be fully transparent for collision)
         *
         * @return    Boolean True if the x/y point collides with the FlxSprite, false if not
         */
        public static function pixelPerfectPointCheck(pointX:uint, pointY:uint, target:FlxSprite, alphaTolerance:int = 255):Boolean
        {
            //    Intersect check
            if (FlxMath.pointInCoordinates(pointX, pointY, target.x, target.y, target.framePixels.width, target.framePixels.height) == false)
            {
                return false;
            }

            //    How deep is pointX/Y within the rect?
            var test:BitmapData = target.framePixels;

            if (FlxColor.getAlpha(test.getPixel32(pointX - target.x, pointY - target.y)) >= alphaTolerance)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        /**
         * Creates a "wall" around the given camera which can be used for FlxSprite collision
         *
         * @param    camera                The FlxCamera to use for the wall bounds (can be FlxG.camera for the current one)
         * @param    placement            CAMERA_WALL_OUTSIDE or CAMERA_WALL_INSIDE
         * @param    thickness            The thickness of the wall in pixels
         * @param    adjustWorldBounds    Adjust the FlxG.worldBounds based on the wall (true) or leave alone (false)
         *
         * @return    FlxGroup The 4 FlxTileblocks that are created are placed into this FlxGroup which should be added to your State
         */
        public static function createCameraWall(camera:FlxCamera, placement:uint, thickness:uint, adjustWorldBounds:Boolean = false):FlxGroup
        {
            var left:FlxTileblock;
            var right:FlxTileblock;
            var top:FlxTileblock;
            var bottom:FlxTileblock;

            switch (placement)
            {
                case CAMERA_WALL_OUTSIDE:
                    left = new FlxTileblock(camera.x - thickness, camera.y + thickness, thickness, camera.height - (thickness * 2));
                    right = new FlxTileblock(camera.x + camera.width, camera.y + thickness, thickness, camera.height - (thickness * 2));
                    top = new FlxTileblock(camera.x - thickness, camera.y - thickness, camera.width + thickness * 2, thickness);
                    bottom = new FlxTileblock(camera.x - thickness, camera.height, camera.width + thickness * 2, thickness);

                    if (adjustWorldBounds)
                    {
                        FlxG.worldBounds = new FlxRect(camera.x - thickness, camera.y - thickness, camera.width + thickness * 2, camera.height + thickness * 2);
                    }
                    break;

                case CAMERA_WALL_INSIDE:
                    left = new FlxTileblock(camera.x, camera.y + thickness, thickness, camera.height - (thickness * 2));
                    right = new FlxTileblock(camera.x + camera.width - thickness, camera.y + thickness, thickness, camera.height - (thickness * 2));
                    top = new FlxTileblock(camera.x, camera.y, camera.width, thickness);
                    bottom = new FlxTileblock(camera.x, camera.height - thickness, camera.width, thickness);

                    if (adjustWorldBounds)
                    {
                        FlxG.worldBounds = new FlxRect(camera.x, camera.y, camera.width, camera.height);
                    }
                    break;
            }

            var result:FlxGroup = new FlxGroup(4);

            result.add(left);
            result.add(right);
            result.add(top);
            result.add(bottom);

            return result;
        }

    }

}
