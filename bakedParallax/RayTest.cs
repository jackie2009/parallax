using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayTest : MonoBehaviour {
	private void OnDrawGizmos()
	{
	print(	getOffset(new Vector2(0.3f, 0.45f), 60,0));
		//
	}

	public static float getOffset(Vector2 start,float rot,int axisID)//axisID 0 :x ,1:z
    {
		RaycastHit info;

      
		
		 
		Vector3 dir=new Vector3(0,-Mathf.Cos(rot*Mathf.Deg2Rad),-Mathf.Sin(rot*Mathf.Deg2Rad));
        if (axisID == 0)
        {
            dir.x = -dir.z;
            dir.z = 0;
        }
		Vector3 samplerPos = new Vector3(start.x * 10, 0, start.y * 10);
		Vector3 origin=samplerPos-dir*2;
		if (Physics.Raycast(origin, dir, out info, 100))
		{
           //  Gizmos.DrawSphere(info.point,0.2f);
            if (axisID == 0)
            {
                return (info.point.x - samplerPos.x) / 10;
            }
            else
            {
                return (info.point.z - samplerPos.z) / 10;
            }
		}

		return 0;
	}
}
