using UnityEngine;
using LuaInterface;

namespace LuaFramework
{
    public class ColliderBehaviour : MonoBehaviour
    {
        public string luaTableName = "";
		public LuaTable luaTable = null;

        //在需要物理作用的情况下，会触发这个方法 
        private void OnCollisionEnter2D(Collision2D collision)
        {
            Debug.Log("碰到");
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnTriggerEnter2D", luaTable, collision);
            
        }

        private void OnTriggerEnter2D(Collider2D collision)
        {
            Debug.Log("OnTriggerEnter2D");
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnTriggerEnter2D", luaTable, collision);
        }

        private void OnTriggerExit2D(Collider2D collision)
        {
            Debug.Log("OnTriggerExit2D");
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnTriggerExit2D", luaTable, collision);
        }

        public void OnTriggerEnter(Collider collision)
        {
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnTriggerEnter", luaTable, collision);
        }

        public void OnTriggerExit(Collider collision)
        {
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnTriggerExit", luaTable, collision);
        }

        public LuaTable GetLuaTable()
        {
            return luaTable;
        }

        public void SetLuaTable(LuaTable lt){
            luaTable = lt;
        }

        [NoToLua]
        public void SetParams(LuaTable params_table)
        {
            if (luaTable == null) return;
            if (params_table == null)
                return;

            luaTable.SetTable("params", params_table);
        }
    }
}