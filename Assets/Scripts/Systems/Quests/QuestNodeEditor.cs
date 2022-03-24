using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;
using XNode;
using XNodeEditor;

[CustomNodeEditor(typeof(QuestNode))]
public class QuestNodeEditor : NodeEditor
{
    private QuestNode simpleNode;

    public override void OnBodyGUI()
    {
        if (simpleNode == null) simpleNode = target as QuestNode;

        serializedObject.Update();

        target.name = simpleNode.questName != "" ? simpleNode.questName : "Quest";

        //
        // GUI
        //

        GUILayout.Label("Quest Name");
        simpleNode.questName = GUILayout.TextField(simpleNode.questName, new GUILayoutOption[]
            { 
                GUILayout.MinWidth(200)
            });

        //NodeEditorGUILayout.PropertyField(serializedObject.FindProperty("questName"));

        GUILayout.Label("Quest Description");
        simpleNode.questDescrp = GUILayout.TextArea(simpleNode.questDescrp, new GUILayoutOption[]
            {
                GUILayout.MinHeight(50) 
            });

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Quest Start");
        simpleNode.startOption = (QuestStartOption)EditorGUILayout.EnumPopup(simpleNode.startOption);
        EditorGUILayout.EndHorizontal();

        /*for(int x = 0; x < simpleNode.tasks.Count; x++)
        {
            GUILayout.Label(" Element " + x);

            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("Task Type");
            simpleNode.tasks[x].taskType = (TaskType)EditorGUILayout.EnumPopup(simpleNode.tasks[x].taskType);
            EditorGUILayout.EndHorizontal();
        }*/

        NodeEditorGUILayout.PortField(target.GetInputPort("preQuests"));
        NodeEditorGUILayout.PortField(target.GetOutputPort("nextQuests"));

        /*for (int x = 0; x < simpleNode.tasks.Length; x++)
        {
            if(simpleNode.GetInputPort("Tasks " + x).ConnectionCount > 0)
            {
                Node node = simpleNode.GetInputPort("Tasks " + x).Connection.node;
                simpleNode.tasks[x] = node != null ? (node as TaskNode) : null;
            }
        }*/

        /*GUILayout.Label("Tasks");

        for(int x = 0; x < simpleNode.tasks.Length; x++)
        {
            NodePort port = simpleNode.GetInputPort("tasks " + x);
            EditorGUILayout.BeginHorizontal();
            NodeEditorGUILayout.PortField(port);
            simpleNode.tasks[x] = (port.ConnectionCount > 0) && (port.Connection != null) ? port.Connection.node as TaskNode : null;
            EditorGUILayout.EndHorizontal();
        }

        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("+", new GUILayoutOption[]{GUILayout.Width(20)})) 
        { ChangeTaskArray(true); }
        if (GUILayout.Button("-", new GUILayoutOption[] { GUILayout.Width(20) }))
        { ChangeTaskArray(false); }
        EditorGUILayout.EndHorizontal();*/

        NodeEditorGUILayout.PropertyField(serializedObject.FindProperty("tasks"));

        for (int x = 0; x < simpleNode.tasks.Length; x++)
        {
            NodePort port = simpleNode.GetInputPort("tasks " + x);
            simpleNode.tasks[x] = (port.ConnectionCount > 0) && (port.Connection != null) ? port.Connection.node as TaskNode : null;
        }

        if (GUILayout.Button("Taskok lekérése"))
        {
            Debug.Log(simpleNode.tasks.Length);

            for(int x = 0; x < simpleNode.tasks.Length; x++)
            {
                if (simpleNode.tasks[x] != null) Debug.Log(simpleNode.tasks[x].taskType);
            }
        }

        if (GUILayout.Button("Követelmény küldetése"))
        {
            NodePort port = target.GetInputPort("preQuests");
            for (int x = 0; x < port.ConnectionCount; x++)
            {
                Node childNode = port.GetConnection(x).node;
                Debug.Log(((QuestNode)childNode).questName);
            }
        }

        if (GUILayout.Button("Következõ küldetések"))
        {
            NodePort port = target.GetOutputPort("nextQuests");
            for(int x = 0; x < port.ConnectionCount; x++)
            {
                Node childNode = port.GetConnection(x).node;
                Debug.Log(((QuestNode)childNode).questName);
            }
        }

        // Apply property modifications
        serializedObject.ApplyModifiedProperties();
    }

    void ChangeTaskArray(bool increase)
    {
        if (!increase && simpleNode.tasks.Length == 0) return;

        TaskNode[] newList = new TaskNode[simpleNode.tasks.Length + (increase ? 1 : -1)];

        for (int x = 0; x < (newList.Length < simpleNode.tasks.Length ? newList.Length : simpleNode.tasks.Length); x++)
        {
            newList[x] = simpleNode.tasks[x];
        }

        simpleNode.tasks = newList;
    }
}
