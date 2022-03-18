using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InteractHandler : MonoBehaviour
{
    [SerializeField]
    private float range = 2;

    private InputSystemValues _input;

    public GameObject interactUI;

    private void Awake()
    {
        _input = GameObject.FindGameObjectWithTag("GameSystem").GetComponent<InputSystemValues>();
    }

    private void FixedUpdate()
    {
        Collider[] hitters = Physics.OverlapSphere(transform.position, range);
        List<Interactable> interactables = new List<Interactable>();

        foreach (Collider c in hitters)
        {
            if (c.tag == "Interactable" && c.GetComponent<Interactable>() && c.GetComponent<Interactable>().isInteractable())
            {
                interactables.Add(c.GetComponent<Interactable>());
            }
        }

        if(interactables.Count > 0)
        {
            interactUI.transform.GetChild(1).GetComponent<Text>().text = interactables[0].GetDisplayName();
            if(interactUI != null) interactUI.SetActive(true);
        }
        else
        {
            if (interactUI != null) interactUI.SetActive(false);
        }

        if(_input.interact && interactables.Count > 0)
        {
            interactables[0].Interact();
            _input.interact = false;
        }
    }

    //Gizmo
    private void OnDrawGizmosSelected()
    {
        Gizmos.color = new Color(1, 0.5f, 1);
        Gizmos.DrawWireSphere(transform.position, range);
    }
}
