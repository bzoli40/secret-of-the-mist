using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InventorySystem : MonoBehaviour
{
    private Dictionary<Item, int> inventory;

    /// <summary>Tárgy hozzáadása az Inventoryhoz
    /// </summary>
    public void AddItem(Item item, int quantity)
    {
        if(inventory.ContainsKey(item))
        {
            //Ha már van ilyen tárgy
            inventory[item] += quantity;
        }
        else
        {
            //Ha már/még nincs
            inventory.Add(item, quantity);
        }
    }
}
