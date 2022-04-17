using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BurstAudio : MonoBehaviour
{
    public AudioClip burstClip;

    public void Burst()
    {
        AudioSource audio = GameObject.FindGameObjectWithTag("MainAudio").GetComponent<AudioSource>();
        if (audio != null)
        {
            audio.clip = burstClip;
            audio.Play();
        }
    }
}
