using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System;

public class GameModuleShow : MonoBehaviour
{
    [InitializeOnLoadMethod]
    static void InitializeOnLoadMethod()
    {
        InitkeyToNickname();
        EditorApplication.projectWindowItemOnGUI += ReplaceFolderNickname;
    }
    [Serializable]
    internal class GameModuleContent
    {
        public string name = string.Empty;
        public bool enable = false;
    }
    [Serializable]
    internal class GameModuleConfig
    {
        public List<GameModuleContent> modules = new List<GameModuleContent>();
    }

    [Serializable]
    internal class NicknameConfig
    {
        public string name = string.Empty;
        public int color = 1;
    }
    static Dictionary<string, NicknameConfig> keyToNickname = new Dictionary<string, NicknameConfig>();
    static Dictionary<string, string> baoToNickname = new Dictionary<string, string>();
    static void InitkeyToNickname()
    {
        string fileName = Application.dataPath + "/game_module_show_config.txt";
        if (AppDefine.CurQuDao != "main"){
            string fileNameQD = Application.dataPath + "/game_module_show_config_" + AppDefine.CurQuDao + ".txt";
            if (File.Exists(fileNameQD))
                fileName = fileNameQD;
        }
        Debug.Log(fileName);
        var lines = File.ReadAllLines(fileName);
        string[] item;
        foreach (var line in lines)
        {
            if(line != null && line != "")
            {
                item = line.Split('|');
                if(item.Length >= 2)
                {
                    NicknameConfig cc = new NicknameConfig();
                    cc.name = item[1];
                    if (item.Length >= 3)
                    {
                        int.TryParse(item[2], out cc.color);
                    }
                    // Debug.Log(item[0]);
                    if (!keyToNickname.ContainsKey(item[0].ToLower()))
                        keyToNickname.Add(item[0].ToLower(), cc);                
                }
                else
                {
                    Debug.Log("Error game_module_show_config  line=\"" + line + "\"");
                }
            }
        }

        //         string BuildGameModuleConfigFile = "VersionConfig/GameModuleConfigText.txt";
        //         fileName = Application.dataPath + "/" + BuildGameModuleConfigFile;
        //         if (File.Exists (fileName)) {
        //             lines = File.ReadAllLines(fileName);
        //             foreach (var line in lines)
        //             {
        //                 baoToNickname.Add(line.ToLower(), "1");
        //             }
        //         }

        fileName = Application.dataPath + "/VersionConfig/GameModuleConfig.json";
        if (AppDefine.CurQuDao != "main"){
            string acQD = Application.dataPath + "/VersionConfig/GameModuleConfig_" + AppDefine.CurQuDao + ".json";
            if (File.Exists(acQD))
                fileName = acQD;
        }
        if (File.Exists(fileName))
        {
            GameModuleConfig gamemoduleConfig = JsonUtility.FromJson<GameModuleConfig>(File.ReadAllText(fileName));
            baoToNickname.Clear();
            Debug.Log("长度=" + gamemoduleConfig.modules.Count);
            foreach (GameModuleContent it in gamemoduleConfig.modules)
            {
                if (!it.enable) continue;
                // Debug.Log(it.name.ToLower());
                if (!baoToNickname.ContainsKey(it.name.ToLower())){
                    baoToNickname.Add(it.name.ToLower(), "1");
                }
            }
        }
    }
    // Delegates 
    private static void ReplaceFolderNickname(string guid, Rect selectionRect)
    {
        var path = AssetDatabase.GUIDToAssetPath(guid);

        if (!AssetDatabase.IsValidFolder(path))
            return;

        // Game/GameModule
        if (path.Contains("Assets/Game/GameModule/"))
        {
            var dirs = path.Split('/');
            if (dirs.Length != 4) return;
            string ww = dirs[3];
            if (keyToNickname.ContainsKey(ww.ToLower()) || dirs.Length == 4)
            {
                string nickname = "未知";
                if (keyToNickname.ContainsKey(ww.ToLower()))
                {
                    var cc = keyToNickname[ww.ToLower()];
                    nickname = cc.name;
                    if (cc.color == 1)
                    {
                        GUI.color = new Color(131f / 255, 223f / 255, 139f / 255, 1);
                    }
                    else if(cc.color == 2)
                    {
                        GUI.color = new Color(248f / 255, 100f / 255, 100f / 255, 1);
                    }
                    else
                    {
                        GUI.color = new Color(2f / 255, 100f / 255, 100f / 255, 1);
                    }
                }
                else
                {
                    GUI.color = new Color(248f / 255, 100f / 255, 100f / 255, 1);
                }
                float width = 120f;
                Rect rr = new Rect(selectionRect);
                rr.x += (rr.width - width);
                rr.y += 2f;
                rr.width = width;
                GUI.TextArea(rr, nickname);
                GUI.color = Color.white;
            }
            string pp = path.Substring(12, path.Length-12);
            if (baoToNickname.ContainsKey(pp.ToLower()))
            {
                string nickname = "√";
                GUI.color = new Color(255f / 255, 0f / 255, 0f / 255, 1);
                float width = 16f;
                Rect rr = new Rect(selectionRect);
                rr.x += (rr.width - width);
                rr.y += 2f;
                rr.width = width;
                GUI.TextArea(rr, nickname);
                GUI.color = Color.white;
            }
        }
    }
}