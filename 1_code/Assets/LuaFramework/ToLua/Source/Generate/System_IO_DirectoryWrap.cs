﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class System_IO_DirectoryWrap
{
	public static void Register(LuaState L)
	{
		L.BeginStaticLibs("Directory");
		L.RegFunction("GetFiles", GetFiles);
		L.RegFunction("GetDirectories", GetDirectories);
		L.RegFunction("GetFileSystemEntries", GetFileSystemEntries);
		L.RegFunction("EnumerateDirectories", EnumerateDirectories);
		L.RegFunction("EnumerateFiles", EnumerateFiles);
		L.RegFunction("EnumerateFileSystemEntries", EnumerateFileSystemEntries);
		L.RegFunction("GetDirectoryRoot", GetDirectoryRoot);
		L.RegFunction("CreateDirectory", CreateDirectory);
		L.RegFunction("Delete", Delete);
		L.RegFunction("Exists", Exists);
		L.RegFunction("GetLastAccessTime", GetLastAccessTime);
		L.RegFunction("GetLastAccessTimeUtc", GetLastAccessTimeUtc);
		L.RegFunction("GetLastWriteTime", GetLastWriteTime);
		L.RegFunction("GetLastWriteTimeUtc", GetLastWriteTimeUtc);
		L.RegFunction("GetCreationTime", GetCreationTime);
		L.RegFunction("GetCreationTimeUtc", GetCreationTimeUtc);
		L.RegFunction("GetCurrentDirectory", GetCurrentDirectory);
		L.RegFunction("GetLogicalDrives", GetLogicalDrives);
		L.RegFunction("GetParent", GetParent);
		L.RegFunction("Move", Move);
		L.RegFunction("SetCreationTime", SetCreationTime);
		L.RegFunction("SetCreationTimeUtc", SetCreationTimeUtc);
		L.RegFunction("SetCurrentDirectory", SetCurrentDirectory);
		L.RegFunction("SetLastAccessTime", SetLastAccessTime);
		L.RegFunction("SetLastAccessTimeUtc", SetLastAccessTimeUtc);
		L.RegFunction("SetLastWriteTime", SetLastWriteTime);
		L.RegFunction("SetLastWriteTimeUtc", SetLastWriteTimeUtc);
		L.EndStaticLibs();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFiles(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string[] o = System.IO.Directory.GetFiles(arg0);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 2)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				string[] o = System.IO.Directory.GetFiles(arg0, arg1);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 3)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				System.IO.SearchOption arg2 = (System.IO.SearchOption)LuaDLL.luaL_checknumber(L, 3);
				string[] o = System.IO.Directory.GetFiles(arg0, arg1, arg2);
				ToLua.Push(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.IO.Directory.GetFiles");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDirectories(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string[] o = System.IO.Directory.GetDirectories(arg0);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 2)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				string[] o = System.IO.Directory.GetDirectories(arg0, arg1);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 3)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				System.IO.SearchOption arg2 = (System.IO.SearchOption)LuaDLL.luaL_checknumber(L, 3);
				string[] o = System.IO.Directory.GetDirectories(arg0, arg1, arg2);
				ToLua.Push(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.IO.Directory.GetDirectories");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFileSystemEntries(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string[] o = System.IO.Directory.GetFileSystemEntries(arg0);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 2)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				string[] o = System.IO.Directory.GetFileSystemEntries(arg0, arg1);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 3)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				System.IO.SearchOption arg2 = (System.IO.SearchOption)LuaDLL.luaL_checknumber(L, 3);
				string[] o = System.IO.Directory.GetFileSystemEntries(arg0, arg1, arg2);
				ToLua.Push(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.IO.Directory.GetFileSystemEntries");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnumerateDirectories(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				string arg0 = ToLua.CheckString(L, 1);
				System.Collections.Generic.IEnumerable<string> o = System.IO.Directory.EnumerateDirectories(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 2)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				System.Collections.Generic.IEnumerable<string> o = System.IO.Directory.EnumerateDirectories(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 3)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				System.IO.SearchOption arg2 = (System.IO.SearchOption)LuaDLL.luaL_checknumber(L, 3);
				System.Collections.Generic.IEnumerable<string> o = System.IO.Directory.EnumerateDirectories(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.IO.Directory.EnumerateDirectories");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnumerateFiles(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				string arg0 = ToLua.CheckString(L, 1);
				System.Collections.Generic.IEnumerable<string> o = System.IO.Directory.EnumerateFiles(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 2)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				System.Collections.Generic.IEnumerable<string> o = System.IO.Directory.EnumerateFiles(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 3)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				System.IO.SearchOption arg2 = (System.IO.SearchOption)LuaDLL.luaL_checknumber(L, 3);
				System.Collections.Generic.IEnumerable<string> o = System.IO.Directory.EnumerateFiles(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.IO.Directory.EnumerateFiles");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnumerateFileSystemEntries(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				string arg0 = ToLua.CheckString(L, 1);
				System.Collections.Generic.IEnumerable<string> o = System.IO.Directory.EnumerateFileSystemEntries(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 2)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				System.Collections.Generic.IEnumerable<string> o = System.IO.Directory.EnumerateFileSystemEntries(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 3)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				System.IO.SearchOption arg2 = (System.IO.SearchOption)LuaDLL.luaL_checknumber(L, 3);
				System.Collections.Generic.IEnumerable<string> o = System.IO.Directory.EnumerateFileSystemEntries(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.IO.Directory.EnumerateFileSystemEntries");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDirectoryRoot(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			string o = System.IO.Directory.GetDirectoryRoot(arg0);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreateDirectory(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			System.IO.DirectoryInfo o = System.IO.Directory.CreateDirectory(arg0);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Delete(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				string arg0 = ToLua.CheckString(L, 1);
				System.IO.Directory.Delete(arg0);
				return 0;
			}
			else if (count == 2)
			{
				string arg0 = ToLua.CheckString(L, 1);
				bool arg1 = LuaDLL.luaL_checkboolean(L, 2);
				System.IO.Directory.Delete(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.IO.Directory.Delete");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Exists(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			bool o = System.IO.Directory.Exists(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLastAccessTime(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime o = System.IO.Directory.GetLastAccessTime(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLastAccessTimeUtc(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime o = System.IO.Directory.GetLastAccessTimeUtc(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLastWriteTime(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime o = System.IO.Directory.GetLastWriteTime(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLastWriteTimeUtc(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime o = System.IO.Directory.GetLastWriteTimeUtc(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCreationTime(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime o = System.IO.Directory.GetCreationTime(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCreationTimeUtc(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime o = System.IO.Directory.GetCreationTimeUtc(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCurrentDirectory(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			string o = System.IO.Directory.GetCurrentDirectory();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLogicalDrives(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			string[] o = System.IO.Directory.GetLogicalDrives();
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetParent(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			System.IO.DirectoryInfo o = System.IO.Directory.GetParent(arg0);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Move(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			System.IO.Directory.Move(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetCreationTime(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime arg1 = StackTraits<System.DateTime>.Check(L, 2);
			System.IO.Directory.SetCreationTime(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetCreationTimeUtc(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime arg1 = StackTraits<System.DateTime>.Check(L, 2);
			System.IO.Directory.SetCreationTimeUtc(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetCurrentDirectory(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			System.IO.Directory.SetCurrentDirectory(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetLastAccessTime(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime arg1 = StackTraits<System.DateTime>.Check(L, 2);
			System.IO.Directory.SetLastAccessTime(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetLastAccessTimeUtc(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime arg1 = StackTraits<System.DateTime>.Check(L, 2);
			System.IO.Directory.SetLastAccessTimeUtc(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetLastWriteTime(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime arg1 = StackTraits<System.DateTime>.Check(L, 2);
			System.IO.Directory.SetLastWriteTime(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetLastWriteTimeUtc(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			System.DateTime arg1 = StackTraits<System.DateTime>.Check(L, 2);
			System.IO.Directory.SetLastWriteTimeUtc(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

