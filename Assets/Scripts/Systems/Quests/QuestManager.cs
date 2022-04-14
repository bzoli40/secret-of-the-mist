using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XNode;

public class QuestManager : MonoBehaviour
{
    [Header("Import Options")][SerializeField]
    private QuestNodeGraph questCollection;

    private List<QuestNode> quests;

    private List<QuestNode> completedQuests;

    private QuestNode currentQuest;

    private void Start()
    {
        quests = new List<QuestNode>();

        ImportQuests();

        //Start New Quest
        QuestNode qnode = CheckForNewQuests();

        if (qnode  != null) StartCoroutine(InitNewQuest(qnode));
    }

    void ImportQuests()
    {
        List<Node> tempList = questCollection.nodes;

        for(int x = 0; x < tempList.Count; x++)
        {
            if (tempList[x].name != "Task") quests.Add(tempList[x] as QuestNode);
        }
    }

    QuestNode CheckForNewQuests()
    {
        QuestNode firstNew = null;

        int x = 0;

        while(x < quests.Count && firstNew == null)
        {
            if (quests[x].preQuests.Length == 0)
                firstNew = quests[x];
            else
                x++;
        }

        return firstNew;
    }

    IEnumerator InitNewQuest(QuestNode newQuest)
    {
        yield return new WaitForSeconds(3);
        currentQuest = newQuest;

        string[] arguments = new string[] { "Új küldetés" , newQuest.questName, newQuest.questCode };

        EventSystem.instance.NewEvent(EventCategory.QUEST, arguments);
    }

    void ResumeQuest()
    {

    }

    void EndQuest()
    {

    }
}
