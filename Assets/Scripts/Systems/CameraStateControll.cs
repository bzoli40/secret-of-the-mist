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

    public bool in3rd = true;

    public void SwitchFollower()
    {
        follower.m_Follow = in3rd ? UpDwnFollow.transform : TrdPersonFollow.transform;
        in3rd = !in3rd;
    }

}
