using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New Item", menuName = "KodersBase/Item")]
public class Item : ScriptableObject
{
    [SerializeField]
    private ItemCategory category;

    [SerializeField]
    private Sprite icon;

    [SerializeField]
    private string codingName;
    [SerializeField]
    private string displayName;

    [SerializeField]
    private string description;

    [SerializeField]
    private Rarity rarity;

    public ItemCategory GetCategory()
    {
        return category;
    }

    public string GetCodingName()
    {
        return codingName;
    }
}
