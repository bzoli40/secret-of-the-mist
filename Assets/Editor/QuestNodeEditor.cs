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
    public override void OnBodyGUI()
    {
        QuestNode node = target as QuestNode;

        serializedObject.Update();

        target.name = node.questName != "" ? node.questName : "Quest";

        //
        // GUI
        //

        GUILayout.Label("Quest Coding Name");
        node.questCode = EditorGUILayout.TextField(node.questCode, new GUILayoutOption[]
            {
                GUILayout.MinWidth(200)
            });

        GUILayout.Label("Quest Name");
        node.questName = EditorGUILayout.TextField(node.questName, new GUILayoutOption[]
            { 
                GUILayout.MinWidth(200)
            });

        //NodeEditorGUILayout.PropertyField(serializedObject.FindProperty("questName"));

        GUILayout.Label("Quest Description");
        node.questDescrp = EditorGUILayout.TextArea(node.questDescrp, new GUILayoutOption[]
            {
                GUILayout.MinHeight(50) 
            });

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Quest Start");
        node.startOption = (QuestStartOption)EditorGUILayout.EnumPopup(node.startOption);
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

        //NodeEditorGUILayout.PropertyField(serializedObject.FindProperty("tasks"));

        EditorGUILayout.PropertyField(serializedObject.FindProperty("tasks"));

        //for (int x = 0; x < node.tasks.Length; x++)
        //{
        //    NodePort port = node.GetInputPort("tasks " + x);
        //    node.tasks[x] = (port.ConnectionCount > 0) && (port.Connection != null) ? port.Connection.node as TaskNode : null;
        //}

        node.preQuests = new QuestNode[node.GetInputPort("preQuests").ConnectionCount];
        for (int x = 0; x < node.GetInputPort("preQuests").ConnectionCount; x++)
        {
            Node prePortX = node.GetInputPort("preQuests").GetConnection(x).node;
            node.preQuests[x] = prePortX as QuestNode;
        }

        if (GUILayout.Button("Taskok lekérése"))
        {
            Debug.Log(node.tasks.Length);

            for(int x = 0; x < node.tasks.Length; x++)
            {
                if (node.tasks[x] != null) Debug.Log(node.tasks[x].taskType);
            }
        }

        if (GUILayout.Button("Követelmény küldetése"))
        {
            NodePort port = target.GetInputPort("preQuests");
            /*for (int x = 0; x < port.ConnectionCount; x++)
            {
                Node childNode = port.GetConnection(x).node;
                Debug.Log(((QuestNode)childNode).questName);
            }*/

            for(int x = 0; x < node.preQuests.Length; x++)
            {
                Debug.Log(node.preQuests[x].questName);
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

    /*void ChangeTaskArray(bool increase)
    {
        if (!increase && simpleNode.tasks.Length == 0) return;

        TaskNode[] newList = new TaskNode[simpleNode.tasks.Length + (increase ? 1 : -1)];

        for (int x = 0; x < (newList.Length < simpleNode.tasks.Length ? newList.Length : simpleNode.tasks.Length); x++)
        {
            newList[x] = simpleNode.tasks[x];
        }

        simpleNode.tasks = newList;
    }*/
}
