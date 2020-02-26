using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MakeOffsetMap : MonoBehaviour
{
	public Material material;
 	public Texture2D testTex;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	[ContextMenu("test")]
	void test()
	{
		int size = 256;
		testTex=new Texture2D(size,size,TextureFormat.RGBAFloat,false,true);
		 
		var colors = new Color[size*size];
		for (int i = 0; i < size; i++)
		{
			for (int j = 0; j < size; j++)
			{
				colors[j + i * size].r = RayTest.getOffsetZ(new Vector2(j, i) / size, -60)*10;
				colors[j + i * size].g = RayTest.getOffsetZ(new Vector2(j, i) / size, -30)*10;
				colors[j + i * size].b = RayTest.getOffsetZ(new Vector2(j, i) / size, 30)*10;
				colors[j + i * size].a = RayTest.getOffsetZ(new Vector2(j, i) / size, 60)*10;
			}
		}
		testTex.SetPixels(colors);
		testTex.Apply();
		material.SetTexture("_ParallaxMapZ",testTex);
		
	}
}
