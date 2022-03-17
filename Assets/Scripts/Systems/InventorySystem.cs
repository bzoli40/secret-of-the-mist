using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InventorySystem : MonoBehaviour
{
    private Dictionary<Item, int> inventory;

    /// <summary>T�rgy hozz�ad�sa az Inventoryhoz
    /// </summary>
    public void AddItem(Item item, int quantity)
    {
        if(inventory.ContainsKey(item))
        {
            //Ha m�r van ilyen t�rgy
            inventory[item] += quantity;
        }
        else
        {
            //Ha m�r/m�g nincs
            inventory.Add(item, quantity);
        }
    }
}
