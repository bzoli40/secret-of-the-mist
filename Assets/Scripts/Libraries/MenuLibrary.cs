using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MenuLibrary : MonoBehaviour
{
    public GameObject inventoryMenu;
    public GameObject questBar;

    //Health
    public Transform healthBar;

    public GameObject hearthPref;
    public Sprite empty_hearth, full_hearth;

    //Loading
    public GameObject loadingScreen;
    public Text loadingMessage;
    public Image loadingBar;
}
