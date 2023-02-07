extends Node


func floodfill(f_img,x,y,color):
	f_img.lock()
	var w = f_img.get_height()
	var h = f_img.get_width()
	var old_color = f_img.get_pixel(x,y)
	if color == old_color:
			return
	var queue = []
	queue.append(Vector2(x,y))
	while len(queue) > 0:
		var coords = queue.pop_back()
		x = coords.x
		y = coords.y
		if x < 0 or x > w or y < 0 or y>=h or f_img.get_pixel(x,y) != old_color:
			continue
		else:
			f_img.set_pixel(x,y,color)
			queue.append(Vector2(x,y+1))
			queue.append(Vector2(x,y-1))
			queue.append(Vector2(x+1,y))
			queue.append(Vector2(x-1,y))
