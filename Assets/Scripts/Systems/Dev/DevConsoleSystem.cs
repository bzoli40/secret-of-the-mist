using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class DevConsoleSystem : MonoBehaviour
{
    bool consoleOn = false;

    public InputField DevConsole;

    //Parancsok
    public static DevCommand<string, int> ADD_ITEM;
    public static DevCommand<string> SUMMON_EFFECT;

    //Parancs-lista
    public List<object> commands;

    //
    //
    //

    private void Start()
    {
        DevConsole.gameObject.SetActive(false);
    }

    //Parancsok meghat�roz�sa �s felt�lt�se a list�ra
    private void Awake()
    {
        ADD_ITEM = new DevCommand<string, int>("add_item", "Add an item to your inventory with the selected amount", "add_item", (x, y) =>
        {
            GameObject.FindGameObjectWithTag("GameSystem").GetComponent<InventorySystem>().AddItem(x, y);
            Debug.Log("Item hozz�adva!");
        });

        SUMMON_EFFECT = new DevCommand<string>("summon_effect", "Summon the EFFECT with the AMOUNT", "summon_effect", (x) =>
        {
            GameObject.FindGameObjectWithTag("GameSystem").transform.GetChild(0).GetComponent<EffectLibrary>().SummonEffect(x);
            Debug.Log("Effekt leid�zve!");
        });

        commands = new List<object>
        {
            ADD_ITEM,
            SUMMON_EFFECT
        };
    }

    //Parancssor megnyit�sa
    public void OnDevConsole(InputValue value)
    {
        Player p = GameObject.FindGameObjectWithTag("GameSystem").GetComponent<Player>();

        if (p.playerState == PlayerState.DOANYTHING)
        {
            DevConsole.gameObject.SetActive(true);
            consoleOn = true;
            DevConsole.ActivateInputField();

            p.ChangeFocus();
        }
        else
        {
            DevConsole.gameObject.SetActive(false);

            if(consoleOn)
            {
                p.ChangeFocus();
            }

            consoleOn = false;
        }

    }

    //Ha enterezz�nk, akkor n�zze meg az InputFieldet
    public void OnEnter(InputValue value)
    {
        ExecuteCommand(DevConsole.text);
        DevConsole.text = "";

        OnDevConsole(null);
    }

    public void ExecuteCommand(string cmdLine)
    {
        string[] args = cmdLine.Split(' ');

        for(int x = 0; x < commands.Count; x++)
        {
            DevCommandBase cmdBase = commands[x] as DevCommandBase;

            if(cmdLine.Contains(cmdBase.cmdId))
            {
                if (commands[x] as DevCommand != null)
                {
                    (commands[x] as DevCommand).Invoke();
                }
                else if(commands[x] as DevCommand<string> != null)
                {
                    (commands[x] as DevCommand<string>).Invoke(args[1]);
                }
                else if (commands[x] as DevCommand<string, int> != null)
                {
                    (commands[x] as DevCommand<string, int>).Invoke(args[1], int.Parse(args[2]));
                }
            }
        }
    }

}
