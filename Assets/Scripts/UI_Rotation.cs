using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class UI_Rotation : MonoBehaviour
{
    private void Update()
    {
        transform.eulerAngles = GameObject.FindGameObjectWithTag("CinemachineTarget").transform.eulerAngles;
    }
}
