using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class ZombieAI : MonoBehaviour
{
    private NavMeshAgent nav_agent;

    [Header("AI beállítások")]
    public float posUpdateDistance;

    public float attackRange;
    public Vector3 attackRangeOffset;
    public float followRange;

    //public AIMode ai_mode;

    public bool isAttacking = false;
    public bool isMoving = false;

    private void Awake()
    {
        nav_agent = GetComponent<NavMeshAgent>();
    }

    private void Update()
    {
        if(GameManager.main.gameState == GameState.PLAY)
        {
            CheckForPlayerForHit();

            if (!isAttacking) CheckForPlayerNearby();
            else isMoving = false;

            if (isAttacking)
            {
                Debug.Log("Támad!");
            }
            else if (isMoving)
            {
                Vector3 playerPos = GameObject.FindGameObjectWithTag("Player").transform.position;
                if (Vector3.Distance(playerPos, nav_agent.destination) >= posUpdateDistance)
                {
                    nav_agent.destination = playerPos;
                }

                if (Vector3.Distance(transform.position, nav_agent.destination) <= posUpdateDistance)
                {
                    isMoving = false;
                }
            }
            else if (!isMoving)
            {
                nav_agent.destination = transform.position;
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

        if(isMoving && !isTherePlayer)
        {
            GetComponent<Animator>().SetTrigger("stop");
            isMoving = false;
        }
        else if(!isMoving && isTherePlayer)
        {
            GetComponent<Animator>().SetTrigger("move");
            isMoving = true;
        }
    }

    private void CheckForPlayerForHit()
    {
        Collider[] hitters = Physics.OverlapSphere(transform.position + attackRangeOffset, attackRange);

        bool isTherePlayer = false;

        foreach (Collider hitter in hitters)
        {
            if (hitter.tag == "Player" || hitter.GetComponent<IsPlayer>() != null)
            {
                isTherePlayer = true;
            }
        }

        if (isTherePlayer)
        {
            GetComponent<Animator>().SetTrigger("attack");
            isAttacking = true;
        }
        else
        {
            GetComponent<Animator>().SetTrigger(isMoving ? "move" : "stop");
            isAttacking = false;
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, followRange);

        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(Vector3.zero + attackRangeOffset, attackRange);
    }

    public static Vector3 VectorMultiply (Vector3 A, Vector3 B)
    {
        return new Vector3(A.x * B.x, A.z * B.z, A.z * B.z);
    }
}
