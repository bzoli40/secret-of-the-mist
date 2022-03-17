using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New Quest Task", menuName = "KodersBase/Quests/Quest Task")]
public class QuestTask : ScriptableObject
{
    public enum TaskType { KILL, COLLECT, GO_TO, TALK_TO, ETC };
    public TaskType taskType;
}
