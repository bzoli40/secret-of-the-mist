using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EventObject
{
    public double happened;
    public EventCategory type;
    public string[] args;

    public EventObject(EventCategory _t, string[] _a, double _h)
    {
        type = _t;
        args = _a;
        happened = _h;
    }
}

public class EventSystem : MonoBehaviour
{
    public static EventSystem instance;

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

    public void NewEvent(EventCategory _event, string[] _arguments)
    {
        EventObject newEvent = new EventObject(_event, _arguments, inGameTime);

        eventsStored.Add(newEvent);
        onEventRecieved(newEvent);
    }

    public void OnEventReceived(EventObject eventHappened)
    {
        switch (eventHappened.type)
        {
            case EventCategory.COLLECT:
                GetComponent<NotificationHandler>().PushNotification(NotificationType.PICK_UP, eventHappened.args);
                break;
            case EventCategory.QUEST:
                GetComponent<NotificationHandler>().PushNotification(NotificationType.QUEST_STATE_CHANGE, eventHappened.args);
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
