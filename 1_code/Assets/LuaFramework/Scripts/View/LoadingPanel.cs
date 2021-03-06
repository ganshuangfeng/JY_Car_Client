using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using LuaFramework;
using TMPro;

public class LoadingPanel : MonoBehaviour {
	[SerializeField]
	public RectTransform ImgProgressBar;

	[SerializeField]
	public Text  TextProgressTitle;

	[SerializeField]
	public Transform SwitchingDisplayNode;

	[SerializeField]
	public float SwitchImageInterval = 5.0f;
	[SerializeField]
	public bool RandomImages = true;
	[SerializeField]
	public string[] SwitchImages;

	[SerializeField]
	public float SwitchTipInterval = 3.0f;
	[SerializeField]
	public bool RandomTips = true;
	[SerializeField]
	public string[] SwitchTips;

	[SerializeField]
	public Text TextVersion;
	[SerializeField]
	public Text TextError;

	private GameObject SwitchingDisplayPanel;
	private Transform SwitchingBlurBG;

	private int progressWidth = 1000;

	private bool isPressed = false;
	private float debugStamp = 0.0f;
	private int lastStamp = 0;
	private const int FRAME_INTERVAL = 3;
	private int debugFrame = 0;
	

	// Use this for initialization
	void Start () {
		if(ImgProgressBar == null)
			Debug.LogError ("[UI] LoadingPanel ProgressBar is null");
		if (TextProgressTitle == null)
			Debug.LogError ("[UI] LoadingPanel ProgressTitle is null");
		
		Transform transFg = ImgProgressBar.Find ("progress_fg");
		if(transFg != null)
			progressWidth = (int)(transFg.GetComponent<RectTransform> ().rect.width);

		SwitchingBlurBG = SwitchingDisplayNode.Find ("bg_blur");
		if (SwitchingBlurBG != null)
			SwitchingBlurBG.gameObject.SetActive (false);

		PlayerPrefs.SetInt("_DEBUG_CORE_", 0);
	}
	
	// Update is called once per frame
	void Update () {
#if UNITY_EDITOR
		if (Input.GetMouseButtonDown(0))
		{
			isPressed = true;
			debugStamp = Time.time;
			lastStamp = 0;
		}
		if (Input.GetMouseButtonUp(0))
			isPressed = false;

#elif UNITY_ANDROID || UNITY_IOS
		if(Input.touchCount > 0)
		{
			if(Input.GetTouch(0).phase == TouchPhase.Began)
			{
				isPressed = true;
				debugStamp = Time.time;
				lastStamp = 0;
			}
			if (Input.GetTouch(0).phase == TouchPhase.Canceled || Input.GetTouch(0).phase == TouchPhase.Ended)
				isPressed = false;
		}
#endif

		if (isPressed)
		{
			float diffTime = Time.time - debugStamp;
			if (diffTime > 10.0f)
			{
				isPressed = false;
				PlayerPrefs.SetInt("_DEBUG_CORE_", 15);
				debugFrame = -1;
				Debug.Log("[Debug] set debug core: 15 loop");
			}
			else
			{
				if(diffTime > 3)
				{
					int diffInt = Mathf.FloorToInt(diffTime);
					if (lastStamp != diffInt)
					{
						lastStamp = diffInt;
						PlayerPrefs.SetInt("_DEBUG_CORE_", 15);
						debugFrame = FRAME_INTERVAL;
						Debug.Log("[Debug] set debug core: 15 frame");
					}
				}
			}
		}

		if(debugFrame > 0)
		{
			--debugFrame;
			if(debugFrame <= 0)
				PlayerPrefs.SetInt("_DEBUG_CORE_", 0);
		}
}

	void OnDisable() {
	}

	void OnDestroy() {
		if (SwitchingDisplayPanel) {
			SwitchingDisplayPanel.transform.SetParent (null);
			GameObject.Destroy (SwitchingDisplayPanel);
		}
		SwitchingDisplayPanel = null;
	}

	public void SetLoadingTitle(string title) {
		TextProgressTitle.text = title;
	}

	public void SetLoadingProgress(float value) {
		ImgProgressBar.sizeDelta = new Vector2 (value * progressWidth, 50);
	}

	public void SetVersion(string value)
	{
		if(TextVersion != null)
			TextVersion.text = value;
	}
	public void SetError(string value)
	{
		if(TextError != null)
			TextError.text = value;
	}

	public void StartSwitchingDisplay(ResourceManager resMgr) {
		if (SwitchImages.Length <= 0 && SwitchTips.Length <= 0)
			return;

		GameObject go = resMgr.LoadAsset<GameObject> ("SwitchingDisplay.prefab", null, null);
		if (go == null) {
			Debug.LogError ("[UI] LoadingPanel SwitchingDisplayPanel load prefab failed.");
			return;
		}
		SwitchingDisplayPanel = GameObject.Instantiate (go, SwitchingDisplayNode);
		if (SwitchingDisplayPanel == null) {
			Debug.LogError ("[UI] LoadingPanel Load SwitchingDisplayPanel failed.");
			return;
		}
		SwitchingDisplayPanel.transform.localPosition = Vector3.zero;
		SwitchingDisplayPanel.transform.localRotation = Quaternion.identity;
		SwitchingDisplayPanel.transform.localScale = Vector3.one;

		SwitchingDisplay sd = SwitchingDisplayPanel.GetComponent<SwitchingDisplay> ();
		if (sd == null) {
			Debug.LogError ("[UI] LoadingPanel GetComponent SwitchingDisplay failed.");

			GameObject.Destroy (SwitchingDisplayPanel);
			SwitchingDisplayPanel = null;
			return;
		}

		if (SwitchingBlurBG != null)
			SwitchingBlurBG.gameObject.SetActive (true);

		if (SwitchImages.Length > 0) {
			List<Sprite> sprites = new List<Sprite> ();
			Sprite sprite;
			for (int idx = 0; idx < SwitchImages.Length; ++idx) {
				sprite = resMgr.GetTextureSync (SwitchImages [idx]);
				if (sprite != null)
					sprites.Add (sprite);
				else
					Debug.LogError (string.Format("[UI] LoadingPanel Load Sprite({0}) failed.", SwitchImages[idx]));
			}

			List<Sprite> result = new List<Sprite> ();
			if (RandomImages) {
				List<int> rndTbl = Disorder (sprites.Count);
				for (int idx = 0; idx < rndTbl.Count; ++idx)
					result.Add (sprites [rndTbl [idx]]);
			} else
				result.AddRange (sprites);
			result.Add (result [0]);

			sd.BuildPageScroll (result, SwitchImageInterval);
		}

		if (SwitchTips.Length > 0) {
			List<string> tips = new List<string> ();
			for (int idx = 0; idx < SwitchTips.Length; ++idx)
				tips.Add (SwitchTips [idx]);

			List<string> result = new List<string> ();
			if (RandomTips) {
				List<int> rndTbl = Disorder (tips.Count);
				for (int idx = 0; idx < rndTbl.Count; ++idx)
					result.Add (tips [rndTbl [idx]]);
			} else
				result.AddRange (tips);
			result.Add (result [0]);

			sd.BuildTipScroll (result, SwitchTipInterval);
		}
	}

	public void SetActive(bool value) {
		gameObject.SetActive (value);
	}

	//[0, count)
	private List<int> Disorder(int count) {
		List<int> result = new List<int> (count);

		bool[] traceTbl = new bool[count];
		int LoopCount = 100;
		while (--LoopCount >= 0) {
			int idx = Random.Range (0, 65535) % count;
			if (!traceTbl [idx]) {
				traceTbl [idx] = true;
				result.Add (idx);
				if (result.Count >= count)
					break;
			}
		}

		if (result.Count < count) {
			for (int idx = 0; idx < count; ++idx) {
				if (!traceTbl [idx])
					result.Add (idx);
			}
		}

		return result;
	}
}
