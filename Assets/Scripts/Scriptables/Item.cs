using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New Item", menuName = "KodersBase/Item")]
public class Item : ScriptableObject
{
    public enum ItemCategory { MATERIAL, WEAPON, QUEST };
    [SerializeField]
    private ItemCategory category;

    public ItemCategory GetCategory()
    {
        return category;
    }
}
