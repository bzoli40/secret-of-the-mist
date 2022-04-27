using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XNode;

public class QuestManager : MonoBehaviour
{
    [Header("Import Options")][SerializeField]
    private QuestNodeGraph questCollection;

    [Header("World Elements")]
    public Transform gotoQuestPT;

    private List<QuestNode> quests;

    public List<QuestNode> currentQuests { get; private set; }
    private List<QuestNode> completedQuests;

    private bool questStateChangeNow = false;

    private void Start()
    {
        quests = new List<QuestNode>();
        currentQuests = new List<QuestNode>();
        completedQuests = new List<QuestNode>();

        GetComponent<EventHandler>().onEventRecieved += OnEventHappened;

        ImportQuests();

        //Start New Quests
        StartCoroutine(CheckForStartableQuests());
    }

    private void OnDestroy()
    {
        GetComponent<EventHandler>().onEventRecieved -= OnEventHappened;
    }

    void OnEventHappened(EventObject _eventObj)
    {
        if (_eventObj.type == EventCategory.QUEST) return;

        for (int x = 0; x < currentQuests.Count; x++)
        {
            QuestNode c_quest = currentQuests[x];

            TaskObject currentTask = c_quest.tasks[c_quest.progress];

            //Érzékelés
            if (currentTask.taskType.ToString() == _eventObj.type.ToString())
            {
                if (currentTask.taskType == TaskType.COLLECT && currentTask.item.GetCodingName() == _eventObj.args[1])
                {
                    c_quest.tasks[c_quest.progress].counter++;
                    Debug.Log("Emelés - A");
                    GetComponent<UI_System>().UpdateQuestTaskUI();
                }
                else if (currentTask.taskType == TaskType.GO_TO && _eventObj.args[1] == c_quest.questCode && _eventObj.args[0] == currentTask.location.ToString())
                {
                    c_quest.tasks[c_quest.progress].counter++;
                    Debug.Log("Emelés - A");
                    GetComponent<UI_System>().UpdateQuestTaskUI();
                }
            }
        }

        StartCoroutine(CheckForQuestStateUpdates());
    }

    void ImportQuests()
    {
        /*List<Node> tempList = questCollection.nodes;

        for(int x = 0; x < tempList.Count; x++)
        {
            if (tempList[x].name != "Task") quests.Add(tempList[x] as QuestNode);
        }*/

        List <Node> tempList = questCollection.nodes;

        for (int x = 0; x < tempList.Count; x++)
        {
            (tempList[x] as QuestNode).status = QuestStatus.NOT_STARTED;
            quests.Add(tempList[x] as QuestNode);
        }
    }

    IEnumerator CheckForStartableQuests()
    {
        //QuestNode firstNew = null;

        //int x = 0;

        //while(x < quests.Count && firstNew == null)
        //{
        //    if (quests[x].preQuests.Length == 0)
        //        firstNew = quests[x];
        //    else
        //        x++;
        //}

        //return firstNew;

        for(int x = 0; x < quests.Count; x++)
        {
            //Debug.Log(quests[x].status);
            if (quests[x].status == QuestStatus.NOT_STARTED)
            {

                if (quests[x].preQuests.Length == 0)
                {
                    Debug.Log("Found!");

                    yield return new WaitUntil(() => !questStateChangeNow);
                    StartCoroutine(InitNewQuest(quests[x]));
                }
                else if (presCompleted(quests[x]))
                {
                    Debug.Log("Found!");

                    yield return new WaitUntil(() => !questStateChangeNow);
                    StartCoroutine(InitNewQuest(quests[x]));
                }
            }
        }
    }

    IEnumerator InitNewQuest(QuestNode _newQuest)
    {
        questStateChangeNow = true;

        quests.Find(x => x.questCode == _newQuest.questCode).status = QuestStatus.STARTED;
        _newQuest.status = QuestStatus.STARTED;
        currentQuests.Add(_newQuest);
        
        for(int x = 0; x < _newQuest.tasks.Length; x++)
        {
            _newQuest.tasks[x].counter = 0;
        }

        _newQuest.progress = 0;

        string[] arguments = new string[] { _newQuest.questName, _newQuest.questCode };

        EventHandler.instance.NewEvent(EventCategory.QUEST, arguments, QuestStatus.STARTED);

        yield return new WaitForSeconds(3);

        GetComponent<UI_System>().UpdateQuestListUI("add", _newQuest);

        questStateChangeNow = false;
    }

    IEnumerator CheckForQuestStateUpdates()
    {
        //Taskok vizsgálata
        for (int x = 0; x < currentQuests.Count; x++)
        {
            QuestNode c_quest = currentQuests[x];
            TaskObject currentTask = c_quest.tasks[c_quest.progress];

            if (currentTask.counter >= currentTask.quantity)
            {
                c_quest.progress++;
                //Debug.Log("Emelés - B");
                GetComponent<UI_System>().UpdateQuestTaskUI();

                //Debug.Log("Quest update");
            }
        }

        //Lezárás
        for (int x = 0; x < currentQuests.Count; x++)
        {
            QuestNode c_quest = currentQuests[x];

            if (c_quest.progress >= c_quest.tasks.Length)
            {
                yield return new WaitUntil(() => !questStateChangeNow);
                StartCoroutine(CloseQuest(c_quest));
            }
        }
    }

    IEnumerator CloseQuest(QuestNode _closingOne)
    {
        questStateChangeNow = true;

        quests.Find(x => x.questCode == _closingOne.questCode).status = QuestStatus.FINISHED;
        _closingOne.status = QuestStatus.FINISHED;

        completedQuests.Add(_closingOne);
        currentQuests.Remove(_closingOne);

        GetComponent<UI_System>().UpdateQuestListUI("remove", _closingOne);

        string[] arguments = new string[] { _closingOne.questName, _closingOne.questCode };

        EventHandler.instance.NewEvent(EventCategory.QUEST, arguments, QuestStatus.FINISHED);

        yield return new WaitForSeconds(3);

        questStateChangeNow = false;

        StartCoroutine(CheckForStartableQuests());
    }

    //
    // Search
    //

    public QuestNode findQuest(string _codeName)
    {
        QuestNode res = null;

        for(int x = 0; x < quests.Count; x++)
        {
            if (quests[x].questCode == _codeName) res = quests[x];
        }

        return res;
    }

    //
    // Checkers
    //

    public bool presCompleted(QuestNode _quest)
    {
        bool res = true;

        for(int x = 0; x < _quest.preQuests.Length; x++)
        {
            bool found = false;

            for (int y = 0; y < completedQuests.Count; y++)
            {
                if (_quest.preQuests[x].questCode == completedQuests[y].questCode)
                {
                    found = true;
                }
            }

            if (!found) res = false;
        }

        return res;
    }

    //
    //
    //

    public void SpawnGoToInteraction(QuestNode _quest, int _progress)
    {
        GameObject gtInteract = new("GoToInteractor - " + _quest.questCode, typeof(GoToInteraction));

        GoToInteraction gt = gtInteract.GetComponent<GoToInteraction>();
        TaskObject to = _quest.tasks[_progress];

        gtInteract.transform.parent = gotoQuestPT;
        gtInteract.transform.position = to.location;

        gt.SetGoTo(to.completeRange, to.location, _quest.questCode);
    }
}
