using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager main;

    public float inGameTime { get; private set; } = 0;

    public event Action whenGameLoadCompleted;

    public float loadProgress { get; private set; } = 0;
    private bool loaded = false;
    public float trueProgress { get; private set; } = 1;

    public GameState gameState { get; private set; } = GameState.PAUSED;

    private void Awake()
    {
        if (main == null) main = this;
    }

    private void Start()
    {
        StartLoad();
    }

    private void FixedUpdate()
    {
        if(loaded) 
            inGameTime += Time.fixedDeltaTime;
        else if (loadProgress < trueProgress)
            loadProgress += Time.deltaTime * 0.25f;
        else if (!loaded && loadProgress >= 1)
        {
            GetComponent<UI_System>().LoadingScreenEnd();

            //Játék bool értékek
            {
                loaded = true;
                gameState = GameState.PLAY;
                GetComponent<Player>().WhenLoadEnded();
            }

            StartCoroutine(LoadFinished());
        }
    }

    IEnumerator LoadFinished()
    {
        yield return new WaitForSeconds(2);
        whenGameLoadCompleted();
    }

    private void StartLoad()
    {
        UI_System UI = GetComponent<UI_System>();
        UI.ShowLoadingScreen(true);

        //Küldetések
        UI.AddLoadMessage(0, "Küldetések betöltése");
        if(GetComponent<QuestManager>().ImportQuests())
        {
            trueProgress = 0.5f;

            //Statok
            UI.AddLoadMessage(0.5f, "Statisztikák beállítása");
            if (UI.SetupStats())
            {
                trueProgress = 1f;
                UI.AddLoadMessage(0.98f, "Betöltés sikeres!");
            }
        }
    }
}
