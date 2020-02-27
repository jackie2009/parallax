using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MakeOffsetMap : MonoBehaviour
{
	public Material material;
 	public Texture2D testTexX;
 	public Texture2D testTexZ;
	// Use this for initialization
	void Start () {
        create();

    }
	
	// Update is called once per frame
	void Update () {
		
	}
    [ContextMenu("test")]
    void test() {
      
    }
	[ContextMenu("create")]
	void create()
	{
        testTexX= createTexture(0);
        testTexZ= createTexture(1);

        material.SetTexture("_ParallaxMapX",testTexX);
        material.SetTexture("_ParallaxMapZ",testTexZ);
		
	}
    Texture2D createTexture(int axisID) {
        int size = 256;
        Texture2D tex = new Texture2D(size, size, TextureFormat.RGBAFloat, false, true);

        var colors = new Color[size * size];
        for (int i = 0; i < size; i++)
        {
            for (int j = 0; j < size; j++)
            {
                colors[j + i * size].r = RayTest.getOffset(new Vector2(j, i) / size, -60, axisID) * 10;
                colors[j + i * size].g = RayTest.getOffset(new Vector2(j, i) / size, -30, axisID) * 10;
                colors[j + i * size].b = RayTest.getOffset(new Vector2(j, i) / size, 30, axisID) * 10;
                colors[j + i * size].a = RayTest.getOffset(new Vector2(j, i) / size, 60, axisID) * 10;
            }
        }
        tex.SetPixels(colors);
        tex.Apply();
        return tex;
    }
}
