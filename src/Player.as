package {
    import org.flixel.*;

    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.Joints.*;

    import flash.ui.GameInputDevice;
    import flash.ui.GameInputControl;
    import flash.utils.Dictionary;

    public class Player extends GameObject {
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;
        [Embed(source="/../assets/audio/drive.mp3")] private var SfxAccel:Class;
        [Embed(source="/../assets/audio/donk.mp3")] private var SfxEnd:Class;
        [Embed(source="/../assets/audio/collide.mp3")] private var SfxCollide:Class;
        [Embed(source="/../assets/audio/passenger.mp3")] private var SfxPassenger:Class;
        [Embed(source="/../assets/images/ui/HUD_arrow.png")] private static var HUDCheckmark:Class;
        [Embed(source="/../assets/images/misc/highlight.png")] private static var ImgHighlight:Class;
        [Embed(source="/../assets/images/ui/HUD_Heart.png")] private static var HUDHeart:Class;
        [Embed(source="/../assets/images/ui/need_date.png")] private static var ImgNoDate:Class;
        [Embed(source="/../assets/images/ui/go_home.png")] private static var ImgGoHome:Class;
        [Embed(source="/../assets/images/ui/alreadydone.png")] private static var ImgBeenThere:Class;

        public static const COLLISION_TAG:String = "car_thing";

        // the player's maximum velocity
        private static const MAX_VELOCITY:Number = 460;
        // factor in acceleration. higher == faster acceleration, tighter turns
        private static const ACCELERATION_MULTIPLIER:Number = 1.75;
        // the amount of drag generated by the road
        private static const ROAD_DRAG:Number = 27;

        private var m_physScale:Number = 30
        private var m_physBody:b2Body,
                    m_groundBody:b2Body;
        private var m_world:b2World;
        private var driver_sprite:Class;
        private var highlight_sprite:GameObject;
        private var highlight_number:FlxText;
        private var carSprite:GameObject;
        private var mainSprite:GameObject;
        private var collider:GameObject;
        public var playerConfig:Object;
        private var checkmark_sprite:GameObject;
        private var heart_sprite:GameObject;
        private var controller:GameInputDevice;
        private var startPos:DHPoint;
        private var passengers:Array;
        private var accel:DHPoint,
                    directionsPressed:DHPoint,
                    throttle:Boolean,
                    facingVector:DHPoint;
        private var _colliding:Boolean = false;
        private var _collisionDirection:Array,
                    _checkpointStatusList:Array;
        private var completionIndicator:GameObject;
        private var _driver_name:String;
        private var driver_tag:Number, frameRate:Number = 12,
                    completionTime:Number = -1,
                    checkInTime:Number = 0,
                    no_date_text_timer:Number = 0;
        private var _checkpoints_complete:Boolean = false,
                    _winner:Boolean = false,
                    _race_started:Boolean = false,
                    play_heart:Boolean = false,
                    heart_scale_down:Boolean = false;
        private var _lastCheckpointIdx:Number = 0;
        private var player_hud:PlayerHud;
        private var _driving:Boolean = false;
        private var checking_in:Boolean = false;
        private var lastPassengerRemoveTime:Number = 0;
        private var passengerRemoveThreshold:Number = 1;
        private var curCheckpoint:Checkpoint;
        private var lastCompletedCheckpoint:Checkpoint;
        private var curHomeInd:Number;
        private var meter:Meter;
        private var streetPoints:Array;
        private var impactParticles:ParticleExplosion;
        private var exhaustPos:DHPoint;
        private var car_sprite:Class;
        private var no_date_text:GameObject;
        private var checkin_timelimit:Number = 3;
        private var been_there:GameObject;
        private var been_there_timer:Number;
        private var _showBeenThereList:Array;

        {
            public static const CTRL_PAD:Number = 1;
            public static const CTRL_KEYBOARD_1:Number = 2;
            public static const CTRL_KEYBOARD_2:Number = 3;
            private static var keyboardControls:Dictionary = new Dictionary();
            keyboardControls[CTRL_KEYBOARD_1] = {
                'up': "W",
                'down': "S",
                'left': "A",
                'right': "D",
                'throttle': "R",
                'highlight': "E"
            };
            keyboardControls[CTRL_KEYBOARD_2] = {
                'up': "I",
                'down': "K",
                'left': "J",
                'right': "L",
                'throttle': "P",
                'highlight': "O"
            };
        }

        private var controlType:Number = CTRL_PAD;
        private var accelSFX:FlxSound;
        private var lastCheckpointSound:FlxSound;
        private var collideSfx:FlxSound;
        private var passengerSfx:FlxSound;
        private var wallBounceAmount:Number = 1.7;
        private var idx:Number;

        public function Player(pos:DHPoint,
                               controller:GameInputDevice,
                               _world:b2World,
                               groundBody:b2Body,
                               streetPoints:Array,
                               ctrlType:Number=CTRL_PAD,
                               _tag:Number=0,
                               checkpoint_count:Number=0):void
        {
            super(pos);

            this.playerConfig = PlayersController.getInstance().playerConfigs[_tag];

            this.m_world = _world;
            this.m_groundBody = groundBody;
            this.dir = new DHPoint(0, 0);
            this.accel = new DHPoint(0, 0);
            this.directionsPressed = new DHPoint(0, 1);
            this.facingVector = new DHPoint(0, 1);
            this.throttle = false;
            this.controlType = ctrlType;
            this.streetPoints = streetPoints;

            this.controller = controller;
            this.driver_tag = _tag;

            var tagData:Object = PlayersController.getInstance().resolveTag(this.driver_tag);
            this.driver_sprite = tagData['sprite'];
            this._driver_name = tagData['name'];
            this.car_sprite = tagData['car'];
            this.idx = tagData['index'];
            this._checkpointStatusList = new Array();

            this.passengers = new Array();

            this.addAnimations();

            this.accelSFX = new FlxSound();
            this.accelSFX.loadEmbedded(SfxAccel, false);
            this.accelSFX.volume = 1;

            this.lastCheckpointSound = new FlxSound();
            this.lastCheckpointSound.loadEmbedded(SfxEnd, false);
            this.lastCheckpointSound.volume = 1;

            this.collideSfx = new FlxSound();
            this.collideSfx.loadEmbedded(SfxCollide, false);
            this.collideSfx.volume = 1;

            this.passengerSfx = new FlxSound();
            this.passengerSfx.loadEmbedded(SfxPassenger, false);
            this.passengerSfx.volume = 1;

            this.completionIndicator = new GameObject(new DHPoint(0,0));
            this.completionIndicator.loadGraphic(ImgGoHome, false, false, 102, 48);
            this.completionIndicator.addAnimation("run", [0, 1, 2, 3, 4, 5, 6, 7], 13, true);
            this.completionIndicator.play("run");
            this.completionIndicator.visible = false;

            this.no_date_text = new GameObject(new DHPoint(this.pos.x, this.pos.y));
            this.no_date_text.loadGraphic(ImgNoDate, false, false, 59, 30);
            this.no_date_text.visible = false;

            this.been_there = new GameObject(new DHPoint(this.pos.x, this.pos.y));
            this.been_there.loadGraphic(ImgBeenThere, false, false, 90, 33);
            this.been_there.visible = false;

            this._checkpointStatusList = new Array();

            var i:Number = 0
            for(i = 0; i < checkpoint_count; i++) {
                this._checkpointStatusList.push(false);
            }

            this._showBeenThereList = new Array();

            for(i = 0; i < checkpoint_count; i++) {
                this._showBeenThereList.push(false);
            }

            this.collider = new GameObject(new DHPoint(0, 0), this);
            this.collider.makeGraphic(this.mainSprite.width * .6,
                                      this.mainSprite.height * .5,
                                      0xffffff00,
                                      true);
            this.collider.visible = false;

            this.setupPhysics();

            this._collisionDirection = new Array(0, 0, 0, 0);
            this.meter = new Meter(this.pos, 100, 50, 10);
            this.meter.setVisible(false);
            this.setupParticles();
        }

        public function getFacingVector():DHPoint {
            return this.facingVector;
        }

        public function setHudPos(pos:DHPoint):void {
            this.player_hud.setPos(pos);
        }

        public function setupParticles():void {
            impactParticles = new ParticleExplosion(13, 2, .4, 12);
            impactParticles.gravity = new DHPoint(0, .3);
        }

        public function overlapsPassenger(passenger:Passenger):Boolean {
            return this.carSprite._getRect().overlaps(passenger.getStandingHitbox());
        }

        public function removePassenger(hitVector:DHPoint):void {
            if (this.timeAlive - this.lastPassengerRemoveTime < this.passengerRemoveThreshold) {
                return;
            }
            var lastPassenger:Object;
            if (this.passengers.length > 0) {
                lastPassenger = this.passengers.pop();
                this.lastPassengerRemoveTime = this.timeAlive;
            }
            if (lastPassenger != null) {
                var destPoint:DHPoint = this.streetPoints[
                    Math.floor(Math.random() * (this.streetPoints.length - 1))];
                lastPassenger.leaveCar(hitVector, destPoint);
                this.impactParticles.run(this.getMiddle());
            }
            if (this.passengers.length == 0) {
                this.checking_in = false;
                this.meter.setVisible(false);
            }
            this.collideSfx.play();
        }

        public function addPassenger(passenger:Passenger, playSound:Boolean=true):void {
            if (passenger.driver != null) {
                return;
            }
            passenger.enterCar(this);
            this.passengers.push(passenger);
            passenger.idx = this.passengers.indexOf(passenger);
            if (playSound) {
                passengerSfx.play();
            }
        }

        public function getPassengers():Array {
            return this.passengers;
        }

        public function get bodyVelocity():Number {
            return this.m_physBody.GetAngularVelocity();
        }

        public function get bodyLinearVelocity():DHPoint {
            var vel:b2Vec2 = this.m_physBody.GetLinearVelocity();
            return new DHPoint(vel.x * m_physScale, vel.y * m_physScale);
        }

        public function setupPhysics():void {
            var box:b2PolygonShape = new b2PolygonShape();
            box.SetAsBox((this.collider.width * .6) / m_physScale,
                         (this.collider.height * .8) / m_physScale);
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.shape = box;
            fixtureDef.density = 0.5;
            fixtureDef.restitution = 0.5;
            fixtureDef.userData = {'tag': COLLISION_TAG, 'player': this};
            var bd:b2BodyDef = new b2BodyDef();
            bd.type = b2Body.b2_dynamicBody;
            bd.position.Set(this.pos.x / m_physScale, (this.pos.y) / m_physScale);
            bd.fixedRotation = true;
            m_physBody = this.m_world.CreateBody(bd);
            m_physBody.CreateFixture(fixtureDef);

            var jointDef:b2FrictionJointDef = new b2FrictionJointDef();
            jointDef.localAnchorA.SetZero();
            jointDef.localAnchorB.SetZero();
            jointDef.bodyA = m_physBody;
            jointDef.bodyB = m_groundBody;
            jointDef.maxForce = ROAD_DRAG;
            jointDef.maxTorque = 50;
            jointDef.collideConnected = true;
            m_world.CreateJoint(jointDef as b2JointDef);
        }

        public function addAnimations():void {
            var tagData:Object = PlayersController.getInstance().resolveTag(this.driver_tag);

            this.highlight_sprite = new GameObject(this.pos);
            this.highlight_sprite.zSorted = true;
            this.highlight_sprite.basePosOffset = new DHPoint(0, -2000);
            this.highlight_sprite.loadGraphic(ImgHighlight, false, false, 64, 64);
            this.highlight_sprite.color = tagData["tint"];
            this.highlight_sprite.visible = false;

            this.highlight_number = new FlxText(0, 0, 100, (this.idx + 1) + "");
            this.highlight_number.setFormat("Pixel_Berry_08_84_Ltd.Edition", 16, tagData['tint'], "left");
            this.highlight_number.visible = false;

            this.carSprite = new GameObject(this.pos);
            this.carSprite.loadGraphic(car_sprite, false, false, 64, 64);
            this.carSprite.basePosOffset = new DHPoint(0, -1000);
            this.carSprite.zSorted = true;
            this.carSprite.addAnimation("drive_right", [0,1,2,3], this.frameRate, true);
            this.carSprite.addAnimation("drive_up", [4,5,6,7], this.frameRate, true);
            this.carSprite.addAnimation("drive_down", [8,9,10,11], this.frameRate, true);
            this.carSprite.addAnimation("drive_left", [12,13,14,15], this.frameRate, true);
            this.carSprite.play("drive_down");

            this.mainSprite = new GameObject(this.pos, this);
            this.mainSprite.loadGraphic(driver_sprite, true, false, 64, 64);
            this.mainSprite.zSorted = true;
            this.mainSprite.basePosOffset = new DHPoint(
                this.mainSprite.width / 2,
                1000
            );
            this.mainSprite.addAnimation("drive_right", [0,1,2,3], this.frameRate, true);
            this.mainSprite.addAnimation("drive_up", [4,5,6,7], this.frameRate, true);
            this.mainSprite.addAnimation("drive_down", [8,9,10,11], this.frameRate, true);
            this.mainSprite.addAnimation("drive_left", [12,13,14,15], this.frameRate, true);
            this.mainSprite.play("drive_down");

            this.checkmark_sprite = new GameObject(new DHPoint(0, 0));
            this.checkmark_sprite.loadGraphic(HUDCheckmark, false, false, 32, 32);
            this.checkmark_sprite.visible = false;

            this.heart_sprite = new GameObject(new DHPoint(0,0));
            this.heart_sprite.loadGraphic(HUDHeart, false, false, 12, 10);
            this.heart_sprite.visible = false;
        }

        public function set colliding(c:Boolean):void {
            this._colliding = c;
        }

        public function get collisionDirection():Array {
            return this._collisionDirection;
        }

        public function set driving(r:Boolean):void {
            this._driving = r;
        }

        public function get driving():Boolean {
            return this._driving;
        }

        public function getCollider():GameObject {
            return this.collider;
        }

        override public function addVisibleObjects():void {
            super.addVisibleObjects();
            FlxG.state.add(this.highlight_sprite);
            FlxG.state.add(this.highlight_number);
            FlxG.state.add(this.carSprite);
            FlxG.state.add(this.mainSprite);
            FlxG.state.add(this.collider);
            this.player_hud = new PlayerHud(this.driver_tag);
            this.player_hud.buildHud();
            FlxG.state.add(this.checkmark_sprite);
            this.impactParticles.addVisibleObjects();
            var i:int = 0;
        }

        public function addMeter():void {
            FlxG.state.add(this.completionIndicator);
            FlxG.state.add(this.no_date_text);
            FlxG.state.add(this.heart_sprite);
            FlxG.state.add(this.been_there);
            this.meter.addVisibleObjects();
        }

        public function get lastCheckpointIdx():Number {
            return this._lastCheckpointIdx;
        }

        public function get checkpoints_complete():Boolean {
            return this._checkpoints_complete;
        }

        public function get driver_name():String {
            return this._driver_name;
        }

        public function get checkpointStatusList():Array {
            return this._checkpointStatusList;
        }

        public function get winner():Boolean {
            return this._winner;
        }

        public function get race_started():Boolean {
            return this._race_started;
        }

        public function set race_started(v:Boolean):void {
            this._race_started = v;
        }

        public function completeCheckpoint():void {
            this.checking_in = false;
            this.meter.setVisible(false);
            if(this.curCheckpoint.cp_type != Checkpoint.HOME) {
                this.curCheckpoint.markComplete(this.idx);
                this.lastCompletedCheckpoint = this.curCheckpoint;
                this._checkpointStatusList[this.curCheckpoint.index] = true;
                this.checkmark_sprite.visible = true;
                this.checkmark_sprite.setPos(this.pos);
                this.checkmark_sprite.setDir(
                    this.player_hud.posOf(this.curCheckpoint.cp_type).sub(this.pos).normalized().mulScl(14));
                this.playHeart();
            }
            var checkpointsComplete:Boolean = true;
            for (var n:Number = 0; n < this._checkpointStatusList.length; n++) {
                if(n != this.curHomeInd) {
                    if(!this._checkpointStatusList[n]) {
                        checkpointsComplete = false;
                    }
                }
            }
            if(!checkpointsComplete) {
                curCheckpoint.playSfx();
            }
            if(this.curCheckpoint.cp_type != Checkpoint.HOME) {
                if(checkpointsComplete) {
                    this.lastCheckpointSound.play();
                    this._checkpoints_complete = true;
                    this.completionTime = this.curTime;
                    this.completionIndicator.visible = true;
                }
            }
            if(checkpointsComplete){
                if(curCheckpoint.cp_type == Checkpoint.HOME) {
                    this._winner = true;
                    this.completionIndicator.visible = false;
                }
            }
        }

        public function playHeart():void {
            this.heart_sprite.scale = new DHPoint(.1,.1);
            this.heart_sprite.visible = true;
            this.heart_scale_down = false;
            this.heart_sprite.setPos(this.pos);
            this.play_heart = true;
        }

        public function setVisitedNotification(c:Checkpoint):void {
            if(this._checkpointStatusList[c.index] && !this._showBeenThereList[c.index]) {
                this._showBeenThereList[c.index] = true;
            }
        }

        public function crossCheckpoint(checkpoint:Checkpoint, home_ind:Number):void {
            if(this._showBeenThereList[checkpoint.index] && !this.no_date_text.visible && !this._checkpoints_complete) {
                this.been_there.visible = true;
                this.been_there_timer = (this.curTime + 5) / 1000;
            }
            if (!this.checking_in) {
                if(!this._checkpoints_complete) {
                    if (!this._checkpointStatusList[checkpoint.index] && checkpoint.cp_type != Checkpoint.HOME)
                    {
                        if(this.passengers.length > 0) {
                            this.checkIn(checkpoint);
                            this.curCheckpoint = checkpoint;
                            this.curHomeInd = home_ind;
                        } else {
                            if(!this.been_there.visible) {
                                this.completionIndicator.visible = false;
                                this.no_date_text.visible = true;
                                this.no_date_text_timer = (this.curTime + 5) / 1000;
                            }
                        }
                    }
                } else {
                    if(checkpoint.cp_type == Checkpoint.HOME) {
                        if(this.passengers.length > 0) {
                            this.checkIn(checkpoint);
                            this.curCheckpoint = checkpoint;
                            this.curHomeInd = home_ind;
                        } else {
                            this.completionIndicator.visible = false;
                            this.no_date_text.visible = true;
                            this.no_date_text_timer = this.curTime + (5/1000);
                        }
                    }
                }
            }
        }


        public function checkIn(checkpoint:Checkpoint):void {
            this.meter.setVisible(true);
            this.checking_in = true;
            this.checkin_timelimit = this.checkpoints_complete ? 1 : 3;
            this.checkInTime = this.curTime;
        }

        public function checkOut():void {
            if(this.checking_in) {
                this.checking_in = false;
                this.meter.setVisible(false);
            }
        }

        override public function update():void {
            super.update();

            if(this.no_date_text.visible) {
                this.no_date_text.x = this.x;
                this.no_date_text.y = this.y - 30;
                if(this.no_date_text_timer < this.curTime) {
                    this.no_date_text.visible = false;
                    if (this.checkpoints_complete) {
                        this.completionIndicator.visible = true;
                    }
                }
            }
            if(this.been_there.visible) {
                this.been_there.x = this.pos.x;
                this.been_there.y = this.pos.y - 33;
                if(this.been_there_timer < this.curTime) {
                    this.been_there.visible = false;
                }
            }

            if (this.impactParticles != null) {
                this.impactParticles.update();
            }
            var p:int = 0;

            if(this.play_heart) {
                this.heart_sprite.setPos(new DHPoint(this.pos.x + 20, this.pos.y - 20));
                if(this.heart_sprite.scale.x >= 4) {
                    this.heart_scale_down = true;
                }
                if(!this.heart_scale_down) {
                    this.heart_sprite.scale.x += .06;
                    this.heart_sprite.scale.y += .06;
                } else if(this.heart_scale_down) {
                    this.heart_sprite.scale.x -= .06;
                    this.heart_sprite.scale.y -= .06;
                    if(this.heart_sprite.scale.x <= 0) {
                        this.play_heart = false;
                        this.heart_sprite.visible = false;
                    }
                }
            }

            this.swapPos.x = (this.m_physBody.GetPosition().x * m_physScale / 2) - this.mainSprite.width/2;
            this.swapPos.y = (this.m_physBody.GetPosition().y * m_physScale / 2) - this.mainSprite.height/2;
            this.setPos(this.swapPos);

            if(this.race_started) {
                if(this.driving) {
                    this.updateMovement();
                    this.updateDrivingAnimation();
                    if (this.controlType == CTRL_KEYBOARD_1 || this.controlType == CTRL_KEYBOARD_2) {
                        this.updateKeyboard(this.controlType);
                    }
                }
            } else {
                this.mainSprite.play("drive_down");
                this.carSprite.play("drive_down");
            }
            if(this.checking_in) {
                this.meter.setPos(this.pos.add(new DHPoint(30, -10), this.swapPos));
                this.meter.setPoints((((this.curTime - this.checkInTime)/1000)/this.checkin_timelimit)*100);

                if ((this.curTime - this.checkInTime) / 1000 >= this.checkin_timelimit) {
                    this.completeCheckpoint()
                }
            }

            if (this.checkmark_sprite.visible && this.lastCompletedCheckpoint != null) {
                if (this.checkmark_sprite.getPos().sub(
                        this.player_hud.posOf(
                            this.lastCompletedCheckpoint.cp_type))._length() < 10)
                {
                    this.checkmark_sprite.visible = false;
                    this.player_hud.markCheckpoint(this.lastCompletedCheckpoint.cp_type);
                }
            }
        }

        public function setFinished():void {
            this.completionIndicator.visible = false;
        }

        public function updateMovement():void {
            if (this.throttle) {
                this.accelSFX.play();
                var accelMul:Number = ACCELERATION_MULTIPLIER;
                if (this.directionsPressed.x != 0 || this.directionsPressed.y != 0) {
                    movementForce.x = this.directionsPressed.x * accelMul;
                    movementForce.y = this.directionsPressed.y * accelMul;
                } else {
                    movementForce.x = this.facingVector.x * accelMul;
                    movementForce.y = this.facingVector.y * accelMul;
                }
                if (this.bodyLinearVelocity._length() < MAX_VELOCITY) {
                    this.m_physBody.ApplyImpulse(movementForce, this.m_physBody.GetPosition())
                }
            }

            if(!this.throttle) {
                this.accelSFX.stop();
            }

            if (this._colliding) {
                if (this._collisionDirection != null) {
                    if (this._collisionDirection[0] == 1 &&
                        this._collisionDirection[1] == 1 &&
                        this._collisionDirection[2] == 1 &&
                        this._collisionDirection[3] == 1)
                    {
                        // stuck!
                    } else {
                        if (this._collisionDirection[1] == 1) {
                            // right
                            this.m_physBody.SetLinearVelocity(
                                new b2Vec2(
                                    Math.min(this.m_physBody.GetLinearVelocity().x, 0),
                                    this.m_physBody.GetLinearVelocity().y
                                )
                            );
                            this.m_physBody.ApplyImpulse(
                                new b2Vec2(-this.wallBounceAmount, 0),
                                this.m_physBody.GetPosition()
                            );
                        }
                        if (this._collisionDirection[0] == 1) {
                            // left
                            this.m_physBody.SetLinearVelocity(
                                new b2Vec2(
                                    Math.max(this.m_physBody.GetLinearVelocity().x, 0),
                                    this.m_physBody.GetLinearVelocity().y
                                )
                            );
                            this.m_physBody.ApplyImpulse(
                                new b2Vec2(wallBounceAmount, 0),
                                this.m_physBody.GetPosition()
                            );
                        }
                        if (this._collisionDirection[3] == 1) {
                            // down
                            this.m_physBody.SetLinearVelocity(
                                new b2Vec2(
                                    this.m_physBody.GetLinearVelocity().x,
                                    Math.min(this.m_physBody.GetLinearVelocity().y, 0)
                                )
                            );
                            this.m_physBody.ApplyImpulse(
                                new b2Vec2(0, -wallBounceAmount),
                                this.m_physBody.GetPosition()
                            );
                        }
                        if (this._collisionDirection[2] == 1) {
                            // up
                            this.m_physBody.SetLinearVelocity(
                                new b2Vec2(
                                    this.m_physBody.GetLinearVelocity().x,
                                    Math.max(this.m_physBody.GetLinearVelocity().y, 0)
                                )
                            );
                            this.m_physBody.ApplyImpulse(
                                new b2Vec2(0, wallBounceAmount),
                                this.m_physBody.GetPosition()
                            );
                        }
                    }
                }
            }
            this._collisionDirection[0] = 0;
            this._collisionDirection[1] = 0;
            this._collisionDirection[2] = 0;
            this._collisionDirection[3] = 0;
        }

        public function updateDrivingAnimation():void {
            if(Math.abs(this.directionsPressed.x) > Math.abs(this.directionsPressed.y)) {
                if(this.throttle) {
                    if(this.directionsPressed.x >= 0) {
                        this.mainSprite.play("drive_right");
                        this.carSprite.play("drive_right");
                        this.mainSprite.basePosOffset.x = this.mainSprite.width / 2;
                        this.mainSprite.basePosOffset.y = 3000;
                        this.facingVector.x = 1;
                        this.facingVector.y = 0;
                    } else {
                        this.mainSprite.play("drive_left");
                        this.carSprite.play("drive_left");
                        this.mainSprite.basePosOffset.x = this.mainSprite.width / 2;
                        this.mainSprite.basePosOffset.y = 1000;
                        this.facingVector.x = -1;
                        this.facingVector.y = 0;
                    }
                }
            } else if(Math.abs(this.directionsPressed.y) > Math.abs(this.directionsPressed.x)) {
                if(this.throttle) {
                    if(this.directionsPressed.y >= 0) {
                        this.mainSprite.play("drive_down");
                        this.carSprite.play("drive_down");
                        this.facingVector.y = 1;
                        this.facingVector.x = 0;
                    } else {
                        this.mainSprite.play("drive_up");
                        this.carSprite.play("drive_up");
                        this.facingVector.y = -1;
                        this.facingVector.x = 0;
                    }
                }
            }
        }

        public function updateKeyboard(ctrlType:Number=CTRL_KEYBOARD_1):void {
            if (FlxG.keys.justPressed(keyboardControls[ctrlType]['right'])) {
                this.directionsPressed.x = 1;
            } else if (FlxG.keys.justReleased(keyboardControls[ctrlType]['right'])){
                this.directionsPressed.x = 0;
            }
            if (FlxG.keys.justPressed(keyboardControls[ctrlType]['left'])) {
                this.directionsPressed.x = -1;
            } else if (FlxG.keys.justReleased(keyboardControls[ctrlType]['left'])){
                this.directionsPressed.x = 0;
            }

            if (FlxG.keys.justPressed(keyboardControls[ctrlType]['up'])) {
                this.directionsPressed.y = -1;
            } else if (FlxG.keys.justReleased(keyboardControls[ctrlType]['up'])){
                this.directionsPressed.y = 0;
            }
            if (FlxG.keys.justPressed(keyboardControls[ctrlType]['down'])) {
                this.directionsPressed.y = 1;
            } else if (FlxG.keys.justReleased(keyboardControls[ctrlType]['down'])){
                this.directionsPressed.y = 0;
            }

            if (FlxG.keys.justPressed(keyboardControls[ctrlType]['throttle'])) {
                this.throttle = true;
            } else if (FlxG.keys.justReleased(keyboardControls[ctrlType]['throttle'])) {
                this.throttle = false;
            }

            if (FlxG.keys.justPressed(keyboardControls[ctrlType]['highlight'])) {
                this.highlight_sprite.visible = true;
                this.highlight_number.visible = true;
                this.player_hud.highlight();
            } else if (FlxG.keys.justReleased(keyboardControls[ctrlType]['highlight'])) {
                this.highlight_sprite.visible = false;
                this.highlight_number.visible = false;
                this.player_hud.unhighlight();
            }
        }

        public function controllerChanged(control:Object,
                                          mapping:Object):void
        {
            if (this.controller == null || control['device'].id != this.controller.id) {
                return;
            }

            if (control['id'] == mapping["right"]["button"]) {
                if (control['value'] == mapping["right"]["value_off"]) {
                    this.directionsPressed.x = 0;
                    return;
                } else if (control['value'] == mapping["right"]["value_on"]) {
                    this.directionsPressed.x = 1;
                    return;
                }
            }
            if (control['id'] == mapping["left"]["button"]) {
                if (control['value'] == mapping["left"]["value_off"]) {
                    this.directionsPressed.x = 0;
                    return;
                } else if (control['value'] == mapping["left"]["value_on"]) {
                    this.directionsPressed.x = -1;
                    return;
                }
            }
            if (control['id'] == mapping["up"]["button"]) {
                if (control['value'] == mapping["up"]["value_off"]) {
                    this.directionsPressed.y = 0;
                    return;
                } else if (control['value'] == mapping["up"]["value_on"]){
                    this.directionsPressed.y = 1;
                    return;
                }
            }
            if (control['id'] == mapping["down"]["button"]) {
                if (control['value'] == mapping["down"]["value_off"]) {
                    this.directionsPressed.y = 0;
                    return;
                } else if(control['value'] == mapping["down"]["value_on"]) {
                    this.directionsPressed.y = -1;
                    return;
                }
            }
            if (control['id'] == mapping["a"]["button"]) {
                if (control['value'] == mapping["a"]["value_on"]) {
                    this.throttle = true;
                    return;
                } else if (control["value"] == mapping["a"]["value_off"]){
                    this.throttle = false;
                    return;
                }
            }
            if (control['id'] == mapping["b"]["button"]) {
                if (control['value'] == mapping["b"]["value_on"]) {
                    this.highlight_sprite.visible = true;
                    this.highlight_number.visible = true;
                    this.player_hud.highlight();
                    return;
                } else if (control["value"] == mapping["b"]["value_off"]){
                    this.highlight_sprite.visible = false;
                    this.highlight_number.visible = false;
                    this.player_hud.unhighlight();
                    return;
                }
            }
        }

        override public function getMiddle():DHPoint {
            return this.mainSprite.getMiddle();
        }

        override public function setPos(pos:DHPoint):void {
            super.setPos(pos);
            pos.x = Math.round(pos.x);
            pos.y = Math.round(pos.y);
            this.highlight_sprite.setPos(pos);
            this.highlight_number.x = pos.x + 64 / 2;
            this.highlight_number.y = pos.y + 64 + 3;
            this.mainSprite.setPos(pos);
            this.carSprite.setPos(pos);
            this.completionIndicator.x = pos.x - 15;
            this.completionIndicator.y = pos.y - 30;
            this.collider.setPos(pos.add(
                new DHPoint((this.mainSprite.width - this.collider.width) / 2,
                            this.mainSprite.height - this.collider.height), this.swapPos));

        }
    }
}
