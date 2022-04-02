using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
[RequireComponent(typeof(TextMeshPro))]
public class TextMeshProOutline : MonoBehaviour
{
 
    [ColorUsageAttribute(true, true)]
    public Color OutlineColor = new Color(255, 128, 0, 255);
    public float OutlineWidth = 0.2f;
    private TextMeshPro textmeshPro;
    void Awake()
    {
        textmeshPro = GetComponent<TextMeshPro>();
        textmeshPro.outlineWidth = OutlineWidth;
        textmeshPro.outlineColor = OutlineColor;
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        textmeshPro.outlineWidth = OutlineWidth;
        textmeshPro.outlineColor = OutlineColor;
    }
}
