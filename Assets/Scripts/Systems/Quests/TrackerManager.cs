using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Tracker
{
    public GameObject g_obj;
    public Vector3 pointTo;

    public Tracker(GameObject _obj, Vector3 _point)
    {
        g_obj = _obj;
        pointTo = _point;
    }
}

public class TrackerManager : MonoBehaviour
{
    [HideInInspector]
    public bool usingNow = false;

    public GameObject trackerPref;
    public Transform trackerPT;

    public List<Tracker> trackerList = new();

    public Vector3 trackersOffset;

    private void Update()
    {
        if (usingNow)
        {
            foreach (Tracker tracker in trackerList)
            {
                tracker.g_obj.transform.position = Camera.main.WorldToScreenPoint(tracker.pointTo + trackersOffset);

                float distance = Vector3.Distance(tracker.pointTo, GameObject.FindGameObjectWithTag("Player").transform.position);

                tracker.g_obj.transform.GetChild(2).GetComponent<Text>().text = Mathf.RoundToInt(distance) + "m";
            }
        }
    }

    public void NewTracker(Vector3 whereToPoint)
    {
        GameObject newTrackerObj = Instantiate(trackerPref, trackerPT);
        Tracker newTracker = new Tracker(newTrackerObj, whereToPoint);

        trackerList.Add(newTracker);

        usingNow = true;
    }

    public void ResetTrackers()
    {
        usingNow = false;

        foreach(Tracker tracker in trackerList)
        {
            Destroy(tracker.g_obj);
        }

        trackerList.Clear();
    }
}
