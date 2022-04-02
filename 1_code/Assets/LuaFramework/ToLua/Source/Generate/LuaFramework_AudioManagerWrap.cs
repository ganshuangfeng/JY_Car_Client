﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LuaFramework_AudioManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LuaFramework.AudioManager), typeof(Manager));
		L.RegFunction("GetIsShakeOn", GetIsShakeOn);
		L.RegFunction("SetIsShakeOn", SetIsShakeOn);
		L.RegFunction("GetIsSoundOn", GetIsSoundOn);
		L.RegFunction("SetIsSoundOn", SetIsSoundOn);
		L.RegFunction("GetIsMusicOn", GetIsMusicOn);
		L.RegFunction("SetIsMusicOn", SetIsMusicOn);
		L.RegFunction("GetIsCenterOn", GetIsCenterOn);
		L.RegFunction("SetIsCenterOn", SetIsCenterOn);
		L.RegFunction("GetCenterVolume", GetCenterVolume);
		L.RegFunction("SetCenterVolume", SetCenterVolume);
		L.RegFunction("GetMusicVolume", GetMusicVolume);
		L.RegFunction("SetMusicVolume", SetMusicVolume);
		L.RegFunction("GetSoundVolume", GetSoundVolume);
		L.RegFunction("SetSoundVolume", SetSoundVolume);
		L.RegFunction("PlayBGM", PlayBGM);
		L.RegFunction("PlaySound", PlaySound);
		L.RegFunction("Pause", Pause);
		L.RegFunction("ContinuePlay", ContinuePlay);
		L.RegFunction("PauseBG", PauseBG);
		L.RegFunction("ContinuePlayBG", ContinuePlayBG);
		L.RegFunction("CloseLoopSound", CloseLoopSound);
		L.RegFunction("CloseSound", CloseSound);
		L.RegFunction("CloseBGMSound", CloseBGMSound);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetIsShakeOn(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool o = obj.GetIsShakeOn();
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				bool o = obj.GetIsShakeOn(arg0);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.GetIsShakeOn");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetIsShakeOn(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
				obj.SetIsShakeOn(arg0);
				return 0;
			}
			else if (count == 3)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
				string arg1 = ToLua.CheckString(L, 3);
				obj.SetIsShakeOn(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.SetIsShakeOn");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetIsSoundOn(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool o = obj.GetIsSoundOn();
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				bool o = obj.GetIsSoundOn(arg0);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.GetIsSoundOn");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetIsSoundOn(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
				obj.SetIsSoundOn(arg0);
				return 0;
			}
			else if (count == 3)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
				string arg1 = ToLua.CheckString(L, 3);
				obj.SetIsSoundOn(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.SetIsSoundOn");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetIsMusicOn(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool o = obj.GetIsMusicOn();
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				bool o = obj.GetIsMusicOn(arg0);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.GetIsMusicOn");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetIsMusicOn(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
				obj.SetIsMusicOn(arg0);
				return 0;
			}
			else if (count == 3)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
				string arg1 = ToLua.CheckString(L, 3);
				obj.SetIsMusicOn(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.SetIsMusicOn");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetIsCenterOn(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool o = obj.GetIsCenterOn();
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				bool o = obj.GetIsCenterOn(arg0);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.GetIsCenterOn");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetIsCenterOn(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
				obj.SetIsCenterOn(arg0);
				return 0;
			}
			else if (count == 3)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
				string arg1 = ToLua.CheckString(L, 3);
				obj.SetIsCenterOn(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.SetIsCenterOn");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCenterVolume(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				float o = obj.GetCenterVolume();
				LuaDLL.lua_pushnumber(L, o);
				return 1;
			}
			else if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				float o = obj.GetCenterVolume(arg0);
				LuaDLL.lua_pushnumber(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.GetCenterVolume");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetCenterVolume(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				obj.SetCenterVolume(arg0);
				return 0;
			}
			else if (count == 3)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				string arg1 = ToLua.CheckString(L, 3);
				obj.SetCenterVolume(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.SetCenterVolume");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetMusicVolume(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				float o = obj.GetMusicVolume();
				LuaDLL.lua_pushnumber(L, o);
				return 1;
			}
			else if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				float o = obj.GetMusicVolume(arg0);
				LuaDLL.lua_pushnumber(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.GetMusicVolume");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetMusicVolume(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				obj.SetMusicVolume(arg0);
				return 0;
			}
			else if (count == 3)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				string arg1 = ToLua.CheckString(L, 3);
				obj.SetMusicVolume(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.SetMusicVolume");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetSoundVolume(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				float o = obj.GetSoundVolume();
				LuaDLL.lua_pushnumber(L, o);
				return 1;
			}
			else if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				float o = obj.GetSoundVolume(arg0);
				LuaDLL.lua_pushnumber(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.GetSoundVolume");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetSoundVolume(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				obj.SetSoundVolume(arg0);
				return 0;
			}
			else if (count == 3)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				string arg1 = ToLua.CheckString(L, 3);
				obj.SetSoundVolume(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.SetSoundVolume");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlayBGM(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				obj.PlayBGM(arg0);
				return 0;
			}
			else if (count == 3)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				string arg1 = ToLua.CheckString(L, 3);
				obj.PlayBGM(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.PlayBGM");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlaySound(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				string o = obj.PlaySound(arg0);
				LuaDLL.lua_pushstring(L, o);
				return 1;
			}
			else if (count == 3)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
				string o = obj.PlaySound(arg0, arg1);
				LuaDLL.lua_pushstring(L, o);
				return 1;
			}
			else if (count == 4)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
				LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
				string o = obj.PlaySound(arg0, arg1, arg2);
				LuaDLL.lua_pushstring(L, o);
				return 1;
			}
			else if (count == 5)
			{
				LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
				LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
				string arg3 = ToLua.CheckString(L, 5);
				string o = obj.PlaySound(arg0, arg1, arg2, arg3);
				LuaDLL.lua_pushstring(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.AudioManager.PlaySound");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Pause(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.Pause(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ContinuePlay(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.ContinuePlay(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PauseBG(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
			obj.PauseBG();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ContinuePlayBG(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
			obj.ContinuePlayBG();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CloseLoopSound(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.CloseLoopSound(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CloseSound(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
			obj.CloseSound();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CloseBGMSound(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.AudioManager obj = (LuaFramework.AudioManager)ToLua.CheckObject<LuaFramework.AudioManager>(L, 1);
			obj.CloseBGMSound();
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
}

