using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

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

                GameObject barObj = Instantiate(questListIconPref, questListPT);
                questTopIconsObjs.Add(barObj);
            }
        }
        else
        {
            switch (modifyType)
            {
                case "add":
                    currentlyShownQuest = quest.questCode;
                    currentlySeeAbleQuests.Add(quest.questCode);

                    GameObject barObj = Instantiate(questListIconPref, questListPT);
                    questTopIconsObjs.Add(barObj);
                    break;

                case "remove":
                    int where = findQuest(quest.questCode);

                    if (where >= 0)
                    {
                        currentlySeeAbleQuests.RemoveAt(where);
                        //Debug.Log(questTopIconsObjs.Count);

                        Destroy(questTopIconsObjs[where]);
                        questTopIconsObjs.RemoveAt(where);

                        //Debug.Log(questTopIconsObjs.Count);

                        if (currentlySeeAbleQuests.Count > 0)
                        {
                            currentlyShownQuest = currentlySeeAbleQuests[0];
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

        if (current.progress >= current.tasks.Length) return;

        menu_lib.questBar.transform.GetChild(2).GetChild(0).GetComponent<Text>().text = current.questName;
        menu_lib.questBar.transform.GetChild(2).GetChild(2).GetComponent<Text>().text = current.questDescrp;

        TaskObject currentT = current.tasks[current.progress];

        string taskString = currentT.taskDescr;
        string taskCounter = currentT.quantity > 1 ? " (" + currentT.counter + "/" + currentT.quantity + ")" : "";

        Sprite whichType = taskIcons.Find(x => x.name == "task_type_icons_" + currentT.taskType.ToString().ToLower());

        if (whichType != null) taskPT.GetChild(0).GetChild(0).GetComponent<Image>().sprite = whichType;
        taskPT.GetChild(0).GetChild(1).GetComponent<Text>().text = taskString + taskCounter;
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
}
