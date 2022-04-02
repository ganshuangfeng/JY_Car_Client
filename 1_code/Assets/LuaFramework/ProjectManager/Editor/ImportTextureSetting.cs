using UnityEngine;
using UnityEditor;
using System.IO;

public class ImportTextureSetting //: AssetPostprocessor
{
	void ResetSetting(TextureImporter textureImporter) {
		TextureImporterPlatformSettings platformSettings = textureImporter.GetPlatformTextureSettings("iPhone");

		textureImporter.spritePackingTag = string.Empty;
		platformSettings.overridden = false;
		textureImporter.SetPlatformTextureSettings(platformSettings);
	}

    // PSD导入到UI的地方已经处理过格式问题，其实不需要在导入图片的时候再强制设置一次，这里视情况决定是否开放
    void OnPreprocessTexture()
    {
		//TextureImporter textureImporter = assetImporter as TextureImporter;
		//TextureImporterPlatformSettings platformSettings = textureImporter.GetPlatformTextureSettings("iPhone");

		//if (textureImporter.textureType != TextureImporterType.Sprite) {
		//	ResetSetting (textureImporter);
		//	return;
		//}

		//if (!assetPath.EndsWith (".png") && !assetPath.EndsWith (".tga") && !assetPath.EndsWith (".jpg")) {
		//	ResetSetting (textureImporter);
		//	return;
		//}
		
		////special file
		//if (assetPath.EndsWith ("erweimabg.png"))
		//	return;

		//if (textureImporter.spritePackingTag.StartsWith ("LOCK_")) {
		//	Debug.Log ("Keep Sprite Tag:" + assetPath);
		//	return;
		//}

		//if (assetPath.Contains ("Unused/")) {
		//	ResetSetting (textureImporter);
		//	return;
		//}

		//if (!assetPath.Contains ("/Image/") && !assetPath.Contains ("/MergeImage/") && !assetPath.Contains ("/Texture2D/") && !assetPath.Contains ("/MaterialTexture2D/")) {
		//	ResetSetting (textureImporter);
		//	return;
		//}

		////"Assets/Game/"
		//int index = 11;
		//string filePath = Path.GetDirectoryName (assetPath);
		//string spriteTag = filePath.Substring (index + 1, filePath.Length - index - 1);
		//spriteTag = spriteTag.Replace ('/', '_');

		//Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D> (assetPath);
		//if (texture == null) {
		//	Debug.LogWarning (string.Format("[Texture] LoadAssetAtPath({0}) failed.", assetPath));
		//	return;
		//}
		//if (textureImporter.spritePackingTag == null || textureImporter.spritePackingTag == "")
		//{
		//	if (texture.width >= 512 || texture.height >= 512)
		//		textureImporter.spritePackingTag = "";
		//	else
		//		textureImporter.spritePackingTag = spriteTag;
		//}
		//else
		//{
		//	if ( textureImporter.spritePackingTag.Contains(spriteTag) )
		//	{
		//		if (texture.width >= 512 || texture.height >= 512)
		//		{
		//			string ss = spriteTag + Path.GetFileNameWithoutExtension (assetPath);
		//			textureImporter.spritePackingTag = "";
		//		}
		//		else
		//		{
		//			string ss = spriteTag;
		//			if (textureImporter.spritePackingTag != ss)
		//			{
		//				textureImporter.spritePackingTag = spriteTag;
		//				// Debug.Log("<color=red>《 512   assetPath  =" + assetPath + "</color>");
		//				// Debug.Log("<color=red>旧tag  =" + textureImporter.spritePackingTag + "</color>");
		//				// Debug.Log("<color=red>新tag  =" + ss + "</color>");
		//			}					
		//		}
		//	}
		//	else
		//	{
		//		if (texture.width >= 512 || texture.height >= 512)
		//			textureImporter.spritePackingTag = "";
		//		else
		//			textureImporter.spritePackingTag = spriteTag;
		//	}
		//}

		//if (textureImporter.DoesSourceTextureHaveAlpha()) {
		//	platformSettings.format = TextureImporterFormat.ETC2_RGBA8;
		//	platformSettings.overridden = true;
		//	textureImporter.SetPlatformTextureSettings(platformSettings);
		//}
    }
    private static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromPath)
    {
        //foreach (string move in movedAssets)
        //    AssetDatabase.ImportAsset(move);
    }
}