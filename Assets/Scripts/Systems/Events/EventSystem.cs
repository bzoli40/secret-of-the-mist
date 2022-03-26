using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EventObject
{
    public double happened;
    public EventType type;
    public string[] args;

    public EventObject(EventType _t, string[] _a, double _h)
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

    public void NewEvent(EventType _event, string[] _arguments)
    {
        EventObject newEvent = new EventObject(_event, _arguments, inGameTime);

        eventsStored.Add(newEvent);
        onEventRecieved(newEvent);
    }

    public void OnEventReceived(EventObject eventHappened)
    {
        if(eventHappened.type == EventType.COLLECT)
        {
            GetComponent<NotificationHandler>().PushNotification(NotificationType.PICK_UP, eventHappened.args);
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
