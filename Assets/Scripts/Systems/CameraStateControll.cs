using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Cinemachine;

public class CameraStateControll : MonoBehaviour
{
    public CinemachineVirtualCamera follower;

    [Header("Follow Targets")]
    public GameObject TrdPersonFollow;
    public GameObject UpDwnFollow;
    public CinemachineVirtualCamera inventoryFollow;

    public bool in3rd = true;

    private void Start()
    {
        follower.m_Follow = TrdPersonFollow.transform;
    }

    public void SwitchCameraMode(string which)
    {
        switch(which)
        {
            case "upDwn":
                follower.m_Follow = in3rd ? UpDwnFollow.transform : TrdPersonFollow.transform;
                break;

            case "inventory":
                inventoryFollow.Priority = in3rd ? 11 : 9;
                break;
        }

        in3rd = !in3rd;
    }

}
