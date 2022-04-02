using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GhostShadowXray : MonoBehaviour {
    [Header("是否开启残影效果")]
    public bool openGhoseEffect;
    [Header("生成残影与残影之间的时间间隔")]
    public float interval = 0.2f;
    [Header("显示残影的持续时间")]    
    public float duration = 0.4f;
    
    [Header("残影颜色")]
    public Color color = Color.white;
    [Header("边缘颜色强度")]//边缘颜色强度
    [Range(-1, 2)]
    public float Intension = 1;
    
    //网格数据
    SkinnedMeshRenderer[] meshRender;
    
    //X-ray
    Shader ghostShader;
    List<GameObject> objs = new List<GameObject>();

    private float lastTime = 0;
    
    private Vector3 lastPos = Vector3.zero;

    void Start () {
        //获取身上所有的Mesh
        meshRender = this.gameObject.GetComponentsInChildren<SkinnedMeshRenderer> ();
        
        ghostShader = Shader.Find("Custom/Xray");

        // lastPos = this.transform.position;
    }    

     void OnDisable()
    {
        if (objs != null){
             foreach (GameObject go in objs)
            {
                DestroyImmediate(go);
            }
            objs.Clear();
        }
        objs = null;
    }

    void Update () {
        if (openGhoseEffect == false) {
            return;
        }
        //人物有位移才创建残影
        if (lastPos == this.transform.position)
        {
            return;
        }
        lastPos = this.transform.position;
        if(Time.time - lastTime < interval){//残影间隔时间
            return;
        }
        lastTime = Time.time;
        
        if (meshRender == null){
            Debug.Log("meshRender == null");
            return;
        }

        for (int i = 0; i < meshRender.Length; i++) {
            Mesh mesh = new Mesh ();
            meshRender[i].BakeMesh(mesh);
            
            GameObject go = new GameObject();
            // go.name = "ghost_xray";
            go.hideFlags = HideFlags.HideAndDontSave;
            objs.Add(go);
            
            GhostItem item = go.AddComponent<GhostItem>();//控制残影消失
            item.duration = duration;
            item.deleteTime = Time.time + duration;
            
            MeshFilter filter = go.AddComponent<MeshFilter>();
            filter.mesh = mesh;
            
            MeshRenderer meshRen = go.AddComponent<MeshRenderer>();
            
            meshRen.material = meshRender[i].material;
            meshRen.material.shader = ghostShader;//设置xray效果
            meshRen.material.SetFloat("_Intension", Intension);//颜色强度传入shader中
            meshRen.material.SetColor("_RimColor",color);//颜色设置
            
            go.transform.parent = meshRender[i].transform.parent;
            go.transform.localScale = meshRender[i].transform.localScale;
            go.transform.position = meshRender[i].transform.position;
            go.transform.rotation = meshRender[i].transform.rotation;
            go.transform.parent = null;
            
            item.meshRenderer = meshRen;
        }
    }
}