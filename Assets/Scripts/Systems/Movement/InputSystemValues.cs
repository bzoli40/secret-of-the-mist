using UnityEngine;
#if ENABLE_INPUT_SYSTEM
using UnityEngine.InputSystem;
#endif

public class InputSystemValues : MonoBehaviour
{
	[Header("Character Input Values")]
	public Vector2 move;
	public Vector2 look;
	public bool jump;
	public bool sprint;
	public bool attack;
	public bool interact;

	[Header("Movement Settings")]
	public bool analogMovement;

#if !UNITY_IOS || !UNITY_ANDROID
	[Header("Mouse Cursor Settings")]
	public bool cursorInputForLook = true;
#endif

	private Player p;

    private void Awake()
    {
		p = GameObject.FindGameObjectWithTag("GameSystem").GetComponent<Player>();
    }

    public void OnMove(InputValue value)
	{
		move = p.playerState == PlayerState.DOANYTHING ? value.Get<Vector2>():new Vector2(0f,0f);
	}

	public void OnLook(InputValue value)
	{
		if (p.playerState != PlayerState.DOANYTHING) return;

		if (cursorInputForLook)
		{
			look = value.Get<Vector2>();
		}
	}

	public void OnJump(InputValue value)
	{
		if (p.playerState != PlayerState.DOANYTHING) return;

		jump = value.isPressed;
	}

	public void OnSprint(InputValue value)
	{
		if (p.playerState != PlayerState.DOANYTHING) return;

		sprint = value.isPressed;
	}

	public void OnAttack(InputValue value)
	{
		if (p.playerState != PlayerState.DOANYTHING) return;

		attack = value.isPressed;
	}

	public void OnInteract(InputValue value)
	{
		if (p.playerState != PlayerState.DOANYTHING) return;

		interact = value.isPressed;
	}

#if !UNITY_IOS || !UNITY_ANDROID

	public void OnApplicationFocus()
	{
		SetCursorState(p.playerState == PlayerState.DOANYTHING);
	}

	public void SetCursorState(bool newState)
	{
		Cursor.lockState = newState ? CursorLockMode.Locked : CursorLockMode.None;
	}

#endif

}