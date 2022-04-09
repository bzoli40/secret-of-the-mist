using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectLibrary : MonoBehaviour
{
    public GameObject[] effects;

    public GameObject FindEffect(string _name)
    {
        GameObject found = null;

        for(int x = 0; x < effects.Length; x++)
        {
            Debug.Log(effects[x].name.ToLower() + " - " + ("effect_" + _name));
            if (effects[x].name.ToLower() == ("effect_" + _name)) found = effects[x];
        }

        return found;
    }

    public void SummonEffect(string _name)
    {
        GameObject effect = FindEffect(_name);
        Debug.Log("Yolo");

        if (effect == null) return;

        Debug.Log("Yolo1.4");

        Transform playerPlace = GameObject.FindGameObjectWithTag("Player").transform;

        Instantiate(effect, playerPlace.position + (playerPlace.forward * 3f), effect.transform.rotation);
        Debug.Log("Yolo2");
    }

    //summon_effect thunderstrike


}
