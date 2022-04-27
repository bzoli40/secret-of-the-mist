using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EventObject
{
    public double happened;
    public EventCategory type;
    public string[] args;
    public object arg_bonus;

    public EventObject(EventCategory _t, string[] _a, double _h, object _b)
    {
        type = _t;
        args = _a;
        happened = _h;
        arg_bonus = _b;
    }
}

public class EventHandler : MonoBehaviour
{
    public static EventHandler instance;

    List<EventObject> eventsStored;
    public event Action<EventObject> onEventRecieved;

    public float inGameTime = 0;

    private void Awake()
    {
        if (instance == null) instance = this;
    }

    private void Start()
    {
        eventsStored = new List<EventObject>();
        onEventRecieved += OnEventReceived;
    }

    private void FixedUpdate()
    {
        inGameTime += Time.fixedDeltaTime;
    }

    public void NewEvent(EventCategory _event, string[] _arguments, object _arg_bonus = null)
    {
        EventObject newEvent = new (_event, _arguments, inGameTime, _arg_bonus);

        eventsStored.Add(newEvent);
        onEventRecieved(newEvent);
    }

    public void OnEventReceived(EventObject eventHappened)
    {
        switch (eventHappened.type)
        {
            case EventCategory.COLLECT:
                GetComponent<NotificationHandler>().PushNotification(NotificationType.COLLECT, eventHappened.args);
                break;
            case EventCategory.QUEST:
                GetComponent<NotificationHandler>().PushNotification(NotificationType.QUEST_STATE_CHANGE, eventHappened.args, eventHappened.arg_bonus);
                break;
        }
    }

    //
    //
    //

    private void OnDestroy()
    {
        onEventRecieved -= OnEventReceived;
    }
}
