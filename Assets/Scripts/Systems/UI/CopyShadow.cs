using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CopyShadow : MonoBehaviour
{
    public Text what;
    private void Update()
    {
        GetComponent<Text>().text = what.text;    
    }
}
