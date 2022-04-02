using UnityEditor;
using System.IO;

public class ProjectEditUtility
{
    /// <summary>
    /// 动画 Image Lua 预制体 声音 粒子 字体
    /// </summary>
    static string[] GameSubFolders = new string[] { "Animation", "Image", "Lua", "Prefab", "Audio", "Particle", "Font" };

    public static void CreateGameTemplateForlders(string gameName)
    {
        string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(assetGUIDArray[0]);

            if (assetPath == "Assets")
            {
                string assetPathAndName = AssetDatabase.GenerateUniqueAssetPath(assetPath + "/Game/" + gameName);
                AssetDatabase.CreateFolder(assetPath + "/Game", assetPathAndName.Replace("Assets/Game/", string.Empty));

                foreach (string item in GameSubFolders)
                {
                    AssetDatabase.CreateFolder(assetPathAndName, item);
                    StreamWriter sw = new StreamWriter(assetPathAndName + "/" + item + "/" + gameName + "_" + item + "_Desc.txt");      //  生成文件 
                    sw.Write("存放" + item + "资源");
                    sw.Close();   //释放掉
                }
                AssetDatabase.Refresh();

                Selection.activeObject = AssetDatabase.LoadAssetAtPath(assetPathAndName, typeof(DefaultAsset));
            }
        }
    }
}
