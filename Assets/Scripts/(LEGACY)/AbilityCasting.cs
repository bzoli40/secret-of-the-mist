using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class AbilityCasting : MonoBehaviour
{

    [SerializeField]
    private bool isHolding = false;

    public AbilityUI abilityUI;
    public GameObject cameraFollowObj;

    private void Start()
    {
        InputMaster inputMaster = new InputMaster();
        inputMaster.Player.Enable();

        //Event megh�v�sok
    }

    private void FixedUpdate()
    {
        if (isHolding)
        {
            RaycastHit hit;

            if(Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out hit))
            {
                Debug.Log(hit.point);
            }
        }
    }

    public void OnAbility_Ultimate(InputValue value)
    {
        //UI �rtes�t�s

        if (abilityUI.CanUseUlt() && false)
        {
            //Camera.main.GetComponent<CameraStateControll>().SwitchFollower();
            isHolding = !isHolding;
        }
    }

    /*
    public void InitThrowObject()
    {
        Instantiate(testProj, throwableParent);
    }

    public void ThrowObject()
    {
        if (throwableParent.childCount > 0)
        {
            Transform child = throwableParent.GetChild(0);

            child.eulerAngles = transform.eulerAngles;
            child.parent = null;

            child.GetComponent<ThrowSpell>().LaunchProjectile();
        }
    }
    */
}
