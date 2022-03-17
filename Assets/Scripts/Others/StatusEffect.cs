using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StatusEffect : MonoBehaviour
{
    public enum SE_Type { SLOW, ROOT, FREEZE, REGEN, BLIND };

    public SE_Type type;
    public float startTime;
    public float duration;

    public StatusEffect(SE_Type t_, float s_, float d_)
    {
        type = t_;
        startTime = s_;
        duration = d_;
    }

    /// <summary>
    /// Visszaadja, hogy aktív-e még az effekt, vagy lejárt már
    /// </summary>
    /// <returns></returns>
    public bool isActiveYet()
    {
        return true;
    }
}
