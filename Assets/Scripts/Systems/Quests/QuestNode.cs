using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XNode;

public class QuestNode : Node
{
    public string questName;
    public string questDescrp;
    public QuestStartOption startOption;

    [Input(dynamicPortList = true)]
    public List<TaskNode> tasks;

    [Input] public int preQuests;
    [Output] public int nextQuests;

    public override object GetValue(NodePort port)
    {
        if (port.fieldName == "preQuests")
        {
            return GetInputPort("preQuests").ConnectionCount;
        }
        else if (port.fieldName == "nextQuests")
        {
            return GetOutputPort("nextQuests").ConnectionCount;
        }
        else return null;
    }
}
