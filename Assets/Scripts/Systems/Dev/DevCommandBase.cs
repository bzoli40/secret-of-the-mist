using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DevCommandBase
{
    private string _cmdId;
    private string _cmdDescr;
    private string _cmdFormat;

    public string cmdId { get { return _cmdId; } }
    public string cmdDescr { get { return _cmdDescr; } }
    public string cmdFormat { get { return _cmdFormat; } }

    public DevCommandBase(string i, string d, string f)
    {
        _cmdId = i;
        _cmdDescr = d;
        _cmdFormat = f;
    }
}

public class DevCommand : DevCommandBase
{
    private Action _cmdAction;

    public DevCommand(string i, string d, string f, Action a) : base (i, d, f)
    {
        this._cmdAction = a;
    }

    public void Invoke()
    {
        _cmdAction.Invoke();
    }
}

public class DevCommand<T1> : DevCommandBase
{
    private Action<T1> _cmdAction;

    public DevCommand(string i, string d, string f, Action<T1> a) : base(i, d, f)
    {
        this._cmdAction = a;
    }

    public void Invoke(T1 value1)
    {
        _cmdAction.Invoke(value1);
    }
}

public class DevCommand<T1, T2> : DevCommandBase
{
    private Action<T1, T2> _cmdAction;

    public DevCommand(string i, string d, string f, Action<T1, T2> a) : base(i, d, f)
    {
        this._cmdAction = a;
    }

    public void Invoke(T1 value1, T2 value2)
    {
        _cmdAction.Invoke(value1, value2);
    }
}
