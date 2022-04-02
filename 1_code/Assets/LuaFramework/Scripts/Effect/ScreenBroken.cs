using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ScreenBroken : MonoBehaviour
{
    public int select = 0;
    public List<Material> matList;
    public Material mat;
    public float normalScale = 0;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (select < 0){
            select = 0;
        }
        if (select > matList.Count){
            select = matList.Count - 1;
        }
        if (matList[select]){
            mat = matList[select];
        }
        RenderTexture src0 = RenderTexture.GetTemporary(source.width, source.height);
        mat.SetTexture("_MainTex", source);
        mat.SetFloat("_BrokenScale", normalScale);
        Graphics.Blit(source, src0, mat, 0);
        Graphics.Blit(src0, destination);

        RenderTexture.ReleaseTemporary(src0);
    }
}
