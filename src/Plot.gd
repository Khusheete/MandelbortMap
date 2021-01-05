tool
extends ColorRect

signal image_generated(image)

export var resolution: Vector2 = Vector2(1024, 1024) setget set_resolution, get_resolution

#material of the fractal
#render material should at least have a "bounds" parameter
export var render_material: Material setget set_render_material, get_render_material

#position on the plane
export var plane_center: Vector2 = Vector2(-0.5, 0.0)
export var plane_min_size: float = 1.5

#gradient map
export var color_gradient: Gradient = preload("res://data/gradients/normal.tres") setget set_color_gradient, get_color_gradient

func set_render_material(mat: Material):
	#make material unique, so it does not replace base values of the original material
	if mat != null:
		render_material = mat.duplicate()
	else:
		render_material = null
	if has_node("Viewport"):
		$Viewport/Figure.material = render_material

func get_render_material() -> Material:
	return render_material



func set_resolution(res: Vector2):
	resolution = res
	if has_node("Viewport"):
		$Viewport.size = res


func get_resolution() -> Vector2:
	return resolution


func set_color_gradient(color_grad: Gradient):
	color_gradient = color_grad
	var shader_color_grad: GradientTexture = material.get_shader_param("color_gradient")
	shader_color_grad.gradient = color_grad

func get_color_gradient() -> Gradient:
	return color_gradient

func _ready():
	#set texture
	#due to a bug, this will throw an error
	var viewport_texture: ViewportTexture = $Viewport.get_texture()
	material.set_shader_param("tex", viewport_texture)


func _process(_delta: float):
	if render_material != null:
		render_material.set_shader_param("bounds", get_bounds())
	

#returns the bound of the figure
func get_bounds() -> Plane:
	var min_len: float = min(rect_size.x, rect_size.y)
	var plane_size: Vector2 = plane_min_size * rect_size / min_len
	return Plane(plane_center.x - plane_size.x, plane_center.y - plane_size.y, plane_center.x + plane_size.x, plane_center.y + plane_size.y)

func get_aspect_ratio() -> float:
	return rect_size.x / rect_size.y

#transforms the global position pos into position inside the figure
func transform_pos(pos: Vector2) -> Vector2:
	var local_pos: Vector2 = pos - rect_global_position
	var nlocal_pos = local_pos / rect_size
	
	var bounds: Plane = get_bounds()
	return Vector2(lerp(bounds.x, bounds.z, nlocal_pos.x), lerp(bounds.d, bounds.y, nlocal_pos.y))



#returns weather or not the point of global position pos is over this plot
func is_over(pos: Vector2) -> bool:
	return (pos - rect_global_position) < rect_size



func generate_image():
	#create viewport and render target
	var viewport: Viewport = Viewport.new()
	viewport.size = Vector2(resolution.x * get_aspect_ratio(), resolution.y)
	viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	var figure_render: ColorRect = ColorRect.new()
	figure_render.rect_size = viewport.size
	figure_render.material = material
	
	
	#add to scene tree
	viewport.add_child(figure_render)
	add_child(viewport)
	
	# Wait for content
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var image: Image = viewport.get_texture().get_data()
	
	remove_child(viewport)
	emit_signal("image_generated", image)
