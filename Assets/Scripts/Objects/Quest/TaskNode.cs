using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XNode;

//[CreateAssetMenu(fileName = "New Quest Task", menuName = "KodersBase/Quests/Quest Task")]
//[System.Serializable]

[NodeTint("#5f8794")]
public class TaskNode : Node
{
    public TaskType taskType;

    //Collect
    public int quantity;
    public Item item;

    //Go-to
    public Vector3 location;

    [Output] public TaskNode questTask;

    public override object GetValue(NodePort port)
    {
        return null;
    }
}
