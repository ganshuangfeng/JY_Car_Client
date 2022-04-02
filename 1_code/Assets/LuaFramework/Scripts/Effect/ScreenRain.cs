using UnityEngine;

public class ScreenRain : MonoBehaviour
{
    [Range(0,1)]
    public float blend = 1;

    [Range(0, 1)]
    public float moreRainAmount = 1;

    public bool wipe = true;

    [Range(0.1f, 20f)]
    public float wipeSizeX = 0.8f;

    [Range(0.1f, 20f)]
    public float wipeSizeY = 8.5f;

    public bool debugWipe = false;

	private Material mtrl = null;

    private int srcTexPropId = 0; 
    private int blendPropId = 0;
    private int wipeRTPropId = 0;
    private int wipeRTCanvasPropId = 0;
    private int wipeRTCanvas2PropId = 0;
    private int wipeScreenPosPropId = 0;
    private int wipeScreenSizePropId = 0;
    private int wipeSizePropId = 0;
    private int moreRainAmountPropId = 0;

    private RenderTexture wipeRT = null;
    private RenderTexture wipeRTCanvas = null;
    private RenderTexture wipeRTCanvas2 = null;
    private Vector2 wipeScreenPos;

    private void Awake()
    {
        mtrl = new Material(Shader.Find("Hidden/ScreenRain"));

        srcTexPropId = Shader.PropertyToID("_SrcTex");
        blendPropId = Shader.PropertyToID("_Blend");
        wipeRTPropId = Shader.PropertyToID("_WipeTex");
        wipeRTCanvasPropId = Shader.PropertyToID("_WipeCanvasTex");
        wipeRTCanvas2PropId = Shader.PropertyToID("_WipeCanvas2Tex");
        wipeScreenPosPropId = Shader.PropertyToID("_WipeScreenPos");
        wipeScreenSizePropId = Shader.PropertyToID("_WipeScreenSize");
        wipeSizePropId = Shader.PropertyToID("_WipeSize");
        moreRainAmountPropId = Shader.PropertyToID("_MoreRainAmount");

        wipeScreenPos = Vector2.one * -9000;
    }

    private void Update()
    {
        if(wipe)
        {
            if(Input.GetMouseButton(0))
            {
                //if (camera.gameObject.Instance.SetCamRainState == 0) {
                    //return;
                //}
                wipeScreenPos = Input.mousePosition;
            }
            else
            {
                wipeScreenPos = Vector2.one * -9000;
            }
        }
    }

	private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(mtrl == null || mtrl.shader == null || !mtrl.shader.isSupported)
        {
            enabled = false;
            return;
        }

        if(wipe)
        {
            if(wipeRT == null || !wipeRT.IsCreated())
            {
                DestroyWipeRT();
                wipeRT = new RenderTexture(src.width, src.height, 0, RenderTextureFormat.Default);
                Graphics.Blit(Texture2D.blackTexture, wipeRT);
            }
            if(wipeRTCanvas == null || !wipeRTCanvas.IsCreated())
            {
                DestroyWipeRTCanvas();
                wipeRTCanvas = new RenderTexture(src.width, src.height, 0, RenderTextureFormat.Default);
                wipeRTCanvas2 = new RenderTexture(src.width, src.height, 0, RenderTextureFormat.Default);
                Graphics.Blit(Texture2D.blackTexture, wipeRTCanvas);
            }
            mtrl.SetTexture(wipeRTPropId, wipeRT);
            mtrl.SetTexture(wipeRTCanvasPropId, wipeRTCanvas);
            mtrl.SetTexture(wipeRTCanvas2PropId, wipeRTCanvas2);
            mtrl.SetVector(wipeScreenPosPropId, wipeScreenPos);
            mtrl.SetVector(wipeScreenSizePropId, new Vector4(Screen.width, Screen.height, 0, 0));
            mtrl.SetVector(wipeSizePropId, new Vector4(wipeSizeX, wipeSizeY, 0, 0));
            Graphics.Blit(null, wipeRT, mtrl, 2);
            Graphics.Blit(null, wipeRTCanvas, mtrl, 3);
            Graphics.Blit(null, wipeRTCanvas2, mtrl, 4);
            Graphics.Blit(wipeRTCanvas2, wipeRTCanvas);
            mtrl.EnableKeyword("WIPE");
        }
        else
        {
            DestroyWipeRT();
            DestroyWipeRTCanvas();
            mtrl.DisableKeyword("WIPE");
        }

        mtrl.SetFloat(moreRainAmountPropId, moreRainAmount);
        mtrl.SetTexture(srcTexPropId, src);
        mtrl.SetFloat(blendPropId, blend);
        int rtSizeScale = 1;
#if UNITY_EDITOR
        rtSizeScale = 2;
#else
        rtSizeScale = 3; // 性能更好
#endif
        RenderTexture srcRT = RenderTexture.GetTemporary(src.width / rtSizeScale, src.height / rtSizeScale, 0, src.format);
        RenderTexture destRT = RenderTexture.GetTemporary(srcRT.width, srcRT.height, 0, srcRT.format);
        Graphics.Blit(src, srcRT);
        Graphics.Blit(srcRT, destRT, mtrl, 0);
        Graphics.Blit(destRT, dest, mtrl, 1);
        RenderTexture.ReleaseTemporary(srcRT);
        RenderTexture.ReleaseTemporary(destRT);
    }

#if UNITY_EDITOR
    // Debug
    private void OnGUI()
    {
        if(debugWipe)
        {
            if(wipeRT != null)
            {
                GUI.DrawTexture(new Rect(0,0,wipeRT.width / 4, wipeRT.height/4), wipeRT, ScaleMode.ScaleAndCrop, false);
            }
            if(wipeRTCanvas != null)
            {
                GUI.DrawTexture(new Rect(0,wipeRTCanvas.height/4,wipeRTCanvas.width / 4, wipeRTCanvas.height/4), wipeRTCanvas, ScaleMode.ScaleAndCrop, false);
            }
        }
    }
#endif

    private void OnDestroy()
    {
        if(mtrl != null)
        {
            DestroyImmediate(mtrl);
            mtrl = null;
        }

        DestroyWipeRT();
        DestroyWipeRTCanvas();
    }

    private void OnDisable()
    {
        DestroyWipeRT();
        DestroyWipeRTCanvas();
    }

    private void DestroyWipeRT()
    {
        if(wipeRT != null)
        {
            Destroy(wipeRT);
            wipeRT = null;
        }
    }

    private void DestroyWipeRTCanvas()
    {
        if(wipeRTCanvas != null)
        {
            Destroy(wipeRTCanvas);
            wipeRTCanvas = null;
        }
        if(wipeRTCanvas2 != null)
        {
            Destroy(wipeRTCanvas2);
            wipeRTCanvas2 = null;
        }
    }
}
