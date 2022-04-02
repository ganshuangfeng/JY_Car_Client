using UnityEngine;
using System.Collections.Generic;
 
public class GhostEffect2D : MonoBehaviour
{
    [Header("是否开启残影效果")]
    public bool openGhoseEffect;
 
    [Header("是否开启褪色消失")]
    public bool openFade;
 
    [Header("显示残影的持续时间")]
    public float durationTime;
    [Header("生成残影与残影之间的时间间隔")]
    public float spawnTimeval;
    private float spawnTimer;//生成残影的时间计时器
 
    [Header("残影颜色")]
    public Color ghostColor;
    [Header("残影层级")]
    public int ghostSortingOrder;
 
    [Header("残影GameObject")]
    public GameObject ghostGameObject;

    private List<GameObject> ghostList = new List<GameObject>();//残影列表
 
    private void Start()
    {
    }
 
    private void Update()
    {
        if (openGhoseEffect == false)
        {
            if (ghostList.Count == 0) return;
            for (int i = 0; i < ghostList.Count; i++)
            {
                GameObject tempGhost = ghostList[i];
                ghostList.Remove(tempGhost);
                Destroy(tempGhost);
            }
            return;
        }
 
        DrawGhost();
        Fade();
    }
 
    /// <summary>
    /// 绘制残影
    /// </summary>
    private void DrawGhost()
    {
        if (spawnTimer >= spawnTimeval)
        {
            spawnTimer = 0;
 
            GameObject _ghost = GameObject.Instantiate(this.ghostGameObject,this.transform.parent);
            _ghost.name = "ghost";
            _ghost.transform.position = transform.position;
            _ghost.transform.localScale = transform.localScale;
            _ghost.transform.localRotation = transform.Find("@car").transform.localRotation;
            var ghostSRs = _ghost.GetComponentsInChildren<SpriteRenderer>();
            foreach (var _sr in ghostSRs){                
                _sr.sortingOrder = ghostSortingOrder;
                _sr.color = ghostColor;
            }
 
            if (openFade == false)
            {
                Destroy(_ghost, durationTime);
            }
            else{
                ghostList.Add(_ghost);
            }
        }
        else
        {
            spawnTimer += Time.deltaTime;
        }
    }
 
    /// <summary>
    /// 褪色操作
    /// </summary>
    private void Fade()
    {
        if (openFade == false)
        {
            return;
        }
 
        for (int i = 0; i < ghostList.Count; i++)
        {
            var ghostSRs = ghostList[i].GetComponentsInChildren<SpriteRenderer>();
            foreach (var ghostSR in ghostSRs){
                if (ghostSR.color.a <= 0)
                {
                    GameObject tempGhost = ghostList[i];
                    ghostList.Remove(tempGhost);
                    Destroy(tempGhost);
                    break;
                }
                else
                {
                    float fadePerSecond = (ghostColor.a / durationTime);
                    Color tempColor = ghostSR.color;
                    tempColor.a -= fadePerSecond * Time.deltaTime;
                    ghostSR.color = tempColor;
                }
            }
        }
    }
}