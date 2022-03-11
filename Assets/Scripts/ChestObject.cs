using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChestObject : Interactable
{

    public override void Interact()
    { 
        if(!interacted && interactable)
        {
            interacted = true;
            interactable = false;
            GetComponent<Animator>().SetTrigger("Open");
        }
    }
}
