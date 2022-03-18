using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemLibrary : MonoBehaviour
{
    public Item[] items;

    public Item findItem(string codingName)
    {
        Item i = null;
        int count = 0;

        foreach(Item it in items)
        {
            if (codingName == it.GetCodingName())
            {
                i = it;
                count++;
            }
        }

        if(count > 1)
        {
            Debug.LogWarning("Több Item kódja is azonos!");
        }

        return i;
    }
}
