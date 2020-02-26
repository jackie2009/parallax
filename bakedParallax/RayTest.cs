using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayTest : MonoBehaviour {
	private void OnDrawGizmos()
	{
	print(	getOffsetZ(new Vector2(0.2f, 0.2f), -30));
		//
	}

	public static float getOffsetZ(Vector2 start,float rot)
	{
		RaycastHit info;
		 
		
		
		 
		Vector3 dir=new Vector3(0,-Mathf.Cos(rot*Mathf.Deg2Rad),-Mathf.Sin(rot*Mathf.Deg2Rad));
		Vector3 samplerPos = new Vector3(start.x * 10, 0, start.y * 10);
		Vector3 origin=samplerPos-dir*2;
		if (Physics.Raycast(origin, dir, out info, 100))
		{
			//Gizmos.DrawSphere(info.point,0.2f);
			return (info.point.z - samplerPos.z)/10;
		}

		return 0;
	}
}
