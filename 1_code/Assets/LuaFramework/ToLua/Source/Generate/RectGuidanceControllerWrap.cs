﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class RectGuidanceControllerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(RectGuidanceController), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("SetTarget", SetTarget);
		L.RegFunction("ClearTaget", ClearTaget);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("Target", get_Target, set_Target);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetTarget(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				RectGuidanceController obj = (RectGuidanceController)ToLua.CheckObject<RectGuidanceController>(L, 1);
				UnityEngine.RectTransform arg0 = (UnityEngine.RectTransform)ToLua.CheckObject(L, 2, typeof(UnityEngine.RectTransform));
				bool arg1 = LuaDLL.luaL_checkboolean(L, 3);
				obj.SetTarget(arg0, arg1);
				return 0;
			}
			else if (count == 4)
			{
				RectGuidanceController obj = (RectGuidanceController)ToLua.CheckObject<RectGuidanceController>(L, 1);
				UnityEngine.RectTransform arg0 = (UnityEngine.RectTransform)ToLua.CheckObject(L, 2, typeof(UnityEngine.RectTransform));
				bool arg1 = LuaDLL.luaL_checkboolean(L, 3);
				float arg2 = (float)LuaDLL.luaL_checknumber(L, 4);
				obj.SetTarget(arg0, arg1, arg2);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: RectGuidanceController.SetTarget");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ClearTaget(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			RectGuidanceController obj = (RectGuidanceController)ToLua.CheckObject<RectGuidanceController>(L, 1);
			obj.ClearTaget();
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
	static int get_Target(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			RectGuidanceController obj = (RectGuidanceController)o;
			UnityEngine.RectTransform ret = obj.Target;
			ToLua.PushSealed(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Target on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_Target(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			RectGuidanceController obj = (RectGuidanceController)o;
			UnityEngine.RectTransform arg0 = (UnityEngine.RectTransform)ToLua.CheckObject(L, 2, typeof(UnityEngine.RectTransform));
			obj.Target = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Target on a nil value");
		}
	}
}

