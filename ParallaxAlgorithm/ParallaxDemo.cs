﻿using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParallaxDemo : MonoBehaviour {
     public Texture2D image;
    private Color32 []data;
    
   public float parallaxScale = 0.5f;
    [Range(0,180)]
  public  float testRot; 
  [Range(-0.5f,0.5f)]
  public  float offsetPoint;
    // Use this for initialization
    void Start () {
        data = image.GetPixels32();
    }
    bool isBlock(Vector3 pos)
    {

        int startX =Mathf.Clamp( (int)((pos.x + 0.5f) * image.width),0,image.width-1);
        int startY = Mathf.Clamp((int)((pos.y + 0.5f) * image.width),0,image.width-1);;

       
      if (data[(image.width - (startY )) * image.width + startX].r > 128) return true;
       
        return false;
    }
    float getDepth(Vector3 pos) {

       // if (pos.x <=- 0.5 || pos.x >= 0.5) return -1;
       // if (pos.y <=- 0.5 || pos.y >= 0.5) return -1;

        int startX =Mathf.Clamp( (int)((pos.x + 0.5f) * image.width),0,image.width-1);
        int startY = Mathf.Clamp((int)((pos.y + 0.5f) * image.width),0,image.width-1);;
    
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
         float numLayers = 12;// Mathf.Lerp(maxLayers, minLayers, Mathf.Abs(Vector3.Dot(new Vector3(0, 1, 0), dir)));
         // dir.y = (dir.y + 0.1f) / 1.1f;
          dir = Vector3.Normalize(dir);
        // height of each layer
        float layerHeight = 1.0f / numLayers;
        // depth of current layer
        float currentLayerHeight = 1.0f;
        // shift of texture coordinates for each iteration
        float dtexTotal = dir.x / dir.y / 2;///2 是因为 layerHeight 1相当于0.5米 因为是下半个 quad
                                          
        //做个最大偏移保护 这里是 3 现实使用 这个数值会很小 因为 1代表一个贴图覆盖的距离 
     //   if (Mathf.Abs(dtexTotal) > 3)dtexTotal= dtexTotal / Mathf.Abs(dtexTotal)*3f;
        float dtex =   dtexTotal/ numLayers;  

        // current texture coordinates
        float currentTextureCoords = curent.x;

        // get first depth from heightmap
        float heightFromTexture =0;
       
        // while point is above surface
        for (int k = 0; k < numLayers; k++)
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
        return Mathf.Clamp( (currentTextureCoords - curent.x),-1f,1f);
 
         // 计算 h1 和 h2
         float prevTexCoords = currentTextureCoords + dtex;
         float afterHeight  = heightFromTexture - currentLayerHeight;
         float beforeHeight = currentLayerHeight + layerHeight -  getDepth(new Vector3( prevTexCoords,curent.y,0));
         // 利用 h1 h2 得到权重，在两个红点间使用权重进行差值
         float weight = afterHeight / (afterHeight + beforeHeight);
         float finalTexCoords = prevTexCoords * weight + currentTextureCoords * (1.0f - weight);
 
         return   Mathf.Clamp(finalTexCoords - curent.x,-1,1);

     

    } 
    float parallaxMappingRaymarch(Vector3 curent, Vector3 dir)
    {
        
        float numLayers = 12;
       
        
        // determine number of layers from angle between V and N
        dir = Vector3.Normalize(dir);
        float step=1/(numLayers-3);
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
       
        for(int k=0;k<numLayers;k++)
        {
            if(heightFromTexture > currentLayerHeight){
 
                currentLayerHeight += layerHeight;
                // shift texture coordinates along vector V
                currentTextureCoords += dtex;

                step/=2f;
                layerHeight = 1.0f*step;
                dtex = dir.x/dir.y /2*step;;
                k--;

            }
            // to the next layer
            currentLayerHeight -= layerHeight;
            // shift texture coordinates along vector V
            currentTextureCoords -= dtex;
           
           
            heightFromTexture = getDepth(new Vector3(currentTextureCoords, curent.y, 0) );
        }

 
        
      //  return Mathf.Clamp( (currentTextureCoords - curent.x),-1f,1f);
        
        
         
         // 计算 h1 和 h2
         float prevTexCoords = currentTextureCoords + dtex;
         float afterHeight  = heightFromTexture - currentLayerHeight;
         float beforeHeight = currentLayerHeight + layerHeight -  getDepth(new Vector3( prevTexCoords,curent.y,0));
         // 利用 h1 h2 得到权重，在两个红点间使用权重进行差值
         float weight = afterHeight / (afterHeight + beforeHeight);
         float finalTexCoords = prevTexCoords * weight + currentTextureCoords * (1.0f - weight);
 
         return   Mathf.Clamp(finalTexCoords - curent.x,-1,1);

     

    }
 
    private void OnDrawGizmos()
    {
        data = image.GetPixels32();
      //  if (data == null) return;
        Vector3 view = new Vector3(Mathf.Cos(testRot * Mathf.Deg2Rad), Mathf.Sin(testRot * Mathf.Deg2Rad), 0);
       
        Vector3 current= new Vector3(offsetPoint,  0,0); 
        Vector3 start = current+ view*1/Mathf.Abs(view.y)/2;
      //print(view.y);
       //  drawOffsetLine(current, parallaxMappingFast(current, view),Color.green);
      //   drawOffsetLine(current, SteepParallaxMapping(current, view,false),Color.yellow);
      drawOffsetLine(current, SteepParallaxMapping(current, view,true),Color.cyan);
      drawOffsetLine(current, parallaxMappingRaymarch(current, view),Color.magenta);
 
         

        Gizmos.color = Color.white;
         Gizmos.DrawLine(start, current);
        Gizmos.color = Color.blue;
         Gizmos.DrawLine(current, current- view * 1 / Mathf.Abs(view.y) / 2);
         view.y *= -1;
        for (float i = 0; i < 2; i+=0.001f)
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
