using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMove : MonoBehaviour
{
    public Transform targetTf;

    /// <summary>
    /// Rotate
    /// </summary>
    public float rotateSpeed = 0.01f;
    public float yMaxLimit = 45;
    public float yMinLimit = -45;
    private float targetX; 
    private float targetY; 

    /// <summary>
    /// Zoom
    /// </summary>
    public float zoomSpeed = 1f;
    public float minDistance = 3;
    public float maxDistance = 10;
    public bool isCamp = false;
    private float curDistance;
    private float targetDistance;
    private float zoomVelocity = 0f;

    private int curTouchCount;
    private int lastTouchCount;
    public int CurTouchCount {
        get { return curTouchCount;}
        set { curTouchCount = value;}
    }
    private Vector3 difVector;

    public bool isDirForward = true;

    public int autoAngle = 18;

    // Start is called before the first frame update
    void Start()
    {
        Init();
    }

    void Init()
    {
        this.curTouchCount = 0;
        this.lastTouchCount = 0;
        if (targetTf == null)
        {
            targetTf = new GameObject("Target").transform;
        }
        this.transform.LookAt(targetTf);
        this.curDistance = Vector3.Distance(this.transform.position, targetTf.position);
        this.targetDistance = this.curDistance;
        this.targetX = this.transform.eulerAngles.y;
        this.targetY = this.transform.eulerAngles.x;
    }

    // Update is called once per frame
    void LateUpdate()
    {
        if (curTouchCount == 0) 
        {
            RotateFromAngle(autoAngle, isDirForward);
        }
    }

    private void UpdateTouchCount(int inputTouchCount)
    {
        if (curTouchCount != inputTouchCount)
        {
            lastTouchCount = curTouchCount;
            curTouchCount = inputTouchCount;
            //print(lastTouchCount + "--->" + curTouchCount);
        }
        
    }
    private bool IsRighTouch(Vector2 tuoch){
        float width = 200 * 5f;
        float height = 120 * 5f;
        Camera mian = transform.GetComponent<Camera>();
        Vector2 v = RectTransformUtility.WorldToScreenPoint(mian,transform.parent.position);
        if ( Mathf.Abs(tuoch.x - v.x) < width * transform.parent.localScale.x && Mathf.Abs(tuoch.y - v.y) < height * transform.parent.localScale.y) {
            return true;
        }
        return false;
    }

    private void RotateAround(float x, float y)
    {
        targetX += x * rotateSpeed;
        targetY -= y * rotateSpeed;
        targetY = ClampAngle(targetY, yMinLimit, yMaxLimit);
        RotateCamera(targetY, targetX);
    }

    private void RotateFromAngle(int angle, bool isDirForward)
    {
        float xChange = angle * Time.deltaTime; 
        if(isDirForward) 
        {
            targetX -= xChange;
        }else
        {
            targetX += xChange;
        }
        RotateCamera(this.transform.eulerAngles.x, targetX);
    }

    private void RotateCamera(float targetY, float targetX)
    {
        Quaternion rotation = Quaternion.Euler(targetY, targetX, 0);
        Vector3 position = rotation * new Vector3(0.0f, 0.0f, -curDistance) + targetTf.position;
        this.transform.rotation = rotation;
        this.transform.position = position;
    }

    private float ClampAngle(float angle, float min, float max)
    {
        if (angle < -360) angle += 360;
        if (angle > 360) angle -= 360;
        return Mathf.Clamp(angle, min, max);
    }

    private void Zoom(float d)
    {
        if (d > 0.0f)
        {   
            targetDistance -= zoomSpeed;
        }
        else if(d < 0.0f)
        {
            targetDistance += zoomSpeed;
        }
        targetDistance = Mathf.Clamp(targetDistance, minDistance, maxDistance);
        if (isCamp)
        {
            curDistance = Mathf.SmoothDamp(curDistance, targetDistance, ref zoomVelocity, 0.1f);
        }
        else
        {
            curDistance = targetDistance;
        }
        Vector3 pos = this.transform.rotation * new Vector3(0, 0, -curDistance) + targetTf.position;
        this.transform.position = pos;
    }

#if UNITY_EDITOR
    private Vector3 oldPos1; 
    private Vector3 oldPos2;
    private void Update() {
        if (Input.GetMouseButton(0))
        {
            if(Input.touchCount == 0)
            {
                if (Input.GetKey(KeyCode.Z))
                {
                    UpdateTouchCount(2);
                }
                else
                {
                    UpdateTouchCount(1);
                }
            }
        }
        else
        {
            UpdateTouchCount(0);
        }

        if (IsRighTouch(Input.mousePosition) == false) {
            return;
        }

        if (Input.GetKeyDown(KeyCode.Z))
        {
            oldPos1 = new Vector3(Screen.width, Screen.height , 0);
        }
        if (Input.GetMouseButtonDown(0))
        {
            oldPos2 = Input.mousePosition;

        }

        if (curTouchCount == 1)
        {
            if (lastTouchCount == 2 && curTouchCount == 1)
            {
                return;
            }
            var x = Input.GetAxis("Mouse X");
            var y = Input.GetAxis("Mouse Y");
            if(x != 0 || y != 0)
            {
                RotateAround(x, y);
            }
        }
        else if (curTouchCount == 2)
        {
            Vector3 curPos1 = new Vector3(Screen.width, Screen.height, 0);
            Vector3 curPos2 = Input.mousePosition;
            float currenDistance = Vector3.Distance(curPos1, curPos2);
            float lastDistance = Vector3.Distance(oldPos1, oldPos2);
            float distance = - (currenDistance - lastDistance) ;
            Zoom(distance);
            oldPos1 = curPos1;
            oldPos2 = curPos2;
        }
    }
#elif UNITY_IOS || UNITY_ANDROID
    private Vector2 oldPos1; 
    private Vector2 oldPos2;
    private void Update() {
        if (Input.GetMouseButton(0))
        {
            if(Input.touchCount == 1 || Input.touchCount == 2)
            {
                UpdateTouchCount(Input.touchCount);
            }
        }
        else
        {
            UpdateTouchCount(0);
        }

        if (IsRighTouch(Input.mousePosition) == false) {
            return;
        }
        
        if (curTouchCount == 1)
        {
            if (lastTouchCount == 2 && curTouchCount == 1)
            {
                return;
            }
            var x = Input.GetAxis("Mouse X");
            var y = Input.GetAxis("Mouse Y");
            if (Input.GetTouch(0).phase == TouchPhase.Ended)
            {
                UpdateTouchCount(0);
            }
            if (Input.GetTouch(0).phase == TouchPhase.Moved)
            {
                if(x != 0 || y != 0)
                {
                    RotateAround(x, y);
                }
            }
        }
        else if (curTouchCount == 2)
        {
            if (Input.GetTouch(1).phase == TouchPhase.Began)
            {
                oldPos1 = Input.GetTouch(0).position;
                oldPos2 = Input.GetTouch(1).position;
            }
            if (Input.GetTouch(0).phase == TouchPhase.Moved || Input.GetTouch(1).phase == TouchPhase.Moved)
            {
                Vector2 curPos1 = Input.GetTouch(0).position;
                Vector2 curPos2 = Input.GetTouch(1).position;
                float currenDistance = Vector3.Distance(curPos1, curPos2);
                float lastDistance = Vector3.Distance(oldPos1, oldPos2);
                float distance = currenDistance - lastDistance;
                Zoom(distance);
                oldPos1 = curPos1;
                oldPos2 = curPos2;
            }
        }
    }
#endif

}
