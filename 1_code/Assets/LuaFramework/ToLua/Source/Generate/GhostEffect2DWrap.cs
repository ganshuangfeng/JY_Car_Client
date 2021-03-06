//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class GhostEffect2DWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(GhostEffect2D), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("openGhoseEffect", get_openGhoseEffect, set_openGhoseEffect);
		L.RegVar("openFade", get_openFade, set_openFade);
		L.RegVar("durationTime", get_durationTime, set_durationTime);
		L.RegVar("spawnTimeval", get_spawnTimeval, set_spawnTimeval);
		L.RegVar("ghostColor", get_ghostColor, set_ghostColor);
		L.RegVar("ghostSortingOrder", get_ghostSortingOrder, set_ghostSortingOrder);
		L.RegVar("ghostGameObject", get_ghostGameObject, set_ghostGameObject);
		L.EndClass();
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
	static int get_openGhoseEffect(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			bool ret = obj.openGhoseEffect;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index openGhoseEffect on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_openFade(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			bool ret = obj.openFade;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index openFade on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_durationTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			float ret = obj.durationTime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index durationTime on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_spawnTimeval(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			float ret = obj.spawnTimeval;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index spawnTimeval on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ghostColor(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			UnityEngine.Color ret = obj.ghostColor;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ghostColor on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ghostSortingOrder(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			int ret = obj.ghostSortingOrder;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ghostSortingOrder on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ghostGameObject(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			UnityEngine.GameObject ret = obj.ghostGameObject;
			ToLua.PushSealed(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ghostGameObject on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_openGhoseEffect(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.openGhoseEffect = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index openGhoseEffect on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_openFade(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.openFade = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index openFade on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_durationTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.durationTime = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index durationTime on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_spawnTimeval(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.spawnTimeval = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index spawnTimeval on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ghostColor(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			UnityEngine.Color arg0 = ToLua.ToColor(L, 2);
			obj.ghostColor = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ghostColor on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ghostSortingOrder(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.ghostSortingOrder = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ghostSortingOrder on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ghostGameObject(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GhostEffect2D obj = (GhostEffect2D)o;
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 2, typeof(UnityEngine.GameObject));
			obj.ghostGameObject = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ghostGameObject on a nil value");
		}
	}
}

