extends VBoxContainer

var CHILDS:Array[Node]

func CHECK(NEW:Node):
	CHILDS.append(NEW)
	if CHILDS.size() > 9:
		CHILDS[0].queue_free()
		CHILDS.remove_at(0)
