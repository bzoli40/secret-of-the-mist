using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UI_System : MonoBehaviour
{
    MenuLibrary menu_lib;

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
    }

    public void SetInventoryMenu(bool show)
    {
        menu_lib.inventoryMenu.SetActive(show);
    }

    #endregion
}
