using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class AbilitySystem : MonoBehaviour
{
    public void OnHitPush(InputValue value)
    {
        Debug.Log(value.Get<Vector2>());
    }
}
