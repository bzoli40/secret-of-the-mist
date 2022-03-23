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
                GUILayout.MinWidth(200),
            });


        GUILayout.Label("Quest Description");
        simpleNode.questDescrp = GUILayout.TextArea(simpleNode.questDescrp, new GUILayoutOption[]
            {
                GUILayout.MinHeight(50),
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

        NodeEditorGUILayout.DynamicPortList(
            "Tasks",
            typeof(TaskNode),
            serializedObject,
            NodePort.IO.Input,
            Node.ConnectionType.Override,
            Node.TypeConstraint.None,
            null);

        if(GUILayout.Button("Taskok lekérése"))
        {
            for(int x = 0; x < simpleNode.tasks.Count; x++)
            {
                if (simpleNode.tasks[x] != null) Debug.Log(simpleNode.tasks[x].taskType);
            }
        }

        // Apply property modifications
        serializedObject.ApplyModifiedProperties();
    }
}
