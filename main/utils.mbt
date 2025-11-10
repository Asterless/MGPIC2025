///|
pub fn set_score(score : Int) -> Unit {
  game_state.score = score
  game_state.score_bar.content = "Score: " + game_state.score.to_string()
}

///|
pub fn Cat::merge(self : Cat, other : Cat) -> Unit {
  let l = self.level
  set_score(game_state.score + get_level_data(l).merge_score)
  let p_cat_1 = global_p[self.entity].0
  let p_cat_2 = global_p[other.entity].0
  let cat_x = {
    let p_mid = (p_cat_1.x + p_cat_2.x) / 2.0
    let size = cat_size(l + 1)
    if CANVAS_WIDTH - p_mid - 16.0 < size {
      CANVAS_WIDTH - 17.0 - size
    } else if p_mid - 16.0 < 0 {
      17.0 + size
    } else {
      p_mid
    }
  }
  let p_mid = Vec2D::{ x: cat_x, y: 0 }
  let merged = add_cat(p_mid, l + 1)
  global_v[merged.entity].y = 1000
  cats_by_entity.remove(self.entity)
  cats_by_entity.remove(other.entity)
  Entity::destroy(self.entity)
  Entity::destroy(other.entity)
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
pub fn cat_picture(level : Int) -> Picture {
  let data = get_level_data(level)
  let size_vec = Vec2D::new(data.size, data.size)
  Picture::new(size_vec, data.path)
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
pub fn get_cat_collision_layer(level : Int) -> CollisionLayer {
  if level > 0 && level <= cat_collision_layers.length() {
    cat_collision_layers[level - 1]
  } else {
    cat_collision_layers[0]
  }
}

///|
pub fn cat_collision_mask_layers(level : Int) -> Array[CollisionLayer] {
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
