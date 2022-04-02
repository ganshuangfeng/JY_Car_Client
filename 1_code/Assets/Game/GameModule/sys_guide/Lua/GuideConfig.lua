GuideConfig = {
	[1] = {
		step = 1,
		qp_des = "点击油门开启战车之旅",
		qp_pos = {x=93, y=-806, z=0},
		rw_pos = {x=-26, y=-871, z=0},
		ok_func = "ok",
	},
	[2] = {
		step = 2,
		sz_pos={x=345, y=-895, z=0},
		sz_des = "按住油门",
		target = "2DNode/Canvas/GUIRoot/DrivePanel/@down_node/DriveAccelerator",
		-- ok_func = "ok",
	},
	[3] = {
		step = 3,
		sz_pos={x=345, y=-895, z=0},
		sz_des = "松开起步",
		target = "2DNode/Canvas/GUIRoot/DrivePanel/@down_node/DriveAccelerator",
		-- ok_func = "ok",
	},
	[4] = {
		step = 4,
		qp_des = "小油门能使战车短距离行驶",
		qp_pos = {x=32, y=-806, z=0},
		rw_pos = {x=-70, y=-871, z=0},
		ok_func = "ok",
	},
	[5] = {
		step = 5,
		sz_pos={x=345, y=-895, z=0},
		sz_des = "按住油门",
		target = "2DNode/Canvas/GUIRoot/DrivePanel/@down_node/DriveAccelerator",
		-- ok_func = "ok",
	},
	[6] = {
		step = 6,
		sz_pos={x=345, y=-895, z=0},
		sz_des = "小油门时松开",
		target = "2DNode/Canvas/GUIRoot/DrivePanel/@down_node/DriveAccelerator",
		-- ok_func = "ok",
	},
	[7] = {
		step = 7,
	},
	[8] = {
		step = 8,
	},
	[9] = {
		step = 9,
		qp_des = "战车停留在该处可发动大招",
		qp_pos = {x=-173, y=-619, z=0},
		rw_pos = {x=-288, y=-684, z=0},
		ok_func = "ok",
	},
	[10] = {
		step = 10,
		qp_des = "击败对手或率先到达终点均可获得胜利",
		qp_pos = {x=-173, y=-619, z=0},
		rw_pos = {x=-288, y=-684, z=0},
		ok_func = "ok",
	},
	[11] = {
		step = 11,
		sz_pos={x=-400, y=-500, z=0},
		sz_des = "解锁宝箱",
		target = "Canvas/LayerLv1/HallPanel/@view_node/SysMatchPanel/@boxs/@box1",
		-- ok_func = "ok",
	},
	[12] = {
		step = 12,
		sz_pos={x=158, y=-259, z=0},
		target = "Canvas/LayerLv5/SysBoxOpenPanel/@use_time/@unlock_btn",
		-- ok_func = "ok",
	},
	[13] = {
		step = 13,
		sz_pos={x=-400, y=-500, z=0},
		sz_des = "开启宝箱",
		target = "Canvas/LayerLv1/HallPanel/@view_node/SysMatchPanel/@boxs/@box1",
		-- ok_func = "ok",
	},
	[14] = {
		step = 14,
		qp_des = "前往战车界面提升车辆性能",
		qp_pos = {x=-173, y=-619, z=0},
		rw_pos = {x=-288, y=-684, z=0},
		ok_func = "ok",
	},
	[15] = {
		step = 15,
		sz_pos={x=-418, y=-900, z=0},
		target = "Canvas/LayerLv1/HallPanel/@ui_node/@main_ui/@chariot",
		-- ok_func = "ok",
	},
	[16] = {
		step = 16,
		sz_pos={x=-366, y=37, z=0},
		target = "Canvas/LayerLv1/HallPanel/@view_node/SysCarUpgradePanel/@upgrade_btn",
		-- ok_func = "ok",
	},
	[17] = {
		step = 17,
		sz_pos={x=0, y=-900, z=0},
		target = "Canvas/LayerLv1/HallPanel/@ui_node/@main_ui/@match",
		-- ok_func = "ok",
	},
	[18] = {
		step = 18,
		qp_des = "新司机教学已结束，在段位赛中不断晋升吧！",
		qp_pos = {x=-253, y=-619, z=0},
		rw_pos = {x=-348, y=-684, z=0},
		ok_func = "ok",
	},
}