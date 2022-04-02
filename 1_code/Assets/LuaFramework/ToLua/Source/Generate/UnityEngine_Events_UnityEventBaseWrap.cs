﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_Events_UnityEventBaseWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.Events.UnityEventBase), typeof(System.Object));
		L.RegFunction("GetPersistentEventCount", GetPersistentEventCount);
		L.RegFunction("GetPersistentTarget", GetPersistentTarget);
		L.RegFunction("GetPersistentMethodName", GetPersistentMethodName);
		L.RegFunction("SetPersistentListenerState", SetPersistentListenerState);
		L.RegFunction("RemoveAllListeners", RemoveAllListeners);
		L.RegFunction("ToString", ToString);
		L.RegFunction("GetValidMethodInfo", GetValidMethodInfo);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPersistentEventCount(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.Events.UnityEventBase obj = (UnityEngine.Events.UnityEventBase)ToLua.CheckObject<UnityEngine.Events.UnityEventBase>(L, 1);
			int o = obj.GetPersistentEventCount();
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPersistentTarget(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Events.UnityEventBase obj = (UnityEngine.Events.UnityEventBase)ToLua.CheckObject<UnityEngine.Events.UnityEventBase>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Object o = obj.GetPersistentTarget(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPersistentMethodName(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Events.UnityEventBase obj = (UnityEngine.Events.UnityEventBase)ToLua.CheckObject<UnityEngine.Events.UnityEventBase>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			string o = obj.GetPersistentMethodName(arg0);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPersistentListenerState(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.Events.UnityEventBase obj = (UnityEngine.Events.UnityEventBase)ToLua.CheckObject<UnityEngine.Events.UnityEventBase>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Events.UnityEventCallState arg1 = (UnityEngine.Events.UnityEventCallState)LuaDLL.luaL_checknumber(L, 3);
			obj.SetPersistentListenerState(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveAllListeners(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.Events.UnityEventBase obj = (UnityEngine.Events.UnityEventBase)ToLua.CheckObject<UnityEngine.Events.UnityEventBase>(L, 1);
			obj.RemoveAllListeners();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ToString(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.Events.UnityEventBase obj = (UnityEngine.Events.UnityEventBase)ToLua.CheckObject<UnityEngine.Events.UnityEventBase>(L, 1);
			string o = obj.ToString();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetValidMethodInfo(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			object arg0 = ToLua.ToVarObject(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			System.Type[] arg2 = ToLua.CheckObjectArray<System.Type>(L, 3);
			System.Reflection.MethodInfo o = UnityEngine.Events.UnityEventBase.GetValidMethodInfo(arg0, arg1, arg2);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

