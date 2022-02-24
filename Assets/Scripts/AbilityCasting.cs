using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class AbilityCasting : MonoBehaviour
{
    [SerializeField]
    private bool isHolding = false;

    public GameObject testProj;
    public Transform throwableParent;

    private void Start()
    {
        InputMaster inputMaster = new InputMaster();
        inputMaster.Player.Enable();

        //Event meghívások
    }

    public void OnAbility_1(InputValue value)
    {
        Animator anim = GetComponent<Animator>();

        if (!isHolding)
        {
            anim.SetTrigger("startMotion");
        }
        else
        {
            anim.SetTrigger("spellTrigger");
        }

        isHolding = !isHolding;
    }

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
}
