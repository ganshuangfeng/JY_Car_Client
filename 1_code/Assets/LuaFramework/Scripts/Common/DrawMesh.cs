using UnityEngine;
using System.Collections;
using LuaFramework;

//预制体翻转过180度 绘制的时候是顶点逆时针旋转
public class DrawMesh : MonoBehaviour
{

    #region 画三角形
    public Mesh DrawTriangle(Vector3 v1, Vector3 v2, Vector3 v3)
    {   
        Mesh mesh = new Mesh();
        mesh.Clear();
 
        //设置顶点
        mesh.vertices = new Vector3[] { v1,v2,v3 };
        //设置三角形顶点顺序，顺时针设置
        mesh.triangles = new int[] { 0, 1, 2 };
        return mesh;
    }
    #endregion
 
    #region 画正方形
    public Mesh DrawSquare(Vector3 v1, Vector3 v2, Vector3 v3,Vector3 v4)
    { 
        Mesh mesh = new Mesh();
        mesh.vertices = new Vector3[] { v1, v2, v3, v4};
        mesh.uv = new Vector2[] {new Vector2(0,1) , new Vector2(0,0), new Vector2(1,0), new Vector2(1,1)};
        mesh.triangles = new int[]
        { 0, 1, 2,
          0, 2, 3
        };
        // Debug.Log("x:" + mesh.uv.x);
        // Debug.Log("x:" + mesh.uv.y);
        // Vector2[] uvs = new Vector2[mesh.vertices.Length];
        // for(int i = 0; i < uvs.Length;i++ ){
        //     uvs[i] = 
        // }
        return mesh;
    }
    #endregion
 
    #region 画圆
    /// <summary>
    /// 画圆
    /// </summary>
    /// <param name="radius">圆的半径</param>
    /// <param name="segments">圆的分割数</param>
    /// <param name="centerCircle">圆心得位置</param>
    public Mesh DrawCircle(float radius, int segments, Vector3 centerCircle)
    { 
        //顶点
        Vector3[] vertices = new Vector3[segments + 1];
        vertices[0] = centerCircle;
        float deltaAngle = Mathf.Deg2Rad * 360f / segments;
        float currentAngle = 0;
        for (int i = 1; i < vertices.Length; i++)
        {
            float cosA = Mathf.Cos(currentAngle);
            float sinA = Mathf.Sin(currentAngle);
            vertices[i] = new Vector3(cosA * radius + centerCircle.x, sinA * radius + centerCircle.y, 0);
            currentAngle += deltaAngle;
        }
 
        //三角形
        int[] triangles = new int[segments * 3];
        for (int i = 0, j = 1; i < segments * 3 - 3; i += 3, j++)
        {
            triangles[i] = 0;
            triangles[i + 1] = j + 1;
            triangles[i + 2] = j;
        }
        triangles[segments * 3 - 3] = 0;
        triangles[segments * 3 - 2] = 1;
        triangles[segments * 3 - 1] = segments;
 
 
        Mesh mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        return mesh;
    }
    #endregion
 
    #region 画圆环
    /// <summary>
    /// 画圆环
    /// </summary>
    /// <param name="radius">圆半径</param>
    /// <param name="innerRadius">内圆半径</param>
    /// <param name="segments">圆的分个数</param>
    /// <param name="centerCircle">圆心坐标</param>
    public Mesh DrawRing(float radius, float innerRadius, int segments, Vector3 centerCircle)
    {
        //顶点
        Vector3[] vertices = new Vector3[segments * 2];
        float deltaAngle = Mathf.Deg2Rad * 360f / segments;
        float currentAngle = 0;
        for (int i = 0; i < vertices.Length; i += 2)
        {
            float cosA = Mathf.Cos(currentAngle);
            float sinA = Mathf.Sin(currentAngle);
            vertices[i] = new Vector3(cosA * innerRadius + centerCircle.x, sinA * innerRadius + centerCircle.y, 0);
            vertices[i + 1] = new Vector3(cosA * radius + centerCircle.x, sinA * radius + centerCircle.y, 0);
            currentAngle += deltaAngle;
        }
 
        //三角形
        int[] triangles = new int[segments * 6];
        for (int i = 0, j = 0; i < segments * 6; i += 6, j += 2)
        {
            triangles[i] = j;
            triangles[i + 1] = (j + 1) % vertices.Length;
            triangles[i + 2] = (j + 3) % vertices.Length;
 
            triangles[i + 3] = j;
            triangles[i + 4] = (j + 3) % vertices.Length;
            triangles[i + 5] = (j + 2) % vertices.Length;
        }
 
        Mesh mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        return mesh;
    }
    #endregion

    #region 画扇形面
    /// <summary>
    /// 画扇形面
    /// </summary>
    /// <param name="radius">圆半径</param>
    /// <param name="innerRadius">内圆半径</param>
    /// <param name="segments">圆的分个数</param>
    /// <param name="angledegree">扇形或扇面的角度</param>
    /// <param name="centerCircle">圆心坐标</param>
    public Mesh Flabellate (float radius, float innerradius,float angledegree,int segments,Vector3 centerCircle, float roationAngle = 0)
    {
        //vertices(顶点):
        int vertices_count = segments* 2+2;              //因为vertices(顶点)的个数与triangles（索引三角形顶点数）必须匹配
        Vector3[] vertices = new Vector3[vertices_count];       
        float angleRad = Mathf.Deg2Rad * angledegree;
        float angleCur = Mathf.Deg2Rad * roationAngle;
        float angledelta = angleRad / segments;
        Vector2[] uvs = new Vector2[vertices_count];
        for(int i=0;i< vertices_count; i+=2)
        {
            float cosA = Mathf.Cos(angleCur);
            float sinA = Mathf.Sin(angleCur);

            vertices[i] = new Vector3(innerradius * cosA + centerCircle.x, innerradius * sinA + centerCircle.y, 0);
            vertices[i + 1] = new Vector3(radius * cosA + centerCircle.x, radius * sinA + centerCircle.y, 0);
            uvs[i] = new Vector2(1,i / segments);
            uvs[i + 1] = new Vector2(0,i / segments);
            angleCur += angledelta;
        }


        //三角形
        int[] triangles = new int[segments * 6];
        for (int i = 0, j = 0; i < segments * 6; i += 6, j += 2)
        {
            triangles[i] = j;
            triangles[i + 1] = (j + 1) % vertices.Length;
            triangles[i + 2] = (j + 3) % vertices.Length;
 
            triangles[i + 3] = j;
            triangles[i + 4] = (j + 3) % vertices.Length;
            triangles[i + 5] = (j + 2) % vertices.Length;
        }
        
        // //uv:
        // Vector2[] uvs = new Vector2[vertices_count];
        // for (int i = 0; i < vertices_count; i++)
        // {
        //     uvs[i] = new Vector2(vertices[i].x / radius / 2 + 0.5f, vertices[i].y / radius / 2 + 0.5f);
        // }


        //负载属性与mesh
        Mesh mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        return mesh;
    }
    #endregion


    #region 在GameObject上画Mesh
    public GameObject CreateDrawMeshGameObject(Material mat,Mesh mesh)
    {   
        var go = new GameObject();
        go.transform.parent = gameObject.transform;
        var meshFilter = go.AddComponent<MeshFilter>();
        var meshRenderer = go.AddComponent<MeshRenderer>();
        meshRenderer.material = mat;

        meshFilter.mesh.Clear();
        meshFilter.mesh = mesh;
        return go;

        // var v1 = mesh.vertices[mesh.vertices.Length - 1];
        // var v2 = mesh.vertices[mesh.vertices.Length - 2];

        // var go2 = new GameObject("Square");
        // go2.transform.parent = gameObject.transform;
        // var mesh2 = DrawSquare(v1, new Vector3(v1.x - 10, v1.y, v1.z), new Vector3(v2.x - 10, v2.y, v2.z) ,v2);

        // MergeMesh();
    }
    #endregion

    /// <summary>
    /// gameObject为空对象。其子物体有对应的物体入方块，球，胶囊
    /// 运行后空物体将会生成一个将方块球胶囊合并的网格
    /// </summary>
    public GameObject MergeMesh(MeshFilter[] meshFilters, Material mat)
    {
        if (meshFilters == null || meshFilters.Length == 0) {
            meshFilters = GetComponentsInChildren<MeshFilter>();
        }
        CombineInstance[] combineInstances = new CombineInstance[meshFilters.Length];
        for (int i = 0; i < meshFilters.Length; i++)
        {
            combineInstances[i].mesh = meshFilters[i].mesh;
            combineInstances[i].transform = meshFilters[i].transform.localToWorldMatrix;
        }
        Mesh newMesh = new Mesh();
        newMesh.CombineMeshes(combineInstances);

        GameObject go = new GameObject();
        go.transform.parent = gameObject.transform;
        go.name = "MergeMesh";

        var meshFilter = go.AddComponent<MeshFilter>();
        meshFilter.sharedMesh = newMesh;
        var meshRenderer = go.AddComponent<MeshRenderer>();
        meshRenderer.material = mat;
        return go;
    }

    public void DrawRoad(){
        float hight = 1.46f;
        float width = 1.58f;
        float length = 1.2f;
        float rad = 1.8f;
        float inrad = 0.2f;

        float centerCircleX = width * 3 / 2 + length;
        float centerCircleY = hight * 6 / 2 + length;

        //右上角
        Vector3 centerCircle = new Vector3(centerCircleX, centerCircleY,0);
        var mesh1 = Flabellate(rad, inrad,90, 50,centerCircle);
        var go1 = CreateDrawMeshGameObject(null,mesh1);
        go1.transform.parent = gameObject.transform;
        var v1 = mesh1.vertices[mesh1.vertices.Length - 1];
        var v2 = mesh1.vertices[mesh1.vertices.Length - 2];

        var mesh2 = DrawSquare(v1, new Vector3(v1.x - length, v1.y, v1.z), new Vector3(v2.x - length, v2.y, v2.z) ,v2);
        var go2 = CreateDrawMeshGameObject(null,mesh2);
        go2.transform.parent = gameObject.transform;

        v1 = mesh1.vertices[0];
        v2 = mesh1.vertices[1];
        var mesh3 = DrawSquare(v1, new Vector3(v1.x, v1.y  - length, v1.z), new Vector3(v2.x, v2.y  - length, v2.z) ,v2);
        var go3 = CreateDrawMeshGameObject(null,mesh3);
        go3.transform.parent = gameObject.transform;

        MeshFilter[] meshFilters = new MeshFilter[3];
        meshFilters[0] = go1.GetComponent<MeshFilter>();
        meshFilters[1] = go2.GetComponent<MeshFilter>();
        meshFilters[2] = go3.GetComponent<MeshFilter>();
        var mergeObj = MergeMesh(meshFilters,null);
        mergeObj.transform.localRotation = new Quaternion(0,0,0,0);
        mergeObj.transform.localPosition = Vector3.zero;
        mergeObj.layer = 8;
        mergeObj.name = "14";
        Destroy(go1);
        Destroy(go2);
        Destroy(go3);

        var mesh = mesh2;
        var mesh_1 = mesh;
        for (int i = 0; i < 3; i++)
        {
            v1 = mesh.vertices[1];
            v2 = mesh.vertices[2];
            mesh = DrawSquare(v1, new Vector3(v1.x - width, v1.y, v1.z), new Vector3(v2.x - width, v2.y, v2.z) ,v2);
            mesh_1 = mesh;
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = (14 - i - 1).ToString();
        }

        mesh = mesh3;
        var mesh_2 = mesh;
        for (int i = 0; i < 6; i++)
        {
            v1 = mesh.vertices[1];
            v2 = mesh.vertices[2];
            mesh = DrawSquare(v1, new Vector3(v1.x, v1.y  - hight, v1.z), new Vector3(v2.x, v2.y  - hight, v2.z) ,v2);
            mesh_2 = mesh;
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = (14 + i + 1).ToString();
        }

        //左下角
        centerCircle = new Vector3(-centerCircleX, -centerCircleY,0);
        mesh1 = Flabellate(rad, inrad,90, 50,centerCircle,180);
        go1 = CreateDrawMeshGameObject(null,mesh1);
        go1.transform.parent = gameObject.transform;
        v1 = mesh1.vertices[mesh1.vertices.Length - 1];
        v2 = mesh1.vertices[mesh1.vertices.Length - 2];

        mesh2 = DrawSquare(v1, new Vector3(v1.x + length, v1.y, v1.z), new Vector3(v2.x + length, v2.y, v2.z) ,v2);
        go2 = CreateDrawMeshGameObject(null,mesh2);
        go2.transform.parent = gameObject.transform;

        v1 = mesh1.vertices[0];
        v2 = mesh1.vertices[1];
        mesh3 = DrawSquare(v1, new Vector3(v1.x, v1.y  + length, v1.z), new Vector3(v2.x, v2.y  + length, v2.z) ,v2);
        go3 = CreateDrawMeshGameObject(null,mesh3);
        go3.transform.parent = gameObject.transform;

        meshFilters = new MeshFilter[3];
        meshFilters[0] = go1.GetComponent<MeshFilter>();
        meshFilters[1] = go2.GetComponent<MeshFilter>();
        meshFilters[2] = go3.GetComponent<MeshFilter>();
        mergeObj = MergeMesh(meshFilters,null);
        mergeObj.transform.localRotation = new Quaternion(0,0,0,0);
        mergeObj.transform.localPosition = Vector3.zero;
        mergeObj.layer = 8;
        mergeObj.name = "3";
        Destroy(go1);
        Destroy(go2);
        Destroy(go3);

        mesh = mesh2;
        mesh_1 = mesh;
        for (int i = 0; i < 3; i++)
        {
            v1 = mesh.vertices[1];
            v2 = mesh.vertices[2];
            mesh = DrawSquare(v1, new Vector3(v1.x + width, v1.y, v1.z), new Vector3(v2.x + width, v2.y, v2.z) ,v2);
            mesh_1 = mesh;
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            if (3 - i - 1 > 0)  {
                go.name = (3 - i - 1).ToString();
            }
            else{
                go.name = "22";
            }
        }

        mesh = mesh3;
        mesh_2 = mesh;
        for (int i = 0; i < 6; i++)
        {
            v1 = mesh.vertices[1];
            v2 = mesh.vertices[2];
            mesh = DrawSquare(v1, new Vector3(v1.x, v1.y  + hight, v1.z), new Vector3(v2.x, v2.y  + hight, v2.z) ,v2);
            mesh_2 = mesh;
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = (3 + i + 1).ToString();
        }

        //右下角
        centerCircle = new Vector3(centerCircleX, -centerCircleY,0);
        mesh1 = Flabellate(rad, inrad,90, 50,centerCircle,270);
        go1 = CreateDrawMeshGameObject(null,mesh1);
        go1.transform.parent = gameObject.transform;
        v1 = mesh1.vertices[0];
        v2 = mesh1.vertices[1];

        mesh2 = DrawSquare(v1, new Vector3(v1.x - length, v1.y, v1.z), new Vector3(v2.x - length, v2.y, v2.z) ,v2);
        go2 = CreateDrawMeshGameObject(null,mesh2);
        go2.transform.parent = gameObject.transform;

        v1 = mesh1.vertices[mesh1.vertices.Length - 1];
        v2 = mesh1.vertices[mesh1.vertices.Length - 2];
        mesh3 = DrawSquare(v1, new Vector3(v1.x, v1.y  + length, v1.z), new Vector3(v2.x, v2.y  + length, v2.z) ,v2);
        go3 = CreateDrawMeshGameObject(null,mesh3);
        go3.transform.parent = gameObject.transform;

        meshFilters = new MeshFilter[3];
        meshFilters[0] = go1.GetComponent<MeshFilter>();
        meshFilters[1] = go2.GetComponent<MeshFilter>();
        meshFilters[2] = go3.GetComponent<MeshFilter>();
        mergeObj = MergeMesh(meshFilters,null);
        mergeObj.transform.localRotation = new Quaternion(0,0,0,0);
        mergeObj.transform.localPosition = Vector3.zero;
        mergeObj.layer = 8;
        mergeObj.name = "21";
        Destroy(go1);
        Destroy(go2);
        Destroy(go3);

        //左上角
        centerCircle = new Vector3(-centerCircleX, centerCircleY,0);
        mesh1 = Flabellate(rad, inrad,90, 50,centerCircle,90);
        go1 = CreateDrawMeshGameObject(null,mesh1);
        go1.transform.parent = gameObject.transform;
        v1 = mesh1.vertices[0];
        v2 = mesh1.vertices[1];

        mesh2 = DrawSquare(v1, new Vector3(v1.x + length, v1.y, v1.z), new Vector3(v2.x + length, v2.y, v2.z) ,v2);
        go2 = CreateDrawMeshGameObject(null,mesh2);
        go2.transform.parent = gameObject.transform;

        v1 = mesh1.vertices[mesh1.vertices.Length - 1];
        v2 = mesh1.vertices[mesh1.vertices.Length - 2];

        mesh3 = DrawSquare(v1, new Vector3(v1.x, v1.y  - length, v1.z), new Vector3(v2.x, v2.y  - length, v2.z) ,v2);
        go3 = CreateDrawMeshGameObject(null,mesh3);
        go3.transform.parent = gameObject.transform;

        meshFilters = new MeshFilter[3];
        meshFilters[0] = go1.GetComponent<MeshFilter>();
        meshFilters[1] = go2.GetComponent<MeshFilter>();
        meshFilters[2] = go3.GetComponent<MeshFilter>();
        mergeObj = MergeMesh(meshFilters,null);
        mergeObj.transform.localRotation = new Quaternion(0,0,0,0);
        mergeObj.transform.localPosition = Vector3.zero;
        mergeObj.layer = 8;
        mergeObj.name = "10";
        Destroy(go1);
        Destroy(go2);
        Destroy(go3);
        gameObject.SetActive(false);
    }

    public GameObject CreateRoadRange(int[] road_ids,Material mat,Material mat1 = null){
        for (int i = 0; i < road_ids.Length; i++)
        {
            Debug.Log(road_ids[i]);
        }

        if (road_ids == null || road_ids.Length == 0) return null;

        GameObject obj = GameObject.Instantiate(gameObject);
        var draw_mesh = obj.GetComponent<DrawMesh>();
        if (draw_mesh != null){
            Destroy(draw_mesh);
        }

        MeshFilter[] meshFilters = new MeshFilter[road_ids.Length];
        for (int i = 0; i < road_ids.Length; i++)
        {
            var road_id = road_ids[i];
            var go = obj.transform.Find(road_id.ToString());
            meshFilters[i] = go.GetComponent<MeshFilter>();
        }
        CombineInstance[] combineInstances = new CombineInstance[meshFilters.Length];
        for (int i = 0; i < meshFilters.Length; i++)
        {
            combineInstances[i].mesh = meshFilters[i].mesh;
            combineInstances[i].transform = meshFilters[i].transform.localToWorldMatrix;
        }
        Mesh newMesh = new Mesh();
        newMesh.CombineMeshes(combineInstances);

        for (int i = 0; i < obj.transform.childCount; i++)
        {
            Destroy(obj.transform.GetChild(i).gameObject);
        }

        var meshFilter = obj.GetComponent<MeshFilter>();
        if (meshFilter == null) {
            meshFilter = obj.AddComponent<MeshFilter>();
        }
        meshFilter.sharedMesh = newMesh;
        var meshRenderer = obj.GetComponent<MeshRenderer>();
        if(meshRenderer == null) {
            meshRenderer = obj.AddComponent<MeshRenderer>();
        }
        meshRenderer.material = mat;

        obj.transform.parent = gameObject.transform;
        obj.transform.localPosition = Vector3.zero;
        obj.transform.localRotation = new Quaternion(0,0,0,0);
        obj.transform.parent = gameObject.transform.parent;
        obj.SetActive(true);
        CreatHead(road_ids,obj,mat1);
        return obj;
    }

    void  CreatHead(int[] road_ids,GameObject obj,Material mat)
    {
        Debug.Log(mat.name + "材质名字///////");
        var weiroad = obj.transform.Find(road_ids[0].ToString());
        var weiroad_meshfilter = weiroad.GetComponent<MeshFilter>();
        var weiroad_mesh = weiroad_meshfilter.mesh; 
        for(int i = 0;i < weiroad_mesh.vertices.Length; i++){
        }
        if(road_ids[0] == 22||road_ids[0] == 1||road_ids[0] == 2)
        {
            var v1 = weiroad_mesh.vertices[1];
            var v2 = weiroad_mesh.vertices[2];
            var mesh = DrawSquare(new Vector3(v2.x + 0.415182f,v2.y,v2.z),v2,v1,new Vector3(v1.x + 0.415182f,v1.y,v1.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "wei";
            go.transform.parent = obj.transform;
        }else if(road_ids[0] == 3){
            var v1 = weiroad_mesh.vertices[weiroad_mesh.vertices.Length -6];
            var v2 = weiroad_mesh.vertices[weiroad_mesh.vertices.Length -7];

            var mesh = DrawSquare(new Vector3(v1.x + 0.415182f,v1.y,v1.z),v1,v2,new Vector3(v2.x + 0.415182f,v2.y,v2.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "wei";
            go.transform.parent = obj.transform;
        }else if(road_ids[0] <= 9 && road_ids[0] >= 3)
        {
            var v1 = weiroad_mesh.vertices[0];
            var v2 = weiroad_mesh.vertices[3];

            var mesh = DrawSquare(new Vector3(v1.x,v1.y - 0.415182f,v1.z),v1,v2,new Vector3(v2.x,v2.y - 0.415182f,v2.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "wei";
            go.transform.parent = obj.transform;
        }else if(road_ids[0] == 10){
            var v1 = weiroad_mesh.vertices[weiroad_mesh.vertices.Length - 3];
            var v2 = weiroad_mesh.vertices[weiroad_mesh.vertices.Length - 2];

            var mesh = DrawSquare(new Vector3(v2.x,v2.y - 0.415182f,v2.z),v2,v1,new Vector3(v1.x,v1.y - 0.415182f,v1.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "wei";
            go.transform.parent = obj.transform;
        }else if(road_ids[0] >= 11&&road_ids[0] <= 13){
            var v1 = weiroad_mesh.vertices[weiroad_mesh.vertices.Length - 3];
            var v2 = weiroad_mesh.vertices[weiroad_mesh.vertices.Length - 2];

            var mesh = DrawSquare(new Vector3(v2.x - 0.415182f,v2.y,v2.z),v2,v1,new Vector3(v1.x - 0.415182f,v1.y,v1.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "wei";
            go.transform.parent = obj.transform;
        }
        else if(road_ids[0] == 14){
            var v1 = weiroad_mesh.vertices[weiroad_mesh.vertices.Length - 7];
            var v2 = weiroad_mesh.vertices[weiroad_mesh.vertices.Length - 6];
            var mesh = DrawSquare(new Vector3(v2.x - 0.415182f,v2.y,v2.z),v2,v1,new Vector3(v1.x - 0.415182f,v1.y,v1.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "wei";
            go.transform.parent = obj.transform;
        }
        else if(road_ids[0] >= 15&&road_ids[0] <= 20){
            var v1 = weiroad_mesh.vertices[0];
            var v2 = weiroad_mesh.vertices[3];
            var mesh = DrawSquare(new Vector3(v1.x,v1.y + 0.415182f,v1.z),v1,v2,new Vector3(v2.x,v2.y + 0.415182f,v2.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "wei";
            go.transform.parent = obj.transform;
        }
        else if(road_ids[0] == 21){
            var v1 = weiroad_mesh.vertices[weiroad_mesh.vertices.Length - 2];
            var v2 = weiroad_mesh.vertices[weiroad_mesh.vertices.Length - 3];
            var mesh = DrawSquare(new Vector3(v1.x,v1.y + 0.415182f,v1.z),v1,v2,new Vector3(v2.x,v2.y + 0.415182f,v2.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "wei";
            go.transform.parent = obj.transform;
        }

        int max = road_ids.Length - 1;
        var touroad = obj.transform.Find(road_ids[max].ToString());
        var touroad_meshfilter = touroad.GetComponent<MeshFilter>();
        var touroad_mesh = touroad_meshfilter.mesh; 
        for(int i = 0;i < touroad_mesh.vertices.Length; i++){
            Debug.Log(touroad_mesh.vertices[i]);
        }
        if(road_ids[max] == 22||road_ids[max] == 1||road_ids[max] == 2)
        {   
            var v1 = touroad_mesh.vertices[3];
            var v2 = touroad_mesh.vertices[0];
            var mesh = DrawSquare(new Vector3(v2.x - 0.415182f,v2.y,v2.z),v2,v1,new Vector3(v1.x - 0.415182f,v1.y,v1.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "tou";
            go.transform.parent = obj.transform;
        }
        else if(road_ids[max] == 3)
        {  
            var v1 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 3];
            var v2 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 2];
            var mesh = DrawSquare(new Vector3(v2.x,v2.y + 0.415182f,v2.z),v2,v1,new Vector3(v1.x,v1.y + 0.415182f,v1.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "tou";
            go.transform.parent = obj.transform;
        }
        else if(road_ids[max] <= 9 && road_ids[max] >= 3)
        {
            var v1 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 3];
            var v2 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 2];
            var mesh = DrawSquare(new Vector3(v2.x,v2.y + 0.415182f,v2.z),v2,v1,new Vector3(v1.x,v1.y + 0.415182f,v1.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "tou";
            go.transform.parent = obj.transform;
        }
        else if(road_ids[max] == 10)
        {
            var v1 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 6];
            var v2 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 7];
            var mesh = DrawSquare(new Vector3(v1.x + 0.415182f,v1.y,v1.z),v1,v2,new Vector3(v2.x + 0.415182f,v2.y,v2.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "tou";
            go.transform.parent = obj.transform;
        }
        else if(road_ids[max] >= 11&&road_ids[max] <= 13)
        {
            var v1 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 4];
            var v2 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 1];
            var mesh = DrawSquare(new Vector3(v1.x + 0.415182f,v1.y,v1.z),v1,v2,new Vector3(v2.x + 0.415182f,v2.y,v2.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "tou";
            go.transform.parent = obj.transform;
        }
        else if(road_ids[max] == 14)
        {
            var v1 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 3];
            var v2 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 2];
            var mesh = DrawSquare(new Vector3(v2.x,v2.y - 0.415182f,v2.z),v2,v1,new Vector3(v1.x,v1.y - 0.415182f,v1.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "tou";
            go.transform.parent = obj.transform;
        }
        else if(road_ids[max] >= 15&&road_ids[max] <= 20)
        {
            var v1 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 3];
            var v2 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 2];
            var mesh = DrawSquare(new Vector3(v2.x,v2.y - 0.415182f,v2.z),v2,v1,new Vector3(v1.x,v1.y - 0.415182f,v1.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "tou";
            go.transform.parent = obj.transform;
        }
        else if(road_ids[max] == 21){
            var v1 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 7];
            var v2 = touroad_mesh.vertices[touroad_mesh.vertices.Length - 6];
            var mesh = DrawSquare(new Vector3(v2.x - 0.415182f,v2.y,v2.z),v2,v1,new Vector3(v1.x - 0.415182f,v1.y,v1.z));
            var go = CreateDrawMeshGameObject(null,mesh);
            go.transform.parent = gameObject.transform;
            go.transform.localRotation = new Quaternion(0,0,0,0);
            go.transform.localPosition = Vector3.zero;
            go.layer = 8;
            go.name = "tou";
            go.transform.parent = obj.transform;
        }


        var meshRenderer = obj.transform.Find("tou").GetComponent<MeshRenderer>();
        if(meshRenderer == null) {
            meshRenderer = obj.AddComponent<MeshRenderer>();
        }
        meshRenderer.material = mat;

        meshRenderer = obj.transform.Find("wei").GetComponent<MeshRenderer>();
        if(meshRenderer == null) {
            meshRenderer = obj.AddComponent<MeshRenderer>();
        }
        meshRenderer.material = mat;
    }

    // void OnGUI()
    // {
    //     if (GUILayout.Button("               MergeMesh"))
    //     {
    //         // MergeMesh();
    //     }

    //     if (GUILayout.Button("               DrawRoad"))
    //     {
    //         DrawRoad();
    //     }

    //     if (GUILayout.Button("               CreateRoadRange"))
    //     {
    //         int[] road_ids = new int[4];
    //         road_ids[0] = 22;
    //         road_ids[1] = 1;
    //         road_ids[2] = 2;
    //         road_ids[3] = 3;
    //         Material mat = null;
    //         CreateRoadRange( road_ids, mat);
    //     }
    // }
}