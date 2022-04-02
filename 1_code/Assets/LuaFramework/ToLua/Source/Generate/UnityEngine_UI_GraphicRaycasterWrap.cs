﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_UI_GraphicRaycasterWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.UI.GraphicRaycaster), typeof(UnityEngine.EventSystems.BaseRaycaster));
		L.RegFunction("Raycast", Raycast);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("sortOrderPriority", get_sortOrderPriority, null);
		L.RegVar("renderOrderPriority", get_renderOrderPriority, null);
		L.RegVar("ignoreReversedGraphics", get_ignoreReversedGraphics, set_ignoreReversedGraphics);
		L.RegVar("blockingObjects", get_blockingObjects, set_blockingObjects);
		L.RegVar("eventCamera", get_eventCamera, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Raycast(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.UI.GraphicRaycaster obj = (UnityEngine.UI.GraphicRaycaster)ToLua.CheckObject<UnityEngine.UI.GraphicRaycaster>(L, 1);
			UnityEngine.EventSystems.PointerEventData arg0 = (UnityEngine.EventSystems.PointerEventData)ToLua.CheckObject<UnityEngine.EventSystems.PointerEventData>(L, 2);
			System.Collections.Generic.List<UnityEngine.EventSystems.RaycastResult> arg1 = (System.Collections.Generic.List<UnityEngine.EventSystems.RaycastResult>)ToLua.CheckObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.EventSystems.RaycastResult>));
			obj.Raycast(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sortOrderPriority(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.UI.GraphicRaycaster obj = (UnityEngine.UI.GraphicRaycaster)o;
			int ret = obj.sortOrderPriority;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index sortOrderPriority on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_renderOrderPriority(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.UI.GraphicRaycaster obj = (UnityEngine.UI.GraphicRaycaster)o;
			int ret = obj.renderOrderPriority;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index renderOrderPriority on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ignoreReversedGraphics(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.UI.GraphicRaycaster obj = (UnityEngine.UI.GraphicRaycaster)o;
			bool ret = obj.ignoreReversedGraphics;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ignoreReversedGraphics on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_blockingObjects(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.UI.GraphicRaycaster obj = (UnityEngine.UI.GraphicRaycaster)o;
			UnityEngine.UI.GraphicRaycaster.BlockingObjects ret = obj.blockingObjects;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index blockingObjects on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_eventCamera(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.UI.GraphicRaycaster obj = (UnityEngine.UI.GraphicRaycaster)o;
			UnityEngine.Camera ret = obj.eventCamera;
			ToLua.PushSealed(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index eventCamera on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ignoreReversedGraphics(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.UI.GraphicRaycaster obj = (UnityEngine.UI.GraphicRaycaster)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.ignoreReversedGraphics = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ignoreReversedGraphics on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_blockingObjects(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.UI.GraphicRaycaster obj = (UnityEngine.UI.GraphicRaycaster)o;
			UnityEngine.UI.GraphicRaycaster.BlockingObjects arg0 = (UnityEngine.UI.GraphicRaycaster.BlockingObjects)LuaDLL.luaL_checknumber(L, 2);
			obj.blockingObjects = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index blockingObjects on a nil value");
		}
	}
}

