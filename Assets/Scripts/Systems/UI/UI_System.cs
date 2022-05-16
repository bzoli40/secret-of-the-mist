using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class LoadingMessage
{
    public string message;
    public float where;

    public LoadingMessage(float _where, string _message)
    {
        where = _where;
        message = _message;
    }
}

public class UI_System : MonoBehaviour
{
    MenuLibrary menu_lib;

    //Prefabs
    public GameObject itemInventoryPref;

    public GameObject questTaskPref;
    public GameObject questListIconPref;

    //Transform parent
    public Transform inventoryPT;

    public Transform taskPT;
    public Transform questListPT;

    //Created Object List
    private List<GameObject> itemInInventoryObjs = new();

    private List<GameObject> questTopIconsObjs = new();
    private List<GameObject> questTasksObjs = new();

    //Images
    public List<Sprite> taskIcons = new();

    //QuestBar
    private string currentlyShownQuest;
    private int currentlyShownTask;
    private List<string> currentlySeeAbleQuests = new();

    //Loading
    private List<LoadingMessage> loadingMessages = new();

    //
    //
    //

    private void Start()
    {
        menu_lib.inventoryMenu.SetActive(false);
        menu_lib.questBar.SetActive(false);
    }

    private void Awake()
    {
        menu_lib = transform.GetChild(0).GetComponent<MenuLibrary>();
    }

    private void Update()
    {
        float progress = 0;
        if ((progress = GameManager.main.loadProgress) <= 1)
        {
            menu_lib.loadingBar.fillAmount = progress;
            UpdateLoadMessage(progress);
        }

    }

    #region Loading

    public void AddLoadMessage(float _w, string _m)
    {
        loadingMessages.Add(new LoadingMessage(_w, _m));
    }

    public void UpdateLoadMessage(float _progress)
    {
        string msg = "";

        for(int x = 0; x < loadingMessages.Count; x++)
        {
            if (loadingMessages[x].where <= _progress) msg = loadingMessages[x].message;
        }

        menu_lib.loadingMessage.text = msg;
    }

    public void ShowLoadingScreen(bool isTrue)
    {
        menu_lib.loadingScreen.SetActive(isTrue);
    }

    public void LoadingScreenEnd()
    {
        menu_lib.loadingScreen.GetComponent<Animator>().SetTrigger("fadeOut");
    }

    #endregion

    #region Inventory

    public void SetInventoryMenu()
    {
        menu_lib.inventoryMenu.SetActive(!menu_lib.inventoryMenu.activeSelf);
        if(menu_lib.inventoryMenu.activeSelf)
        {
            ListItems();
        }
    }

    public void SetInventoryMenu(bool show)
    {
        menu_lib.inventoryMenu.SetActive(show);
    }

    public void ListItems()
    {
        DeletePreviousInventoryPrefs();

        Dictionary<Item, int> itemInInventory = GetComponent<InventorySystem>().GetItemList();
        Debug.Log(itemInInventory.Count);

        foreach(KeyValuePair<Item, int> pair in itemInInventory)
        {
            GameObject newListElement = Instantiate(itemInventoryPref, inventoryPT);
            newListElement.transform.GetChild(0).GetComponent<Image>().sprite = pair.Key.GetIcon();
            newListElement.transform.GetChild(1).GetComponent<Text>().text = pair.Value.ToString();

            itemInInventoryObjs.Add(newListElement);
        }
    }

    public void DeletePreviousInventoryPrefs()
    {
        if (itemInInventoryObjs.Count == 0) return;

        for(int x = 0; x < itemInInventoryObjs.Count; x++)
        {
            Destroy(itemInInventoryObjs[x]);
        }

        itemInInventoryObjs = new List<GameObject>();
    }

    #endregion

    #region Quest

    public void UpdateQuestListUI(string modifyType = "", QuestNode quest = null)
    {
        List<QuestNode> c_quests = GetComponent<QuestManager>().currentQuests;

        if(currentlySeeAbleQuests.Count == 0 && c_quests.Count != 0)
        {
            currentlyShownQuest = c_quests[0].questCode;

            for (int x = 0; x < c_quests.Count; x++)
            {
                currentlySeeAbleQuests.Add(c_quests[x].questCode);

                AddNewQuestIcon();
            }
        }
        else
        {
            switch (modifyType)
            {
                case "add":
                    currentlyShownQuest = quest.questCode;
                    currentlySeeAbleQuests.Add(quest.questCode);

                    AddNewQuestIcon();
                    break;

                case "remove":
                    int where = findQuest(quest.questCode);

                    if (where >= 0)
                    {
                        currentlySeeAbleQuests.RemoveAt(where);
                        //Debug.Log(questTopIconsObjs.Count);

                        questTopIconsObjs[where].GetComponent<Animator>().Play("destroyIcon_Quest");
                        StartCoroutine(DeleteObj(2/6f, questTopIconsObjs[where]));
                        //Destroy(questTopIconsObjs[where]);
                        questTopIconsObjs.RemoveAt(where);


                        //Debug.Log(questTopIconsObjs.Count);

                        if (currentlySeeAbleQuests.Count > 0)
                        {
                            currentlyShownQuest = currentlySeeAbleQuests[0];
                            DarkenAllQuestIcon(0);
                        }
                    }

                    break;
            }
        }

        if (currentlySeeAbleQuests.Count > 0) UpdateQuestTaskUI();
        menu_lib.questBar.SetActive(c_quests.Count > 0);
    }

    public void UpdateQuestTaskUI()
    {
        QuestNode current = GetComponent<QuestManager>().findQuest(currentlyShownQuest);

        if (current == null) return;
        if (current.progress >= current.tasks.Length) return;

        menu_lib.questBar.transform.GetChild(2).GetChild(0).GetComponent<Text>().text = current.questName;
        menu_lib.questBar.transform.GetChild(2).GetChild(2).GetComponent<Text>().text = current.questDescrp;

        TaskObject currentT = current.tasks[current.progress];

        if (currentT.taskType == TaskType.GO_TO) GetComponent<QuestManager>().SpawnGoToInteraction(current, current.progress);

        string taskString = currentT.taskDescr;
        string taskCounter = currentT.quantity > 1 ? " (" + currentT.counter + "/" + currentT.quantity + ")" : "";

        Sprite whichType = taskIcons.Find(x => x.name == "task_type_icons_" + currentT.taskType.ToString().ToLower());

        // Ha kell tracker
        GetComponent<TrackerManager>().ResetTrackers();
        if (currentT.taskType == TaskType.GO_TO) GetComponent<TrackerManager>().NewTracker(currentT.location);

        if (whichType != null) taskPT.GetChild(0).GetChild(0).GetComponent<Image>().sprite = whichType;
        taskPT.GetChild(0).GetChild(1).GetComponent<Text>().text = taskString + taskCounter;
    }

    public void AddNewQuestIcon()
    {
        DarkenAllQuestIcon();

        GameObject barObj = Instantiate(questListIconPref, questListPT);
        questTopIconsObjs.Add(barObj);
    }

    public void DarkenAllQuestIcon(int except = -1)
    {
        if (questTopIconsObjs.Count != 0)
        {
            for (int x = 0; x < questTopIconsObjs.Count; x++)
            {
                if(x != except)
                {
                    questTopIconsObjs[x].GetComponent<Image>().color = new Color(0.5f, 0.5f, 0.5f);
                    questTopIconsObjs[x].GetComponent<Animator>().Play("switchIcon_Quest_from");
                }
                else
                {
                    questTopIconsObjs[x].GetComponent<Image>().color = new Color(1f, 0.8f, 0.29f);
                    questTopIconsObjs[x].GetComponent<Animator>().Play("switchIcon_Quest_to");
                }
            }
        }
    }

    //
    // Switch
    //

    public void OnQuest(InputValue value)
    {
        if (currentlySeeAbleQuests.Count < 2) return;

        int currentQuestIndex = findQuest(currentlyShownQuest);
        int next = currentQuestIndex + 1;
        if (next >= currentlySeeAbleQuests.Count) next = 0;

        currentlyShownQuest = GetComponent<QuestManager>().findQuest(currentlySeeAbleQuests[next]).questCode;

        DarkenAllQuestIcon(next);

        UpdateQuestTaskUI();
    }

    //
    // Search
    //

    public int findQuest(string _codeName)
    {
        int res = -1;

        for (int x = 0; x < currentlySeeAbleQuests.Count; x++)
        {
            if (currentlySeeAbleQuests[x] == _codeName) res = x;
        }

        return res;
    }

    #endregion

    #region Stats

    public bool SetupStats()
    {
        Player player = GetComponent<Player>();
        player.SetupBasics();

        int hp = player.health;
        int maxhp = player.maxHealth;

        for(int x = 0; x < maxhp; x++)
        {
            GameObject hearthObj = Instantiate(menu_lib.hearthPref, menu_lib.healthBar.transform);
            hearthObj.GetComponent<Image>().sprite = menu_lib.full_hearth;
        }

        return true;
    }

    #endregion

    IEnumerator DeleteObj (float delay, GameObject obj)
    {
        yield return new WaitForSeconds(delay);
        Destroy(obj);
    }
}
