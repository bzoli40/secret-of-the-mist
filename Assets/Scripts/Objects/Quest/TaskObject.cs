using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New Task", menuName = "KodersBase/Task")]
public class TaskObject : ScriptableObject
{
    public TaskType taskType;
    public string taskDescr;

    //System variables
    public bool completed = false;
    public int counter = 0;

    //Collect
    public int quantity = 1;
    public Item item;

    //Go-to
    public Vector3 location;
}
