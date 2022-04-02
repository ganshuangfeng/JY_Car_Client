using UnityEngine;
using System.Collections.Generic;
using UnityEditor;
using System.IO;

public class MaterialsGUI : EditorWindow
{
        protected static MaterialsGUI s_instance = null;
        internal static MaterialsGUI instance
        {
            get
            {
                if (s_instance == null)
                    s_instance = GetWindow<MaterialsGUI >();
                return s_instance;
            }
        }
        [MenuItem("Assets/更新模型信息")]
        static void ImportUpdatePbx()
        {
            instance.LoadInit();
            Object[] objs = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
            List<string> pngandtga = new List<string>();

            for (int i = 0; i < objs.Length; i++)
            {
                Object obj = objs[i];
                string url = AssetDatabase.GetAssetPath(obj);
                if (string.IsNullOrEmpty(url))
                    continue;
                string ext = Path.GetExtension(url);
                if (ext == ".png")
                {
                    pngandtga.Add(url);
                    continue;
                }
                if (ext != ".fbx" && ext != ".FBX")
                    continue;
                instance.LoadMaterials(url);
            }
            for (int i = 0; i < pngandtga.Count; i++)
            {
                string url = pngandtga[i];
                instance.LoadTexture(url);
            }
            instance.SettingMaterials();
            AssetDatabase.Refresh();
        }
        
        private List<Material> mListMaterial = new List<Material>();
        private List<string> mListMaterialName = new List<string>();
		private Dictionary<string, MaterialsDate> mDicTexture = new Dictionary<string, MaterialsDate>();
        
        /// <summary>
        /// 颜色贴图 -贴图的命名规则（材质_目标贴图后缀）
        /// </summary>
        private string[] AlbedoTexture = new string[] { "_AlbedoTransparency",  "_Albedo" };
        /// <summary>
        /// 高光贴图
        /// </summary>
        private string[] MetallicTexture = new string[] { "_MetallicSmoothness", "_Metallic" };
        /// <summary>
        /// 法线贴图
        /// </summary>
        private string[] NormalTexture = new string[] { "_Normal" };
        /// <summary>
        /// Ao贴图
        /// </summary>
        private string[] OcclusionTexture = new string[] { "_Ao", "_AO", "_Occlusion" };
        /// <summary>
        /// 初始化
        /// </summary>
        private void LoadInit()
        {
            mListMaterial.Clear();
            mListMaterialName.Clear();
            mDicTexture.Clear();
        }
        /// <summary>
        /// 加载所有PBX文件的Material（材质球）
        /// </summary>
        /// <param name="url"></param>
        private void LoadMaterials(string url)
        {
            ModelImporter modelImporter = ModelImporter.GetAtPath(url) as ModelImporter;
            modelImporter.importMaterials = true;
            modelImporter.materialLocation = ModelImporterMaterialLocation.External;
            modelImporter.materialName = ModelImporterMaterialName.BasedOnMaterialName;
            modelImporter.materialSearch = ModelImporterMaterialSearch.Everywhere;
            AssetDatabase.ImportAsset(url);
            Object obj = AssetDatabase.LoadAssetAtPath<Object>(url);

            GameObject go = obj as GameObject;

            Renderer[] skins = go.GetComponentsInChildren<MeshRenderer>(true);
            if (skins.Length == 0)
                return;
            for (int i = 0; i < skins.Length; i++)
            {
                Renderer renderer = skins[i];
                if (renderer.sharedMaterials != null && renderer.sharedMaterials.Length > 0)
                {
                    for (int j = 0; j < renderer.sharedMaterials.Length; j++)
                    {
                        Material mat = renderer.sharedMaterials[j];
                        if (mat != null)
                        {
                            mListMaterial.Add(mat);
                            mat.shader = Shader.Find("Standard");
                            if (!mListMaterialName.Contains(mat.name))
                            {
                                mListMaterialName.Add(mat.name);
                            }
                        }
                    }
                }
            }
        }
        /// <summary>
        /// 加载文件中的所有Texture（贴图）
        /// </summary>
        /// <param name="url"></param>
        private void LoadTexture(string url)
        {
            Texture2D TempTexture = AssetDatabase.LoadAssetAtPath<Texture2D>(url);
            string TempTextureName = TempTexture.name;
            TextureImporter texture = AssetImporter.GetAtPath(url) as TextureImporter;


            for (int i = 0; i < AlbedoTexture.Length; i++)
            {
                    if (DateTexture(AlbedoTexture[i], TextureType.Albedo, TempTexture))
                        return;
            }
            for (int i = 0; i < MetallicTexture.Length; i++)
            {
                    if (DateTexture(MetallicTexture[i], TextureType.Metallic, TempTexture))
                        return;
            }
            for (int i = 0; i < OcclusionTexture.Length; i++)
            {
                    if (DateTexture(OcclusionTexture[i], TextureType.Occlusion, TempTexture))
                        return;
            }
            for (int i = 0; i < NormalTexture.Length; i++)
            {
                    if (DateTexture(NormalTexture[i], TextureType.Normal, TempTexture))
                    {
                        TextureImporter tempTexture = AssetImporter.GetAtPath(url) as TextureImporter;
                        tempTexture.textureType = TextureImporterType.NormalMap;
                        return;
                    }
            }
        }
        private bool DateTexture(string varTextureName, TextureType varTextureType, Texture Texture)
        {
            string TempTextureName = Texture.name;

            string key = GetMaterialsBuyTexture(TempTextureName, varTextureName);
            if (mListMaterialName.Contains(key))
            {
                MaterialsDate Date = new MaterialsDate();
                if (mDicTexture.ContainsKey(key))
                {
                    Date = mDicTexture[key];
                }

                switch (varTextureType)
                {
                    case TextureType.Albedo:
                        Date.Albedo = Texture;
                        break;
                    case TextureType.Metallic:
                        Date.Metallic = Texture;
                        break;
                    case TextureType.Normal:
                        Date.Normal = Texture;
                        break;
                    case TextureType.Occlusion:
                        Date.Occlusion = Texture;
                        break;
                    default:
                        break;
                }
                if (mDicTexture.ContainsKey(key))
                {
                    mDicTexture[key] = Date;
                }
                else
                {
                    mDicTexture.Add(key, Date);
                }
                return true;
            }
            else
            {
                return false;
            }
        }
        /// <summary>
        /// 移除指定后缀获取对应材质的名称
        /// </summary>
        private string GetMaterialsBuyTexture(string TextureName,string varTextureName)
        {
            string key = TextureName;
            if (TextureName.Contains(varTextureName))
            {
                int index = TextureName.LastIndexOf(varTextureName);
                key = TextureName.Substring(0, index);
            }
            return key;
        }
        /// <summary>
        /// 给材质贴上指定的贴图
        /// </summary>
        private void SettingMaterials()
        {
            for (int i = 0; i < mListMaterial.Count; i++)
            {
                string MaterialName = mListMaterial[i].name;
                Material mat = mListMaterial[i];
                if (mDicTexture.ContainsKey(MaterialName))
                {
                    var date = mDicTexture[MaterialName];
                    if (date.Albedo != null)
                        mat.SetTexture("_MainTex", date.Albedo);
                    if (date.Metallic != null)
                        mat.SetTexture("_MetallicGlossMap", date.Metallic);
                    if (date.Normal != null)
                        mat.SetTexture("_BumpMap", date.Normal);
                    if (date.Occlusion != null)
                        mat.SetTexture("_OcclusionMap", date.Occlusion);
                }
                else
                {
                    Debug.LogError("Materials :"+MaterialName+"Texture Not Existent");
                }
            }
        }
        public struct MaterialsDate
        {
            public Texture Albedo;
            public Texture Metallic;
            public Texture Normal;
            public Texture Occlusion;
        }
        public enum TextureType
        {
            Albedo,
            Metallic,
            Normal,
            Occlusion,
        }
}
