///|
const CANVAS_WIDTH : Double = 480.0

///|
const CANVAS_HEIGHT : Double = 600.0

///|
struct GameState {
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
let game_state : GameState = {
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
struct Cat {
  entity : @system.Entity
  level : Int
}

///|
struct CatLevelData {
  size : Double
  path : String
  merge_score : Int
  sound : String
}

///|
let cat_level_config : Array[CatLevelData] = [
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
let cats_by_entity : @hashmap.HashMap[@system.Entity, Cat] = @hashmap.HashMap::new()

///|
fn main {
  @system.App::new(@canvas.CanvasBackend::new())
  .with_canvas_width(CANVAS_WIDTH)
  .with_canvas_height(CANVAS_HEIGHT)
  .with_fps(60)
  .add_plugin(@plugins.default_plugin)
  // .add_plugin(@plugins.debug_plugin)
  .add_system(input_system)
  .add_system(force_system)
  .add_system(merge_system)
  .add_system(play_sound_system)
  .add_initializer(game_start)
  .run()
}

///|
fn game_start(_backend : &@system.Backend) -> Unit {
  add_pointer()
  for x = 0.0; x < CANVAS_WIDTH; x = x + 16.0 {
    add_bottom(@math.Vec2D::new(x, CANVAS_HEIGHT - 16.0))
  }
  for x = 0.0; x < CANVAS_HEIGHT; x = x + 16.0 * 3.0 {
    add_side_walls(@math.Vec2D::new(0, x))
    add_side_walls(@math.Vec2D::new(CANVAS_WIDTH - 16.0, x))
  }
  add_background()
  add_score_bar()
}

///|
fn add_pointer() -> Unit {
  @position.positions[game_state.pointer_entity] = @math.Vec2D::new(
    CANVAS_WIDTH / 2.0,
    80.0,
  )
  let velocity = @math.Vec2D::new(0.0, 0.0)
  @velocity.velocities[game_state.pointer_entity] = velocity
  @sprite.sprites[game_state.pointer_entity] = game_state.pointer_sprite
}

///|
fn add_bottom(pos : @math.Vec2D) -> Unit {
  let entity = @system.Entity::new()
  @position.positions[entity] = pos
  let animation = @sprite.Animation::new(
    "./assets/Terrain/Terrain (16x16).png",
    max_frame=1,
    height=16,
    width=16,
    offset=@math.Vec2D::new(16.0 * 7, 0.0),
  )
  let sprite = @sprite.Sprite::new_animation(animation, 20)
  @sprite.sprites[entity] = sprite
  let collide : @collision.Collide = @collision.Collide::{
    shape: @collision.CollisionShape::Rect(
      size=@math.Vec2D::new(16.0, 16.0),
      offset=@math.Vec2D::new(0.0, 0.0),
    ),
    layer: terrain_collision_layer,
    mask: @collision.CollisionMask::empty(),
  }
  @collision.collides[entity] = collide
}

///|
fn add_side_walls(pos : @math.Vec2D) -> Unit {
  let animation = @sprite.Animation::new(
    "./assets/Terrain/Terrain (16x16).png",
    max_frame=1,
    height=16 * 3,
    width=16,
    offset=@math.Vec2D::new(16.0 * 15, 0.0),
  )
  // Left Wall
  let wall = @system.Entity::new()
  @position.positions[wall] = pos
  let left_collide : @collision.Collide = @collision.Collide::{
    shape: @collision.CollisionShape::Rect(
      size=@math.Vec2D::new(16.0, 16.0),
      offset=@math.Vec2D::zero(),
    ),
    layer: terrain_collision_layer,
    mask: @collision.CollisionMask::new([pointer_collision_layer]),
  }
  @sprite.sprites[wall] = @sprite.Sprite::new_animation(animation, 5)
  @collision.collides[wall] = left_collide
}

///|
const POINTER_MAX_VELOCITY : Double = 7.5

///|
let pointer_collision_layer : @collision.CollisionLayer = @collision.CollisionLayer::new()

///|
let terrain_collision_layer : @collision.CollisionLayer = @collision.CollisionLayer::new()

///|
fn input_system(backend : &@system.Backend) -> Unit {
  let new_velocity = @velocity.velocities
    .get(game_state.pointer_entity)
    .unwrap()
  // Move pointer
  if @system.is_pressed(@system.Code::KeyA) {
    // Move left
    if new_velocity.x > -POINTER_MAX_VELOCITY {
      new_velocity.x -= 2.5
    }
  } else if @system.is_pressed(@system.Code::KeyD) {
    // Move right
    if new_velocity.x < POINTER_MAX_VELOCITY {
      new_velocity.x += 2.5
    }
  } else {
    new_velocity.x = 0.0
  }
  // Move Cats
  if @system.is_just_pressed(@system.Code::KeyQ) {
    for pair in cats_by_entity {
      let (entity, _cat) = pair
      @velocity.velocities[entity].x = -4.0 / _cat.level.to_double()
    }
  } else if @system.is_just_pressed(@system.Code::KeyE) {
    for pair in cats_by_entity {
      let (entity, cat) = pair
      @velocity.velocities[entity].x = 4.0 / cat.level.to_double()
    }
  }
  if @system.is_just_pressed(@system.Code::Space) {
    // Start background music on first interaction
    if !game_state.background_music_started {
      backend.play_audio(
        "./assets/Sounds/background_music.wav",
        volume=0.2,
        loop_=true,
      )
      game_state.background_music_started = true
    }
    // Release cat
    let position = @position.positions[game_state.pointer_entity].0
    let _ = add_cat(position, game_state.next_cat_level)
    game_state.next_cat_level = random_cat_level()
    game_state.pointer_sprite = @sprite.Sprite::new_picture(
      cat_picture(game_state.next_cat_level),
      10,
    )
    backend.play_audio("./assets/sounds/jump.wav", volume=1.0, loop_=false)
  }
  @velocity.velocities[game_state.pointer_entity] = new_velocity
  let collide : @collision.Collide = @collision.Collide::{
    shape: @collision.CollisionShape::Rect(
      size=@math.Vec2D::new(32.0, 32.0),
      offset=@math.Vec2D::new(0.0, 0.0),
    ),
    layer: pointer_collision_layer,
    mask: @collision.CollisionMask::new([terrain_collision_layer]),
  }
  @sprite.sprites[game_state.pointer_entity] = game_state.pointer_sprite
  @collision.collides[game_state.pointer_entity] = collide
}

///|
fn add_background() -> Unit {
  let entity = @system.Entity::new()
  let picture = @sprite.Picture::new(
    @math.Vec2D::new(CANVAS_WIDTH, CANVAS_HEIGHT),
    "./assets/Background/Brown.png",
    repeat=true,
  )
  let sprite = @sprite.Sprite::new_picture(picture, 0)
  @sprite.sprites[entity] = sprite
  @position.positions[entity] = @math.Vec2D::zero()
}

///|
fn add_score_bar() -> Unit {
  set_score(0)
  let entity = @system.Entity::new()
  @position.positions[entity] = @math.Vec2D::new(
    CANVAS_WIDTH / 2 - 200.0,
    CANVAS_HEIGHT * 0.10,
  )
  let sprite = @sprite.Sprite::new_text(game_state.score_bar, 5)
  @sprite.sprites[entity] = sprite
  let entity_2 = @system.Entity::new()
  @position.positions[entity_2] = @math.Vec2D::new(
    CANVAS_WIDTH / 2 - 120.0,
    CANVAS_HEIGHT * 0.30,
  )
  let entity_3 = @system.Entity::new()
  @position.positions[entity_3] = @math.Vec2D::new(
    CANVAS_WIDTH / 2 - 120.0,
    CANVAS_HEIGHT * 0.40,
  )
  let text = @sprite.Text::new(
    "Pause A/D to move",
    font="30px ThaleahFat",
    color="Gray",
  )
  let text2 = @sprite.Text::new(
    "Pause Q/E to switch",
    font="30px ThaleahFat",
    color="Gray",
  )
  let optional_sprite_2 = @sprite.Sprite::new_text(text, 5)
  @sprite.sprites[entity_2] = optional_sprite_2
  let optional_sprite_3 = @sprite.Sprite::new_text(text2, 5)
  @sprite.sprites[entity_3] = optional_sprite_3
}

///|
fn set_score(score : Int) -> Unit {
  game_state.score = score
  game_state.score_bar.content = "Score: " + game_state.score.to_string()
}

///|
fn merge_system(backend : &@system.Backend) -> Unit {
  let merged_this_frame = @hashset.HashSet::new() // Guard against multiple merges in one frame
  for pair in game_state.to_merge {
    let (cat1_entity, cat2_entity) = pair
    if merged_this_frame.contains(cat1_entity) ||
      merged_this_frame.contains(cat2_entity) {
      continue // if either cat has already been merged this frame, skip
    }
    let cat1_opt = cats_by_entity.get(cat1_entity)
    let cat2_opt = cats_by_entity.get(cat2_entity)
    if cat1_opt is Some(_) && cat2_opt is Some(_) {
      let cat1 = cat1_opt.unwrap()
      let cat2 = cat2_opt.unwrap()
      // Mark as merged
      merged_this_frame.add(cat1_entity)
      merged_this_frame.add(cat2_entity)
      // Get sound from config
      let sound_path = get_level_data(cat1.level + 1).sound
      // Perform merge
      cat1.merge(cat2)
      backend.play_audio(sound_path, volume=0.8, loop_=false)
    }
  }
  // Clear the merge list
  game_state.to_merge.clear()
}

///|
const GRAVITY : Double = 0.3

///|
///
const FRICTION : Double = 0.1

///|
fn force_system(_backend : &@system.Backend) -> Unit {
  for pair in cats_by_entity {
    let (entity, _cat) = pair
    @velocity.velocities[entity].y += GRAVITY // Gravity
    @velocity.velocities[entity].x *= 1.0 - FRICTION // Friction
    if @velocity.velocities[entity].x < 0.01 && @velocity.velocities[entity].x > -0.01 {
      @velocity.velocities[entity].x = 0.0
    }
  }
}

///|
fn Cat::merge(self : Cat, other : Cat) -> Unit {
  set_score(game_state.score + cat_level_config[self.level].merge_score)
  let position = @position.positions[self.entity].0
  let pos_add = @math.Vec2D::new(
    0.0,
    -(cat_level_config[self.level].size / 2.0),
  )
  let _ = add_cat(position + pos_add, self.level + 1)
  cats_by_entity.remove(self.entity)
  cats_by_entity.remove(other.entity)
  @system.Entity::destroy(self.entity)
  @system.Entity::destroy(other.entity)
}

///|
pub fn add_cat(position : @math.Vec2D, level : Int) -> Cat {
  let entity = @system.Entity::new()
  let data = get_level_data(level)
  let velocity = @velocity.Velocity(@math.Vec2D::zero())
  let picture = cat_picture(level)
  let cat_layer = get_cat_collision_layer(level)
  let collide : @collision.Collide = @collision.Collide::{
    shape: @collision.CollisionShape::Rect(
      size=@math.Vec2D::new(data.size, data.size),
      offset=@math.Vec2D::zero(),
    ),
    layer: cat_layer,
    mask: @collision.CollisionMask::new(cat_collision_mask_layers(level)),
  }
  let area : @collision.Area = @collision.Area::new(
    @collision.CollisionShape::Rect(
      size=@math.Vec2D::new(data.size * 1.2, data.size * 1.2),
      offset=@math.Vec2D::zero(),
    ),
    cat_layer,
    @collision.CollisionMask::new([cat_collision_layers[level - 1]]),
    monitoring_mouse=true,
  )
  let self_entity = entity
  area.on_enter(fn(other : @system.Entity) {
    // CRITICAL: Do not merge with yourself.
    if self_entity == other {
      return
    }
    game_state.to_merge.add((self_entity, other))
  })
  area.on_just_pressed(fn(_button : @system.MouseButton) {
    game_state.cats_clicked.add(self_entity)
  })
  let cat : Cat = { entity, level }
  cats_by_entity.set(entity, cat)
  @position.positions[entity] = position
  @velocity.velocities[entity] = velocity
  @collision.collides[entity] = collide
  @collision.areas[entity] = area
  @sprite.sprites[entity] = @sprite.Sprite::new_picture(picture, 10) //Zindex 10 to be above the pointer
  cat
}

///|
pub fn get_level_data(level : Int) -> CatLevelData {
  let index = if level > 0 && level <= cat_level_config.length() {
    level - 1
  } else {
    0 // Default to level 1 data
  }
  cat_level_config[index]
}

///|
pub fn cat_picture(level : Int) -> @sprite.Picture {
  let data = get_level_data(level)
  let size_vec = @math.Vec2D::new(data.size, data.size)
  @sprite.Picture::new(size_vec, data.path)
}

///|
pub fn cat_size(level : Int) -> Double {
  get_level_data(level).size
}

///|
pub fn random_cat_level() -> Int {
  // Use the global random generator instead of creating a new one.
  let roll = game_state.score % 10
  let value = if roll < 0 { roll + 10 } else { roll }
  if value < 5 {
    // 0-49: 50% chance
    1
  } else if value < 7 {
    // 50-84: 35% chance
    2
  } else if value < 9 {
    // 85-94: 10% chance
    3
  } else {
    // 95-99: 5% chance
    4
  }
}

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

///|
pub fn get_cat_collision_layer(level : Int) -> @collision.CollisionLayer {
  if level > 0 && level <= cat_collision_layers.length() {
    cat_collision_layers[level - 1]
  } else {
    cat_collision_layers[0]
  }
}

///|
pub fn cat_collision_mask_layers(
  level : Int,
) -> Array[@collision.CollisionLayer] {
  let layers = Array::new()
  layers.push(terrain_collision_layer)
  for i = 0; i < cat_collision_layers.length(); i = i + 1 {
    // Corrected logic: Add all layers EXCEPT the current cat's own level.
    if i != level - 1 {
      layers.push(cat_collision_layers[i])
    }
  }
  layers
}

///|
fn play_sound_system(backend : &@system.Backend) -> Unit {
  for cat_entity in game_state.cats_clicked {
    let cat_opt = cats_by_entity.get(cat_entity)
    if cat_opt is Some(_) {
      let cat = cat_opt.unwrap()
      let sound_path = get_level_data(cat.level).sound
      backend.play_audio(sound_path, volume=1.0, loop_=false)
    }
  }
  game_state.cats_clicked.clear()
}
