using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class Movement : MonoBehaviour
{
    [SerializeField]
    private LayerMask layerMask;

    //public AbilityUsage abUs;

    public bool isMoved = false;
    public bool movedLast = false;
    public bool runMode = false;

    public GameObject player;
    public float moveSpeed = 1;
    public float runSpeed = 2;

    public float facing = 0;
    public float rotateSpeed = 1;

    float rotateSmooth;

    public Transform throwableParent;

    //private-k
    //private InputMaster inputMaster;
    private float movementS = 0;

    [SerializeField]
    Vector3 moveVec;

    public GameObject testProj;

    //Input setupolás

    /*private void Awake()
    {
        inputMaster = new InputMaster();
        inputMaster.Player.Enable();

        //Event meghívások
        inputMaster.Player.Run.performed += Run;
        inputMaster.Player.Run.canceled += Run;
    }*/

    private void Start()
    {
        //inputMaster = new InputMaster();
        //inputMaster.Player.Enable();

        //Event meghívások
        //inputMaster.Player.Sprint.performed += Run;
        //inputMaster.Player.Sprint.canceled += Run;
        //inputMaster.Player.Ability_1.performed += abUs.UseAbility1;
    }

    //

    void FixedUpdate()
    {
        Animator anim = player.GetComponent<Animator>();

        //

        //Move();

        movementS = runMode ? runSpeed : moveSpeed;
        anim.SetFloat("walkSpeed", runMode ? 1 : 0);

        //Top-button kamerához mozgás

        //Vector2 inputVec = inputMaster.Player.Movement.ReadValue<Vector2>();

        Vector3 dir = new Vector3(0,0,0); //= new Vector3(inputVec.x, 0f, inputVec.y).normalized;

        if (dir.magnitude >= 0.1f)
        {
            float targetAngle = Mathf.Atan2(dir.x, dir.z) * Mathf.Rad2Deg + Camera.main.transform.eulerAngles.y;
            float angle = Mathf.SmoothDampAngle(transform.eulerAngles.y, targetAngle, ref rotateSmooth, rotateSpeed);

            transform.rotation = Quaternion.Euler(0f, angle, 0f);

            moveVec = Quaternion.Euler(0f, angle, 0f) * Vector3.forward;

            anim.SetFloat("motionChecker", 1);

            GetComponent<Rigidbody>().MovePosition(transform.position + movementS * Time.deltaTime * moveVec);
        }
        else
        {
            anim.SetFloat("motionChecker", 0);
        }
        
        /*
        //Fordulás
        Ray ray = Camera.main.ScreenPointToRay(Mouse.current.position.ReadValue());

        if (Physics.Raycast(ray, out RaycastHit hit, float.MaxValue, layerMask))
        {
            Vector3 target = hit.point - new Vector3(0, transform.position.y, 0);

            transform.LookAt(target);
        }
        */
    }

    //

    public void Run(InputAction.CallbackContext value)
    {
        runMode = value.performed;
    }

    /*public void Test(string animName)
    {
        Animator anim = player.GetComponent<Animator>();
        //anim.Play(animName, 0);

        Instantiate(testProj, throwableParent);

        anim.SetTrigger("startMotion");
    }

    public void TestTrigger()
    {
        Animator anim = player.GetComponent<Animator>();
        anim.SetTrigger("spellTrigger");
    }

    public void ThrowObject()
    {
        if(throwableParent.childCount > 0)
        {
            Transform child = throwableParent.GetChild(0);

            child.eulerAngles = transform.eulerAngles;
            child.parent = null;

            child.GetComponent<ThrowSpell>().LaunchProjectile();
        }
    }*/
}
