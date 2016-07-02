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
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;
        [Embed(source="/../assets/images/ui/readysetgo.png")] private var StartSprite:Class;
        [Embed(source="/../assets/images/ui/timeout.png")] private var TimeOutSprite:Class;
        [Embed(source="/../assets/images/worlds/doggydonk_2.png")] private var DecorDogSprite:Class;
        [Embed(source="/../assets/images/worlds/makeoutBench_4.png")] private var DecorMakoutSprite:Class;
        [Embed(source="/../assets/images/worlds/tree_solo_1.png")] private var DecorTreeSprite:Class;
        [Embed(source="/../assets/images/worlds/clamFountain_3.png")] private var DecorClamSprite:Class;
        [Embed(source = "../assets/audio/bumrush_bgm_intro.mp3")] private var SndBGMIntro:Class;
        [Embed(source = "../assets/audio/bumrush_bgm_loop.mp3")] private var SndBGM:Class;
        [Embed(source = "../assets/audio/bumrush_success.mp3")] private var SfxEnd:Class;

        private var m_physScale:Number = 30
        private var listener:ContactListener;
        private var checkpoints:Array;
        private var decorations:Array;
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
        CONFIG::debug {
            private var cursorPosText:FlxText;
        }

        public var m_world:b2World;

        private var map_paths:Array = [
            "map_6",
            "map_7",
            "map_8",
            "map_3",
            "map_4",
            "map_5",
            "map_9",
            "map_10",
            "map_11"];
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
                    "pos": new DHPoint(.2, -.01),
                    "hitbox_pos": new DHPoint(.22, .2),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.8, .26),
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
                    "pos": new DHPoint(.4, .145),
                    "hitbox_pos": new DHPoint(.42, .35),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.5, .49),
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
                    "pos": new DHPoint(.09, .49),
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
                    "pos": new DHPoint(.55, .467),
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
                    "pos": new DHPoint(.7, .468),
                    "hitbox_pos": new DHPoint(.72, .695),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.1, -.01),
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
                    "pos": new DHPoint(.9, .02),
                    "hitbox_pos": new DHPoint(.92, .194),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.2, .02),
                    "hitbox_pos": new DHPoint(.22, .205),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.8, .02),
                    "hitbox_pos": new DHPoint(.82, .194),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.7, .01),
                    "hitbox_pos": new DHPoint(.72, .194),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.001, .03),
                    "hitbox_pos": new DHPoint(.02, .205),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.DINNER,
                    "pos": new DHPoint(.5, .04),
                    "hitbox_pos": new DHPoint(.455, .06),
                    "marker_rotation": 90
                }
            ],
            [
                {
                    "type": Checkpoint.HOME,
                    "pos": new DHPoint(.6, .155),
                    "hitbox_pos": new DHPoint(.62, .356),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.4, .15),
                    "hitbox_pos": new DHPoint(.42, .332),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.9, .005),
                    "hitbox_pos": new DHPoint(.92, .175),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.9, .49),
                    "hitbox_pos": new DHPoint(.92, .675),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.1, .16),
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
                    "pos": new DHPoint(.3, .167),
                    "hitbox_pos": new DHPoint(.32, .351),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.8, .2),
                    "hitbox_pos": new DHPoint(.82, .384),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.61, .01),
                    "hitbox_pos": new DHPoint(.625, .18),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.805, .52),
                    "hitbox_pos": new DHPoint(.752, .595),
                    "marker_rotation": 90
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.205, .165),
                    "hitbox_pos": new DHPoint(.165, .244),
                    "marker_rotation": 90
                },
                {
                    "type": Checkpoint.DINNER,
                    "pos": new DHPoint(.4, .23),
                    "hitbox_pos": new DHPoint(.42, .352),
                    "marker_rotation": 0
                }
            ],
            [
                {
                    "type": Checkpoint.HOME,
                    "pos": new DHPoint(.2, .01),
                    "hitbox_pos": new DHPoint(.221, .177),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.79, .4),
                    "hitbox_pos": new DHPoint(.745, .5),
                    "marker_rotation": 90
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.7, .01),
                    "hitbox_pos": new DHPoint(.721, .178),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.6, .48),
                    "hitbox_pos": new DHPoint(.62, .67),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.283, .333),
                    "hitbox_pos": new DHPoint(.244, .405),
                    "marker_rotation": 90
                },
                {
                    "type": Checkpoint.DINNER,
                    "pos": new DHPoint(.4, .53),
                    "hitbox_pos": new DHPoint(.425, .67),
                    "marker_rotation": 0
                }
            ],
            [
                {
                    "type": Checkpoint.HOME,
                    "pos": new DHPoint(.45, .1),
                    "hitbox_pos": new DHPoint(.471, .255),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.36, .595),
                    "hitbox_pos": new DHPoint(.45, .686),
                    "marker_rotation": -90
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.9, .45),
                    "hitbox_pos": new DHPoint(.85, .53),
                    "marker_rotation": 90
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.55, .3),
                    "hitbox_pos": new DHPoint(.57, .485),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.001, .45),
                    "hitbox_pos": new DHPoint(.09, .53),
                    "marker_rotation": -90
                },
                {
                    "type": Checkpoint.DINNER,
                    "pos": new DHPoint(.35, .36),
                    "hitbox_pos": new DHPoint(.38, .49),
                    "marker_rotation": 0
                }
            ],
            [
                {
                    "type": Checkpoint.HOME,
                    "pos": new DHPoint(.45, .28),
                    "hitbox_pos": new DHPoint(.471, .4),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.BOOZE,
                    "pos": new DHPoint(.18, .25),
                    "hitbox_pos": new DHPoint(.1, .46),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.MOVIES,
                    "pos": new DHPoint(.75, .34),
                    "hitbox_pos": new DHPoint(.65, .42),
                    "marker_rotation": 90
                },
                {
                    "type": Checkpoint.PARK,
                    "pos": new DHPoint(.7, .2),
                    "hitbox_pos": new DHPoint(.72, .45),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.CLUB,
                    "pos": new DHPoint(.05, .35),
                    "hitbox_pos": new DHPoint(.2, .43),
                    "marker_rotation": 0
                },
                {
                    "type": Checkpoint.DINNER,
                    "pos": new DHPoint(.3, .35),
                    "hitbox_pos": new DHPoint(.32, .46),
                    "marker_rotation": 0
                }
            ]
        ];
        private var decoration_types:Object = {
            "tree": {
                "graphic": DecorTreeSprite,
                "size": new DHPoint(24, 34),
                "anim_frames": [0],
                "framerate": .5
            },
            "dog": {
                "graphic": DecorDogSprite,
                "size": new DHPoint(30, 24),
                "anim_frames": [0, 1],
                "framerate": 7
            },
            "makeout": {
                "graphic": DecorMakoutSprite,
                "size": new DHPoint(116/4, 27),
                "anim_frames": [0, 1, 2, 3],
                "framerate": 7
            },
            "clam": {
                "graphic": DecorClamSprite,
                "size": new DHPoint(108/3, 35),
                "anim_frames": [0, 1, 2],
                "framerate": 7
            }
        };
        private var decorations_data:Array = [
            [
                {
                    "type": "dog",
                    "pos": new DHPoint(.609, .190)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.257, .628)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.714, .715)
                },
                {
                    "type": "clam",
                    "pos": new DHPoint(.148, .108)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.065, .271)
                },
                {
                    "type": "clam",
                    "pos": new DHPoint(.745, .307)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.737, .396)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.316, .09)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.346, .09)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.376, .09)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.691, .212)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.691, .262)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.691, .312)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.691, .362)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.277, .565)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.032, .262)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.709, .633)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.749, .633)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.789, .633)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.829, .633)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.869, .633)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.909, .633)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.949, .633)
                },
                //bottom row of trees
                {
                    "type": "tree",
                    "pos": new DHPoint(.045, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.095, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.195, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.245, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.295, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.345, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.395, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.445, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.495, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.545, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.595, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.645, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.695, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.745, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.795, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.845, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.895, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.945, .88)
                }
            ],
            [
                {
                    "type": "tree",
                    "pos": new DHPoint(.258, .229)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.298, .229)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.338, .229)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.258, .558)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.298, .558)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.338, .558)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.378, .558)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.895, .217)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.925, .227)
                },
                {
                    "type": "clam",
                    "pos": new DHPoint(.534, .239)
                },
                {
                    "type": "clam",
                    "pos": new DHPoint(.441, .561)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.196, .599)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.718, .419)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.223, .268)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.824, .229)
                },
                //bottom row of trees
                {
                    "type": "tree",
                    "pos": new DHPoint(.045, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.095, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.195, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.245, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.295, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.345, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.395, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.445, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.495, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.545, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.595, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.645, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.695, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.745, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.795, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.845, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.895, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.945, .88)
                }
            ],
            [
                {
                    "type": "tree",
                    "pos": new DHPoint(.173, .389)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.173, .439)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.173, .489)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.173, .539)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.173, .589)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.173, .539)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.307, .613)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.827, .628)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.069, .092)
                },
                {
                    "type": "clam",
                    "pos": new DHPoint(.559, .261)
                },
                {
                    "type": "clam",
                    "pos": new DHPoint(.211, .092)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.711, .275)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.110, .493)
                },
                //bottom row of trees
                {
                    "type": "tree",
                    "pos": new DHPoint(.045, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.095, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.195, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.245, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.295, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.345, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.395, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.445, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.495, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.545, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.595, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.645, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.695, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.745, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.795, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.845, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.895, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.945, .88)
                }
            ],
            [
                {
                    "type": "tree",
                    "pos": new DHPoint(.1, .07)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.16, .12)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.14, .22)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.26, .45)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.44, .30)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.61, .51)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.67, .51)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.48, .65)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.629, .124)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.105, .174)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.430, .575)
                },
                //bottom row of trees
                {
                    "type": "tree",
                    "pos": new DHPoint(.045, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.095, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.195, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.245, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.295, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.345, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.395, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.445, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.495, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.545, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.595, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.645, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.695, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.745, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.795, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.845, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.895, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.945, .88)
                }
            ],
            [
                {
                    "type": "makeout",
                    "pos": new DHPoint(.69, .28)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.19, .13)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.10, .46)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.15, .54)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.12, .63)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.31, .60)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.42, .55)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.85, .17)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.86, .63)
                },
                {
                    "type": "clam",
                    "pos": new DHPoint(.210, .257)
                },
                {
                    "type": "clam",
                    "pos": new DHPoint(.858, .250)
                },
                //bottom row of trees
                {
                    "type": "tree",
                    "pos": new DHPoint(.045, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.095, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.195, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.245, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.295, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.345, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.395, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.445, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.495, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.545, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.595, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.645, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.695, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.745, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.795, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.845, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.895, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.945, .88)
                }
            ],
            [
                {
                    "type": "tree",
                    "pos": new DHPoint(.42, .48)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.61, .30)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.88, .344)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.10, .68)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.09, .13)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.41, .15)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.47, .66)
                },
                {
                    "type": "clam",
                    "pos": new DHPoint(.23, .4)
                },
                //bottom row of trees
                {
                    "type": "tree",
                    "pos": new DHPoint(.045, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.095, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.195, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.245, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.295, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.345, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.395, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.445, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.495, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.545, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.595, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.645, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.695, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.745, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.795, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.845, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.895, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.945, .88)
                }
            ],
            [
                {
                    "type": "tree",
                    "pos": new DHPoint(.42, .48)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.61, .30)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.8, .344)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.3, .5)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.55, .13)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.41, .15)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.47, .46)
                },
                {
                    "type": "clam",
                    "pos": new DHPoint(.4, .4)
                },
                //bottom row of trees
                {
                    "type": "tree",
                    "pos": new DHPoint(.045, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.095, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.195, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.245, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.295, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.345, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.395, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.445, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.495, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.545, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.595, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.645, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.695, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.745, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.795, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.845, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.895, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.945, .88)
                }
            ],
            [
                {
                    "type": "tree",
                    "pos": new DHPoint(.42, .48)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.7, .2)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.3, .4)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.7, .4)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.55, .13)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.41, .15)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.47, .26)
                },
                //bottom row of trees
                {
                    "type": "tree",
                    "pos": new DHPoint(.045, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.095, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.195, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.245, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.295, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.345, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.395, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.445, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.495, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.545, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.595, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.645, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.695, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.745, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.795, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.845, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.895, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.945, .88)
                }
            ],
            [
                {
                    "type": "tree",
                    "pos": new DHPoint(.42, .48)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.7, .2)
                },
                {
                    "type": "makeout",
                    "pos": new DHPoint(.3, .4)
                },
                {
                    "type": "dog",
                    "pos": new DHPoint(.7, .4)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.55, .13)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.41, .15)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.47, .26)
                },
                //bottom row of trees
                {
                    "type": "tree",
                    "pos": new DHPoint(.045, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.095, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.145, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.195, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.245, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.295, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.345, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.395, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.445, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.495, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.545, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.595, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.645, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.695, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.745, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.795, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.845, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.895, .88)
                },
                {
                    "type": "tree",
                    "pos": new DHPoint(.945, .88)
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
            this.decorations = new Array();
            var checkpoint:Checkpoint, decoration:GameObject, decorConfig:Object;
            var i:Number = 0, curDecorInfo:Object;
            for(i = 0; i < this.checkpoints_data[this.active_map_index].length; i++) {
                checkpoint = new Checkpoint(
                    new DHPoint(-1000, -1000),
                    new DHPoint(20, 20),
                    this.checkpoints_data[this.active_map_index][i]["type"],
                    PlayersController.getInstance().getRegisteredPlayers()
                );
                this.checkpoints.push(checkpoint);
                if(this.checkpoints_data[this.active_map_index][i]["type"] == Checkpoint.HOME) {
                    this.home_cp_index = i;
                }
                checkpoint.setMarkerRotation(this.checkpoints_data[this.active_map_index][i]["marker_rotation"]);
                checkpoint.addVisibleObjects();
            }

            for(i = 0; i < this.decorations_data[this.active_map_index].length; i++) {
                curDecorInfo = this.decorations_data[this.active_map_index][i];
                decorConfig = this.decoration_types[curDecorInfo['type']];
                decoration = new GameObject(new DHPoint(-100, -100));
                decoration.loadGraphic(decorConfig['graphic'],
                                       true, false,
                                       decorConfig['size'].x,
                                       decorConfig['size'].y);
                decoration.zSorted = true;
                if (decorConfig['anim_frames'].length != 1) {
                    decoration.addAnimation("run", decorConfig['anim_frames'],
                                            decorConfig['framerate'], true);
                    decoration.play("run");
                }
                this.add(decoration);
                this.decorations.push(decoration);
            }

            this.start_sprite = new GameObject(new DHPoint(0,0));
            this.start_sprite.loadGraphic(this.StartSprite, true, false, 325, 117);
            this.start_sprite.addAnimation("play", [0,1,2], .5, false);
            this.start_sprite.visible = false;

            this.time_out_sprite = new GameObject(new DHPoint(0,0));
            this.time_out_sprite.loadGraphic(this.TimeOutSprite, false, false, 902, 204);
            this.time_out_sprite.visible = false;

            CONFIG::debug {
                this.cursorPosText = new FlxText(0, 0, 300, "");
                this.cursorPosText.setFormat("Pixel_Berry_08_84_Ltd.Edition",20,0xccffffff,"left");
            }

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
                            cur.setMarkerIconPos();
                        }

                        for(var i:int = 0; i < that.decorations.length; i++) {
                            curData = that.decorations_data[that.active_map_index][i];
                            that.decorations[i].setPos(
                                new DHPoint(
                                    event.userData['bg'].x + event.userData['bg'].width * curData['pos'].x,
                                    event.userData['bg'].y + event.userData['bg'].height * curData['pos'].y
                                )
                            );
                        }
                        that.setupWorld(event.userData['bg']);
                        PlayersController.getInstance().addRegisteredPlayers(
                            that.checkpoints, that.active_map_index,
                            that.m_world, that.groundBody, that.streetPoints);

                        CONFIG::debug {
                            FlxG.mouse.show();
                            FlxG.state.add(that.cursorPosText);
                        }
                    }

                    if (that.bgsLoaded >= 2) {
                        FlxG.stage.removeEventListener(
                            GameState.EVENT_SINGLETILE_BG_LOADED,
                            arguments.callee
                        );
                    }
                });

            this.startRaceTimer();
        }

        override public function update():void {
            super.update();

            CONFIG::debug {
                this.cursorPosText.x = FlxG.mouse.x + 50;
                this.cursorPosText.y = FlxG.mouse.y - 50;
                this.cursorPosText.text = ((FlxG.mouse.x - this.collider.x) / this.collider.width).toFixed(3) + " x " + ((FlxG.mouse.y - this.collider.y) / this.collider.height).toFixed(3);
            }

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

                if (this.finished) {
                    curPlayer.setFinished();
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
                if (FlxG.music != null) {
                    FlxG.music.stop();
                }
                FlxG.play(SfxEnd);
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
                wall.SetAsBox(curCheckpoint.checkpoint_sprite.width / m_physScale, (curCheckpoint.checkpoint_sprite.height * .8) / m_physScale);
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
