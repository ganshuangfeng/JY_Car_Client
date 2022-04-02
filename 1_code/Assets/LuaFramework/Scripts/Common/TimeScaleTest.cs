using UnityEngine;

public class TimeScaleTest : MonoBehaviour
{
     void FixedUpdate()
    {
        Debug.Log("【FixedUpdate】deltaTime: " + Time.deltaTime + "\tunscaledDeltaTime:" + Time.unscaledDeltaTime + "\ttime:" + Time.time + "\t unscaledTime:" + Time.unscaledTime);
    }

    void Update()
    {
        Debug.Log("【Update】deltaTime: " + Time.deltaTime + "\tunscaledDeltaTime:" + Time.unscaledDeltaTime + "\ttime:" + Time.time + "\t unscaledTime:" + Time.unscaledTime);
    }

    void LateUpdate()
    {
        Debug.Log("【LateUpdate】deltaTime: " + Time.deltaTime + "\tunscaledDeltaTime:" + Time.unscaledDeltaTime + "\ttime:" + Time.time + "\tunscaledTime:" + Time.unscaledTime);
    }

    void OnGUI()
    {
        if (GUI.Button(new Rect(0, 0, 100, 40), "暂停"))
        {
            Time.timeScale = 0;
        }

        if (GUI.Button(new Rect(0, 50, 100, 40), "X2倍"))
        {
            Time.timeScale = 2;
        }

        if (GUI.Button(new Rect(0, 100, 100, 40), "X3倍"))
        {
            Time.timeScale = 3;
        }
    }
}