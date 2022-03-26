using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemObject : Interactable
{
    public Item itemWhatPickUp;

    private void Start()
    {
        displayName = itemWhatPickUp != null ? itemWhatPickUp.GetDisplayName() : "_item_";
    }

    public override void Interact()
    {
        if (!interacted && interactable)
        {
            interacted = true;

            GameObject.FindGameObjectWithTag("GameSystem").GetComponent<InventorySystem>().AddItem(itemWhatPickUp, 1);
            AddEvent(new string[] { "Item", itemWhatPickUp.GetCodingName() });

            Destroy(gameObject);
        }
    }
}
