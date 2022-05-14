using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    //Alapértékek
    public int health { get; private set; }
    public int maxHealth { get; private set; }


    private int experience, level;

    private List<StatusEffect> current_effects;

    public PlayerState playerState { get; private set; } = PlayerState.NOCONTROLL;

    //Basic
    private void Start()
    {
        health = maxHealth = 100;
    }

    public void WhenLoadEnded()
    {
        playerState = PlayerState.DOANYTHING;
    }

    //UI & chat
    public void ChangeFocus()
    {
        playerState = (playerState == PlayerState.DOANYTHING) ? PlayerState.NOCONTROLL : PlayerState.DOANYTHING;
        GetComponent<InputSystemValues>().OnApplicationFocus();
    }

    //Képességek
    

    //Inventory
    private InventorySystem player_inventory;

    private void Awake()
    {
        player_inventory = GetComponent<InventorySystem>();
    }

}
