using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UI_System : MonoBehaviour
{
    MenuLibrary menu_lib;

    //Prefabs
    public GameObject itemInventoryPref;

    //Transform parent
    public Transform inventoryParentTransform;

    //Created Object List
    private List<GameObject> itemInInventoryPrefs = new();

    //
    //
    //

    private void Start()
    {
        menu_lib.inventoryMenu.SetActive(false);
    }

    private void Awake()
    {
        menu_lib = transform.GetChild(0).GetComponent<MenuLibrary>();
    }

    #region Inventory

    public void SetInventoryMenu()
    {
        menu_lib.inventoryMenu.SetActive(!menu_lib.inventoryMenu.activeSelf);
        if(menu_lib.inventoryMenu.activeSelf)
        {
            ListItems();
        }
    }

    public void SetInventoryMenu(bool show)
    {
        menu_lib.inventoryMenu.SetActive(show);
    }

    public void ListItems()
    {
        DeletePreviousInventoryPrefs();

        Dictionary<Item, int> itemInInventory = GetComponent<InventorySystem>().GetItemList();
        Debug.Log(itemInInventory.Count);

        foreach(KeyValuePair<Item, int> pair in itemInInventory)
        {
            GameObject newListElement = Instantiate(itemInventoryPref, inventoryParentTransform);
            newListElement.transform.GetChild(0).GetComponent<Image>().sprite = pair.Key.GetIcon();
            newListElement.transform.GetChild(1).GetComponent<Text>().text = pair.Value.ToString();

            itemInInventoryPrefs.Add(newListElement);
        }
    }

    public void DeletePreviousInventoryPrefs()
    {
        if (itemInInventoryPrefs.Count == 0) return;

        for(int x = 0; x < itemInInventoryPrefs.Count; x++)
        {
            Destroy(itemInInventoryPrefs[x]);
        }

        itemInInventoryPrefs = new List<GameObject>();
    }

    #endregion
}
