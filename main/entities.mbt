///|
struct Cat {
  entity : Entity
  level : Int
}

///|
fn add_cat(position : Vec2D, level : Int) -> Cat {
  let entity = Entity::new()
  let cat : Cat = { entity, level }
  let size = cat.size()
  let velocity = @velocity.Velocity(Vec2D::zero())
  let cat_layer = cat.collision_layer()
  let collide : Collide = Collide::{
    shape: CollisionShape::Rect(
      size=Vec2D::new(size, size),
      offset=Vec2D::zero(),
    ),
    layer: cat_layer,
    mask: CollisionMask::new(cat.collision_mask_layers()),
  }
  let area : Area = Area::new(
    CollisionShape::Rect(
      size=Vec2D::new(size * 1.2, size * 1.2),
      offset=Vec2D::zero(),
    ),
    cat_layer,
    CollisionMask::new([cat_collision_layers[level - 1]]),
    monitoring_mouse=true,
  )
  let self_entity = entity
  area.on_enter(fn(other : Entity) {
    // CRITICAL: Do not merge with yourself.
    if self_entity == other {
      return
    }
    game_state.to_merge.add((self_entity, other))
  })
  area.on_just_pressed(fn(_button : MouseButton) {
    game_state.cats_clicked.add(self_entity)
  })
  cats_by_entity.set(entity, cat)
  global_position[entity] = position
  global_velocity[entity] = velocity
  global_collides[entity] = collide
  global_areas[entity] = area
  global_sprites[entity] = Sprite::new_picture(cat.picture(), 10) //Zindex 10 to be above the pointer
  cat
}

///|
fn Cat::merge(self : Cat, other : Cat) -> Unit {
  set_score(game_state.score + self.merge_score())
  let p_cat_1 = global_position[self.entity].0
  let p_cat_2 = global_position[other.entity].0
  let cat_x = {
    let p_mid = (p_cat_1.x + p_cat_2.x) / 2.0
    let size = self.size() + 16.0
    if CANVAS_WIDTH - p_mid - 16.0 < size {
      CANVAS_WIDTH - 17.0 - size
    } else if p_mid - 16.0 < 0 {
      17.0 + size
    } else {
      p_mid
    }
  }
  let p_mid = Vec2D::{ x: cat_x, y: 0 }
  let merged = add_cat(p_mid, self.level + 1)
  global_velocity[merged.entity].y = 1000
  cats_by_entity.remove(self.entity)
  cats_by_entity.remove(other.entity)
  Entity::destroy(self.entity)
  Entity::destroy(other.entity)
}

///|
fn Cat::size(self : Cat) -> Double {
  Cat::size_by_level(self.level)
}

///|
fn Cat::size_by_level(level : Int) -> Double {
  (level - 1).to_double() * 16.0 + 32.0
}

///|
fn Cat::merge_score(self : Cat) -> Int {
  @math.pow(2.0, self.level.to_double()).to_int()
}

///|
fn Cat::picture(self : Cat) -> Picture {
  Cat::picture_by_level(self.level)
}

///|
fn Cat::picture_by_level(level : Int) -> Picture {
  let size = Cat::size_by_level(level)
  let size_vec = Vec2D::new(size, size)
  Picture::new(size_vec, "assets/Memes/cat_lv\{level}_\{size}x\{size}.png")
}

///|
fn Cat::sound(self : Cat) -> String {
  Cat::sound_by_level(self.level)
}

///|
fn Cat::sound_by_level(level : Int) -> String {
  "assets/Sounds/merge_lv\{level}.wav"
}

///|
fn Cat::collision_layer(self : Cat) -> CollisionLayer {
  let level = self.level
  if level > 0 && level <= cat_collision_layers.length() {
    cat_collision_layers[level - 1]
  } else {
    cat_collision_layers[0]
  }
}

///|
fn Cat::collision_mask_layers(self : Cat) -> Array[CollisionLayer] {
  let layers = Array::new()
  layers.push(terrain_collision_layer)
  for i = 0; i < cat_collision_layers.length(); i = i + 1 {
    // Corrected logic: Add all layers EXCEPT the current cat's own level.
    if i != self.level - 1 {
      layers.push(cat_collision_layers[i])
    }
  }
  layers
}
