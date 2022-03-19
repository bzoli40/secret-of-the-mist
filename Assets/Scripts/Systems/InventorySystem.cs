using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class InventorySystem : MonoBehaviour
{
    private Dictionary<Item, int> inventory;

    private void Start()
    {
        inventory = new Dictionary<Item, int>();
    }

    public void OnInventory(InputValue value)
    {
        Camera.main.GetComponent<CameraStateControll>().SwitchCameraMode("inventory");
        GameObject.FindGameObjectWithTag("GameSystem").GetComponent<Player>().ChangeFocus();
        GetComponent<UI_System>().SetInventoryMenu();
    }

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

    /// <summary>Tárgy hozzáadása az Inventoryhoz (Dev)
    /// </summary>
    public void AddItem(string itemName, int quantity)
    {
        Item foundItem = transform.GetChild(0).GetComponent<ItemLibrary>().findItem(itemName);

        if(foundItem != null)
        {
            AddItem(foundItem, quantity);
        }
    }
}
