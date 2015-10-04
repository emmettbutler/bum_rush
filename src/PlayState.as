package {
    import org.flixel.*;
    import org.flixel.plugin.photonstorm.FlxCollision;

    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.Joints.*;

    import flash.display.Sprite;

    public class PlayState extends GameState {
        [Embed(source="/../assets/images/ui/readysetgo.png")] private var StartSprite:Class;
        [Embed(source="/../assets/images/ui/timeout.png")] private var TimeOutSprite:Class;
        [Embed(source = "../assets/audio/bumrush_bgm_intro.mp3")] private var SndBGMIntro:Class;
        [Embed(source = "../assets/audio/bumrush_bgm_loop.mp3")] private var SndBGM:Class;

        private var m_physScale:Number = 30
        private var listener:ContactListener;
        private var checkpoints:Array;
        private var start_sprite:GameObject, time_out_sprite:GameObject;
        private var started_race:Boolean = false, shown_start_anim:Boolean = false, finished:Boolean = false;
        private var raceTimeAlive:Number, raceEndTimer:Number;
        private var collider:FlxExtSprite;
        private var bgsLoaded:Number = 0;
        private var streetPoints:Array;
        private var shouldDebugDraw:Boolean = false;
        private var bgmStarted:Boolean, bgmLoopStarted:Boolean;
        private static const RACE_LENGTH:Number = 60;
        private var shown_instructions:Boolean = false;

        public var m_world:b2World;

        private var map_paths:Array = [
            "map_6",
            "map_7",
            "map_8",
            "map_3",
            "map_4",
            "map_5"];
        private var checkpoints_data:Array = [
            [
                {
                    "type": Checkpoint.HOME,
                    "pos": new DHPoint(.49, .18),
                    "hitbox_pos": new DHPoint(.443, .245),
                    "marker_rotation": 90
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.2, .005),
                    "hitbox_pos": new DHPoint(.22, .2),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.8, .28),
                    "hitbox_pos": new DHPoint(.82, .465),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.3, .48),
                    "hitbox_pos": new DHPoint(.32, .68),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.004, .32),
                    "hitbox_pos": new DHPoint(.025, .5),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.DINNER,
                    "pos": new DHPoint(.5, .53),
                    "hitbox_pos": new DHPoint(.525, .68),
                    "marker_rotation": 0
                }
            ],
            [
                {
                    "type": Checkpoint.HOME,
                    "pos": new DHPoint(.7, .2),
                    "hitbox_pos": new DHPoint(.64, .27),
                    "marker_rotation": 90
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.4, .16),
                    "hitbox_pos": new DHPoint(.42, .35),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.5, .50),
                    "hitbox_pos": new DHPoint(.52, .6955),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.865, .02),
                    "hitbox_pos": new DHPoint(.817, .079),
                    "marker_rotation": 90
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.09, .51),
                    "hitbox_pos": new DHPoint(.11, .6955),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.DINNER,
                    "pos": new DHPoint(.1, .20),
                    "hitbox_pos": new DHPoint(.13, .35),
                    "marker_rotation": 0
                }
            ],
            [
                {
                    "type": Checkpoint.HOME,
                    "pos": new DHPoint(.26, .4),
                    "hitbox_pos": new DHPoint(.35, .469),
                    "marker_rotation": -90
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.55, .5),
                    "hitbox_pos": new DHPoint(.57, .695),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.6, .15),
                    "hitbox_pos": new DHPoint(.619, .341),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.7, .5),
                    "hitbox_pos": new DHPoint(.72, .695),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.1, .01),
                    "hitbox_pos": new DHPoint(.12, .2),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.DINNER,
                    "pos": new DHPoint(.35, .19),
                    "hitbox_pos": new DHPoint(.378, .341),
                    "marker_rotation": 0
                }
            ],
            [
                {
                    "type": Checkpoint.HOME,
                    "pos": new DHPoint(.9, .01),
                    "hitbox_pos": new DHPoint(.92, .18),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.2, .05),
                    "hitbox_pos": new DHPoint(.22, .22),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.8, .01),
                    "hitbox_pos": new DHPoint(.82, .18),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.7, .01),
                    "hitbox_pos": new DHPoint(.72, .19),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.001, .06),
                    "hitbox_pos": new DHPoint(.02, .225),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.DINNER,
                    "pos": new DHPoint(.5, .05),
                    "hitbox_pos": new DHPoint(.455, .06),
                    "marker_rotation": 90
                }
            ],
            [
                {
                    "type": Checkpoint.HOME,
                    "pos": new DHPoint(.6, .2),
                    "hitbox_pos": new DHPoint(.62, .365),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.4, .16),
                    "hitbox_pos": new DHPoint(.42, .325),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.9, .02),
                    "hitbox_pos": new DHPoint(.92, .185),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.9, .5),
                    "hitbox_pos": new DHPoint(.92, .676),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.1, .17),
                    "hitbox_pos": new DHPoint(.12, .332),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.DINNER,
                    "pos": new DHPoint(.29, .21),
                    "hitbox_pos": new DHPoint(.32, .341),
                    "marker_rotation": 0
                }
            ],
            [
                {
                    "type": Checkpoint.HOME,
                    "pos": new DHPoint(.3, .2),
                    "hitbox_pos": new DHPoint(.32, .3721),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.8, .2),
                    "hitbox_pos": new DHPoint(.82, .3785),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.6, .01),
                    "hitbox_pos": new DHPoint(.62, .18),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.8, .52),
                    "hitbox_pos": new DHPoint(.751, .59),
                    "marker_rotation": 90
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.2, .17),
                    "hitbox_pos": new DHPoint(.154, .245),
                    "marker_rotation": 90
                },
                {
                    "type": Checkpoint.DINNER,
                    "pos": new DHPoint(.4, .23),
                    "hitbox_pos": new DHPoint(.42, .352),
                    "marker_rotation": 0
                }
            ]
        ];
        private var active_map_index:Number;
        private var home_cp_index:Number;
        private var groundBody:b2Body;

        public function PlayState(map:Number) {
            this.active_map_index = map;
        }

        override public function create():void {
            super.create();

            var pathPrefix:String = "../assets/images/worlds/maps/";
            this.collider = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + this.map_paths[this.active_map_index] + "_collider.png");
            ScreenManager.getInstance().loadSingleTileBG(pathPrefix + this.map_paths[this.active_map_index] + ".png");
            this.gameActive = true;

            this.checkpoints = new Array();
            var checkpoint:Checkpoint;
            var i:Number = 0;
            for(i = 0; i < this.checkpoints_data[this.active_map_index].length; i++) {
                checkpoint = new Checkpoint(
                    new DHPoint(-1000, -1000),
                    new DHPoint(20, 20),
                    this.checkpoints_data[this.active_map_index][i]["type"]
                );
                this.checkpoints.push(checkpoint);
                if(this.checkpoints_data[this.active_map_index][i]["type"] == Checkpoint.HOME) {
                    this.home_cp_index = i;
                }
                checkpoint.setMarkerRotation(this.checkpoints_data[this.active_map_index][i]["marker_rotation"]);
            }

            this.start_sprite = new GameObject(new DHPoint(0,0));
            this.start_sprite.loadGraphic(this.StartSprite, true, false, 325, 117);
            this.start_sprite.addAnimation("play", [0,1,2], .5, false);
            this.start_sprite.visible = false;

            this.time_out_sprite = new GameObject(new DHPoint(0,0));
            this.time_out_sprite.loadGraphic(this.TimeOutSprite, false, false, 902, 204);
            this.time_out_sprite.visible = false;

            var that:PlayState = this;
            FlxG.stage.addEventListener(GameState.EVENT_SINGLETILE_BG_LOADED,
                function(event:DHDataEvent):void {
                    that.bgsLoaded += 1;

                    if (event.userData['bg'] == that.collider) {
                        that.buildStreetGrid(event.userData['bg']);
                        var cur:Checkpoint, curData:Object;

                        that.start_sprite.setPos(new DHPoint(event.userData['bg'].x + event.userData['bg'].width * .4, event.userData['bg'].y + event.userData['bg'].height * .4));
                        that.time_out_sprite.setPos(new DHPoint(event.userData['bg'].x + event.userData['bg'].width * .15, event.userData['bg'].y + event.userData['bg'].height * .3));

                        for(var p:Number = 0; p < that.checkpoints.length; p++) {
                            curData = that.checkpoints_data[that.active_map_index][p];
                            var cp_pos:DHPoint = curData["pos"];
                            cur = that.checkpoints[p];
                            cur.setPos(new DHPoint(
                                event.userData['bg'].x + event.userData['bg'].width * curData["hitbox_pos"].x,
                                event.userData['bg'].y + event.userData['bg'].height * curData["hitbox_pos"].y
                            ));
                            cur.setImgPos(new DHPoint(
                                event.userData['bg'].x + event.userData['bg'].width * cp_pos.x,
                                event.userData['bg'].y + event.userData['bg'].height * cp_pos.y
                            ));
                            cur.index = p;
                        }
                        that.setupWorld(event.userData['bg']);
                        PlayersController.getInstance().addRegisteredPlayers(
                            that.checkpoints.length, that.active_map_index,
                            that.m_world, that.groundBody, that.streetPoints);
                    }

                    if (that.bgsLoaded >= 2) {
                        FlxG.stage.removeEventListener(
                            GameState.EVENT_SINGLETILE_BG_LOADED,
                            arguments.callee
                        );
                    }
                });

            for (i = 0; i < this.checkpoints.length; i++) {
                this.checkpoints[i].addVisibleObjects();
            }

            this.startRaceTimer();
        }

        override public function update():void {
            super.update();

            if (this.m_world != null) {
                this.m_world.Step(1.0 / 30.0, 8, 8);
                if (this.shouldDebugDraw) {
                    m_world.DrawDebugData();
                }
            }

            if (!this.bgmLoopStarted && this.raceTimeAlive / 1000 >= 1 + 6) {
                this.bgmLoopStarted = true;
                FlxG.playMusic(SndBGM, 1);
            }

            this.raceTimeAlive = this.curTime - this.raceBornTime;
            if(this.raceTimeAlive/1000 > 1) {
                if(!this.started_race) {
                    this.shown_instructions = true;
                }
            }
            if(this.raceTimeAlive/1000 > 1) {
                if(!this.started_race && this.shown_instructions) {
                    if(!this.shown_start_anim) {
                        FlxG.state.add(this.start_sprite);
                        FlxG.state.add(this.time_out_sprite);
                        this.start_sprite.visible = true;
                        this.start_sprite.play("play");
                        this.shown_start_anim = true;
                        if (FlxG.music != null) {
                            FlxG.music.stop();
                        }
                        FlxG.play(SndBGMIntro, 1);
                    }

                    if(this.start_sprite.finished) {
                        this.start_sprite.visible = false;
                        this.started_race = true;
                        var players_list:Array;
                        players_list = PlayersController.getInstance().getPlayerList();
                        for(var p:Number = 0; p < players_list.length; p++) {
                            players_list[p].race_started = true;
                            players_list[p].driving = true;
                        }
                    }
                }
            }

            if (FlxG.keys.justPressed("H")) {
                this.shouldDebugDraw = !this.shouldDebugDraw;
            }

            if(this.finished) {
                if(this.raceEndTimer <= this.raceTimeAlive/1000) {
                    FlxG.switchState(new EndState());
                }
            }

            var colliders:Array = PlayersController.getInstance().getPlayerColliders(),
                checkpoint:Checkpoint, curPlayer:Player, curCollider:GameObject,
                k:int, collisionData:Array;
            for (var i:int = 0; i < colliders.length; i++) {
                curCollider = colliders[i];
                curPlayer = curCollider.parent as Player;
                curPlayer.colliding = false;

                var n:int;
                var overlappingCheckpoint:Boolean = false;
                for (n = 0; n < this.checkpoints.length; n++) {
                    checkpoint = this.checkpoints[n];
                    if (curCollider._getRect().overlaps(checkpoint._getRect())) {
                        this.overlapPlayerCheckpoints(curPlayer, checkpoint);
                        overlappingCheckpoint = true;
                    } else {
                        curPlayer.setVisitedNotification(checkpoint);
                    }
                }
                if(!overlappingCheckpoint && !this.finished) {
                    curPlayer.checkOut();
                }

                collisionData = FlxCollision.pixelPerfectCheck(
                    curCollider, this.collider, 255, null, curPlayer.collisionDirection, false);
                if (collisionData[0]) {
                    curPlayer.colliding = collisionData[0];
                }
            }
        }

        override public function destroy():void {
            super.destroy();
        }

        public function endRace():void {
            if(!this.finished) {
                this.raceEndTimer = (this.raceTimeAlive/1000) + 3;
                this.finished = true;
                this.time_out_sprite.visible = true;
                this.gameActive = false;
            }
        }

        public function overlapPlayerCheckpoints(player:Player,
                                                 checkpoint:Checkpoint):void
        {
            if(!this.finished) {
                player.crossCheckpoint(checkpoint, this.home_cp_index);
            }
            if(player.winner) {
                this.endRace();
            }
        }

        private function setupWorld(bg:FlxSprite):void{
            var gravity:b2Vec2 = new b2Vec2(0, 0);
            m_world = new b2World(gravity, true);

            listener = new ContactListener();
            m_world.SetContactListener(listener);

            var dbgDraw:b2DebugDraw = new b2DebugDraw();
            var dbgSprite:Sprite = new Sprite();
            FlxG.stage.addChild(dbgSprite);
            dbgDraw.SetSprite(dbgSprite);
            dbgDraw.SetDrawScale(30 / 2);
            dbgDraw.SetFillAlpha(0.3);
            dbgDraw.SetLineThickness(1.0);
            dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
            m_world.SetDebugDraw(dbgDraw);

            var ground:b2PolygonShape = new b2PolygonShape();
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            var groundBd:b2BodyDef = new b2BodyDef();

            groundBd.position.Set(0, 0);
            ground.SetAsBox(10 / m_physScale, 10 / m_physScale);
            groundBody = m_world.CreateBody(groundBd);
            fixtureDef.shape = ground;
            groundBody.CreateFixture2(ground);

            // Create border of boxes
            var wall:b2PolygonShape= new b2PolygonShape();
            var wallBd:b2BodyDef = new b2BodyDef();
            wallBd.type = b2Body.b2_staticBody;
            var wallB:b2Body;

            // Left
            wallBd.position.Set((bg.x - (100 - bg.width * .01)) / m_physScale, (bg.y + bg.height) / m_physScale);
            wall.SetAsBox(100 / m_physScale, bg.height / m_physScale);
            wallB = m_world.CreateBody(wallBd);
            wallB.CreateFixture2(wall);
            // Right
            wallBd.position.Set((bg.x + bg.width * 2 + (100 - bg.width * .01)) / m_physScale, (bg.y + bg.height) / m_physScale);
            wallB = m_world.CreateBody(wallBd);
            wallB.CreateFixture2(wall);
            // Top
            wallBd.position.Set((bg.x + bg.width) / m_physScale, ((bg.y - bg.height * .06) / m_physScale));
            wall.SetAsBox(bg.width / m_physScale, 100 / m_physScale);
            wallB = m_world.CreateBody(wallBd);
            wallB.CreateFixture2(wall);
            // Bottom
            wallBd.position.Set((bg.x + bg.width) / m_physScale, (bg.y + bg.height * 1.9) / m_physScale);
            wallB = m_world.CreateBody(wallBd);
            wallB.CreateFixture2(wall);

            var curCheckpoint:Checkpoint;
            for(var p:Number = 0; p < this.checkpoints.length; p++) {
                curCheckpoint = this.checkpoints[p];
                wallBd.position.Set((curCheckpoint.checkpoint_sprite.x + curCheckpoint.checkpoint_sprite.width / 2) / m_physScale * 2,
                                    (curCheckpoint.checkpoint_sprite.y + curCheckpoint.checkpoint_sprite.height / 2) / m_physScale * 2);
                wall.SetAsBox(curCheckpoint.checkpoint_sprite.width / m_physScale, curCheckpoint.checkpoint_sprite.height / m_physScale);
                wallB = m_world.CreateBody(wallBd);
                wallB.CreateFixture2(wall);
            }
        }

        private function buildStreetGrid(collider:FlxExtSprite):void {
            /*
             * Assemble an array of non-collidable map points
             */
            this.streetPoints = new Array();
            var cols:int = 40, rows:int = 30, xCoord:Number, yCoord:Number;
            var collideTester:FlxSprite, collisionData:Array;

            for (var i:int = 0; i < cols; i++) {
                xCoord = collider.x + i * (collider.width / cols);
                for (var k:int = 0; k < rows; k++) {
                    yCoord = collider.y + k * (collider.height / rows);
                    collideTester = new FlxSprite(xCoord, yCoord);
                    collideTester.makeGraphic(
                        collider.width / cols,
                        collider.height / rows,
                        0xffff0000
                    );
                    FlxG.state.add(collideTester);
                    collisionData = FlxCollision.pixelPerfectCheck(
                        collideTester, collider, 255, null, null, false);
                    if (!collisionData[0]) {
                        this.streetPoints.push(new DHPoint(
                            xCoord + collideTester.width / 2,
                            yCoord + collideTester.height / 2
                        ));
                    }
                    FlxG.state.remove(collideTester);
                }
            }
        }
    }
}
