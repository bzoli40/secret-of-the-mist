using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class TestRaycast : MonoBehaviour
{
    public GameObject rc;

    public LayerMask mask;

    private void Update()
    {
        Player p = GameObject.FindGameObjectWithTag("GameSystem").GetComponent<Player>();

        if(p.playerState == PlayerState.NOCONTROLL)
        {
            Ray ray = Camera.main.ScreenPointToRay(Mouse.current.position.ReadValue());
            if(Physics.Raycast(ray, out RaycastHit hit, float.MaxValue, mask))
            {
                rc.transform.position = hit.point;
            }
        }
    }
}
