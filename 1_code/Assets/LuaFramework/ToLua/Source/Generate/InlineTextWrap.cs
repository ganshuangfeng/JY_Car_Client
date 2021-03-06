//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class InlineTextWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(InlineText), typeof(UnityEngine.UI.Text));
		L.RegFunction("ActiveText", ActiveText);
		L.RegFunction("SetVerticesDirty", SetVerticesDirty);
		L.RegFunction("OnPointerClick", OnPointerClick);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("OnHrefClick", get_OnHrefClick, set_OnHrefClick);
		L.RegVar("preferredWidth", get_preferredWidth, null);
		L.RegVar("preferredHeight", get_preferredHeight, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ActiveText(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			InlineText obj = (InlineText)ToLua.CheckObject<InlineText>(L, 1);
			obj.ActiveText();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetVerticesDirty(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			InlineText obj = (InlineText)ToLua.CheckObject<InlineText>(L, 1);
			obj.SetVerticesDirty();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnPointerClick(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			InlineText obj = (InlineText)ToLua.CheckObject<InlineText>(L, 1);
			UnityEngine.EventSystems.PointerEventData arg0 = (UnityEngine.EventSystems.PointerEventData)ToLua.CheckObject<UnityEngine.EventSystems.PointerEventData>(L, 2);
			obj.OnPointerClick(arg0);
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
	static int get_OnHrefClick(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			InlineText obj = (InlineText)o;
			InlineText.HrefClickEvent ret = obj.OnHrefClick;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index OnHrefClick on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_preferredWidth(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			InlineText obj = (InlineText)o;
			float ret = obj.preferredWidth;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index preferredWidth on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_preferredHeight(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			InlineText obj = (InlineText)o;
			float ret = obj.preferredHeight;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index preferredHeight on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_OnHrefClick(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			InlineText obj = (InlineText)o;
			InlineText.HrefClickEvent arg0 = (InlineText.HrefClickEvent)ToLua.CheckObject<InlineText.HrefClickEvent>(L, 2);
			obj.OnHrefClick = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index OnHrefClick on a nil value");
		}
	}
}

