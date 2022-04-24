using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XNode;

[NodeTint("#5f9482")]
public class QuestNode : Node
{
    public string questCode;

    public string questName;
    public string questDescrp;
    public QuestStartOption startOption;

    public QuestStatus status = QuestStatus.NOT_STARTED;
    public int progress = 0;

    public TaskObject[] tasks;

    [Input] public QuestNode[] preQuests = new QuestNode[0];
    [Output] public QuestNode[] nextQuests = new QuestNode[0];

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
