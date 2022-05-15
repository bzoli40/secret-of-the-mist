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
    public float attackRangeOffsetY;
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
                transform.LookAt(GameObject.FindGameObjectWithTag("Player").transform);
            }
            else if (isMoving)
            {
                Vector3 playerPos = GameObject.FindGameObjectWithTag("Player").transform.position;
                nav_agent.SetDestination(playerPos);

                Debug.Log(Vector3.Distance(transform.position, nav_agent.destination));

                if (Vector3.Distance(transform.position, nav_agent.destination) <= posUpdateDistance)
                {
                    isMoving = false;
                }
            }
            else if (!isMoving)
            {
                nav_agent.SetDestination(transform.position);
            }
        }
    }

    private void CheckForPlayerNearby()
    {
        Collider[] hitters = Physics.OverlapSphere(transform.position, followRange);

        bool isTherePlayer = false;

        foreach (Collider hitter in hitters)
        {
            if (hitter.tag == "Player" || hitter.tag == "Target" || hitter.GetComponent<IsPlayer>() != null)
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
        Collider[] hitters = Physics.OverlapSphere(PlusY(transform.position, attackRangeOffsetY), attackRange);

        bool isTherePlayer = false;

        foreach (Collider hitter in hitters)
        {
            if (hitter.tag == "Player" || hitter.tag == "Target" || hitter.GetComponent<IsPlayer>() != null)
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
        Gizmos.DrawWireSphere(PlusY(transform.position, attackRangeOffsetY), attackRange);
    }

    public static Vector3 PlusY (Vector3 A, float B)
    {
        return new Vector3(A.x, A.y + B, A.z);
    }
}
