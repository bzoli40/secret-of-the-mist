using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interactable : MonoBehaviour
{
    protected bool interacted = false;
    protected bool interactable = true;

    [SerializeField]
    protected string displayName;

    public virtual void Interact()
    {
        //Interakció
    }

    public string GetDisplayName()
    {
        return displayName;
    }

    public bool isInteractable()
    {
        return interactable;
    }
}
