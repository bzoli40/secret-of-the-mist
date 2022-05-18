using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    //Alapértékek
    public int health { get; private set; }
    public int maxHealth { get; private set; } = 5;
    private bool startupSetted = false;
    public Action OnHealthChange;
    public bool dead = false;


    private int experience, level;

    private List<StatusEffect> current_effects;

    public PlayerState playerState { get; private set; } = PlayerState.NOCONTROLL;

    //Basic
    public void SetupBasics()
    {
        if(!startupSetted)
        {
            health = maxHealth;

            startupSetted = true;
        }
    }

    public void GetHit(int amount)
    {
        if (dead) return;

        Debug.Log("AU!");

        health -= amount;
        OnHealthChange();

        if (health <= 0 && !dead)
        {
            Dying();
            dead = true;
        }
    }

    public void Dying()
    {
        playerState = PlayerState.NOCONTROLL;
        GameObject.FindGameObjectWithTag("Player").GetComponent<Animator>().SetTrigger("dying");
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
