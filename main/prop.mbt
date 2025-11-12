///|
trait Prop {
  get_position(Self) -> Position?
  get_velocity(Self) -> Velocity?
  set_area(Self, Area) -> Unit
  set_collide(Self, Collide) -> Unit
  set_position(Self, Position) -> Unit
  set_sprite(Self, Sprite) -> Unit
  set_velocity(Self, Velocity) -> Unit
}

///|
impl Prop for Entity with get_position(self) -> Position? {
  global_position.get(self)
}

///|
impl Prop for Entity with get_velocity(self) -> Velocity? {
  global_velocity.get(self)
}

///|
impl Prop for Entity with set_area(self, area) -> Unit {
  global_area[self] = area
}

///|
impl Prop for Entity with set_collide(self, collide) -> Unit {
  global_collide[self] = collide
}

///|
impl Prop for Entity with set_position(self, position) -> Unit {
  global_position[self] = position
}

///|
impl Prop for Entity with set_sprite(self, sprite) -> Unit {
  global_sprite[self] = sprite
}

///|
impl Prop for Entity with set_velocity(self, velocity) -> Unit {
  global_velocity[self] = velocity
}
