using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControlling : MonoBehaviour
{
    bool inFightMode = false;

    public void CameraModeSwitch()
    {
        GetComponent<Animator>().Play((inFightMode ? "back_normal" : "from_normal"), 0);

        inFightMode = !inFightMode;
    }

}
