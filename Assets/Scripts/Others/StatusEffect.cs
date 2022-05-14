using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StatusEffect : MonoBehaviour
{
    public Statues_Effect type;
    public float startTime;
    public float duration;

    public StatusEffect(Statues_Effect t_, float s_, float d_)
    {
        type = t_;
        startTime = s_;
        duration = d_;
    }

    /// <summary>
    /// Visszaadja, hogy akt�v-e m�g az effekt, vagy lej�rt m�r
    /// </summary>
    /// <returns></returns>
    public bool isActiveYet()
    {
        return GameManager.main.inGameTime - startTime > duration;
    }
}
