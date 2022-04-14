using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;
using XNode;
using XNodeEditor;

[CustomNodeEditor(typeof(TaskNode))]
public class TaskNodeEditor : NodeEditor
{
    private TaskNode simpleNode;

    public override void OnBodyGUI()
    {
        if (simpleNode == null) simpleNode = target as TaskNode;

        serializedObject.Update();

        //
        // GUI
        //

        NodeEditorGUILayout.PortField(target.GetOutputPort("questTask"));

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Quest Name");
        simpleNode.taskType = (TaskType)EditorGUILayout.EnumPopup(simpleNode.taskType);
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(15);

        switch (simpleNode.taskType)
        {
            case TaskType.COLLECT:
                EditorGUILayout.BeginHorizontal();
                GUILayout.Label("Item", GUILayout.Width(70));
                simpleNode.item = (Item)EditorGUILayout.ObjectField(simpleNode.item, typeof(Item), true);
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                GUILayout.Label("Quantity", GUILayout.Width(70));
                simpleNode.quantity = EditorGUILayout.IntField(simpleNode.quantity);
                EditorGUILayout.EndHorizontal();
                break;
        }

        // Apply property modifications
        serializedObject.ApplyModifiedProperties();
    }
}
