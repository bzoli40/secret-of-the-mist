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
    public float followRange;

    public AIMode ai_mode;

    private void Awake()
    {
        nav_agent = GetComponent<NavMeshAgent>();
    }

    private void Update()
    {
        CheckForPlayerNearby();

        if (GameManager.main.gameState == GameState.PLAY)
        {
            switch (ai_mode)
            {
                case AIMode.FOLLOW:
                    Vector3 playerPos = GameObject.FindGameObjectWithTag("Player").transform.position;
                    if (Vector3.Distance(playerPos, nav_destin) >= posUpdateDistance) nav_destin = playerPos;
                    nav_agent.destination = playerPos;
                    break;

                case AIMode.STANDBY:
                    nav_agent.destination = transform.position;
                    break;
            }
        }
    }

    private void CheckForPlayerNearby()
    {
        Collider[] hitters = Physics.OverlapSphere(transform.position, followRange);

        bool isTherePlayer = false;

        foreach (Collider hitter in hitters)
        {
            if (hitter.tag == "Player" || hitter.GetComponent<IsPlayer>() != null)
            {
                isTherePlayer = true;
            }
        }

        ai_mode = isTherePlayer ? AIMode.FOLLOW : AIMode.STANDBY;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, followRange);
    }
}
