using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using DG.Tweening;

//设置ScrollRect总是在最下方显示刷新
public class MyScrollRectExtend : MonoBehaviour
{
    public ScrollRect scrollRect;
    public ContentSizeFitter content;

    private int m_content_child_count;
    void Start()
    {
        m_content_child_count = content.transform.childCount;
    }

    void Update()
    {
        if (IsRefreshed())
        {
            ChangeScrollToBottom();
        }
    }

    private bool IsRefreshed()
    {
        if(content.transform.childCount != m_content_child_count)
        {
            m_content_child_count = content.transform.childCount;
            return true;
        }
        return false;
    }

    private void ChangeScrollToBottom()
    {
        DOTween.To(() => scrollRect.verticalScrollbar.value = 0, v => scrollRect.verticalScrollbar.value = v, 0, 0.1f).SetEase(Ease.InElastic);
    }
}
