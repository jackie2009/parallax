using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParallaxDemo : MonoBehaviour {
     public Texture2D image;
    private Color32 []data;
    
   public float parallaxScale = 0.5f;
    [Range(20,160)]
  public  float testRot; 
  [Range(-0.5f,0.5f)]
  public  float offsetPoint;
    // Use this for initialization
    void Start () {
        data = image.GetPixels32();
    }
    bool isBlock(Vector3 pos)
    {

        if (pos.x <= -0.5 || pos.x >= 0.5) return false;
        if (pos.y <= -0.5 || pos.y >= 0.5) return false;

        int startX = (int)((pos.x + 0.5f) * image.width);
        int startY = (int)((pos.y + 0.5f) * image.width);
       
      if (data[(image.width - (startY )) * image.width + startX].r > 128) return true;
       
        return false;
    }
    float getDepth(Vector3 pos) {

        if (pos.x <=- 0.5 || pos.x >= 0.5) return -1;
        if (pos.y <=- 0.5 || pos.y >= 0.5) return -1;

        int startX = (int)((pos.x + 0.5f) * image.width);
        int startY = (int)((pos.y + 0.5f) * image.width);
        for (int i = startY-1; i >=0; i--)
        {
            if (data[ i * image.width + startX].r > 128) return (float)i / image.width*2;
        }

        return 0;
    }

    float parallaxMappingFast(Vector3 curent,Vector3 dir)
    {
        // get depth for this fragment
        float initialHeight = getDepth(curent);
 
        float texCoordOffset =- parallaxScale * dir.x * (1-initialHeight);
          
        return   texCoordOffset;
    }

    float SteepParallaxMapping(Vector3 curent, Vector3 dir,bool POMMode)
    {
        // determine number of layers from angle between V and N
      // const float minLayers = 5;
        // const float maxLayers = 15;
         float numLayers = 5;// Mathf.Lerp(maxLayers, minLayers, Mathf.Abs(Vector3.Dot(new Vector3(0, 1, 0), dir)));

        // height of each layer
        float layerHeight = 1.0f / numLayers;
        // depth of current layer
        float currentLayerHeight = 1.0f;
        // shift of texture coordinates for each iteration
        float dtex =   dir.x/dir.y / numLayers/2;

        // current texture coordinates
        float currentTextureCoords = curent.x;

        // get first depth from heightmap
        float heightFromTexture =0;
       
        // while point is above surface
        for (int k = 0; k < 5; k++)
        {
            if (heightFromTexture > currentLayerHeight) break;
             
                // to the next layer
                currentLayerHeight -= layerHeight;
                // shift texture coordinates along vector V
                currentTextureCoords -= dtex;


                heightFromTexture = getDepth(new Vector3(currentTextureCoords, curent.y, 0));
                // break;
             
        }

        if(POMMode==false)
        return (currentTextureCoords - curent.x)*parallaxScale;
 
         // 计算 h1 和 h2
         float prevTexCoords = currentTextureCoords + dtex;
         float afterHeight  = heightFromTexture - currentLayerHeight;
         float beforeHeight = currentLayerHeight + layerHeight -  getDepth(new Vector3( prevTexCoords,curent.y,0));
         // 利用 h1 h2 得到权重，在两个红点间使用权重进行差值
         float weight = afterHeight / (afterHeight + beforeHeight);
         float finalTexCoords = prevTexCoords * weight + currentTextureCoords * (1.0f - weight);
 
         return finalTexCoords - curent.x;

     

    } 
    float parallaxMappingRaymarch(Vector3 curent, Vector3 dir)
    {
        
 
       
        
        // determine number of layers from angle between V and N
       
        float step=0.3f;
        // height of each layer
        float layerHeight =step;
        // depth of current layer
        float currentLayerHeight = 1.0f;
        // shift of texture coordinates for each iteration
        float dtex =   dir.x/dir.y /2*step;

        // current texture coordinates
        float currentTextureCoords = curent.x;

        // get first depth from heightmap
        float heightFromTexture =0;
       
        for(int k=0;k<5;k++)
        {
            if(heightFromTexture > currentLayerHeight){
 
                currentLayerHeight += layerHeight;
                // shift texture coordinates along vector V
                currentTextureCoords += dtex;

                step/=1.5f;
                layerHeight = 1.0f*step;
                dtex = dir.x/dir.y /2*step;;
             

            }
            // to the next layer
            currentLayerHeight -= layerHeight;
            // shift texture coordinates along vector V
            currentTextureCoords -= dtex;
           
           
            heightFromTexture = getDepth(new Vector3(currentTextureCoords, curent.y, 0) );
        }

     
         
         // 计算 h1 和 h2
         float prevTexCoords = currentTextureCoords + dtex;
         float afterHeight  = heightFromTexture - currentLayerHeight;
         float beforeHeight = currentLayerHeight + layerHeight -  getDepth(new Vector3( prevTexCoords,curent.y,0));
         // 利用 h1 h2 得到权重，在两个红点间使用权重进行差值
         float weight = afterHeight / (afterHeight + beforeHeight);
         float finalTexCoords = prevTexCoords * weight + currentTextureCoords * (1.0f - weight);
 
         return finalTexCoords - curent.x;

     

    }
 
    private void OnDrawGizmos()
    {
        data = image.GetPixels32();
      //  if (data == null) return;
        Vector3 view = new Vector3(Mathf.Cos(testRot * Mathf.Deg2Rad), Mathf.Sin(testRot * Mathf.Deg2Rad), 0);
       
        Vector3 current= new Vector3(offsetPoint,  0,0); 
        Vector3 start = current+ view*1/Mathf.Abs(view.y)/2;
      
         drawOffsetLine(current, parallaxMappingFast(current, view),Color.green);
         drawOffsetLine(current, SteepParallaxMapping(current, view,false),Color.yellow);
      drawOffsetLine(current, SteepParallaxMapping(current, view,true),Color.cyan);
      drawOffsetLine(current, parallaxMappingRaymarch(current, view),Color.magenta);
 
         

        Gizmos.color = Color.white;
         Gizmos.DrawLine(start, current);
        Gizmos.color = Color.blue;
         Gizmos.DrawLine(current, current- view * 1 / Mathf.Abs(view.y) / 2);
         view.y *= -1;
        for (float i = 0; i < 2; i+=0.01f)
        {
            if (isBlock(current -view * i)) {
                view.y *= -1;
                Gizmos.DrawSphere(current -view * i, 0.01f);
                break;
            }
        }
   
    }

    private void drawOffsetLine(Vector3 current, float v, Color color)
    {
        Gizmos.color = color;
        Vector3 fixedPoint = current + new Vector3(v, 0, 0);
        Gizmos.DrawLine(fixedPoint, fixedPoint + new Vector3(0, -0.5f, 0));
        for (int i = 1; i < 4; i++)
        {
            Gizmos.DrawLine(fixedPoint + new Vector3(0.001f, 0, 0)*i, fixedPoint + new Vector3(0, -0.5f, 0) + new Vector3(0.001f, 0, 0)*i);
        }
      
    }
}
