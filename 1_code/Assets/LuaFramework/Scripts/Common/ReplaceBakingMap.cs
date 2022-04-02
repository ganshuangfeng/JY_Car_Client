using UnityEngine;
using System;
using System.Collections.Generic;

/// <summary>
/// 直接更新烘培贴图
/// </summary>
public class ReplaceBakingMap : MonoBehaviour
{
    //白天烘培贴图
    [SerializeField]
    public List<Texture2D> dayLightMap;
    [SerializeField]
    public List<Texture2D> dayLightDir;
    //夜晚烘培贴图
    [SerializeField]
    public List<Texture2D> nightLightMap;
    [SerializeField]
    public List<Texture2D> nightLightDir;

    [SerializeField]
    public List<Material> mapMat;

    public float F;
    public Animator DayOrNight;

    public void SetDay (){
        Debug.Log("SetDay XXXXX");
        var lightmaps = new LightmapData[dayLightMap.Count];
        for (int i = 0; i < dayLightMap.Count; i++)
        {
            LightmapData data = new LightmapData();
            data.lightmapColor = dayLightMap[i];
            data.lightmapDir = dayLightDir[i];
            lightmaps[i] = data;
        }
        LightmapSettings.lightmaps = lightmaps;
    }

    public void SetNight(){
        var lightmaps = new LightmapData[nightLightMap.Count];
        for (int i = 0; i < nightLightMap.Count; i++)
        {
            LightmapData data = new LightmapData();
            data.lightmapColor = nightLightMap[i];
            data.lightmapDir = nightLightDir[i];
            lightmaps[i] = data;
        }
        LightmapSettings.lightmaps = lightmaps;
    }

    // void OnGUI()
    // {
    //     if (GUILayout.Button("day"))
    //     {
    //         RenderSettings.ambientLight = Color.white;

    //         for (int i = 0; i < mapMat.Count; i++)
    //         {
    //             mapMat[i].color = Color.white;
    //         }

    //         // var lightmaps = new LightmapData[dayLightMap.Count];
    //         // for (int i = 0; i < dayLightMap.Count; i++)
    //         // {
    //         //     LightmapData data = new LightmapData();
    //         //     data.lightmapColor = dayLightMap[i];
    //         //     data.lightmapDir = dayLightDir[i];
    //         //     lightmaps[i] = data;
    //         // }
    //         // LightmapSettings.lightmaps = lightmaps;
    //         // DayOrNight.Play("Day");
    //         // DayOrNight.speed = -1;
    //     }
    //     if (GUILayout.Button("night"))
    //     {
    //         RenderSettings.ambientLight = Color.black;
    //         for (int i = 0; i < mapMat.Count; i++)
    //         {
    //             mapMat[i].color = new Color(0.2f,0.2f,0.2f);  //Color.black;
    //         }
    //         // RenderSettings.ambientMode = AmbientMode.Trilight;
    //         // RenderSettings.ambientSkyColor = Color.gray;
    //         // RenderSettings.ambientEquatorColor = Color.black;
    //         // RenderSettings.ambientGroundColor = Color.black;

    //         // var lightmaps = new LightmapData[nightLightMap.Count];
    //         // for (int i = 0; i < nightLightMap.Count; i++)
    //         // {
    //         //     LightmapData data = new LightmapData();
    //         //     data.lightmapColor = nightLightMap[i];
    //         //     data.lightmapDir = nightLightDir[i];
    //         //     lightmaps[i] = data;
    //         // }
    //         // LightmapSettings.lightmaps = lightmaps;
    //     //    DayOrNight.Play("Night");
    //         // DayOrNight.speed = 1;
    //     }
    // }
}