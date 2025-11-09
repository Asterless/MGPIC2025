///|
pub const CANVAS_WIDTH : Double = 480.0

///|
pub const CANVAS_HEIGHT : Double = 600.0

///|
pub struct GameState {
  pointer_entity : @system.Entity
  mut pointer_sprite : @sprite.Sprite
  mut score : Int
  score_bar : @sprite.Text
  mut next_cat_level : Int
  to_merge : @hashset.HashSet[(@system.Entity, @system.Entity)]
  mut background_music_started : Bool
  cats_clicked : @hashset.HashSet[@system.Entity]
}

///|
/// Game state initialization
pub let game_state : GameState = {
  pointer_entity: @system.Entity::new(),
  pointer_sprite: @sprite.Sprite::new_picture(cat_picture(1), 10),
  score: 0,
  score_bar: @sprite.Text::new("", font="60px ThaleahFat", color="White"),
  next_cat_level: 1,
  to_merge: @hashset.HashSet::new(),
  background_music_started: false,
  cats_clicked: @hashset.HashSet::new(),
}

///|
pub struct Cat {
  entity : @system.Entity
  level : Int
}

///|
pub struct CatLevelData {
  size : Double
  path : String
  merge_score : Int
  sound : String
}

///|
pub let cat_level_config : Array[CatLevelData] = [
  {
    size: 32.0,
    path: "assets/Memes/cat_lv1_32x32.png",
    merge_score: 2,
    sound: "./assets/sounds/merge_lv1.wav",
  },
  {
    size: 48.0,
    path: "assets/Memes/cat_lv2_48x48.png",
    merge_score: 4,
    sound: "./assets/sounds/merge_lv2.wav",
  },
  {
    size: 64.0,
    path: "assets/Memes/cat_lv3_64x64.png",
    merge_score: 8,
    sound: "./assets/sounds/merge_lv3.wav",
  },
  {
    size: 80.0,
    path: "assets/Memes/cat_lv4_80x80.png",
    merge_score: 32,
    sound: "./assets/sounds/merge_lv4.wav",
  },
  {
    size: 96.0,
    path: "assets/Memes/cat_lv5_96x96.png",
    merge_score: 128,
    sound: "./assets/sounds/merge_lv5.wav",
  },
  {
    size: 112.0,
    path: "assets/Memes/cat_lv6_112x112.png",
    merge_score: 512,
    sound: "./assets/sounds/merge_lv6.wav",
  },
  {
    size: 128.0,
    path: "assets/Memes/cat_lv7_128x128.png",
    merge_score: 2042,
    sound: "./assets/sounds/merge_lv7.wav",
  },
  {
    size: 144.0,
    path: "assets/Memes/cat_lv8_144x144.png",
    merge_score: 4096,
    sound: "./assets/sounds/merge_lv8.wav",
  },
  {
    size: 160.0,
    path: "assets/Memes/cat_lv9_160x160.png",
    merge_score: 0,
    sound: "./assets/sounds/merge_lv9.wav",
  },
]

///|
pub let cats_by_entity : @hashmap.HashMap[@system.Entity, Cat] = @hashmap.HashMap::new()

///|
pub const POINTER_MAX_VELOCITY : Double = 7.5

///|
pub let pointer_collision_layer : @collision.CollisionLayer = @collision.CollisionLayer::new()

///|
pub let terrain_collision_layer : @collision.CollisionLayer = @collision.CollisionLayer::new()

///|
pub const GRAVITY : Double = 0.3

///|
pub const FRICTION : Double = 0.1

///|
pub let cat_collision_layers : Array[@collision.CollisionLayer] = [
  @collision.CollisionLayer::new(), // level 1
  @collision.CollisionLayer::new(), // level 2
  @collision.CollisionLayer::new(), // level 3
  @collision.CollisionLayer::new(), // level 4
  @collision.CollisionLayer::new(), // level 5
  @collision.CollisionLayer::new(), // level 6
  @collision.CollisionLayer::new(), // level 7
  @collision.CollisionLayer::new(), // level 8
  @collision.CollisionLayer::new(), // level 9
]
