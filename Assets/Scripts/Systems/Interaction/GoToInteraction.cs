using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GoToInteraction : MonoBehaviour
{
    private float activationDistance;
    private Vector3 location;
    private string questName;

    private bool activated = false;

    public void SetGoTo(float _a, Vector3 _l, string _q)
    {
        activationDistance = _a;
        location = _l;
        questName = _q;
    }

    private void FixedUpdate()
    {
        if (activated) return;

        Collider[] hitters = Physics.OverlapSphere(transform.position, activationDistance);

        foreach (Collider hitter in hitters)
        {
            Debug.Log(hitter.tag + "/" + hitter.name + " [" + Vector3.Distance(hitter.transform.position, transform.position) + "/" + activationDistance + "]");

            if ((hitter.tag == "Player" || hitter.GetComponent<IsPlayer>() != null) 
                && Vector3.Distance(hitter.transform.position, transform.position) <= activationDistance)
            {
                string[] args = new string[2] { location.ToString(), questName };
                GameObject.FindGameObjectWithTag("GameSystem").GetComponent<EventHandler>().NewEvent(EventCategory.GO_TO, args);

                activated = true;
            }
        }
    }
}
