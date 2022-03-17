using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    //Alap�rt�kek
    private int health, maxHealth;
    private int experience, level;

    private List<StatusEffect> current_effects;

    //K�pess�gek


    //Inventory
    private InventorySystem player_inventory;

    private void Awake()
    {
        player_inventory = GetComponent<InventorySystem>();
    }

}
