///|
pub struct GameState {
  pointer_entity : Entity
  mut pointer_sprite : Sprite
  mut score : Int
  score_bar : Text
  mut next_cat_level : Int
  to_merge : HashSet[(Entity, Entity)]
  mut background_music_started : Bool
  cats_clicked : HashSet[Entity]
}

///|
/// Game state initialization
pub let game_state : GameState = {
  pointer_entity: Entity::new(),
  pointer_sprite: Sprite::new_picture(cat_picture(1), 10),
  score: 0,
  score_bar: Text::new("", font="60px ThaleahFat", color="White"),
  next_cat_level: 1,
  to_merge: HashSet::new(),
  background_music_started: false,
  cats_clicked: HashSet::new(),
}

///|
pub struct Cat {
  entity : Entity
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
pub let cats_by_entity : HashMap[Entity, Cat] = HashMap::new()

///|
pub let pointer_collision_layer : CollisionLayer = CollisionLayer::new()

///|
pub let terrain_collision_layer : CollisionLayer = CollisionLayer::new()

///|
pub let cat_collision_layers : Array[CollisionLayer] = [
  CollisionLayer::new(), // level 1
  CollisionLayer::new(), // level 2
  CollisionLayer::new(), // level 3
  CollisionLayer::new(), // level 4
  CollisionLayer::new(), // level 5
  CollisionLayer::new(), // level 6
  CollisionLayer::new(), // level 7
  CollisionLayer::new(), // level 8
  CollisionLayer::new(), // level 9
]
