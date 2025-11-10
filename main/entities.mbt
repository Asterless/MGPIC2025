///|
pub fn add_cat(position : Vec2D, level : Int) -> Cat {
  let entity = Entity::new()
  let data = get_level_data(level)
  let velocity = @velocity.Velocity(Vec2D::zero())
  let picture = cat_picture(level)
  let cat_layer = get_cat_collision_layer(level)
  let collide : Collide = Collide::{
    shape: CollisionShape::Rect(
      size=Vec2D::new(data.size, data.size),
      offset=Vec2D::zero(),
    ),
    layer: cat_layer,
    mask: CollisionMask::new(cat_collision_mask_layers(level)),
  }
  let area : Area = Area::new(
    CollisionShape::Rect(
      size=Vec2D::new(data.size * 1.2, data.size * 1.2),
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
  let cat : Cat = { entity, level }
  cats_by_entity.set(entity, cat)
  global_p[entity] = position
  global_v[entity] = velocity
  global_c[entity] = collide
  global_a[entity] = area
  global_s[entity] = Sprite::new_picture(picture, 10) //Zindex 10 to be above the pointer
  cat
}
