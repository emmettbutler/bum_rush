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
        [Embed(source="/../assets/sfx/drive.mp3")] private var SfxAccel:Class;
        [Embed(source="/../assets/sfx/donk.mp3")] private var SfxEnd:Class;
        [Embed(source="/../assets/car_p1_64.png")] private var ImgCar:Class;

        public static const COLLISION_TAG:String = "car_thing";

        private var m_physScale:Number = 30
        private var m_physBody:b2Body,
                    m_groundBody:b2Body;
        private var m_world:b2World;
        private var driver_sprite:Class;
        private var carSprite:GameObject;
        private var parking_anim:GameObject;
        private var mainSprite:GameObject;
        private var collider:GameObject;
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
        private var completionIndicator:FlxText;
        private var _driver_name:String;
        private var driver_tag:Number, frameRate:Number = 12,
                    _checkpoints_completed:Number = 0,
                    completionTime:Number = -1,
                    checkInTime:Number = 0;
        private var _checkpoints_complete:Boolean = false,
                    _winner:Boolean = false;
        private var _lastCheckpointIdx:Number = 0;
        private var player_hud:PlayerHud;
        private var _driving:Boolean = false;
        private var checking_in:Boolean = false;
        private var lastPassengerRemoveTime:Number = 0;
        private var passengerRemoveThreshold:Number = 1;
        private var curCheckpoint:Checkpoint;
        private var curHomeInd:Number;
        private var meter:Meter;
        private var streetPoints:Array;
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
                'throttle': "SPACE"
            };
            keyboardControls[CTRL_KEYBOARD_2] = {
                'up': "I",
                'down': "K",
                'left': "J",
                'right': "L",
                'throttle': "P"
            };
        }

        private var controlType:Number = CTRL_PAD;
        private var accelSFX:FlxSound;
        private var lastCheckpointSound:FlxSound;

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
            this._checkpointStatusList = new Array();

            this.passengers = new Array();

            this.addAnimations();

            this.accelSFX = new FlxSound();
            this.accelSFX.loadEmbedded(SfxAccel, true);
            this.accelSFX.volume = .1;

            this.lastCheckpointSound = new FlxSound();
            this.lastCheckpointSound.loadEmbedded(SfxEnd, false);
            this.lastCheckpointSound.volume = .1;

            this.completionIndicator = new FlxText(this.pos.x, this.pos.y - 30, 200, "");
            this.completionIndicator.setFormat(null, 20, 0xffff0000, "center");

            this._checkpointStatusList = new Array();

            for(var i:Number = 0; i < checkpoint_count; i++) {
                this._checkpointStatusList.push(false);
            }

            this.collider = new GameObject(new DHPoint(0, 0), this);
            this.collider.makeGraphic(this.mainSprite.width,
                                      this.mainSprite.height * .5,
                                      0xffffff00,
                                      true);
            this.collider.visible = false;

            this.setupPhysics();

            this._collisionDirection = new Array(0, 0, 0, 0);
            this.meter = new Meter(this.pos, 100, 50, 10);
        }

        public function getFacingVector():DHPoint {
            return this.facingVector;
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
            }
        }

        public function addPassenger(passenger:Passenger):void {
            if (passenger.driver != null) {
                return;
            }
            passenger.enterCar(this);
            this.passengers.push(passenger);
            passenger.idx = this.passengers.indexOf(passenger);
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
            jointDef.maxForce = 6;
            jointDef.maxTorque = 5;
            jointDef.collideConnected = true;
            m_world.CreateJoint(jointDef as b2JointDef);
        }

        public function addAnimations():void {
            this.carSprite = new GameObject(this.pos);
            this.carSprite.zSorted = true;
            this.carSprite.loadGraphic(ImgCar, false, false, 64, 64);
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
                this.mainSprite.height * 2
            );
            this.mainSprite.addAnimation("drive_right", [0,1,2,3], this.frameRate, true);
            this.mainSprite.addAnimation("drive_up", [4,5,6,7], this.frameRate, true);
            this.mainSprite.addAnimation("drive_down", [8,9,10,11], this.frameRate, true);
            this.mainSprite.addAnimation("drive_left", [12,13,14,15], this.frameRate, true);
            this.mainSprite.play("drive_down");

            this.parking_anim = new GameObject(new DHPoint(this.x, this.y));
            this.parking_anim.loadGraphic(
                PlayersController.getInstance().playerConfigs[driver_tag]["parking_anim"],
                false, false, 244, 26);
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
            FlxG.state.add(this.carSprite);
            FlxG.state.add(this.mainSprite);
            FlxG.state.add(this.parking_anim);
            this.parking_anim.visible = false;
            FlxG.state.add(this.completionIndicator);
            FlxG.state.add(this.collider);
            this.player_hud = new PlayerHud(this.driver_tag);
            this.player_hud.buildHud();
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

        public function completeCheckpoint():void {
            this.checking_in = false;
            this.parking_anim.visible = false;
            this.meter.setVisible(false);

            if(this.curCheckpoint.cp_type != Checkpoint.HOME) {
                var checkpointsComplete:Boolean = true;
                this._checkpointStatusList[this.curCheckpoint.index] = true;
                this._checkpoints_completed += 1;
                this.player_hud.finishedCheckpoint(this.curCheckpoint.cp_type);

                curCheckpoint.playSfx();
            }

            for (var n:Number = 0; n < this._checkpointStatusList.length; n++) {
                if(n != this.curHomeInd) {
                    if(!this._checkpointStatusList[n]) {
                        checkpointsComplete = false;
                    }
                }
            }

            if(this.curCheckpoint.cp_type != Checkpoint.HOME) {
                if(checkpointsComplete) {
                    this._checkpoints_complete = true;
                    this.completionTime = this.curTime;
                    this.completionIndicator.text = "Checkpoints complete!";
                }
            }

        }

        public function crossCheckpoint(checkpoint:Checkpoint, home_ind:Number):void {
            if(!this._checkpoints_complete && !this.checking_in) {
                if (!this._checkpointStatusList[checkpoint.index] && checkpoint.cp_type != Checkpoint.HOME)
                {
                    this.checkIn(checkpoint);
                    this.curCheckpoint = checkpoint;
                    this.curHomeInd = home_ind;
                }
            } else if(this._checkpoints_complete && !this.checking_in){
                if(checkpoint.cp_type == Checkpoint.HOME) {
                    this._winner = true;
                    this.lastCheckpointSound.play();
                }
            }
        }


        public function checkIn(checkpoint:Checkpoint):void {
            this.meter.setVisible(true);
            this.checking_in = true;
            this.parking_anim.visible = true;
            this.checkInTime = this.curTime;
        }

        public function checkOut():void {
            if(this.checking_in) {
                this.checking_in = false;
                this.parking_anim.visible = false;
                this.meter.setVisible(false);
            }
        }

        override public function update():void {
            super.update();

            this.setPos(new DHPoint((this.m_physBody.GetPosition().x * m_physScale / 2) - this.mainSprite.width/2,
                                    (this.m_physBody.GetPosition().y * m_physScale / 2) - this.mainSprite.height/2));

            this.updateMovement();
            if(this.driving) {
                this.updateDrivingAnimation();
                if (this.controlType == CTRL_KEYBOARD_1 || this.controlType == CTRL_KEYBOARD_2) {
                    this.updateKeyboard(this.controlType);
                }

                if ((this.curTime - this.completionTime) / 1000 >= 2) {
                    this.completionIndicator.text = "";
                }
            }
            if(this.checking_in) {
                this.meter.setPos(this.pos);
                this.parking_anim.x = this.mainSprite.x;
                this.parking_anim.y = this.mainSprite.y;
                this.meter.setPoints((((this.curTime - this.checkInTime)/1000)/3)*100);

                if ((this.curTime - this.checkInTime) / 1000 >= 3) {
                    this.completeCheckpoint()
                }
            }
        }

        public function updateMovement():void {
            if (this.throttle) {
                this.accelSFX.play();
                var force:b2Vec2, accelMul:Number = .65;
                if (this.directionsPressed.x != 0 || this.directionsPressed.y != 0) {
                    force = new b2Vec2(this.directionsPressed.x * accelMul, this.directionsPressed.y * accelMul);
                } else {
                    force = new b2Vec2(this.facingVector.x * accelMul, this.facingVector.y * accelMul);
                }
                if (this.m_physBody.GetAngularVelocity() < 1) {
                    this.m_physBody.ApplyImpulse(force, this.m_physBody.GetPosition())
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
                        } else if (this._collisionDirection[0] == 1) {
                            // left
                            this.m_physBody.SetLinearVelocity(
                                new b2Vec2(
                                    Math.max(this.m_physBody.GetLinearVelocity().x, 0),
                                    this.m_physBody.GetLinearVelocity().y
                                )
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
                        } else if (this._collisionDirection[2] == 1) {
                            // up
                            this.m_physBody.SetLinearVelocity(
                                new b2Vec2(
                                    this.m_physBody.GetLinearVelocity().x,
                                    Math.max(this.m_physBody.GetLinearVelocity().y, 0)
                                )
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
                        this.facingVector.x = 1;
                        this.facingVector.y = 0;
                    } else {
                        this.mainSprite.play("drive_left");
                        this.carSprite.play("drive_left");
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
                } else if (control['value'] == mapping["right"]["value_on"]) {
                    this.directionsPressed.x = 1;
                }
            }
            if (control['id'] == mapping["left"]["button"]) {
                if (control['value'] == mapping["left"]["value_off"]) {
                    this.directionsPressed.x = 0;
                } else if (control['value'] == mapping["left"]["value_on"]) {
                    this.directionsPressed.x = -1;
                }
            }
            if (control['id'] == mapping["up"]["button"]) {
                if (control['value'] == mapping["up"]["value_off"]) {
                    this.directionsPressed.y = 0;
                } else if (control['value'] == mapping["up"]["value_on"]){
                    this.directionsPressed.y = 1;
                }
            }
            if (control['id'] == mapping["down"]["button"]) {
                if (control['value'] == mapping["down"]["value_off"]) {
                    this.directionsPressed.y = 0;
                } else if(control['value'] == mapping["down"]["value_on"]) {
                    this.directionsPressed.y = -1;
                }
            }
            if (control['id'] == mapping["a"]["button"]) {
                if (control['value'] == mapping["a"]["value_on"]) {
                    this.throttle = true;
                } else if (control["value"] == mapping["a"]["value_off"]){
                    this.throttle = false;
                }
            }
        }

        override public function getMiddle():DHPoint {
            return this.mainSprite.getMiddle();
        }

        override public function setPos(pos:DHPoint):void {
            super.setPos(pos);
            this.mainSprite.setPos(pos);
            this.carSprite.setPos(pos);
            this.completionIndicator.x = pos.x;
            this.completionIndicator.y = pos.y;
            this.collider.setPos(pos);
            this.collider.setPos(pos.add(
                new DHPoint(0,
                            this.mainSprite.height - this.collider.height)));

        }
    }
}
