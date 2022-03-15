using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AbilityUI : MonoBehaviour
{
    [SerializeField]
    private float cooldownUltimate = 10f;
    private float lastUsedUltimate;

    private bool canUseUltimate = true;

    private void Update()
    {
        if(!canUseUltimate)
        {
            float timeSince = Time.time - lastUsedUltimate;

            if(timeSince >= cooldownUltimate)
            {
                canUseUltimate = true;
            }
            else
            {
                float percent = timeSince / cooldownUltimate;
                GetComponent<Image>().fillAmount = percent;
            }

            transform.GetChild(0).gameObject.SetActive(false);
        }
        else
        {
            GetComponent<Image>().fillAmount = 1;
            transform.GetChild(0).gameObject.SetActive(true);
        }
    }

    public void UseUlt()
    {
        if(canUseUltimate)
        {
            lastUsedUltimate = Time.time;
            Debug.Log("h");

            canUseUltimate = false;
            
        }
    }
}
