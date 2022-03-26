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
        AddEvent(null);
    }

    public void AddEvent(string[] args)
    {
        EventSystem.instance.NewEvent(EventType.INTERACT, args);
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
