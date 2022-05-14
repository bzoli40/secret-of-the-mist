using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class ZombieAI : MonoBehaviour
{
    private NavMeshAgent nav_agent;
    private Vector3 nav_destin = new(0,0,0);

    [Header("AI beállítások")]
    public float posUpdateDistance;

    private void Awake()
    {
        nav_agent = GetComponent<NavMeshAgent>();
    }

    private void Update()
    {
        Vector3 playerPos = GameObject.FindGameObjectWithTag("Player").transform.position;

        if (Vector3.Distance(playerPos, nav_destin) >= posUpdateDistance) nav_destin = playerPos;

        nav_agent.destination = playerPos;
    }
}
