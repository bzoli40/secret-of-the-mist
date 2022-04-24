using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(TaskObject))]
[CanEditMultipleObjects]
public class TaskEditor : Editor
{
    private TaskObject obj;

    public override void OnInspectorGUI()
    {
        if (obj == null) obj = target as TaskObject;

        serializedObject.Update();

        GUILayout.Label(obj.name);

        EditorGUILayout.BeginVertical(GUI.skin.box);

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Descr");
        obj.taskDescr = EditorGUILayout.TextArea(obj.taskDescr, new GUILayoutOption[]
            {
                GUILayout.MinHeight(50),
                GUILayout.MinWidth(200)
            });
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Type");
        obj.taskType = (TaskType)EditorGUILayout.EnumPopup(obj.taskType);
        EditorGUILayout.EndHorizontal();

        GUILayout.Space(15);

        EditorGUILayout.BeginVertical(GUI.skin.box);

        switch (obj.taskType)
        {
            case TaskType.COLLECT:
                EditorGUILayout.BeginHorizontal();
                GUILayout.Label("Item", GUILayout.Width(70));
                obj.item = (Item)EditorGUILayout.ObjectField(obj.item, typeof(Item), true);
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                GUILayout.Label("Quantity", GUILayout.Width(70));
                obj.quantity = EditorGUILayout.IntField(obj.quantity);
                EditorGUILayout.EndHorizontal();
                break;
        }

        EditorGUILayout.EndVertical();

        EditorGUILayout.EndVertical();

        serializedObject.ApplyModifiedProperties();

        EditorUtility.SetDirty(target);
    }
}
