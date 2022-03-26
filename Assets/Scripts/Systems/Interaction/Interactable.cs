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
        if (args.Length < 1) return;

        switch (args[0])
        {
            case "Item":
                EventSystem.instance.NewEvent(EventType.COLLECT, args);
                break;
        }
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
