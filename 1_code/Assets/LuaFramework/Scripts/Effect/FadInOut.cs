//淡入淡出效果实现



using UnityEngine;
using System.Collections;

public class FadInOut : MonoBehaviour
{
    public float duration = 0.4f;

    float startTime;
    Material mat = null;

    // Use this for initialization
    void Start()
    {
        startTime = Time.time;//得到启动时间

        MeshRenderer meshRenderer = GetComponent<MeshRenderer>();
        if (!meshRenderer || !meshRenderer.material)
        {
            base.enabled = false;//为空的话 禁用
            // DestroyImmediate(gameObject);//达到设置时间，销毁
        }
        else
        {
            mat = meshRenderer.material;//得到材质
            ReplaceShader();//替换Shader
        }
    }

    // Update is called once per frame
    void Update()
    {
        float time = Time.time - startTime;//获取运行时间
        if (time > duration)
        {
            DestroyImmediate(gameObject);//达到设置时间，销毁
        }
        else
        {
            float remainderTime = duration - time;//得到剩余时间
            if (mat)
            {
                //if(mat.HasProperty("_Color")) 得到mat中是否有这个属性

                Color col = mat.GetColor("_Color");//得到材质中的shader中的_Color颜色
                col.a = remainderTime;//设置Alpha(剩余时间越小 Alpha值越小)
                mat.SetColor("_Color", col);//将修改后的颜色设置回去

                // col = mat.GetColor("_OutlineColor");//原理同上
                // col.a = remainderTime;
                // mat.SetColor("_OutlineColor", col);
            }
        }
    }

    private void ReplaceShader()
    {
        // if (mat.shader.name.Equals("Custom/Toon/Basic Outline"))//检查当前shader名字是否是“ ”
        // {
        //     mat.shader = Shader.Find("Custom/Toon/Basic Outline Replace");//如果是的话 替换shader
        // }
        // else if (mat.shader.name.Equals("Custom/Toon/Basic"))
        // {
        //     mat.shader = Shader.Find("Custom/Toon/Basic Replace");
        // }
        // else
        // {
        //     Debug.LogError("Can't find target shader");
        // }
        var shader = Shader.Find("Custom/Transparent");
        if (shader){
            mat.shader = shader;
        }
        else{
            Debug.LogError("Can't find target shader");
        }
    }
}