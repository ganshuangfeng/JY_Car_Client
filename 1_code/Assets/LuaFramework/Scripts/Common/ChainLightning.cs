
using System;
using System.Collections.Generic;
using UnityEngine;
///<summary>
/// uv贴图闪电链
///</summary>
[RequireComponent(typeof(LineRenderer))]
public class ChainLightning :MonoBehaviour
{
    //美术资源中进行调整
    public float detail = 1;//增加后，线条数量会减少，每个线条会更长。
    public float displacement = 1000;//位移量，也就是线条数值方向偏移的最大值
 
    public Transform target;//链接目标
    public Transform start;
    public float yOffset = 0;  
    [Tooltip("纹理中的行数"), SerializeField]
    public int matTextureRows = 1;
    [Tooltip("纹理中的列数"), SerializeField]
    public int matTextureColumns = 1;
    private LineRenderer _lineRender;
    private List<Vector3> _linePosList;
    private Vector2 matTextureSize;
    private Vector2[] matTextureOffset;

    private System.Random randomGenerator = new System.Random();
 
    private void Awake()
    {
        _lineRender =GetComponent<LineRenderer>();
        _linePosList = new List<Vector3>();
    }

    private void Start(){
        SetMaterialTextute();
    }
 
    public float speed = 0.1f;
    private int loop_count = 0;
    private void Update()
    {
        if(Time.timeScale != 0)
        {
            loop_count ++;
            if(loop_count % (1 / speed) == 0){
                SelectOffset();
            _linePosList.Clear();
            Vector3 startPos =Vector3.zero;
            Vector3 endPos =Vector3.zero;
            if (target != null)
            {
                endPos =target.position + Vector3.up *yOffset;
            }
            if(start != null)
            {
                startPos =start.position + Vector3.up *yOffset;
            }
 
            CollectLinPos(startPos,endPos, displacement);
           _linePosList.Add(endPos);
           _lineRender.SetVertexCount(_linePosList.Count);
            for (int i = 0, n = _linePosList.Count; i< n; i++)
            {
               _lineRender.SetPosition(i, _linePosList[i]);
            }
            }
        }
    }
 
    //收集顶点，中点分形法插值抖动
    private void CollectLinPos(Vector3 startPos,Vector3 destPos,float displace)
    {
        if (displace < detail)
        {
           _linePosList.Add(startPos);
        }
        else
        {
 
            float midX = (startPos.x + destPos.x) / 2;
            float midY = (startPos.y + destPos.y) / 2;
            float midZ = (startPos.z + destPos.z) / 2;
 
            midX += (float)(UnityEngine.Random.value - 0.5) * displace;
            midY += (float)(UnityEngine.Random.value - 0.5) * displace;
            // midZ += (float)(UnityEngine.Random.value - 0.5) * displace;
 
            Vector3 midPos =new Vector3(midX,midY,midZ);
 
            CollectLinPos(startPos,midPos, displace / 2);
            CollectLinPos(midPos,destPos, displace / 2);
        }
    }
 
    //设置材质贴图的尺寸
    private void SetMaterialTextute()
    {
        matTextureSize = new Vector2(1.0f / matTextureColumns, 1.0f / matTextureRows);
        _lineRender.material.mainTextureScale = matTextureSize;
 
        matTextureOffset = new Vector2[matTextureRows * matTextureColumns];
        for (int y = 0; y < matTextureRows; y++)
        {
            for (int x = 0; x < matTextureColumns; x++)
            {
                matTextureOffset[x + (y * matTextureColumns)] = new Vector2((float)x / matTextureColumns, (float)y / matTextureRows);
            }
        }
    }

    private void SelectOffset(){
        int material_index = 0;
        //贴图列表中随机
        material_index = randomGenerator.Next(0, matTextureOffset.Length);

        _lineRender.material.mainTextureOffset = matTextureOffset[material_index];
    }
}
