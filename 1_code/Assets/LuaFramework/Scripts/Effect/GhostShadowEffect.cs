using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GhostShadowEffect : MonoBehaviour {

    [Header("是否开启残影效果")]
    public bool openGhoseEffect;
    [Header("生成残影与残影之间的时间间隔")]
    public float interval = 0.2f;
    [Header("显示残影的持续时间")]
    public float duration = 0.4f;
    [Header("残影颜色")]
    public Color color = Color.white;
    float lastTime = 0.0f;

    MeshFilter[] meshFilters = null;

    MeshRenderer[] meshRenderers = null;

    SkinnedMeshRenderer[] skinedMeshRenderers = null;

    List<GameObject> objs = new List<GameObject>();
    private Vector3 lastPos = Vector3.zero;

    // Use this for initialization
    void Start () 
    {
        meshFilters = gameObject.GetComponentsInChildren<MeshFilter>();
        skinedMeshRenderers = gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
        lastPos = this.transform.position;
        Debug.Log(meshFilters.Length + "meshFilters.length???");
        Debug.Log(skinedMeshRenderers.Length + "skinedMeshRenderers.length???");
    }

    void OnDisable()
    {
        foreach (GameObject go in objs)
        {
            DestroyImmediate(go);
        }
        objs.Clear();
        objs = null;
    }
    // 每帧更新
    void Update () 
    {
        if (openGhoseEffect == false) {
            return;
        }

        //人物有位移才创建残影
        if (lastPos == this.transform.position)
        {
            return;
        }
        lastPos = this.transform.position;

        if (Time.time - lastTime > interval)
        {
            lastTime = Time.time;

            for (int i = 0; skinedMeshRenderers != null && i < skinedMeshRenderers.Length; ++i)
            {
                Mesh mesh = new Mesh();

                skinedMeshRenderers[i].BakeMesh(mesh);

                GameObject go = new GameObject();
                // go.name = "ghost_effect";
                go.hideFlags = HideFlags.HideAndDontSave;
                MeshFilter meshFilter = go.AddComponent<MeshFilter>();
                meshFilter.mesh = mesh;

                MeshRenderer meshRenderer = go.AddComponent<MeshRenderer>();
                meshRenderer.material = skinedMeshRenderers[i].material;
                go.transform.parent = skinedMeshRenderers[i].transform.parent;
                InitFadeInObj(go, skinedMeshRenderers[i].transform.position,skinedMeshRenderers[i].transform.localScale,
                    skinedMeshRenderers[i].transform.rotation, duration);
            }
            // for (int i = 0; meshFilters != null && i < meshFilters.Length; ++i)
            // {
            //     GameObject go = Instantiate(meshFilters[i].gameObject) as GameObject;
            //     go.name = "ghost";
            //     InitFadeInObj(go, meshFilters[i].transform.position, meshFilters[i].transform.rotation, duration);
            // }
        }
    }

    private void InitFadeInObj(GameObject go, Vector3 position,Vector3 scale, Quaternion rotation, float duration)
    {
        // go.hideFlags = HideFlags.HideAndDontSave;
        go.transform.localScale = scale;
        go.transform.position = position;
        go.transform.rotation = rotation;
        go.transform.parent = null;
        FadInOut fi = go.AddComponent<FadInOut>();
        fi.duration = duration;
        objs.Add(go);
    }
}