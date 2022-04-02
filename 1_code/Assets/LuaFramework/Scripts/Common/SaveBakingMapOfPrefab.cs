#if UNITY_EDITOR
using UnityEditor;
using System.IO;
#endif
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
/// <summary>
/// 保存有烘培贴图的预制
/// </summary>
public class SaveBakingMapOfPrefab : MonoBehaviour
{
    [System.Serializable]
    struct RendererInfo
    {
        public Renderer renderer;
        public int lightmapIndex;
        public Vector4 lightmapOffsetScale;
    }
    [SerializeField]
    RendererInfo[] m_RendererInfo;
    [SerializeField]
    Texture2D[] m_Lightmaps;
    [SerializeField]
    Texture2D[] m_Lightmaps2;
    /// <summary>
    /// 光照贴图资源路径
    /// </summary>
    const string LIGHTMAP_RESOURCE_PATH = "Assets/Resources/Lightmaps/";
    /// <summary>
    /// 自己建立的光照贴图结构体-------用于记录
    /// </summary>
    [System.Serializable]
    struct Texture2D_Remap
    {
        public int originalLightmapIndex;
        public Texture2D originalLightmap;
        public Texture2D lightmap0;
        public Texture2D lightmap1;
    }
    /// <summary>
    /// 场景内所有的光照贴图的容器
    /// </summary>
    static List<Texture2D_Remap> sceneLightmaps = new List<Texture2D_Remap>();
    void Awake()
    {
        ApplyLightmaps(m_RendererInfo, m_Lightmaps, m_Lightmaps2);
    }
    /// <summary>
    /// 申请光照贴图，更新光照贴图数组（把更新的光照贴图数据加入总数组LightmapSettings.lightmaps）
    /// </summary>
    /// <param name="rendererInfo"></param>
    /// <param name="lightmaps"></param>
    /// <param name="lightmaps2"></param>
    static void ApplyLightmaps(RendererInfo[] rendererInfo, Texture2D[] lightmaps, Texture2D[] lightmaps2)
    {
        //是否已经存在
        bool existsAlready = false;
        //记录总数组中有几个光照贴图漏掉了
        int counter = 0;
        int[] lightmapArrayOffsetIndex;
        //如果没有就返回
        if (rendererInfo == null || rendererInfo.Length == 0)
            return;
        //场景中光照贴图的数组
        var settingslightmaps = LightmapSettings.lightmaps;
        //临时数组------存放不在场景总数组中的光照贴图
        var combinedLightmaps = new List<LightmapData>();
        //记录下标数组
        lightmapArrayOffsetIndex = new int[lightmaps.Length];
        for (int i = 0; i < lightmaps.Length; i++)
        {
            existsAlready = false;
            for (int j = 0; j < settingslightmaps.Length; j++)
            {//判断该贴图是否在所有光照贴图的数组中
                if (lightmaps[i] == settingslightmaps[j].lightmapColor)
                {
                    lightmapArrayOffsetIndex[i] = j;
                    existsAlready = true;
                }
            }
            if (!existsAlready)
            {//如果不在其中，则先记录下应该在总数组中的下标位置，再创建一个光照贴图数据，存放在临时数组中
                lightmapArrayOffsetIndex[i] = counter + settingslightmaps.Length;
                var newLightmapData = new LightmapData();
                newLightmapData.lightmapColor = lightmaps[i];
                newLightmapData.lightmapDir = lightmaps2[i];
                combinedLightmaps.Add(newLightmapData);
                ++counter;
            }
        }
        //建立一个临时的数组存放所有的光照贴图数据
        var combinedLightmaps2 = new LightmapData[settingslightmaps.Length + counter];
        //将settingslightmaps数组复制到combinedLightmaps2数组，并从下标0开始
        settingslightmaps.CopyTo(combinedLightmaps2, 0);
        if (counter > 0)
        {
            for (int i = 0; i < combinedLightmaps.Count; i++)
            {
                combinedLightmaps2[i + settingslightmaps.Length] = new LightmapData();
                combinedLightmaps2[i + settingslightmaps.Length].lightmapColor = combinedLightmaps[i].lightmapColor;
                combinedLightmaps2[i + settingslightmaps.Length].lightmapDir = combinedLightmaps[i].lightmapDir;
            }
        }
        ApplyRendererInfo(rendererInfo, lightmapArrayOffsetIndex);
        //将总数组更新
        LightmapSettings.lightmaps = combinedLightmaps2;
    }
    /// <summary>
    /// 更新RendererInfo数组
    /// </summary>
    /// <param name="infos"></param>
    /// <param name="arrayOffsetIndex"></param>
    static void ApplyRendererInfo(RendererInfo[] infos, int[] arrayOffsetIndex)
    {
        for (int i = 0; i < infos.Length; i++)
        {
            var info = infos[i];
            info.renderer.lightmapIndex = arrayOffsetIndex[info.lightmapIndex];
            info.renderer.lightmapScaleOffset = info.lightmapOffsetScale;
        }
    }

#if UNITY_EDITOR
    [MenuItem("Assets/Update Scene with Prefab Lightmaps")]
    static void UpdateLightmaps()
    {//更新保存的光照贴图
        SaveBakingMapOfPrefab[] prefabs = FindObjectsOfType<SaveBakingMapOfPrefab>();
        foreach (var instance in prefabs)
        {
            ApplyLightmaps(instance.m_RendererInfo, instance.m_Lightmaps, instance.m_Lightmaps2);
        }
        Debug.Log("Prefab lightmaps updated");
    }

    [MenuItem("Assets/Bake Prefab Lightmaps")]
    static void GenerateLightmapInfo()
    {
        Debug.ClearDeveloperConsole();
        if (Lightmapping.giWorkflowMode != Lightmapping.GIWorkflowMode.OnDemand)
        {//运行lightmapping只有当用户按下烘焙按钮时；如果不是则报错。
            Debug.LogError("ExtractLightmapData requires that you have baked you lightmaps and Auto mode is disabled.");
            return;
        }
        //开始烘培光照贴图
        Lightmapping.Bake();
        //光照贴图的保存路径----------Directory.GetCurrentDirectory()当前的目录
        string lightMapPath = Path.Combine(Directory.GetCurrentDirectory(), LIGHTMAP_RESOURCE_PATH);
        if (!Directory.Exists(lightMapPath))//如果路径不存在，则创建这个路径
            Directory.CreateDirectory(lightMapPath);
        sceneLightmaps = new List<Texture2D_Remap>();
        //当前场景的路径
        var scene = SceneManager.GetActiveScene().path;//因为Unity版本不同也可以使用EditorApplication.currentScene
        //提炼出场景名
        var sceneName = Path.GetFileNameWithoutExtension(scene);
        //光照贴图资源（.asset）在Resources所要保存的路径
        var resourcePath = LIGHTMAP_RESOURCE_PATH + sceneName;
        //光照贴图16bit表示的光照数据文件（.exr）所保存的路径
        var scenePath = Path.GetDirectoryName(scene) + "/" + sceneName + "/";
        //找到所有在运行中的SaveBakingMapOfPrefab对象
        SaveBakingMapOfPrefab[] prefabs = FindObjectsOfType<SaveBakingMapOfPrefab>();
        foreach (var instance in prefabs)
        {
            var gameObject = instance.gameObject;
            var rendererInfos = new List<RendererInfo>();
            var lightmaps = new List<Texture2D>();
            var lightmaps2 = new List<Texture2D>();
            //为使方便在场景名的后面加上预制体的名字
            resourcePath = resourcePath + "_" + gameObject.name;
            //创建光照贴图资源
            GenerateLightmapInfo(scenePath, resourcePath, gameObject, rendererInfos, lightmaps, lightmaps2);
            instance.m_RendererInfo = rendererInfos.ToArray();
            instance.m_Lightmaps = lightmaps.ToArray();
            instance.m_Lightmaps2 = lightmaps2.ToArray();
            //更改预制
            var targetPrefab = PrefabUtility.GetPrefabParent(gameObject) as GameObject;//获取与本物体相关的预制
            if (targetPrefab != null)
            {//替换之前的预制层次
                PrefabUtility.ReplacePrefab(gameObject, targetPrefab);
            }
            ApplyLightmaps(instance.m_RendererInfo, instance.m_Lightmaps, instance.m_Lightmaps2);
        }
        Debug.Log("Update to prefab lightmaps finished");
    }
    /// <summary>
    /// 根据scenePath读取.exr文件，并根据resourcePath创建.asset文件，将相应的信息存入容器sceneLightmaps
    /// </summary>
    /// <param name="scenePath"></param>
    /// <param name="resourcePath"></param>
    /// <param name="root"></param>
    /// <param name="rendererInfos"></param>
    /// <param name="lightmaps"></param>
    /// <param name="lightmaps2"></param>
    static void GenerateLightmapInfo(string scenePath, string resourcePath, GameObject root, List<RendererInfo> rendererInfos, List<Texture2D> lightmaps, List<Texture2D> lightmaps2)
    {
        var renderers = root.GetComponentsInChildren<MeshRenderer>();//光照贴图与MeshRenderer有关
        foreach (MeshRenderer renderer in renderers)
        {
            if (renderer.lightmapIndex != -1)//申请的光照贴图序列号
            {
                RendererInfo info = new RendererInfo();
                info.renderer = renderer;
                //用于光照贴图的UV缩放和偏移量
                info.lightmapOffsetScale = renderer.lightmapScaleOffset;
                //分别获取该MeshRenderer，远与近的光照贴图----------LightmapSettings场景中光照贴图的容器；LightmapSettings.lightmaps场景中光照贴图的数组
                Texture2D lightmap = LightmapSettings.lightmaps[renderer.lightmapIndex].lightmapColor;
                Texture2D lightmap2 = LightmapSettings.lightmaps[renderer.lightmapIndex].lightmapDir;
                int sceneLightmapIndex = AddLightmap(scenePath, resourcePath, renderer.lightmapIndex, lightmap, lightmap2);
                //查找对象在链表中的下标为多少。-1为没有
                info.lightmapIndex = lightmaps.IndexOf(sceneLightmaps[sceneLightmapIndex].lightmap0);
                if (info.lightmapIndex == -1)
                {
                    info.lightmapIndex = lightmaps.Count;
                    lightmaps.Add(sceneLightmaps[sceneLightmapIndex].lightmap0);
                    lightmaps2.Add(sceneLightmaps[sceneLightmapIndex].lightmap1);
                }
                rendererInfos.Add(info);
            }
        }
    }
    /// <summary>
    /// 添加光照贴图-------返回其在容器中下标
    /// </summary>
    /// <param name="scenePath"></param>
    /// <param name="resourcePath"></param>
    /// <param name="originalLightmapIndex"></param>
    /// <param name="lightmap"></param>
    /// <param name="lightmap2"></param>
    /// <returns></returns>
    static int AddLightmap(string scenePath, string resourcePath, int originalLightmapIndex, Texture2D lightmap, Texture2D lightmap2)
    {
        int newIndex = -1;
        //查找自己的光照贴图链表中是否存在想要加入的光照贴图，如果有则返回其下标
        for (int i = 0; i < sceneLightmaps.Count; i++)
        {
            if (sceneLightmaps[i].originalLightmapIndex == originalLightmapIndex)
            {
                return i;
            }
        }
        if (newIndex == -1)
        {
            //创建一个自己建立的光照贴图结构体对象
            var lightmap_Remap = new Texture2D_Remap();
            lightmap_Remap.originalLightmapIndex = originalLightmapIndex;
            lightmap_Remap.originalLightmap = lightmap;
            //组建文件名
            var filename = scenePath + "Lightmap-" + originalLightmapIndex;
            lightmap_Remap.lightmap0 = GetLightmapAsset(filename + "_comp_light.exr", resourcePath + "_light", originalLightmapIndex, lightmap);
            if (lightmap2 != null)
            {
                lightmap_Remap.lightmap1 = GetLightmapAsset(filename + "_comp_dir.exr", resourcePath + "_dir", originalLightmapIndex, lightmap2);
            }
            //将新建的这个光照贴图结构体对象加入容器中
            sceneLightmaps.Add(lightmap_Remap);
            newIndex = sceneLightmaps.Count - 1;
        }
        //返回其下标
        return newIndex;
    }
    /// <summary>
    /// 创建光照贴图并返回
    /// </summary>
    /// <param name="filename"></param>
    /// <param name="resourcePath"></param>
    /// <param name="originalLightmapIndex"></param>
    /// <param name="lightmap"></param>
    /// <returns></returns>
    static Texture2D GetLightmapAsset(string filename, string resourcePath, int originalLightmapIndex, Texture2D lightmap)
    {
        //导入一个资源------------filename路径；ImportAssetOptions导入资源的选择；ImportAssetOptions.ForceUpdate玩家主导的资源导入
        AssetDatabase.ImportAsset(filename, ImportAssetOptions.ForceUpdate);
        //检索资源导入的路径并返回一个对象，将这个对象强转（确定）为图片导入
        var importer = AssetImporter.GetAtPath(filename) as TextureImporter;
        //将已确定为图片导入的对象设置为脚本可读的----开始修改
        importer.isReadable = true;
        AssetDatabase.ImportAsset(filename, ImportAssetOptions.ForceUpdate);
        //根据路径读取一个图片资源
        var assetLightmap = AssetDatabase.LoadAssetAtPath<Texture2D>(filename);
        //在Resources中的路径与文件名.扩展名
        var assetPath = resourcePath + "-" + originalLightmapIndex + ".asset";
        //将图片资源实例化
        var newLightmap = Instantiate<Texture2D>(assetLightmap);
        //根据路径创建光照贴图资源
        AssetDatabase.CreateAsset(newLightmap, assetPath);
        //根据路径读取这个新的图片资源
        newLightmap = AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath);
        //将已确定为图片导入的对象设置为脚本不读的----停止修改
        importer.isReadable = false;
        AssetDatabase.ImportAsset(filename, ImportAssetOptions.ForceUpdate);
        //返回这个新的图片资源
        return newLightmap;
    }
#endif
}
