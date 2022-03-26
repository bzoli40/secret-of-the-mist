using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class NotificationHandler : MonoBehaviour
{
    [Header("Pick Up")]
    public GameObject pickUpNotiPref;
    public Transform pickUpNotiTrans;

    public void PushNotification(NotificationType type, string[] args)
    {
        switch (type)
        {
            case NotificationType.PICK_UP:
                Item item = transform.GetChild(0).GetComponent<ItemLibrary>().findItem(args[1]);

                GameObject notif = pickUpNotiPref;
                notif.transform.GetChild(0).GetComponent<Image>().sprite = item.GetIcon();
                notif.transform.GetChild(1).GetComponent<Text>().text = item.GetDisplayName();

                GameObject notifInst = Instantiate(notif, pickUpNotiTrans);

                StartCoroutine(DestroyNotification(1.5f, notifInst.GetComponent<Animator>()));
                break;
        }
    }

    IEnumerator DestroyNotification(float waitTime, Animator obj)
    {
        yield return new WaitForSeconds(waitTime);
        obj.SetTrigger("despawn");
    }
}
