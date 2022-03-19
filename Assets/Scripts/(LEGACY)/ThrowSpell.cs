using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class ThrowSpell : MonoBehaviour
{
    Rigidbody rigid;

    Vector3 startPos;
    Vector3 startRot;

    private bool isMoving = false;

    [SerializeField]
    private float forceCount = 150;
    [SerializeField]
    private float inMess = 0.02f;
    [SerializeField]
    private float rotation = 1f;

    private void Start()
    {
        rigid = GetComponent<Rigidbody>();
        startPos = transform.position;
        startRot = transform.eulerAngles;

        rigid.isKinematic = true;
        GetComponent<MeshCollider>().enabled = false;
    }

    private void Update()
    {
        if(isMoving)
        {
            transform.Rotate(0,0,rotation);
        }
    }

    public void LaunchProjectile()
    {
        GetComponent<MeshCollider>().enabled = true;

        rigid.isKinematic = false;

        //transform.parent = null;
        rigid.AddForce(transform.forward * forceCount);

        isMoving = true;
    }

    private void OnCollisionEnter(Collision collision)
    {
        Debug.Log("Hit!");

        isMoving = false;

        rigid.isKinematic = true;
        transform.position += transform.forward * inMess;

        transform.GetChild(1).GetComponent<VisualEffect>().Play();
    }

    public void ResetPos()
    {
        transform.position = startPos;
        transform.eulerAngles = startRot;
    }
}
